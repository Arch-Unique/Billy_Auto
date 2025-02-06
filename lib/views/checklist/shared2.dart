import 'dart:ui' as ui;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:inventory/tools/assets.dart';
import 'package:inventory/tools/colors.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

import '../../tools/enums.dart';
import '../../tools/validators.dart';
import '../shared.dart';


class CustomTextField2 extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final Color col, iconColor;
  final FPL varl;
  final VoidCallback? onTap, customOnChanged;
  final TextInputAction tia;
  final dynamic suffix, prefix;
  final bool autofocus, hasBottomPadding, isDense;
  final double fs;
  final FontWeight fw;
  final bool readOnly, isWide, shdValidate;
  final TextAlign textAlign;
  final String? hint;
  final TextEditingController? oldPass;
  const CustomTextField2(this.label, this.controller,
      {this.fs = 16,
      this.hint,
      this.hasBottomPadding = true,
      this.fw = FontWeight.w300,
      this.varl = FPL.text,
      this.col = Colors.black,
      this.iconColor = Colors.grey,
      this.tia = TextInputAction.next,
      this.isDense = true,
      this.prefix,
      this.oldPass,
      this.onTap,
      this.isWide = true,
      this.autofocus = false,
      this.customOnChanged,
      this.readOnly = false,
      this.shdValidate = true,
      this.textAlign = TextAlign.start,
      this.suffix,
      super.key});

  @override
  Widget build(BuildContext context) {
    Color borderCol = Colors.grey;
    bool hasTouched = true;
    bool isLabel = label != "";
    String? vald;
    final w = isWide ? Ui.width(context) : Ui.width(context) / 2;

    return StatefulBuilder(builder: (context, setState) {
      return SizedBox(
        width: wideUi(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isLabel && varl == FPL.multi) Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: AppText.thin(label, color: AppColors.textColor,fontFamily: Assets.appFontFamily1),
            ),
            Row(
              children: [
                if (isLabel && varl != FPL.multi) SizedBox(
                  width: 100,
                  child: AppText.thin(label, color: AppColors.textColor,fontFamily: Assets.appFontFamily1)),
           
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    readOnly: readOnly,
                    textAlign: textAlign,
                    autofocus: autofocus,
                    onChanged: (s) async {
                      // if (s.isNotEmpty) {
                      //   setState(() {
                      //     hasTouched = true;
                      //   });
                      // } else {
                      //   setState(() {
                      //     hasTouched = false;
                      //   });
                      // }
                      if (customOnChanged != null) customOnChanged!();
                    },
                    
                    obscureText: varl == FPL.password ? hasTouched : false,
                    textAlignVertical:
                        varl == FPL.multi ? TextAlignVertical.top : null,
                    keyboardType: varl.textType,
                    textInputAction: tia,
                    maxLines: varl == FPL.multi ? varl.maxLines : 1,
                    maxLength: varl.maxLength,
                    onTap: onTap,
                  
                    validator: shdValidate
                        ? (value) {
                            // setState(() {
                            vald = oldPass == null
                                ? Validators.validate(varl, value)
                                : Validators.confirmPasswordValidator(
                                    value, oldPass!.text);
                  
                            //   Future.delayed(const Duration(seconds: 1), () {
                            //     vald = null;
                            //   });
                            // });
                            return vald;
                          }
                        : null,
                    style: TextStyle(fontSize: fs, fontWeight: fw, color: col),
                    decoration: InputDecoration(
                      fillColor: AppColors.white,
                      filled: true,
                      enabledBorder: customBorder(color: borderCol),
                      focusedBorder: customBorder(color: borderCol),
                      border: customBorder(color: borderCol),
                      focusedErrorBorder: customBorder(color: Colors.red),
                      counter: SizedBox.shrink(),
                      errorStyle: TextStyle(fontSize: 12, color: Colors.red),
                      errorBorder: customBorder(color: borderCol),
                      suffixIconConstraints: suffix != null
                          ? BoxConstraints(minWidth: 24, minHeight: 24)
                          : null,
                      isDense: isDense,
                      prefixIcon: prefix == null
                          ? varl == FPL.phone
                          ? Padding(
                              padding: EdgeInsets.only(
                                  left: 16.0, right: 8 ),
                              child: AppText.thin("+234", color: Color(0xFF667085)),
                            )
                          : null
                          : SizedBox(
                              width: 48,
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 0.0, right: 0),
                                  child: AppIcon(prefix,color: AppColors.lightTextColor,),
                                ),
                              ),
                            ),
                      suffixIcon: suffix != null || varl == FPL.password
                          ? Padding(
                              padding: EdgeInsets.only(right: 16.0),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    hasTouched = !hasTouched;
                                  });
                                },
                                child: AppIcon(
                                    suffix ??
                                        (hasTouched
                                            ? Icons.remove_red_eye_outlined
                                            : Icons.remove_red_eye),
                                    color: iconColor),
                              ),
                            )
                          : null,
                      hintText: hint,
                      hintStyle: TextStyle(
                          fontSize: fs,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: hasBottomPadding ? 16 : 0,
            )
          ],
        ),
      );
    });
  }

  static bool isUserVal(String s) {
    return !(s.isEmpty || s.contains(RegExp(r'[^\w.]')) || s.length < 8);
  }

  OutlineInputBorder customBorder({Color color = Colors.black}) {
    return OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.lightTextColor.withOpacity(0.3)),
      borderRadius: BorderRadius.circular(8),
      gapPadding: 8,
    );
  }

  static dropdown(
      List<String> options, TextEditingController cont, String label,
      {Function(String)? onChanged, String? initOption,double? w}) {
    String curOption =
        (initOption == null || initOption.isEmpty) ? options[0] : initOption;
    cont.text = curOption;
    return StatefulBuilder(builder: (context, setState) {
      return SizedBox(
        width: wideUi(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Row(
              children: [
                SizedBox(
                  width: 100,
                  child: AppText.thin(label, color: AppColors.textColor,fontFamily: Assets.appFontFamily1)),
                Expanded(
                  child: CurvedContainer(
                    color: AppColors.white,
                    border: Border.all(color:AppColors.lightTextColor.withOpacity(0.3) ),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: DropdownButton<String>(
                        value: curOption,
                        isExpanded: true,
                        
                        
                        elevation: 0,
                        hint: AppText.thin(curOption),
                        underline: SizedBox(),
                        // underline: Padding(
                        //   padding: const EdgeInsets.only(top: 16.0),
                        //   child: Divider(
                        //     color: AppColors.white,
                        //   ),
                        // ),
                    
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.lightTextColor,
                        ),
                        dropdownColor: AppColors.white,
                        items: options
                            .map((e) => DropdownMenuItem<String>(
                                value: e, child: AppText.thin(e)))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            curOption = value!;
                            cont.text = curOption;
                          });
                          if (onChanged != null) {
                            onChanged(curOption);
                          }
                        }),
                  ),
                ),
              ],
            ),
                
            if(label.isNotEmpty)
            const SizedBox(
              height: 32,
            )
          ],
        ),
      );
    });
  }
}

double wideUi(BuildContext context){
  return Ui.width(context) < 650 ?  Ui.width(context) < 450 ? Ui.width(context)-50: Ui.width(context)-100 : Ui.width(context) - 200;
}