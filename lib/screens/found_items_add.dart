import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:map_initialization/models/found_items.dart';
import 'package:map_initialization/sharedpreference/shared_preference.dart';
import 'package:map_initialization/utils/color_utils.dart';
import 'package:map_initialization/utils/font_utils.dart';
import 'package:map_initialization/utils/tab_mobile_size.dart';

import '../database/db.dart';
import '../models/lost_items.dart';
import '../models/match_results.dart';
import 'map_screen.dart';

class FoundItemsScreen extends StatefulWidget{
  const FoundItemsScreen({super.key});
  
  @override
  State<FoundItemsScreen> createState() => _FoundItemsScreenState();
}


class _FoundItemsScreenState extends State<FoundItemsScreen> {

  LatLng? selectedLocation;
  DateTime? selectedDate;
  File? selectedImage;

  final ImagePicker picker = ImagePicker();

  TextEditingController itemNameCtrl = TextEditingController();
  TextEditingController descriptionCtrl = TextEditingController();
  TextEditingController categoryCtrl = TextEditingController();
  TextEditingController locationCtrl = TextEditingController();

  List<FoundItems> foundItems = [];



  CameraPosition initialPosition = CameraPosition(target: LatLng(28.683649090758525, 77.09355437945047),zoom: 12,);


  @override
  void initState() {
    super.initState();
    loadFoundMatched();
  }


  Future<void> loadFoundMatched() async{
   final data =  await DbHelper.instance.getFoundItems();

   setState(() {
     foundItems = data;
   });
  }


  Future<String> getAddress(double lat, double log) async {
    List<Placemark> placeMarks = await placemarkFromCoordinates(lat, log);

    Placemark place = placeMarks.first;

    return '${place.street}, ${place.administrativeArea}';
  }

  List<MatchResult> findMatches(FoundItems foundItems,List<LostItems>  lostItems ) {

    List<MatchResult> matches =[];

    for(var lost in lostItems){
      int score = 0;


      if(lost.categoryType.toLowerCase() == foundItems.categoryType.toLowerCase()){
        score +=30;
      }

      if(lost.itemName.toLowerCase().contains(foundItems.itemName.toLowerCase() )  ||   foundItems.itemName.toLowerCase().contains(lost.itemName.toLowerCase())){
        score += 30;
      }

      int dayDifference = foundItems.foundDate.difference(lost.lostDate).inDays.abs();
      if(dayDifference <= 7){
        score += 20;
      }

      double latDiff = (lost.location.latitude - foundItems.location.latitude).abs();
      double logDiff = (lost.location.longitude - foundItems.location.longitude).abs();

      if(latDiff < 0.02 && logDiff < 0.02){
        score += 20;
      }


      if(score >= 50){
        matches.add(MatchResult(lostItem: lost, score: score));
      }

    }
    matches.sort((a,b) => b.score.compareTo(a.score));

    return matches;

  }

  void onSubmit() async {

   String  address = await getAddress(selectedLocation!.latitude, selectedLocation!.longitude);
    if(itemNameCtrl.text.isEmpty || descriptionCtrl.text.isEmpty || categoryCtrl.text.isEmpty || selectedLocation == null ||  selectedDate == null ){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: FontUtils(text: 'Please check all the fields',style: AppTextStyle(fontWeight: FontWeight.bold,fontFamily: AppPreference.getFont(),fontSize: ResponsiveSizes.value(context, mobile: 18 , tablet: 25)),)));
      return;
    }

    final foundItem = FoundItems(
      itemName: itemNameCtrl.text,
      description: descriptionCtrl.text,
      categoryType: categoryCtrl.text,
      location: selectedLocation!,
      foundDate: selectedDate!,
      picture: selectedImage?.path,
        address:address,

    );

    await DbHelper.instance.insertFoundItems(foundItem);

    final lostItems = await DbHelper.instance.getLostItems();
    if (!mounted) return;
    final matches = findMatches(foundItem, lostItems);

    if (matches.isNotEmpty) {
      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text("Possible Matches"),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: matches.length,
                itemBuilder: (context, index) {
                  final match = matches[index];

                  return ListTile(
                    leading: SizedBox(height: 50,width: 50,
                      child: Image.file(File(match.lostItem.picture!),fit: BoxFit.cover,),
                    ),
                    title: Text(match.lostItem.itemName),
                    subtitle: Text(
                      "Score: ${match.score}%",
                    ),
                    trailing: Text(lostItems[index].address!) ,
                  );
                },
              ),
            ),
          );
        },
      );
    }


    setState(() {
      selectedDate = null;
      selectedLocation = null;
      selectedImage = null;

    });


    itemNameCtrl.clear();
    descriptionCtrl.clear();
    categoryCtrl.clear();


    await loadFoundMatched();

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
  }

  Future<void> selectLocation()  async {
    final LatLng? location = await Navigator.push(context, MaterialPageRoute(builder: (_) => MapScreen()));

    if(location != null)  {
      setState(() {
        selectedLocation = location;
      });
    }

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
                onTap: (){
                  photoFromCamera();
                  Navigator.pop(context);
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
        title: FontUtils(text: 'Add Found Items',style: AppTextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontFamily: AppPreference.getFont(),fontSize: ResponsiveSizes.value(context, mobile: 20, tablet: 30)),),
      ),


      body: Padding(
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
                      text: selectedDate == null ? 'Select Found Date' : selectedDate.toString().split(' ')[0]),

                  trailing: const Icon(Icons.calendar_month),
                 onTap: selectDate,
                ),
              ],
            ),

            SizedBox(height: 20,),

            ListTile(
             onTap:showImagePicker,
              title: FontUtils(text: 'Upload Pic'),
              trailing: FontUtils(text: selectedImage == null
                  ? 'No Image' : selectedImage!.path.split('/').last),
            ),


            SizedBox(height: ResponsiveSizes.value(context, mobile: 30, tablet: 55),),

            // submit button

            ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppPreference.getTheme() ? Colors.black : AppColor.defaultColor),
                onPressed: onSubmit,


                child: FontUtils(text: 'Submit',style: AppTextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: ResponsiveSizes.value(context, mobile: 18, tablet: 24)),)
            ),


            Expanded(
              child: ListView.builder(

                 itemCount: foundItems.length,

                  itemBuilder: (context,index){
                    final items = foundItems[foundItems.length - 1 - index];
                    return ListTile(
                      leading: SizedBox(height: 50,width: 50,
                        child: Image.file(File(items.picture!)),
                      ),
                      title: FontUtils(text: items.itemName),
                      subtitle: FontUtils(
                        text:items.address!,
                        // '${items.location.latitude.toStringAsFixed(4)}, '
                        //     '${items.location.longitude.toStringAsFixed(4)}',
                      ),
                      trailing: FontUtils(text: items.categoryType),

                    );
                  },
              ),
            )
          ],
        ),
      ),
    );
  }
}