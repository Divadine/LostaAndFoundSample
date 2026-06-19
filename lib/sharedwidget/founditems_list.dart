import 'dart:io';

import 'package:flutter/material.dart';
import 'package:map_initialization/models/found_items.dart';
import 'package:map_initialization/sharedpreference/shared_preference.dart';
import 'package:map_initialization/utils/font_utils.dart';
import 'package:map_initialization/utils/tab_mobile_size.dart';

import '../screens/founditems_details.dart';


class FoundItemsLists extends StatelessWidget {

  final FoundItems foundItems;
  const FoundItemsLists({super.key, required this.foundItems,});

  @override
  Widget build(BuildContext context){
    return GestureDetector(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (_) => FoundItemsDetails(foundItems: foundItems,)));
      },
      child: Stack(
        children: [
          Container(
          height: 150,
          width: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20)),
            //image: DecorationImage(image:NetworkImage( lostItems.picture !),fit: BoxFit.cover),
          ),

          child: Column(
            children: [
              // 1st widget
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.only(topRight: Radius.circular(10),topLeft: Radius.circular(10)),
                  child: foundItems.picture != null ? Image.file(File(foundItems.picture!), width: double.infinity,fit: BoxFit.cover, )
                      : Icon(Icons.broken_image,size: 40,color: Colors.grey,),
                ),
              ),


              //2nd widget
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius:BorderRadius.only(bottomLeft: Radius.circular(18),bottomRight: Radius.circular(18),),

                ),
                child: FontUtils(
                  text: foundItems.itemName,
                  maxLines: 1,
                  textOverflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTextStyle(fontWeight: FontWeight.bold,fontFamily: AppPreference.getFont(),fontSize: ResponsiveSizes.value(context, mobile: 15, tablet: 20),color: Colors.white),

                ),

              ),


            ],

          ),
        ),


          Positioned(
            top: 10,
            child: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),border: Border.all(color: Colors.red)),
              child: FontUtils(text: foundItems.status ?? '',style: AppTextStyle(color: AppPreference.getTheme() ? Colors.white : Colors.black),),
            ),
          ),


      ],
      ),
    );
  }
}