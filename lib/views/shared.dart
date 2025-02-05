import 'dart:ui' as ui;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:inventory/tools/colors.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

import '../tools/assets.dart';
import '../tools/enums.dart';
import '../tools/validators.dart';

class CurvedContainer extends StatefulWidget {
  final Widget? child;
  final double radius;
  final double? width, height;
  final String? image;
  final Color color;
  final Border? border;
  final BorderRadius? brad;
  final bool shouldClip;
  final VoidCallback? onPressed;
  final EdgeInsets? margin, padding;
  const CurvedContainer(
      {this.child,
      this.radius = 8,
      this.height,
      this.width,
      this.onPressed,
      this.margin,
      this.brad,
      this.padding,
      this.border,
      this.image,
      this.shouldClip = true,
      this.color = Colors.white,
      super.key});

  @override
  State<CurvedContainer> createState() => _CurvedContainerState();
}

class _CurvedContainerState extends State<CurvedContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _sizeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _sizeAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _handleTap() {
    if (widget.onPressed != null) {
      widget.onPressed!();
    }
    _animationController.reverse();
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onPressed == null
          ? MouseCursor.defer
          : SystemMouseCursors.click,
      onHover: widget.onPressed == null
          ? null
          : (_) {
              _animationController.forward();
            },
      onExit: widget.onPressed == null
          ? null
          : (_) {
              _animationController.reverse();
            },
      child: GestureDetector(
          onTapDown: widget.onPressed == null ? null : _handleTapDown,
          onTapUp: widget.onPressed == null ? null : _handleTapUp,
          onTap: widget.onPressed == null ? null : _handleTap,
          onTapCancel: widget.onPressed == null
              ? null
              : () {
                  _animationController.reverse();
                },
          child: AnimatedBuilder(
            animation: _sizeAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _sizeAnimation.value,
                child: child,
              );
            },
            child: AnimatedContainer(
              width: widget.width,
              height: widget.height,
              margin: widget.margin,
              // onEnd: () {
              //   setState(() {
              //     scaleFactor = _sizeAnimation.value;
              //   });
              // },

              clipBehavior: widget.shouldClip ? Clip.hardEdge : Clip.none,
              padding: widget.padding,
              decoration: BoxDecoration(
                  borderRadius:
                      widget.brad ?? BorderRadius.circular(widget.radius),
                  color: widget.color,
                  border: widget.border,
                  image: widget.image == null
                      ? null
                      : DecorationImage(
                          image: AssetImage(widget.image!), fit: BoxFit.fill)),
              duration: Duration(milliseconds: 300),
              child: widget.child,
            ),
          )),
    );
  }
}

class AppIcon extends StatelessWidget {
  const AppIcon(this.asset,
      {this.size = 24, this.color = Colors.black, super.key});
  final dynamic asset;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return asset is String
        ? asset.endsWith("svg") ? SvgPicture.asset(asset) : Image.asset(
            asset,
            width: size,
          )
        : Icon(
            asset,
            size: size,
            color: color,
          );
  }
}

