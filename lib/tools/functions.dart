import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

///file for all #resusable functions
///Guideline: strongly type all variables and functions

abstract class UtilFunctions {
  static const pideg = 180 / pi;
  static const successCodes = [
    200,
    201,
    202,
    203,
    204,
    205,
    206,
    207,
    208,
    226
  ];

  static double deg(double a) => a / pideg;

  static clearTextEditingControllers(List<TextEditingController> conts) {
    for (var i = 0; i < conts.length; i++) {
      conts[i].clear();
    }
  }

  static String formatPhone(String phone) {
    switch (phone[0]) {
      case '0':
        return '+234${phone.substring(1)}';
      case '+':
        return phone;
      default:
        return '+234${phone.substring(1)}';
    }
  }

  static bool nullOrEmpty(String? s) {
    return s == null || s.isEmpty;
  }

  static returnNullEmpty(dynamic k, dynamic v) {
    if (k is String || k is List) {
      if (k == null || k.isEmpty) {
        return v;
      }
      return k;
    }
    return k ?? v;
  }

  static bool isSuccess(int? a) {
    return successCodes.contains(a);
  }

  static Future<String?> showCamera() async {
    final ImagePicker picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery);
    return img?.path;
  }
}
