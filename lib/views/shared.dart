import 'dart:math';
import 'dart:ui' as ui;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:inventory/tools/colors.dart';
import 'package:inventory/views/checklist/shared2.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

import '../controllers/app_controller.dart';
import '../tools/assets.dart';
import '../tools/enums.dart';
import '../tools/service.dart';
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
      {this.size = 24, this.color = Colors.black, this.onTap, super.key});
  final dynamic asset;
  final Color? color;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ct = asset is String
        ? asset.endsWith("svg")
            ? SvgPicture.asset(asset)
            : Image.asset(
                asset,
                width: size,
              )
        : Icon(
            asset,
            size: size,
            color: color,
          );

    if (onTap != null) {
      return InkWell(
        mouseCursor: SystemMouseCursors.click,
        onTap: onTap,
        child: ct,
      );
    }
    return ct;
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
      borderColor: AppColors.lightTextColor,
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
        Expanded(
          child: AppButton(
            onPressed: onPressedA,
            text: titleA,
          ),
        ),
        Ui.boxWidth(24),
        Expanded(
          child: outline(onPressedB, titleB),
        ),
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
              if (mounted) {
                setState(() {
                  disabled = false;
                  isPressed = false;
                });
              }
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
                vertical: 12,
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
                                    : widget.color == AppColors.primaryColor
                                        ? AppColors.white
                                        : AppColors.lightTextColor,
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
          fontSize: 14, color: Colors.white, alignment: TextAlign.center),
      boxShadows: [
        BoxShadow(offset: Offset(0, -4), blurRadius: 40, color: Colors.white)
      ],
      backgroundColor: Colors.green,
      borderRadius: 16,
      forwardAnimationCurve: Curves.elasticInOut,
      snackPosition: SnackPosition.TOP,
      maxWidth: 700,
      animationDuration: Duration(milliseconds: 1500),
      duration: Duration(seconds: 3),
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
      maxWidth: 700,
      icon: AppIcon(
        Icons.dangerous_outlined,
        color: Colors.white,
      ),
      backgroundColor: Colors.red,
      borderRadius: 16,
      duration: Duration(seconds: 3),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 36,
          ),
          // Expanded(child: title),
          title,
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
      content: SizedBox(
          width: Ui.width(context) < 1500
              ? (Ui.width(context) < 1000
                  ? (Ui.width(context) < 700
                      ? Ui.width(context) / 1.4
                      : Ui.width(context) / 2)
                  : Ui.width(context) / 2.5)
              : Ui.width(context) / 3,
          child: content),
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
                fillColor: readOnly ? Colors.grey[300] : Colors.white,
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
                            padding: EdgeInsets.only(left: 16.0, right: 8),
                            child:
                                AppText.thin("+234", color: Color(0xFF667085)),
                          )
                        : null
                    : SizedBox(
                        width: 48,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 0.0, right: 0),
                            child: AppIcon(
                              prefix,
                              color: AppColors.black,
                            ),
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

  static dropdown(List<String> optionss, List<dynamic> valuess,
      TextEditingController cont, String label,
      {Function(dynamic)? onChanged,
      dynamic initOption,
      double? w,
      bool isEnabled = true,
      useOld = true}) {
    dynamic curOption;

    final options = List.from(optionss);
    final values = List.from(valuess);
    if (options.isEmpty || options[0] != "None") {
      options.insert(0, "None");
      dynamic defaultValue =
          options.isEmpty ? 0 : (initOption.runtimeType == String ? "" : 0);
      values.insert(0, defaultValue);
    }

    if (initOption.runtimeType == String) {
      curOption =
          (initOption == null && initOption.isEmpty) ? values[0] : initOption;
    } else {
      curOption = (initOption == null) ? values[0] : initOption;
    }

    cont.text = curOption.toString();
    if (!useOld) {
      return CustomMultiDropdown(
        optionss,
        valuess,
        cont,
        label,
        initValues: [curOption],
        singleOnly: true,
        onChanged: onChanged,
        isEnable: true,
      );
    }

    return StatefulBuilder(builder: (context, setState) {
      return SizedBox(
        width: w ?? Ui.width(context) - 48,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (label.isNotEmpty) AppText.thin(label),
            if (label.isNotEmpty)
              const SizedBox(
                height: 8,
              ),
            CurvedContainer(
              color: AppColors.white,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              border: Border.all(color: Colors.grey),
              child: DropdownButton<dynamic>(
                  value: curOption,
                  isExpanded: true,
                  elevation: 0,
                  hint: AppText.thin(options[!values.contains(curOption)
                      ? 0
                      : values.indexOf(curOption)]),
                  underline: SizedBox(),
                  // underline: Padding(
                  //   padding: const EdgeInsets.only(top: 16.0),
                  //   child: Divider(
                  //     color: AppColors.white,
                  //   ),
                  // ),
                  padding: EdgeInsets.all(6),
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.primaryColor,
                  ),
                  dropdownColor: AppColors.white,
                  isDense: true,
                  items: values
                      .map((e) => DropdownMenuItem<dynamic>(
                          value: e,
                          child: AppText.thin(options[values.indexOf(e)])))
                      .toList(),
                  onChanged: !isEnabled
                      ? null
                      : (value) {
                          setState(() {
                            curOption = value!;
                            cont.text = curOption.toString();
                          });
                          if (onChanged != null) {
                            onChanged(curOption);
                          }
                        }),
            ),
            if (label.isNotEmpty)
              const SizedBox(
                height: 32,
              )
          ],
        ),
      );
    });
  }
}

