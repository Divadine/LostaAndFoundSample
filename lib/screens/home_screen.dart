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
import '../sharedwidget/matcheditems_list.dart';
import 'add_found_items.dart';

class MapApp extends StatefulWidget{


  // final MatchResult bestScore;

  const MapApp({super.key, });

  @override
  State<MapApp> createState() => _MapAppState();
}



class _MapAppState extends State<MapApp> {


  List<LostItems> lostItems = [];
  List<FoundItems> foundItems =[];
  List<MatchResult> matchedResults =[];


  @override
  void initState() {
    super.initState();
    loadData();

  }

  Future<void> loadData() async {
    await loadLostItems();
    await loadFoundItems();

    generateMatches();
  }

  Future<void> loadLostItems() async{
    final data = await DbHelper.instance.getLostItems();

    data.sort((LostItems a, LostItems b) => b.lostDate.compareTo(a.lostDate));
    setState(() {
      lostItems = data;
    });


  }
  Future<void> loadFoundItems() async {
    final data = await DbHelper.instance.getFoundItems();

    print("Found Items Count: ${data.length}");

    data.sort((FoundItems  a,FoundItems  b) => b.foundDate.compareTo(a.foundDate));

    setState(() {
      foundItems = data;
    });
  }

  void generateMatches() async {

    matchedResults.clear();

    for(var lost in lostItems) {
      MatchResult? bestMatch;

      for(var found in foundItems){

        print(
            "${lost.itemName} -> ${found.itemName} : ${calculateMatchingScore(lost, found)}"
        );
        final score = calculateMatchingScore(lost , found);

        if(bestMatch == null || score > bestMatch.score){
          bestMatch =MatchResult ( lostItem: lost, foundItem: found, score: score,);
        }

        if (bestMatch.score > 50) {
          matchedResults.add(bestMatch);
        }
      }


    }

    setState(() {

    });
  }

  int calculateMatchingScore(LostItems lost , FoundItems found) {

    int score = 0;

    if(lost.categoryType.toLowerCase() == found.categoryType.toLowerCase()){
      score += 30;
    }

    if(lost.itemName.toLowerCase().contains(found.itemName.toLowerCase()) || found.itemName.toLowerCase().contains(lost.itemName.toLowerCase())){
      score += 30;
    }

    int dayDifference = lost.lostDate.difference(found.foundDate).inDays.abs();

    if(dayDifference <= 7) {
      score += 20;
    }

    double latDiff = (found.location.latitude - lost.location.latitude).abs();
    double logDiff = (found.location.longitude - lost.location.longitude).abs();

    if(latDiff < 0.02 && logDiff < 0.02){
      score += 20;
    }

    // if(score > 50){
    //   matchedResults.add(MatchResult(lostItem: lost, score: score  ,foundItem: found));
    // }
    matchedResults.sort((a,b) => b.score.compareTo(a.score));

    return score;
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


     body: SingleChildScrollView(
       child: Padding(
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
                         await Navigator.push(context, MaterialPageRoute(builder: (_) => AddLostItems()));
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
                     child: LostItemsLists(lostItems: lostItem) );
               }),
             ),
       
             //
             // SingleChildScrollView(
             //     scrollDirection: Axis.horizontal,
             //     child:Row(
             //         mainAxisAlignment: MainAxisAlignment.start,
             //
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
                         await Navigator.push(context, MaterialPageRoute(builder: (_) => AddFoundItems()));
       
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
       
             //5th Matching Items
       
             Padding(
                 padding: EdgeInsets.all(8),
               child: FontUtils(
                 text: 'Matched Items',
                 style: AppTextStyle(color: AppPreference.getTheme() ? Colors.white : Colors.black, fontFamily: AppPreference.getFont(),fontWeight: FontWeight.bold,fontSize: ResponsiveSizes.value(context, mobile: 18, tablet: 30)),
               ),
             ),
       
             SizedBox(height: 8,),
       
       
             Padding(
                 padding: EdgeInsets.all(8),
               child: SizedBox(
                 height: 160,
                 child: ListView.builder(
                   scrollDirection: Axis.horizontal,
                     itemCount: matchedResults.length,
                     itemBuilder: (context,index){
                     final item = matchedResults[index];
                     return Padding(
                       padding: EdgeInsets.all(7),
                       child: MatchedItemsList(matchResult: item, lostItems: item.lostItem!, foundItems: item.foundItem!,),
                     );
                     }
                 ),
               ),
             ),
       
       
          ],
         ),
       ),
     ),


    );
  }
}
