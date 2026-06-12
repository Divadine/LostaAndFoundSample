import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_initialization/sharedpreference/shared_preference.dart';
import 'package:map_initialization/utils/color_utils.dart';
import 'package:map_initialization/utils/font_utils.dart';
import 'package:map_initialization/utils/tab_mobile_size.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  
  @override
  State<MapScreen> createState() => MapScreenState();
}


class MapScreenState extends State<MapScreen> {

  GoogleMapController? mapController;
  TextEditingController searchController = TextEditingController();
  LatLng? selectedLocation;
  CameraPosition initialPosition = CameraPosition(target: LatLng(28.683649, 77.093554),zoom: 12);


  Future<void> searchedLocation(String loc) async{

    List<Location> locations = await locationFromAddress(loc);

    if(locations.isNotEmpty){
      final  location = locations.first;
      final searchLocation = LatLng(location.latitude, location.longitude);

      setState(() {
        selectedLocation = searchLocation;
      });

      mapController?.animateCamera(CameraUpdate.newLatLngZoom(searchLocation, 15));
    }


  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back,color: Colors.white,)),

        backgroundColor: AppPreference.getTheme() ? Colors.black : AppColor.defaultColor,
        title: FontUtils(text: 'Mark you Location',style: AppTextStyle(color:Colors.white,fontWeight: FontWeight.bold,fontSize: ResponsiveSizes.value(context, mobile: 18, tablet: 25),fontFamily: AppPreference.getFont()),),
        centerTitle: true,
      ),
      
      body: Stack(

          children: [

            GoogleMap(
              initialCameraPosition: initialPosition,
                onMapCreated: (controller) {
                  mapController = controller;
                },
              onTap: (LatLng location){
                setState(() {
                  selectedLocation =location;
                });
              },
              markers:selectedLocation == null ? {} : {
                Marker(
                  markerId: MarkerId('location'),
                  position: selectedLocation!,

                ),
              }


            ),

            SizedBox(height: 15,),

            Positioned(
              bottom: 20,
                left: 0,right: 0,
              child: Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppPreference.getTheme() ? Colors.black : AppColor.defaultColor,),
                  onPressed: () {
                    Navigator.pop(context, selectedLocation);
                  },
                  child: FontUtils(text: 'Confirm Location' ,style: AppTextStyle(color:Colors.white,fontWeight: FontWeight.bold,fontSize: ResponsiveSizes.value(context, mobile: 18, tablet: 25),fontFamily: AppPreference.getFont()))
                ),
              ),
            ),

            //search box

            Padding(
              padding: const EdgeInsets.all(60),
              child: TextField(
                onChanged: (value){
                  searchedLocation(value);
                },

                controller: searchController,
                style: AppTextStyle(fontFamily: AppPreference.getFont(),fontSize: 20,fontWeight: FontWeight.bold,color: Colors.black),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search,size: 30,color: Colors.black ),
                  border: OutlineInputBorder(),
                  hintText:  'Search here...',
                  hintStyle: AppTextStyle(fontFamily: AppPreference.getFont(),fontSize: 20,fontWeight: FontWeight.bold,color: Colors.black),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black,
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.blue,
                      width: 2,
                    ),
                  ),

                ),


              ),
            ),

          ],
        ),

    );
  }
}