import 'package:flutter/material.dart';
import 'package:map_initialization/main.dart';
import 'package:map_initialization/sharedpreference/shared_preference.dart';
import 'package:map_initialization/utils/color_utils.dart';
import 'package:map_initialization/utils/font_utils.dart';
import 'package:map_initialization/utils/tab_mobile_size.dart';

class ThemeColor extends StatefulWidget {
  const ThemeColor({super.key});

  @override
  State<ThemeColor> createState() => _ThemeColorState();
}

class _ThemeColorState extends State<ThemeColor> {

  int selectedIndex = -1;
  bool isSelected = false;

  List colorsTheme = [ 0xff6200EE,
    0xff00C6EE,
    0xff007C0F,
    0xffB00D9A,
    0xffEEB700,
    0xffEE0000,
    0xff84BE11,
    0xffFF9D00,
    0xff850016,
  ];



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppPreference.getTheme() ? Colors.black : AppColor.defaultColor,
        title: FontUtils(text: 'Themes',style: AppTextStyle(color:Colors.white,fontWeight: FontWeight.bold,fontFamily: AppPreference.getFont(),fontSize: ResponsiveSizes.value(context, mobile: 18, tablet: 25)),),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
        ),
      ),

      body: Padding(
          padding: EdgeInsets.only(top: 70,left: 30,right: 30,),
              child: Column(
          children: [
            Expanded(
              child: Padding(
                  padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,mainAxisSpacing: 10,crossAxisSpacing: 10,childAspectRatio: 1.4),
                    itemCount: colorsTheme.length,
                    itemBuilder: (context,index){
                      bool isSelected = selectedIndex == index;
                      return GestureDetector(
                        onTap: (){
                          setState(() {
                            selectedIndex =index;
                          });
                          //colorCtrl.sink.add(Color(colorsTheme[selectedIndex]));
                          setState(() {});
                        },

                        child: Container(

                          decoration: BoxDecoration(
                            color: Color(colorsTheme[index]),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: isSelected
                              ? Center(
                            child: Icon(Icons.check, color: Colors.white),
                          )
                              : null,
                        ),


                      );
                    }),

              ),
            ),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 50,vertical: 100),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('cancel',style: AppTextStyle(fontWeight: FontWeight.bold,fontFamily: AppPreference.getFont(),fontSize: ResponsiveSizes.value(context, mobile: 20, tablet: 25)),),
                  ),
                  
                  
                  
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppPreference.getTheme() ? Colors.black : AppColor.defaultColor),
                      onPressed: (){
                        if (selectedIndex != -1){
                          setState(() {
                            // because of this whole app theme color changing not because of stream builder
                            AppColor.defaultColor = Color(colorsTheme[selectedIndex]);
                          });
                        } else {
                          Navigator.pop(context);
                        }
                        
                        //colorCtrl.sink.add(Color(colorsTheme[selectedIndex]));

                        Navigator.pop(context, selectedIndex);
                      },
                      child: FontUtils(text: 'Apply',style: AppTextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontFamily: AppPreference.getFont(),fontSize: ResponsiveSizes.value(context, mobile: 20, tablet: 25)),))



                ],
              ),
            )



        ],
      ),
      ),
    );
  }
}