class MultiSelectDropdown extends StatefulWidget {
  final List<String> options;
  final List<dynamic> values;
  final TextEditingController controller;
  final String label;
  final Function(List<dynamic>)? onChanged;
  final List<dynamic>? initialSelectedOptions;
  final double? width;

  const MultiSelectDropdown(
    this.options,
    this.values,
    this.controller,
    this.label, {
    super.key,
    this.onChanged,
    this.initialSelectedOptions,
    this.width,
  });

  @override
  MultiSelectDropdownState createState() => MultiSelectDropdownState();
}

class MultiSelectDropdownState extends State<MultiSelectDropdown> {
  List<dynamic> selectedOptions = [];
  List<dynamic> selectedTitleOptions = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialSelectedOptions != null) {
      selectedOptions = List.from(widget.initialSelectedOptions!);
      selectedTitleOptions = List.from(widget.initialSelectedOptions!
          .map((e) => widget.options[widget.values.indexOf(e)]));
    }
    _updateControllerText();
  }

  void _updateControllerText() {
    widget.controller.text = selectedTitleOptions.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return SizedBox(
          width: widget.width ?? MediaQuery.of(context).size.width - 48,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.label.isNotEmpty) AppText.thin(widget.label),
              if (widget.label.isNotEmpty) const SizedBox(height: 8),
              CurvedContainer(
                color: AppColors.primaryColorLight,
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButtonFormField<dynamic>(
                  isExpanded: true,
                  elevation: 0,
                  hint: AppText.thin(selectedTitleOptions.isEmpty
                      ? 'Select options'
                      : selectedTitleOptions.join(', ')),
                  selectedItemBuilder: (context) {
                    return [
                      AppText.thin(selectedTitleOptions.isEmpty
                          ? 'Select options'
                          : selectedTitleOptions.join(', '))
                    ];
                  },
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.primaryColor,
                  ),
                  dropdownColor: AppColors.white,
                  items: widget.values.map((e) {
                    return DropdownMenuItem<dynamic>(
                      value: e,
                      child: Row(
                        children: [
                          Checkbox(
                            value: selectedOptions.contains(e),
                            onChanged: (bool? checked) {
                              setState(() {
                                if (checked == true) {
                                  selectedOptions.add(e);
                                  selectedTitleOptions.add(
                                      widget.options[widget.values.indexOf(e)]);
                                } else {
                                  selectedOptions.remove(e);
                                  selectedTitleOptions.remove(
                                      widget.options[widget.values.indexOf(e)]);
                                }
                                _updateControllerText();
                              });
                              if (widget.onChanged != null) {
                                widget.onChanged!(selectedOptions);
                              }
                            },
                          ),
                          AppText.thin(
                              widget.options[widget.values.indexOf(e)]),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    // No-op because the checkbox handles the selection
                  },
                ),
              ),
              if (widget.label.isNotEmpty) const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}

class CustomMultiDropdown extends StatefulWidget {
  final List<String> options;
  final List<dynamic> values;
  final List<dynamic> initValues;
  final TextEditingController controller;
  final String title;
  final bool isEnable, singleOnly;
  final Function(dynamic)? onChanged;
  const CustomMultiDropdown(
      this.options, this.values, this.controller, this.title,
      {this.initValues = const [],
      this.isEnable = true,
      this.onChanged,
      this.singleOnly = false,
      super.key});

  @override
  State<CustomMultiDropdown> createState() => _CustomMultiDropdownState();
}

class _CustomMultiDropdownState extends State<CustomMultiDropdown> {
  @override
  Widget build(BuildContext context) {
    Widget md;
    if (widget.values.isEmpty || widget.values[0].runtimeType == String) {
      md = getMultiDropDown<String>();
    } else {
      md = getMultiDropDown<int>();
    }

    return StatefulBuilder(
      builder: (context, setState) {
        return SizedBox(
          width: MediaQuery.of(context).size.width - 48,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.title.isNotEmpty) AppText.thin(widget.title),
              if (widget.title.isNotEmpty) const SizedBox(height: 8),
              md,
              if (widget.title.isNotEmpty) const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget getMultiDropDown<T extends Object>() {
    final mdcont = MultiSelectController<T>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (var element in widget.initValues) {
        print(mdcont.selectedItems);
        print(element);

        mdcont.selectWhere((p) {
          return element == p.value;
        });
        print(mdcont.selectedItems);
      }
    });

    final ddec = DropdownItemDecoration(
      backgroundColor: AppColors.primaryColorLight.withOpacity(0.5),
      selectedBackgroundColor: AppColors.primaryColor,
      textColor: AppColors.textColor,
      selectedTextColor: AppColors.white,
    );
    final fdec = FieldDecoration(
        hintText: "${widget.title}",
        suffixIcon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppColors.primaryColor,
        ),
        border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)));
    return MultiDropdown<T>(
      items: widget.values
          .map((e) => DropdownItem<T>(
              label: widget.options[widget.values.indexOf(e)], value: e))
          .toList(),
      searchEnabled: true,
      controller: mdcont,
      enabled: widget.isEnable,
      singleSelect: widget.singleOnly,
      maxSelections: widget.singleOnly ? 1 : 0,
      dropdownItemDecoration: ddec,
      fieldDecoration: fdec,
      onSelectionChange: (selectedItems) {
        if (selectedItems.isEmpty) {
          widget.controller.text = "";
        } else {
          if (widget.singleOnly) {
            widget.controller.text = selectedItems[0].toString();
            widget.onChanged!(selectedItems[0]);
          } else {
            widget.controller.text = selectedItems.join(",");
          }
        }
      },
    );
  }
}

class LogoWidget extends StatelessWidget {
  const LogoWidget(
    this.size, {
    this.isWhite = true,
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
        color: AppColors.primaryColorLight,
      ),
    );
  }
}

