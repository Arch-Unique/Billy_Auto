import 'dart:io';

import 'package:dio/dio.dart';

class AppDioInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    late String failure;
    bool isServerError = false;

    print("failure");
    switch (err.type) {
      case DioExceptionType.badResponse:
        {
          
          String message = "An error ocurred, please try again later";
          // if (err.response != null) {
          //   if (err.response?.data != null) {
          if (err.response?.data is Map<String, dynamic>) {
            // Check if it's a map
            if (err.response?.data["error"] == null) {
              err.response?.data["error"] = message;
            }
          } else if (err.response?.data is String){
            err.response?.data = {"error": err.response?.data};
          }else {
            print(err.response?.data);
            err.response?.data = {"error": message};
          }
          //   }
          // }
          failure = message;
          break;
        }
      case DioExceptionType.cancel:
        // Handle cancellation error
        failure = "Request cancelled.";
        break;

      case DioExceptionType.sendTimeout:
        // Handle send timeout error
        failure = "Request timed out while sending data.";
        break;

      case DioExceptionType.receiveTimeout:
        // Handle receive timeout error
        failure = "Request timed out while receiving data.";
        break;

      case DioExceptionType.unknown:
        // Handle unknown error
        failure = "An unknown error occurred.";
        if (err.error is SocketException) {
          failure = "Network Unavailable";
        }

        break;

      case DioExceptionType.connectionTimeout:
        // Handle connection timeout error
        failure = "Connection to the server timed out.";
        break;

      case DioExceptionType.badCertificate:
        // Handle bad certificate error
        failure = "Encountered a bad SSL certificate.";
        break;

      case DioExceptionType.connectionError:
        // Handle connection error
        failure = "Encountered a connection error.";
        break;
    }

    print(failure);
    if (!isServerError) {
      // Ui.showError(failure);
    }
    if (err.response == null) {
      handler.resolve(Response(
          data: {"error": "Network Unavailable"},
          requestOptions: RequestOptions(),
          statusCode: 0,
          statusMessage: "Network Unavailable"));
    } else {
      if (err.response!.statusCode! >= 500) {
        String msg = "Internal Server Error";
        if (err.response!.data is Map<String, dynamic>) {
          msg = err.response!.data["error"] ?? "Internal Server Error";
        }
        handler.resolve(Response(
            data: {"error": msg},
            requestOptions: RequestOptions(),
            statusCode: 500,
            statusMessage: "Internal Server Error"));
      } else {
        handler.resolve(err.response!);
      }
    }
    // super.onError(err, handler);
  }

  static String handleError(dynamic msg) {
    if (msg is List) {
      if (msg.length == 1) {
        return msg[0];
      }
      return msg.join("\n");
    }
    return msg.toString();
  }
}