import 'package:flutter/material.dart';

class ResponsiveSizes {

  static bool isTablet(BuildContext context){
    return MediaQuery.of(context).size.width >= 600;
  }

  static double value(BuildContext context,{required double mobile,required double tablet,  })
  {
    return isTablet(context) ? tablet : mobile;
  }

}