class BackButtonWidget extends StatelessWidget {
  const BackButtonWidget({this.isMap = false, super.key});
  final bool isMap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.back();
      },
      child: Container(
        // padding:  EdgeInsets.all(8*Ui.dp()),
        clipBehavior: Clip.hardEdge,
        decoration: const BoxDecoration(
          color: Color(0xFFFFF0F3),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: AppIcon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

///This is the general widget for text in this app
///use this rather than the flutter provided text widget
///
/// static methods are provided for fontWeights
/// eg. AppText.semiBoldItalic(
///       "my text",
///       fontSize: 20,
///      )...
///   for -> fontWeight = 600
///          fontSize = 20
///          fontStyle = italic
///
/// if there are font weight that are not provided here
/// feel free to add a  method for it.
/// happy coding :)
///
class AppText extends StatelessWidget {
  final String text;
  final FontWeight? weight;
  final double? fontSize;
  final FontStyle? style;
  final String? fontFamily;
  final Color? color;
  final TextAlign? alignment;
  final TextDecoration? decoration;
  final TextOverflow overflow;
  final int? maxlines;
  final bool shdUseATT;
  final Function? onPressed;

  ///fontSize = 14
  const AppText(
    this.text, {
    super.key,
    this.weight = FontWeight.w500,
    this.fontSize,
    this.style = FontStyle.normal,
    this.color,
    this.onPressed,
    this.fontFamily,
    this.alignment = TextAlign.start,
    this.shdUseATT = false,
    this.overflow = TextOverflow.visible,
    this.maxlines,
    this.decoration,
  });

  ///fontSize: 15
  ///weight: w700
  static AppText bold(String text,
          {Color? color,
          String? fontFamily,
          TextAlign? alignment,
          bool? att,
          double? fontSize = 16,
          Function? onPressed}) =>
      AppText(
        text,
        weight: FontWeight.w500,
        fontFamily: fontFamily,
        shdUseATT: att ?? false,
        color: color,
        onPressed: onPressed,
        alignment: alignment,
        fontSize: fontSize,
      );

  ///fontSize: 15
  ///weight: w700
  static AppText proBold(String text,
          {Color? color,
          String? fontFamily,
          TextAlign? alignment,
          double? fontSize = 16,
          Function? onPressed}) =>
      AppText(
        text,
        weight: FontWeight.w700,
        fontFamily: fontFamily,
        color: color,
        alignment: alignment,
        onPressed: onPressed,
        fontSize: fontSize,
      );

  ///fontSize: 15
  ///weight: w300
  static AppText thin(String text,
          {Color? color,
          String? fontFamily,
          TextAlign? alignment,
          bool? att,
          TextOverflow overflow = TextOverflow.visible,
          TextDecoration? decoration,
          double? fontSize = 14,
          Function? onPressed}) =>
      AppText(
        text,
        weight: FontWeight.w400,
        color: color,
        alignment: alignment,
        decoration: decoration,
        shdUseATT: att ?? false,
        fontFamily: fontFamily,
        fontSize: fontSize,
        onPressed: onPressed,
        overflow: overflow,
      );

  ///weight: w500
  static AppText medium(String text,
          {Color? color,
          String? fontFamily,
          double fontSize = 24,
          TextAlign? alignment,
          TextOverflow overflow = TextOverflow.visible,
          Function? onPressed}) =>
      AppText(
        text,
        fontSize: fontSize,
        weight: FontWeight.w500,
        overflow: overflow,
        alignment: alignment,
        fontFamily: fontFamily,
        onPressed: onPressed,
        color: color,
      );

  ///weight: w300
  ///fontSize: 16
  ///color: #FFFFFF
  static AppText button(
    String text, {
    Color color = Colors.white,
    double fontSize = 16,
    TextAlign? alignment,
    TextDecoration? decoration,
  }) =>
      AppText(
        text,
        fontSize: fontSize,
        weight: FontWeight.w500,
        decoration: decoration,
        alignment: alignment,
        color: color,
      );

  @override
  Widget build(BuildContext context) {
    final ts = TextStyle(
      decoration: decoration,
      fontSize: (fontSize ?? 14),
      color: color ?? Colors.black,
      fontWeight: weight,
      
      overflow: overflow,
      fontStyle: style,
      fontFamily: fontFamily ?? Assets.appFontFamily,
    );

    if (shdUseATT) {
      return AutoSizeText(
        text,
        maxLines: maxlines ?? 2,
        // softWrap: false,
        wrapWords: false,

        style: ts,
        textAlign: alignment,
      );
    }

    final tt = Text(
      text,
      maxLines: maxlines,
      style: ts,
      textAlign: alignment,
    );

    if (onPressed != null) {
      return GestureDetector(
        onTap: () async {
          await onPressed!();
        },
        child: tt,
      );
    }

    return tt;
  }
}

class LoadingIndicator extends StatelessWidget {
  final double size, padding;

  const LoadingIndicator({this.size = 24, this.padding = 0, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          height: size,
          width: size,
          child: const CircularProgressIndicator(
            color: Colors.black,
            backgroundColor: Colors.white,
          ),
        ),
      ),
    );
  }
}

class AppButton extends StatefulWidget {
  final Function? onPressed;
  final Widget? child;
  final String? text, icon;
  final bool? disabled;
  final Color color, borderColor;
  final bool isCircle, isWide, hasBorder;

  const AppButton({
    required this.onPressed,
    this.child,
    this.text,
    this.icon,
    this.disabled,
    this.isWide = true,
    this.isCircle = false,
    this.borderColor = AppColors.primaryColor,
    this.hasBorder = false,
    this.color = AppColors.primaryColor,
    super.key,
  });

  @override
  State<AppButton> createState() => _AppButtonState();

