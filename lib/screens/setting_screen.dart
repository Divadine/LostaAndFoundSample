import 'package:flutter/material.dart';
import 'package:map_initialization/sharedpreference/shared_preference.dart';
import 'package:map_initialization/utils/color_utils.dart';
import 'package:map_initialization/utils/font_utils.dart';
import 'package:map_initialization/utils/tab_mobile_size.dart';

import '../main.dart';
import 'font_style.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  bool isDarkTheme = false;

  @override
  void initState() {
    super.initState();
    loadTheme();
  }

  void loadTheme() {
    isDarkTheme = AppPreference.getTheme();
    setState(() {});
  }


  @override
  Widget build (BuildContext context){
    return Drawer(

      child: SafeArea(
        child: Column(
          children: [
            //title
            Container(
              color: AppPreference.getTheme() ? Colors.black : AppColor.defaultColor,
              padding:EdgeInsets.only(top: ResponsiveSizes.value(context, mobile: 80, tablet: 100),left: ResponsiveSizes.value(context, mobile: 15, tablet: 15),),
              height: ResponsiveSizes.value(context, mobile: 120, tablet: 150),
              width: double.infinity,
              child: FontUtils(textAlign:TextAlign.left,text: 'Settings',style: AppTextStyle(fontFamily:AppPreference.getFont(),fontWeight: FontWeight.bold,fontSize: 18,color: AppColor.secondaryColor),),

            ),

            //theme
            Expanded(child: ListView(children: [
              ListTile(
                leading: Icon(Icons.format_color_text),
                title: FontUtils(text: 'Font Themes ',style: AppTextStyle(fontSize: ResponsiveSizes.value(context, mobile: 14, tablet: 18),fontWeight: FontWeight.bold),),
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (_) => FontStyles()));
                },

              ),


              ListTile(
                leading: Icon(Icons.dark_mode),
                title: FontUtils(text: 'Dark Mode',style: AppTextStyle(fontSize: ResponsiveSizes.value(context, mobile: 14, tablet: 18),fontWeight: FontWeight.bold),),
                trailing: Switch(

                    value: isDarkTheme,
                    onChanged: (value) async {
                      setState(() {
                        isDarkTheme = value;
                      });

                      await AppPreference.setTheme(value);
                      themeCtrl.sink.add(value);
                      print('dark theme on');

                    }
                    ),
              )
            ],))
          ],
        ),
      ),
    );
  }
}