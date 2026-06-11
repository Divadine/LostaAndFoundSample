import 'package:flutter/material.dart';
import 'package:map_initialization/main.dart';
import 'package:map_initialization/sharedpreference/shared_preference.dart';
import 'package:map_initialization/utils/color_utils.dart';
import 'package:map_initialization/utils/font_utils.dart';

import '../utils/tab_mobile_size.dart';

class FontStyles extends StatefulWidget {
  const FontStyles({super.key});

  @override
  State<FontStyles> createState() => _FontStyleState();
}

class _FontStyleState extends State<FontStyles> {

  String? selectedFont ;
  final List<String> fonts = [
    "Inter",
    "Poppins",
    "Roboto Serif",
    "Open Sans",
    "Nunito Sans",
  ];

  @override
  void initState() {
    super.initState();
    loadSavedFont();
  }

  Future<void> loadSavedFont() async {
    selectedFont = AppPreference.getFont() ?? 'Inter';
    setState(() {});
  }

  Future<void>  saveFont() async{
    await AppPreference.setFont(selectedFont  ?? 'Inter');
    fontCtrl.sink.add(selectedFont!);
    Navigator.pop(context, selectedFont);
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppPreference.getTheme() ? Colors.black : AppColor.defaultColor,
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back,color: AppColor.secondaryColor,)),
        centerTitle: true,
        title: FontUtils(text: 'Font Change ',style: AppTextStyle(fontFamily:AppPreference.getFont(),fontWeight: FontWeight.bold,fontSize: ResponsiveSizes.value(context, mobile: 22, tablet: 28) ,color: AppColor.secondaryColor),),
      ),
      
      body: Column(
        children: [
          Container(
            height: 500,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: fonts.map((value) {
                return RadioListTile(
                    value: value,
                  title: FontUtils(text: value),
                    groupValue: selectedFont,
                    activeColor: AppColor.defaultColor,
                    onChanged: (value){
                    setState(() {
                      selectedFont = value;
                    });

                    },


                   );
              },).toList(),
            ),

          ),

          const Spacer(),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: FontUtils(
                  text: 'Cancel',
                  style: AppTextStyle(
                    fontSize: 15,
                    color: AppPreference.getTheme()
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
                // Text(
                //   'Cancel',
                //   style: TextStyle(fontSize: 15, color: Colors.black),
                // ),
              ),
              SizedBox(width: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.defaultColor
                ),
                onPressed: saveFont,
                child: FontUtils(
                  text: 'Apply',
                  style: AppTextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

              ),
            ],
          ),
        ],
      ),
    );
  }
}