  static social(
    Function? onPressed,
    String icon,
  ) {
    return AppButton(
      onPressed: onPressed,
      icon: icon,
      color: Colors.white,
      isCircle: true,
    );
  }

  static half(
    Function? onPressed,
    String title,
  ) {
    return AppButton(
      onPressed: onPressed,
      text: title,
      isWide: false,
    );
  }

  static white(
    Function? onPressed,
    String title,
  ) {
    return AppButton(
      onPressed: onPressed,
      color: Colors.white,
      text: title,
    );
  }

  static outline(Function? onPressed, String title,
      {Color color = Colors.white, String? icon}) {
    return AppButton(
      onPressed: onPressed,
      hasBorder: true,
      icon: icon,
      borderColor: Colors.black,
      text: title,
      color: color,
    );
  }

  static column(String titleA, Function? onPressedA, String titleB,
      Function? onPressedB) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppButton(
          onPressed: onPressedA,
          text: titleA,
        ),
        Ui.boxHeight(16),
        outline(onPressedB, titleB)
      ],
    );
  }

  static row(String titleA, Function? onPressedA, String titleB,
      Function? onPressedB) {
    return Row(
      children: [
        Expanded(child: outline(onPressedB, titleB)),
        Ui.boxWidth(24),
        Expanded(
          child: AppButton(
            onPressed: onPressedA,
            text: titleA,
          ),
        )
      ],
    );
  }

  static title(String title, VoidCallback? onPressed,
      {Color tColor = Colors.black}) {
    return InkWell(
      onTap: onPressed,
      child: Ui.padding(
          padding: 8, child: AppText.thin(title, fontSize: 16, color: tColor)),
    );
  }
}

class _AppButtonState extends State<AppButton> {
  bool disabled = false;
  bool isPressed = false;

  @override
  void initState() {
    disabled = widget.disabled ?? false;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant AppButton oldWidget) {
    disabled = widget.disabled ?? false;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      fillColor: disabled ? Colors.grey : widget.color,
      elevation: widget.hasBorder ? 0 : 2,
      shape: widget.isCircle
          ? const CircleBorder()
          : RoundedRectangleBorder(
              borderRadius: Ui.circularRadius(8),
              side: widget.hasBorder
                  ? BorderSide(color: widget.borderColor)
                  : BorderSide.none,
            ),
      onPressed: (disabled || widget.onPressed == null)
          ? null
          : () async {
              setState(() {
                disabled = true;
                isPressed = true;
              });
              await widget.onPressed!();
              setState(() {
                disabled = false;
                isPressed = false;
              });
            },
      child: widget.isCircle
          ? Container(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                  height: 28,
                  width: 28,
                  child: disabled
                      ? const LoadingIndicator()
                      : Image.asset(widget.icon!)),
            )
          : Container(
              padding: EdgeInsets.symmetric(
                vertical: 14,
              ),
              width: widget.isWide
                  ? double.maxFinite
                  : (Ui.width(context) / 2) - 36,
              child: Center(
                child: !isPressed
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null)
                            AppIcon(
                              widget.icon,
                              color: null,
                            ),
                          if (widget.icon != null) Ui.boxWidth(16),
                          widget.child ??
                              AppText.button(
                                widget.text!,
                                alignment: TextAlign.center,
                                color: widget.hasBorder
                                    ? widget.borderColor
                                    : widget.color == Colors.white
                                        ? Colors.black
                                        : Colors.white,
                              ),
                        ],
                      )
                    : const LoadingIndicator(),
              )),
    );
  }
}

abstract class Ui {
  static SizedBox boxHeight(double height) => SizedBox(height: height);

  static SizedBox boxWidth(double width) => SizedBox(width: width);

  ///All padding
  static Padding padding({Widget? child, double padding = 16}) => Padding(
        padding: EdgeInsets.all(padding),
        child: child,
      );

  static Align align({Widget? child, Alignment align = Alignment.centerLeft}) =>
      Align(
        alignment: align,
        child: child,
      );

  static BorderRadius circularRadius(double radius) => BorderRadius.all(
        Radius.circular(radius),
      );

  static Spacer spacer() => const Spacer();

  static BorderRadius topRadius(double radius) => BorderRadius.vertical(
        top: Radius.circular(radius),
      );