class SignatureView extends StatefulWidget {
  const SignatureView(this.tec, this.label, {this.size, super.key});
  final Rx<Uint8List> tec;
  final String label;
  final double? size;

  @override
  State<SignatureView> createState() => _SignatureViewState();
}

class _SignatureViewState extends State<SignatureView> {
  bool isCaptured = false;
  Uint8List? bytes;

  GlobalKey<SfSignaturePadState> signaturePadKey = GlobalKey();

  @override
  void initState() {
    // TODO: implement initState
    if (widget.tec.value.isNotEmpty) {
      isCaptured = true;
      bytes = widget.tec.value;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.only(left: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.thin(widget.label),
          Ui.boxHeight(8),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: AppColors.lightTextColor.withOpacity(0.3),
                          width: 1)),
                  height: 84,
                  clipBehavior: Clip.hardEdge,
                  width: Ui.width(context) - 48,
                  child: bytes != null
                      ? Image.memory(bytes!)
                      : SfSignaturePad(
                          key: signaturePadKey,
                          backgroundColor: AppColors.white,
                        ),
                ),
              ),
              Ui.boxWidth(8),
              Column(
                children: [
                  CurvedContainer(
                      height: 32,
                      width: 32,
                      color: AppColors.primaryColor,
                      onPressed: () async {
                        ui.Image image =
                            await signaturePadKey.currentState!.toImage();
                        var data = await image.toByteData(
                            format: ui.ImageByteFormat.png);
                        final dd = data!.buffer.asUint8List();

                        widget.tec.value = dd;
                        Ui.showInfo("Signature captured");
                        setState(() {
                          bytes = dd;
                          isCaptured = true;
                        });
                      },
                      child: Center(
                          child: AppIcon(
                        Icons.camera_rounded,
                        color: AppColors.white,
                      ))),
                  Ui.boxHeight(20),
                  CurvedContainer(
                      height: 32,
                      width: 32,
                      color: AppColors.white,
                      border: Border.all(color: AppColors.lightTextColor),
                      onPressed: () {
                        if (isCaptured) {
                          widget.tec.value = Uint8List(0);
                          setState(() {
                            isCaptured = false;
                            bytes = null;
                          });
                        } else {
                          signaturePadKey.currentState!.clear();
                        }
                      },
                      child: Center(
                          child: AppIcon(
                        Icons.close,
                        color: AppColors.lightTextColor,
                      )))
                ],
              )
            ],
          ),
          // Ui.boxHeight(24),
          // AppButton.row(
          //   "Capture",
          //   () async {
          //     ui.Image image = await signaturePadKey.currentState!.toImage();
          //     var data = await image.toByteData(format: ui.ImageByteFormat.png);
          //     final dd = data!.buffer.asUint8List();

          //     widget.tec.value = dd;
          //     Ui.showInfo("Signature captured");
          //     setState(() {
          //       bytes = dd;
          //       isCaptured = true;
          //     });
          //   },
          //   "Clear",
          //   () {
          //     if (isCaptured) {
          //       setState(() {
          //         isCaptured = false;
          //         bytes = null;
          //       });
          //     } else {
          //       signaturePadKey.currentState!.clear();
          //     }
          //   },
          // ),
          // Ui.boxHeight(24),
        ],
      ),
    );
    if (widget.size == null) {
      return content;
    }
    return SizedBox(
      width: widget.size!,
      child: content,
    );
  }
}

