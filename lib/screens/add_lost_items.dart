import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../database/db.dart';
import '../models/found_items.dart';
import '../models/lost_items.dart';
import '../models/match_results.dart';
import '../sharedpreference/shared_preference.dart';
import '../utils/color_utils.dart';
import '../utils/font_utils.dart';
import '../utils/tab_mobile_size.dart';
import 'map_screen.dart';

class AddLostItems extends StatefulWidget {
  const AddLostItems({super.key});

  @override
  State<AddLostItems> createState() => _AddLostItemsState();
}

class _AddLostItemsState extends State<AddLostItems> {

  LatLng? selectedLocation;
  DateTime? selectedDate;
  File? selectedImage;
  late final String address;

  final ImagePicker picker = ImagePicker();

  TextEditingController itemNameCtrl = TextEditingController();
  TextEditingController descriptionCtrl = TextEditingController();
  TextEditingController categoryCtrl = TextEditingController();
  TextEditingController locationCtrl = TextEditingController();

  List<LostItems> lostItems = [];

  CameraPosition initialPosition = CameraPosition(target: LatLng(28.683649090758525, 77.09355437945047),zoom: 12,);


  @override
  void initState(){
    super.initState();
    loadLostItems();
  }

  Future<void> loadLostItems() async{
    final data = await DbHelper.instance.getLostItems();

    data.sort((LostItems a,LostItems b) => b.lostDate.compareTo(a.lostDate));

    setState(() {
      lostItems = data;
    });
  }

  Future<void> selectDate() async{

    final  pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDate: DateTime.now(),

    );
    if(pickedDate != null ){
      setState(() {
        selectedDate = pickedDate;
      });
    }

    if(!mounted) return ;

