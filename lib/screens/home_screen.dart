import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:map_initialization/database/db.dart';
import 'package:map_initialization/screens/found_items_add.dart';
import 'package:map_initialization/screens/map_screen.dart';
import 'package:map_initialization/screens/setting_screen.dart';
import 'package:map_initialization/sharedpreference/shared_preference.dart';
import 'package:map_initialization/utils/color_utils.dart';
import 'package:map_initialization/utils/font_utils.dart';
import 'package:map_initialization/utils/tab_mobile_size.dart';
import '../models/lost_items.dart';
import 'package:geocoding/geocoding.dart';

class MapApp extends StatefulWidget{

  const MapApp({super.key});
  @override
  State<MapApp> createState() => _MapAppState();
}



class _MapAppState extends State<MapApp> {

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
  void initState() {
    super.initState();
    loadLostItems();
  }

  Future<void> loadLostItems() async{
    final data = await DbHelper.instance.getLostItems();
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

  void onSubmit() async {

    String address = await getAddress(
      selectedLocation!.latitude,
      selectedLocation!.longitude,
    );

    if(itemNameCtrl.text.isEmpty || descriptionCtrl.text.isEmpty || categoryCtrl.text.isEmpty || selectedLocation == null ||  selectedDate == null ){
     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: FontUtils(text: 'Please check all the fields',style: AppTextStyle(fontWeight: FontWeight.bold,fontFamily: AppPreference.getFont(),fontSize: ResponsiveSizes.value(context, mobile: 18 , tablet: 25)),)));
     return;
    }

    final item = LostItems(
        itemName: itemNameCtrl.text,
        description: descriptionCtrl.text,
        categoryType: categoryCtrl.text,
        location:selectedLocation!,
        lostDate: selectedDate ?? DateTime.now(),
        picture: selectedImage?.path,
      address: address,
    );



    await DbHelper.instance.insertLostItems(item);

    setState(() {
      lostItems.add(item);

      selectedDate = null;
      selectedLocation = null;
      selectedImage = null;

    });


    itemNameCtrl.clear();
    descriptionCtrl.clear();
    categoryCtrl.clear();


    loadLostItems();

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
  Widget build (BuildContext context){
    return Scaffold(
      drawer: SettingsScreen(),
      appBar: AppBar(

        backgroundColor: AppPreference.getTheme() ? Colors.black : AppColor.defaultColor,
        leading:Builder(
            builder: (context){
              return IconButton(onPressed: (){
                Scaffold.of(context).openDrawer();
              }, icon: Icon(Icons.settings,color: Colors.white,));
            }),
        title: FontUtils(text: 'Map Locator',style: AppTextStyle(fontFamily:AppPreference.getFont(),fontWeight: FontWeight.bold,fontSize: ResponsiveSizes.value(context, mobile: 20, tablet: 25),color: AppColor.secondaryColor),),
        centerTitle: true,
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
                      text: selectedDate == null ? 'Select Lost Date' : selectedDate.toString().split(' ')[0]),

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
                itemCount: lostItems.length,

                  itemBuilder: (context,index){
                    final items = lostItems[lostItems.length - 1 - index];
                    return ListTile(
                      leading: SizedBox(height: 50,width: 50,
                        child: Image.file(File(items.picture!)),
                      ),
                      title: FontUtils(text: items.itemName),
                      subtitle: FontUtils(
                        text:items.address!,

                        // '${items.location.latitude.toStringAsFixed(4)},'
                        //     '${items.location.longitude.toStringAsFixed(4)}',
                      ),
                      trailing: FontUtils(text: items.categoryType),
                    );
                  }),
            )
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppPreference.getTheme() ? Colors.black : AppColor.defaultColor,
          onPressed: (){
           Navigator.push(context, MaterialPageRoute(builder: (_) => FoundItemsScreen()));
          },
          child: Icon(Icons.add,color: Colors.white,size: 35,),
      ),
    );
  }
}