class ProfileLogo extends StatelessWidget {
  const ProfileLogo({
    this.size = 20,
    super.key,
  });
  final double size;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AppService>();
    return CircleAvatar(
      radius: size,
      backgroundColor: AppColors.white,
      child: CircleAvatar(
        radius: size - 1,
        backgroundColor: AppColors.green,
        child: Center(
          child: AppText.thin(
              controller.currentUser.value.username[0].toUpperCase(),
              color: AppColors.white),
        ),
      ),
    );
  }
}

class PasswordChangeModal extends StatefulWidget {
  const PasswordChangeModal(this.username, {super.key});
  final TextEditingController username;

  @override
  State<PasswordChangeModal> createState() => _PasswordChangeModalState();
}

class _PasswordChangeModalState extends State<PasswordChangeModal> {
  TextEditingController p1 = TextEditingController();
  TextEditingController p2 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AppDialog(
        title: AppText.medium("Change Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              "Username",
              widget.username,
              readOnly: true,
              varl: FPL.text,
            ),
            CustomTextField(
              "New Password",
              p1,
              varl: FPL.password,
            ),
            CustomTextField(
              "Confirm Password",
              p2,
              varl: FPL.password,
            ),
            AppButton(
              onPressed: () async {
                final msgU = Validators.validate(FPL.password, p1.text);
                final msgP = Validators.validate(FPL.password, p2.text);
                final msgV =
                    Validators.confirmPasswordValidator(p1.text, p2.text);
                if (msgU == null && msgP == null && msgV == null) {
                  bool f = await Get.find<AppController>()
                      .resetPassword(widget.username.text, p1.text);

                  if (f) {
                    Get.back();
                    Ui.showInfo(
                        "Password set successfully, Now proceed to login");
                  }
                } else {
                  Ui.showError(msgU ?? msgP ?? msgV ?? "An error occured");
                }
              },
              text: "Change Password",
            ),
          ],
        ));
  }
}

