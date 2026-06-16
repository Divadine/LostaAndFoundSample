import 'package:flutter/material.dart';
import 'package:map_initialization/models/found_items.dart';

import '../sharedpreference/shared_preference.dart';
import '../utils/color_utils.dart';
import '../utils/font_utils.dart';
import '../utils/tab_mobile_size.dart';


class FoundItemsDetails extends StatefulWidget {
  final FoundItems foundItems;
  const FoundItemsDetails({super.key, required this.foundItems});

  @override
  State<FoundItemsDetails> createState() => _FoundItemsDetailsState();
}

class _FoundItemsDetailsState extends State<FoundItemsDetails> {
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
        title: FontUtils(text:widget.foundItems.itemName,style: AppTextStyle(color:Colors.white,fontFamily: AppPreference.getFont(),fontWeight: FontWeight.bold,fontSize: ResponsiveSizes.value(context, mobile: 18, tablet: 25)),),

      ),
    );
  }
}
