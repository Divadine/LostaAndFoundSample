import 'package:flutter/material.dart';
import 'package:map_initialization/models/lost_items.dart';
import 'package:map_initialization/sharedpreference/shared_preference.dart';
import 'package:map_initialization/utils/color_utils.dart';
import 'package:map_initialization/utils/font_utils.dart';
import 'package:map_initialization/utils/tab_mobile_size.dart';

class LostItemsDetails extends StatefulWidget {
  final LostItems lostItems;
  const LostItemsDetails({super.key, required this.lostItems});

  @override
  State<LostItemsDetails> createState() => _LostItemsDetailsState();
}

class _LostItemsDetailsState extends State<LostItemsDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
        leading: IconButton(
            onPressed: (){
              Navigator.pop(context);
            }, 
            icon: Icon(Icons.arrow_back,color: Colors.white,size: 18,)),
        backgroundColor: AppPreference.getTheme() ? Colors.black : AppColor.defaultColor,
        centerTitle: true,
        title: FontUtils(text:widget.lostItems.itemName,style: AppTextStyle(color:Colors.white,fontFamily: AppPreference.getFont(),fontWeight: FontWeight.bold,fontSize: ResponsiveSizes.value(context, mobile: 18, tablet: 25)),),

      ),

    );
  }
}
