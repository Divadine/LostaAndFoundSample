
import 'package:flutter/material.dart';
import 'package:map_initialization/sharedpreference/shared_preference.dart';
import 'package:map_initialization/utils/font_utils.dart';
import 'package:map_initialization/utils/tab_mobile_size.dart';


class DetailsAlignment extends StatelessWidget {
  final String title;
  final String value;
  const DetailsAlignment({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FontUtils(
            text: title ?? '',
            style: AppTextStyle(color: AppPreference.getTheme() ? Colors.white : Colors.black,fontWeight: FontWeight.bold,fontFamily: AppPreference.getFont(),fontSize: ResponsiveSizes.value(context, mobile: 18, tablet: 25)),
          ),

          const Text(' : ',style: TextStyle(fontWeight: FontWeight.bold),),

          FontUtils(
            text: value ?? '',
            style: AppTextStyle(color: AppPreference.getTheme() ? Colors.white : Colors.black,fontWeight: FontWeight.bold,fontFamily: AppPreference.getFont(),fontSize: ResponsiveSizes.value(context, mobile: 18, tablet: 25)),
          ),
        ],
      ),
    );
  }
}
