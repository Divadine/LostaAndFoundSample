import 'package:flutter/material.dart';

class FontUtils extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? textOverflow;
  final bool? softwrap;

  const FontUtils({super.key, required this.text, this.textAlign, this.maxLines, this.textOverflow, this.softwrap, this.style});

  @override
  Widget build(BuildContext context){
    return Text(
      text,
      style: style ?? AppTextStyle(),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: textOverflow,
      softWrap: softwrap,


    );
  }
}


TextStyle AppTextStyle (
{

Color? color,
FontWeight? fontWeight,
double? fontSize,
double? height,
  String? fontFamily,
TextDecoration? textDecoration,

}
) {
  return TextStyle(
  color: color,
  fontWeight: fontWeight ?? FontWeight.w400,
  fontSize:  fontSize,
  height: height,
  decoration: textDecoration,
  decorationColor: color,
    fontFamily: fontFamily,

  );
}