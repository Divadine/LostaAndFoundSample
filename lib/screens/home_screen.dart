import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:map_initialization/database/db.dart';
import 'package:map_initialization/models/found_items.dart';
import 'package:map_initialization/models/match_results.dart';
import 'package:map_initialization/screens/add_lost_items.dart';

import 'package:map_initialization/screens/map_screen.dart';
import 'package:map_initialization/screens/setting_screen.dart';
import 'package:map_initialization/sharedpreference/shared_preference.dart';
import 'package:map_initialization/utils/color_utils.dart';
import 'package:map_initialization/utils/font_utils.dart';
import 'package:map_initialization/utils/tab_mobile_size.dart';
import '../models/lost_items.dart';
import 'package:geocoding/geocoding.dart';

import '../sharedwidget/founditems_list.dart';
import '../sharedwidget/lostitems_lists.dart';
import 'add_found_items.dart';

class MapApp extends StatefulWidget{



  const MapApp({super.key, });

  @override
  State<MapApp> createState() => _MapAppState();
}



class _MapAppState extends State<MapApp> {


  List<LostItems> lostItems = [];
  List<FoundItems> foundItems =[];

  @override
  void initState() {
    super.initState();
    loadLostItems();
    loadFoundItems();
  }

  Future<void> loadLostItems() async{
    final data = await DbHelper.instance.getLostItems();
    setState(() {
      lostItems = data;
    });
  }
  Future<void> loadFoundItems() async {
    final data = await DbHelper.instance.getFoundItems();

    setState(() {
      foundItems = data;
    });
  }



  @override
  Widget build (BuildContext context){
    return Scaffold(
      drawer: SettingsScreen(),
      appBar: AppBar(


        leading:Builder(
            builder: (context){
              return IconButton(onPressed: (){
                Scaffold.of(context).openDrawer();
              }, icon: Icon(Icons.settings,color: Colors.white,));
            }),
        title: FontUtils(text: 'Lost And Found',style: AppTextStyle(fontFamily:AppPreference.getFont(),fontWeight: FontWeight.bold,fontSize: ResponsiveSizes.value(context, mobile: 20, tablet: 25),color: AppColor.secondaryColor),),
        centerTitle: true,
        backgroundColor: AppPreference.getTheme() ? Colors.black : AppColor.defaultColor,
      ),

     body: Padding(
         padding: EdgeInsets.only(right: 15,left: 15,top: 15),
       child: Column(
         mainAxisAlignment: MainAxisAlignment.start,
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [

           //1st name and Icon of Lost items for adding
           Padding(
             padding: const EdgeInsets.all(8.0),
             child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               //mainAxisSize: MainAxisSize.max,
               children: [
                 FontUtils(
                   text: 'Lost Items',
                   style: AppTextStyle(
                       color: AppPreference.getTheme() ? Colors.white : Colors.black,
                       fontWeight: FontWeight.bold,fontFamily: AppPreference.getFont(),
                       fontSize: ResponsiveSizes.value(context, mobile: 18, tablet: 25)
                   ),
                 ),

                 IconButton(
                     onPressed: () async {
                       Navigator.push(context, MaterialPageRoute(builder: (_) => AddLostItems()));
                       await loadLostItems();
                       //await loadFoundItems();
                     },
                     icon:Icon(Icons.add_box_outlined,color: AppPreference.getTheme() ? Colors.white : Colors.black,size: ResponsiveSizes.value(context, mobile: 22, tablet: 30),)),
               ],
             ),
           ),

           //2nd for listing of lost items

           SizedBox(
             height: 160,
             child: ListView.builder(scrollDirection: Axis.horizontal,itemCount: lostItems.length,itemBuilder: (context, index){
               final lostItem = lostItems[index];
               return Padding(
                   padding: EdgeInsets.all(7),
                   child: LostItemsLists(lostItems: lostItem));
             }),
           ),


           // SingleChildScrollView(
           //     scrollDirection: Axis.horizontal,
           //     child:Row(
           //         mainAxisAlignment: MainAxisAlignment.start,

           //       children: List.generate(lostItems.length, (index) => Padding(
           //         padding: EdgeInsets.all(7),
           //         child: LostItemsLists(lostItems: lostItems[index])),
           //       )
           //    )
           // ),


           SizedBox(height: 10,),

           //3rd for Found Items

           Padding(
             padding: const EdgeInsets.all(8.0),
             child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               //mainAxisSize: MainAxisSize.max,
               children: [
                 FontUtils(
                   text: 'Found Items',
                   style: AppTextStyle(
                       color: AppPreference.getTheme() ? Colors.white : Colors.black,
                       fontWeight: FontWeight.bold,fontFamily: AppPreference.getFont(),
                       fontSize: ResponsiveSizes.value(context, mobile: 18, tablet: 25)
                   ),
                 ),

                 IconButton(
                     onPressed: () async {
                       Navigator.push(context, MaterialPageRoute(builder: (_) => AddFoundItems()));

                       await loadLostItems();
                       await loadFoundItems();
                     },
                     icon:Icon(Icons.add_box_outlined,color: AppPreference.getTheme() ? Colors.white : Colors.black,size: ResponsiveSizes.value(context, mobile: 22, tablet: 30),)),
               ],
             ),
           ),


           //4th for List of Found Items

           SingleChildScrollView(
               scrollDirection: Axis.horizontal,
               child:Row(

                   children: List.generate(foundItems.length, (index) => Padding(
                       padding: EdgeInsets.all(7),
                       child: FoundItemsLists(foundItems: foundItems[index]),
                       )
                   ),
               )
           ),



        ],
       ),
     ),


    );
  }
}