  static double width(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static bool isSmallScreen(BuildContext context) {
    return width(context) < 1600;
  }

    static bool isMediumScreen(BuildContext context) {
    return width(context) < 1000;
  }

  static double height(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static BorderRadius bottomRadius(double radius) => BorderRadius.vertical(
        bottom: Radius.circular(radius),
      );

  static BorderSide simpleBorderSide({Color color = Colors.grey}) => BorderSide(
        color: color,
        width: 1,
      );

  static showInfo(String message) {
    Get.closeAllSnackbars();
    Get.showSnackbar(GetSnackBar(
      messageText: AppText.thin(message,
          fontSize: 14, color: Colors.black, alignment: TextAlign.center),
      boxShadows: [
        BoxShadow(offset: Offset(0, -4), blurRadius: 40, color: Colors.white)
      ],
      backgroundColor: Colors.white,
      borderRadius: 16,
      forwardAnimationCurve: Curves.elasticInOut,
      snackPosition: SnackPosition.TOP,
      animationDuration: Duration(milliseconds: 1500),
      duration: Duration(seconds: 5),
      padding: EdgeInsets.all(24),
      isDismissible: true,
      margin: EdgeInsets.only(left: 24, right: 24, top: 24),
    ));
  }

  static showError(String message) {
    Get.closeAllSnackbars();
    Get.showSnackbar(GetSnackBar(
      snackPosition: SnackPosition.TOP,
      messageText: AppText.thin(message, fontSize: 14, color: Colors.white),
      boxShadows: [
        BoxShadow(offset: Offset(0, -4), blurRadius: 40, color: Colors.white)
      ],
      shouldIconPulse: true,
      icon: AppIcon(
        Icons.dangerous_outlined,
        color: Colors.white,
      ),
      backgroundColor: Colors.red,
      borderRadius: 16,
      duration: Duration(seconds: 5),
      margin: EdgeInsets.only(left: 24, right: 24, top: 24),
    ));
  }

  static showBottomSheet(String title, String message, Widget backWidget,
      {Function? yesBtn}) {
    Get.bottomSheet(
        Ui.padding(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  AppText.medium(title, fontSize: 24),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: Icon(Icons.close),
                  )
                ],
              ),
              Ui.boxHeight(16),
              AppText.thin(message),
              Ui.boxHeight(24),
              Row(
                children: [
                  Expanded(
                      child: AppButton.outline(() {
                    Get.back();
                  }, "No", color: Colors.white)),
                  Ui.boxWidth(16),
                  Expanded(
                      child: AppButton(
                          onPressed: () async {
                            if (yesBtn != null) await yesBtn();
                            Get.offAll(backWidget);
                          },
                          text: "Yes")),
                ],
              ),
              Ui.boxHeight(24),
            ],
          ),
        ),
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40), topRight: Radius.circular(40))));
  }

  static InputDecoration simpleInputDecoration({
    EdgeInsetsGeometry? contentPadding,
    Color? fillColor,
  }) =>
      InputDecoration(
        border: Ui.outlinedInputBorder(),
        contentPadding: contentPadding,
        fillColor: fillColor,
        errorBorder: Ui.outlinedInputBorder(),
        focusedBorder: Ui.outlinedInputBorder(),
        enabledBorder: Ui.outlinedInputBorder(),
      );

  ///decoration for text fields without a border
  static InputDecoration denseInputDecoration({
    EdgeInsetsGeometry? contentPadding,
    Color fillColor = Colors.grey,
  }) =>
      InputDecoration(
        border: Ui.denseOutlinedInputBorder(),
        contentPadding: contentPadding,
        fillColor: fillColor,
        filled: true,
        errorBorder: Ui.denseOutlinedInputBorder(),
        focusedErrorBorder: Ui.denseOutlinedInputBorder(),
        focusedBorder: Ui.denseOutlinedInputBorder(),
        enabledBorder: Ui.denseOutlinedInputBorder(),
      );

  static InputBorder outlinedInputBorder({
    double circularRadius = 5,
  }) =>
      OutlineInputBorder(
        borderRadius: Ui.circularRadius(circularRadius),
      );

  static InputBorder denseOutlinedInputBorder({
    double circularRadius = 5,
  }) =>
      OutlineInputBorder(
          borderRadius: Ui.circularRadius(circularRadius),
          borderSide: const BorderSide(
            color: Colors.transparent,
            width: 0,
          ));

  static dynamic backgroundImage(String url) => DecorationImage(
      image:
          url.startsWith("http") ? NetworkImage(url) : Image.asset(url).image);
}

