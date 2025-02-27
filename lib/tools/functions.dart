import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inventory/tools/colors.dart';
import 'package:inventory/views/shared.dart';
import 'package:path_provider/path_provider.dart';

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
    final fg = await Get.dialog<String?>(AppDialog(
        title: AppText.medium("Select Image Source"),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            CurvedContainer(
              color: AppColors.primaryColor,
              padding: EdgeInsets.all(16),
              onPressed: () async {
                final ImagePicker picker = ImagePicker();
                final img = await picker.pickImage(source: ImageSource.camera);
                Get.back<String?>(result: img?.path);
              },
              child: AppIcon(
                Icons.camera_alt_rounded,
                color: AppColors.white,
              ),
            ),
            Ui.boxWidth(24),
            CurvedContainer(
              color: AppColors.primaryColor,
              padding: EdgeInsets.all(16),
              onPressed: () async {
                final ImagePicker picker = ImagePicker();
                final img = await picker.pickImage(source: ImageSource.gallery);
                Get.back<String?>(result: img?.path);
              },
              child: AppIcon(
                Icons.photo,
                color: AppColors.white,
              ),
            )
          ],
        )));
    return fg;
  }

  static Future<File> saveToTempFile(Uint8List uint8list,
      {String? filename}) async {
    try {
      // Get the system's temporary directory
      final tempDir = await getTemporaryDirectory();

      // Generate a unique filename if none provided
      final uniqueFileName =
          filename ?? '${DateTime.now().millisecondsSinceEpoch}.png';

      // Create the file path
      final filePath = '${tempDir.path}/$uniqueFileName';

      // Write the Uint8List to a file
      final file = File(filePath);
      await file.writeAsBytes(uint8list);

      return file;
    } catch (e) {
      throw Exception('Failed to convert Uint8List to File: $e');
    }
  }

  static Future<Uint8List> fileToUint8List(File file) async {
    try {
      // Read the file as bytes
      final Uint8List bytes = await file.readAsBytes();
      return bytes;
    } catch (e) {
      throw Exception('Failed to convert File to Uint8List: $e');
    }
  }
}