    final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
    );

    if(pickedTime != null) {

      setState(() {
        selectedDate = DateTime(pickedDate!.year ,pickedDate.month,pickedDate.day,pickedTime.hour,pickedTime.minute);
      });
    }
  }

  String getDateLabel(DateTime date) {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final itemDate = DateTime(date.year, date.month, date.day);

    final diff = today.difference(itemDate).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '$diff days ago';


  }

  String formatTime(DateTime date) {
    final hour =
    date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);

    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '$hour:${date.minute.toString().padLeft(2, '0')} $period';
  }

  Future<void> selectLocation()  async {
    final LatLng? location = await Navigator.push(context, MaterialPageRoute(builder: (_) => MapScreen()));

    if(location != null)  {
      setState(() {
        selectedLocation = location;
      });
    }

  }
  Future<String> getAddress(double lat, double lng) async {
    List<Placemark> placemarks =
    await placemarkFromCoordinates(lat, lng);

    Placemark place = placemarks.first;

    return '${place.locality}, ${place.administrativeArea}';
  }

  List<MatchResult> findMatches(LostItems lostItems, List<FoundItems> foundItems) {
    List<MatchResult> matches =[];

    for(var found in foundItems){

      int score = 0;

      print("Checking ${found.itemName}");
      if(found.categoryType.toLowerCase() == lostItems.categoryType.toLowerCase()){
        score +=30;
      }
      print("Category +30");

      if(found.itemName.toLowerCase().contains(lostItems.itemName.toLowerCase()) || lostItems.itemName.toLowerCase().contains(found.itemName.toLowerCase())){
        score +=30;
      }
      print("Name +30");

      int  dayDifference = lostItems.lostDate.difference(found.foundDate).inDays.abs();
      if(dayDifference <= 7){
        score += 20;
      }
      print("Day Difference: $dayDifference");

      double latDiff = (found.location.latitude - lostItems.location.latitude).abs();
      double logDiff = (found.location.longitude - lostItems.location.longitude).abs();

      if(latDiff  < 0.02 && logDiff < 0.02){
        score +=20;
        print("Final Score: $score");
      }
      print("LatDiff: $latDiff");
      print("LngDiff: $logDiff");

      print("Final Score: $score");
      if(score > 50){
        matches.add(MatchResult(foundItem: found, score: score, lostItem: null));
      }
    }
    matches.sort((a,b) => b.score.compareTo(a.score));

    return matches;
  }


  void onSubmit() async {

    if(itemNameCtrl.text.isEmpty || descriptionCtrl.text.isEmpty || categoryCtrl.text.isEmpty || selectedLocation == null ||  selectedDate == null ){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: FontUtils(text: 'Please check all the fields',style: AppTextStyle(fontWeight: FontWeight.bold,fontFamily: AppPreference.getFont(),fontSize: ResponsiveSizes.value(context, mobile: 18 , tablet: 25)),)));
      return;
    }

    String address = await getAddress(
      selectedLocation!.latitude,
      selectedLocation!.longitude,
    );



    final item = LostItems(
      itemName: itemNameCtrl.text,
      description: descriptionCtrl.text,
      categoryType: categoryCtrl.text,
      location:selectedLocation!,
      lostDate: selectedDate ?? DateTime.now(),
      picture: selectedImage?.path,
      address: address,
        status:"Lost",
    );



    await DbHelper.instance.insertLostItems(item);

    final foundItems = await DbHelper.instance.getFoundItems();

    print("Found Items Count: ${foundItems.length}");


    if(!mounted) return;

    final matches = findMatches(item,foundItems);

    print("Matches Count: ${matches.length}");


    if(matches.isNotEmpty) {

      await DbHelper.instance.updateLostStatus(matches.first.foundItem!.id!, "Matched");

      showDialog(
          context: context,
          builder: (_){
            return AlertDialog(
              title: const Text("Possible Matches"),

              content: SizedBox(
                height: 300,
                width: double.infinity,
                child: ListView.builder(
                    itemCount: matches.length,
                    shrinkWrap: true,
                    itemBuilder: (context,index){
                      final match = matches[index];
                      return ListTile(
                        leading: SizedBox(height: 50,width: 50,
                          child: match.foundItem?.picture != null &&  File(match.foundItem!.picture!).existsSync() ? Image.file(File(match.foundItem!.picture!),fit: BoxFit.cover,) : const Icon(Icons.image),
                        ),

                        title: Row(
                          children: [
                            Text(match.foundItem!.itemName),
                            SizedBox(width: 7,),
                            Text(" Score ${match.score}%"),
                          ],
                        ),

                        subtitle: Text(
                          '${getDateLabel(item.lostDate)} • ${formatTime(item.lostDate)}'
                              '${item.lostDate.hour}:${item.lostDate.minute.toString().padLeft(2, '0')}',
                           // " Score ${match.score}%"
                        ),

                        trailing: Text(match.foundItem!.address!) ,
                      );
                    }
                ),
              ) ,
            );
          }
      );
    }



    setState(() {
      lostItems.add(item);

      selectedDate = null;
      selectedLocation = null;
      selectedImage = null;

    });


    itemNameCtrl.clear();
    descriptionCtrl.clear();
    categoryCtrl.clear();


    await loadLostItems();

  }


  Future<void> photoFromCamera() async {
    final XFile?  pic = await picker.pickImage(source: ImageSource.camera);

    if(pic != null) {
      setState(() {
        selectedImage = File(pic.path) ;
      });
    }

  }

  Future<void> photoFromGallery() async {
    final XFile? pic = await picker.pickImage(source: ImageSource.gallery);

    if(pic != null){
      setState(() {
        selectedImage =File(pic.path) ;
      });
    }
  }

  void showImagePicker(){
    showModalBottomSheet(
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      context: context,
      builder: (context) {

        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: FontUtils(text: 'Camera'),
                onTap: () async {
                  Navigator.pop(context);
                  await photoFromCamera();

                },
              ),


              ListTile(
                leading: Icon(Icons.browse_gallery),
                title: FontUtils(text: 'Gallery'),
                onTap: (){
                  photoFromGallery();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: (){
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back,color: Colors.white,)),
        backgroundColor: AppPreference.getTheme() ? Colors.black : AppColor.defaultColor,
        centerTitle: true,
        title: FontUtils(text: 'Add Lost Items',style: AppTextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontFamily: AppPreference.getFont(),fontSize: ResponsiveSizes.value(context, mobile: 20, tablet: 30)),),
      ),

      body:  SingleChildScrollView(
        padding: EdgeInsets.all(ResponsiveSizes.value(context, mobile: 20, tablet: 35)),
        child: Column(
          children: [
        Column(
        children: [
        TextField(
        controller: itemNameCtrl,
          decoration: InputDecoration(border: OutlineInputBorder(),hintText: 'enter your item ',contentPadding: EdgeInsets.all(12)),
        ),
        SizedBox(height: 15,),
        TextField(
          controller: descriptionCtrl,
          decoration: InputDecoration(border: OutlineInputBorder(),hintText: 'Description ',contentPadding: EdgeInsets.all(12)),
        ),
        SizedBox(height: 15,),
        TextField(
          controller: categoryCtrl,
          decoration: InputDecoration(border: OutlineInputBorder(),hintText: 'category ',contentPadding: EdgeInsets.all(12)),
        ),
        SizedBox(height: 15,),



        // TextField(
        //   controller: locationCtrl,
        //   decoration: InputDecoration(border: OutlineInputBorder(),hintText: 'location',contentPadding: EdgeInsets.all(12)),
        // ),

        ListTile(
          title: FontUtils(text: selectedLocation == null ? 'select location' : '${selectedLocation!.latitude.toStringAsFixed(4)},${selectedLocation!.longitude.toStringAsFixed(4)} '),
          trailing: Icon(Icons.location_on),
          onTap: selectLocation,
        ),



        SizedBox(height: 15,),

        ListTile(
          tileColor: Colors.transparent,

          title: FontUtils(
              text: selectedDate == null ? 'Select Lost Date and Time' : '${selectedDate!.day} / ${selectedDate!.month}/${selectedDate!.year} ' '${selectedDate!.hour}:${selectedDate!.minute}',maxLines: 1,textOverflow: TextOverflow.ellipsis,),

          trailing: const Icon(Icons.calendar_month),
          onTap: selectDate,
        ),
        ],
      ),

        SizedBox(height: 20,),

        ListTile(
          onTap:showImagePicker,
          title: FontUtils(text: 'Upload Pic'),
          trailing: FontUtils(text: selectedImage?.path.split('/').last.length != null ?
          ((selectedImage!.path.split('/').last ?? '').length > 10 ? (selectedImage!.path.split('/').last ?? '').substring(0,10) : (selectedImage!.path.split('/').last ?? ''))
              :
          'No Image' ,

            //textOverflow: TextOverflow.ellipsis,maxLines: 1,
          ),

        //   FontUtils(text: selectedImage == null ?  'No Image' :
        //   (selectedImage!.path.split('/').last.length > 10 ? selectedImage!.path.split('/').last.substring(0,10) : selectedImage!.path.split('/').last),
        // ),
        ),

        SizedBox(height: ResponsiveSizes.value(context, mobile: 30, tablet: 55),),

        // submit button

        ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppPreference.getTheme() ? Colors.black : AppColor.defaultColor),
            onPressed: onSubmit,

            child: FontUtils(text: 'Submit',style: AppTextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: ResponsiveSizes.value(context, mobile: 18, tablet: 24)),)
        ),
      ],
      ),
      )
    );
  }
}