class AppDialog extends StatelessWidget {
  const AppDialog({required this.title, required this.content, super.key});
  final Widget title;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          SizedBox(
            width: 36,
          ),
          Expanded(child: title),
          SizedBox(
            width: 36,
            child: InkWell(
                mouseCursor: SystemMouseCursors.click,
                onTap: () {
                  Get.back();
                },
                child: AppIcon(
                  Icons.close,
                  color: Colors.red,
                )),
          )
        ],
      ),
      content: SizedBox(width: Ui.width(context) / 3, child: content),
    );
  }

  static normal(String title, String body,
      {String titleA = "",
      Function? onPressedA,
      String titleB = "",
      Function? onPressedB}) {
    return AppDialog(
      title: Align(
          alignment: Alignment.center,
          child: AppText.medium(title, fontSize: 18)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText.thin(body),
          Ui.boxHeight(24),
          AppButton.column(titleA, onPressedA, titleB, onPressedB),
        ],
      ),
    );
  }

  static normalIcon(dynamic icon, String body,
      {String titleA = "",
      Function? onPressedA,
      String titleB = "",
      Function? onPressedB}) {
    return AppDialog(
      title: AppIcon(icon),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText.thin(body),
          Ui.boxHeight(24),
          AppButton.column(titleA, onPressedA, titleB, onPressedB),
        ],
      ),
    );
  }

  static status({String body = "", String? icon}) {
    return AppDialog(
        title: icon == null ? SizedBox() : AppIcon(icon),
        content: AppText.thin(body));
  }
}

class CustomTextField extends StatelessWidget {
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
  const CustomTextField(this.label, this.controller,
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
        width: w - 48,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isLabel) AppText.thin(label, color: Colors.black),
            if (isLabel)
              const SizedBox(
                height: 4,
              ),
            TextFormField(
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
                fillColor: suffix != null ? Colors.white : Colors.white,
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
                            child: AppIcon(prefix,color: AppColors.black,),
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
            SizedBox(
              height: hasBottomPadding ? 24 : 0,
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
      borderSide: BorderSide(color: color),
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
        width: w ?? Ui.width(context) - 48,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if(label.isNotEmpty)
            AppText.thin(label),
            
            if(label.isNotEmpty)
            const SizedBox(
              height: 8,
            ),
            CurvedContainer(
              color: AppColors.primaryColorLight,
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
                    color: AppColors.primaryColor,
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

class LogoWidget extends StatelessWidget {
  const LogoWidget(
    this.size, {
      this.isWhite=true,
    super.key,
  });
  final double size;
  final bool isWhite;

  @override
  Widget build(BuildContext context) {
    return Hero(
        tag: Assets.logoWhite,
        child: AppIcon(
          isWhite ? Assets.logoWhite : Assets.logoPrimary,
          size: size,
        ));
  }
}


class AppDivider extends StatelessWidget {
  const AppDivider({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Divider(
        color: AppColors.grey,
      ),
    );
  }
}

class SignatureView extends StatefulWidget {
  const SignatureView(this.tec,this.label, {super.key});
  final Rx<Uint8List> tec;
  final String label;

  @override
  State<SignatureView> createState() => _SignatureViewState();
}

class _SignatureViewState extends State<SignatureView> {
  bool isCaptured = false;
  Uint8List? bytes;

  GlobalKey<SfSignaturePadState> signaturePadKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.bold(widget.label),
          
          Ui.boxHeight(8),
          Container(
            decoration: BoxDecoration(
                border: Border.all(color: AppColors.grey, width: 1)),
            height: 84,
            clipBehavior: Clip.hardEdge,
            width: Ui.width(context)-48,
            child: isCaptured && bytes != null
                ? Image.memory(bytes!)
                : SfSignaturePad(
                    key: signaturePadKey,
                    backgroundColor: AppColors.white,
                  ),
          ),
          Ui.boxHeight(24),
          AppButton.row(
            "Capture",
            () async {
              ui.Image image = await signaturePadKey.currentState!.toImage();
              var data = await image.toByteData(format: ui.ImageByteFormat.png);
              final dd = data!.buffer.asUint8List();
      
              widget.tec.value = dd;
              Ui.showInfo("Signature captured");
              setState(() {
                bytes = dd;
                isCaptured = true;
              });
            },
            "Clear",
            () {
              if (isCaptured) {
                setState(() {
                  isCaptured = false;
                  bytes = null;
                });
              } else {
                signaturePadKey.currentState!.clear();
              }
            },
          ),
          Ui.boxHeight(24),
        ],
      ),
    );
  }
}
