import 'dart:io';

import 'package:flutter/material.dart';
import 'package:map_initialization/sharedpreference/shared_preference.dart';
import 'package:map_initialization/utils/font_utils.dart';
import 'package:map_initialization/utils/tab_mobile_size.dart';

import '../models/lost_items.dart';
import '../screens/lostItems_details.dart';


class LostItemsLists extends StatelessWidget {

  final LostItems lostItems;
  const LostItemsLists({super.key, required this.lostItems,});

  @override
  Widget build(BuildContext context){
    return GestureDetector(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (_) => LostItemsDetails(lostItems: lostItems,)));
      },
      child: Container(
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
                child: lostItems.picture != null ? Image.file(File(lostItems.picture!), width: double.infinity,fit: BoxFit.cover, )
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
                text: lostItems.itemName,
                maxLines: 1,
                textOverflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTextStyle(fontWeight: FontWeight.bold,fontFamily: AppPreference.getFont(),fontSize: ResponsiveSizes.value(context, mobile: 15, tablet: 20),color: Colors.white),
      
              ),
      
            ),
      
          ],
        ),
      ),
    );
  }
}