class ConnectivityWidget extends StatelessWidget {
  const ConnectivityWidget({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final appService = Get.find<AppService>();

    return Obx(() {
      final ic = appService.isConnected.value;
      if (!ic) {
        return Stack(
          alignment: Alignment.center,
          children: [
            AbsorbPointer(child: child),
            BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: CurvedContainer(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText.bold("No Network Connection",
                        fontFamily: Assets.appFontFamily2, fontSize: 24),
                    AppText.thin(
                        "Please kindly connect to a network source or try again later",
                        fontFamily: Assets.appFontFamily2),
                    Icon(
                      Icons.wifi_off_rounded,
                      color: AppColors.primaryColor,
                      size: 128,
                    ),
                    SizedBox(
                      width: 200,
                      child: AppButton(
                        onPressed: () async {
                          final f = await Connectivity().checkConnectivity();
                          appService.isConnected.value =
                              !f.contains(ConnectivityResult.none);
                        },
                        text: "Retry",
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        );
      }
      return child;
    });
  }
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AppController>();

    return Obx(() {
      final ic = controller.isLoading.value;
      if (ic) {
        return GestureDetector(
          onTap: controller.stopLoading,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AbsorbPointer(child: child),
              BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                child: CurvedContainer(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppText.bold("Loading...",
                          fontFamily: Assets.appFontFamily2, fontSize: 24),
                      CircularProgressIndicator()
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }
      return child;
    });
  }
}


class SmartJustifyRow extends MultiChildRenderObjectWidget {
  final double spacing;
  final double runSpacing;

  SmartJustifyRow({
    Key? key,
    required List<Widget> children,
    this.spacing = 0,
    this.runSpacing = 0,
  }) : super(key: key, children: children);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderSmartJustifyRow(spacing: spacing, runSpacing: runSpacing);
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderSmartJustifyRow renderObject) {
    renderObject
      ..spacing = spacing
      ..runSpacing = runSpacing;
  }
}

class RenderSmartJustifyRow extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, SmartJustifyParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, SmartJustifyParentData> {
  RenderSmartJustifyRow({
    required double spacing,
    required double runSpacing,
  })  : _spacing = spacing,
        _runSpacing = runSpacing;

  double get spacing => _spacing;
  double _spacing;
  set spacing(double value) {
    if (_spacing != value) {
      _spacing = value;
      markNeedsLayout();
    }
  }

  double get runSpacing => _runSpacing;
  double _runSpacing;
  set runSpacing(double value) {
    if (_runSpacing != value) {
      _runSpacing = value;
      markNeedsLayout();
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! SmartJustifyParentData) {
      child.parentData = SmartJustifyParentData();
    }
  }

  @override
  void performLayout() {
    final BoxConstraints constraints = this.constraints;
    double width = constraints.maxWidth;
    double height = 0;
    double x = 0;
    List<RenderBox> rowChildren = [];
    RenderBox? child = firstChild;

    while (child != null) {
      final SmartJustifyParentData childParentData =
          child.parentData! as SmartJustifyParentData;
      child.layout(BoxConstraints(maxWidth: width), parentUsesSize: true);
      final double childWidth = child.size.width;
      final double childHeight = child.size.height;

      if (x + childWidth > width && rowChildren.isNotEmpty) {
        // Expand children in the current row
        _expandRowChildren(rowChildren, width);
        // Move to next row
        x = 0;
        height +=
            rowChildren.map((c) => c.size.height).reduce(max) + runSpacing;
        rowChildren.clear();
      }

      rowChildren.add(child);
      x += childWidth + spacing;
      height = max(height, childHeight);

      child = childParentData.nextSibling;
    }

    // Handle last row
    if (rowChildren.isNotEmpty) {
      _expandRowChildren(rowChildren, width);
      height += rowChildren.map((c) => c.size.height).reduce(max);
    }

    // Set final positions
    x = 0;
    double y = 0;
    child = firstChild;
    while (child != null) {
      final SmartJustifyParentData childParentData =
          child.parentData! as SmartJustifyParentData;
      if (x + child.size.width > width) {
        x = 0;
        y += child.size.height + runSpacing;
      }
      childParentData.offset = Offset(x, y);
      x += child.size.width + spacing;
      child = childParentData.nextSibling;
    }

    size = Size(width, height);
  }

  void _expandRowChildren(List<RenderBox> children, double availableWidth) {
    double totalWidth =
        children.fold(0.0, (sum, child) => sum + child.size.width);
    double totalSpacing = spacing * (children.length - 1);
    double extraSpace = availableWidth - totalWidth - totalSpacing;
    if (extraSpace <= 0) return;

    double extraPerChild = extraSpace / children.length;
    for (var child in children) {
      final double newWidth = child.size.width + extraPerChild;
      child.layout(BoxConstraints.tightFor(width: newWidth),
          parentUsesSize: true);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}

class SmartJustifyParentData extends ContainerBoxParentData<RenderBox> {}
