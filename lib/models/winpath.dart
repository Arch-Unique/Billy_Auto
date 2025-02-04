import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'guid.dart';
import 'win32.dart';

class WinPath {
  static Future<String?> getPath(String folderID) {
    final Pointer<Pointer<Utf16>> pathPtrPtr = calloc<Pointer<Utf16>>();
    final Pointer<GUID> knownFolderID = calloc<GUID>()..ref.parse(folderID);

    try {
      final int hr = SHGetKnownFolderPath(
        knownFolderID,
        KF_FLAG_DEFAULT,
        NULL,
        pathPtrPtr,
      );

      if (FAILED(hr)) {
        if (hr == E_INVALIDARG || hr == E_FAIL) {
          throw Error();
        }
        return Future<String?>.value();
      }

      final String path = pathPtrPtr.value.toDartString();
      return Future<String>.value(path);
    } finally {
      calloc.free(pathPtrPtr);
      calloc.free(knownFolderID);
    }
  }
}
