import 'package:flutter/material.dart';
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

  LatLng? selectedLocation;
  CameraPosition initialPosition = CameraPosition(target: LatLng(28.683649, 77.093554),zoom: 12);



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
      
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: initialPosition,
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
          ),

          SizedBox(height: 15,),

          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppPreference.getTheme() ? Colors.black : AppColor.defaultColor,),
            onPressed: () {
              Navigator.pop(context, selectedLocation);
            },
            child: FontUtils(text: 'Confirm Location' ,style: AppTextStyle(color:Colors.white,fontWeight: FontWeight.bold,fontSize: ResponsiveSizes.value(context, mobile: 18, tablet: 25),fontFamily: AppPreference.getFont()))
          )
        ],
      ),
    );
  }
}