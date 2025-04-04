import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:get/instance_manager.dart';
import 'package:get/state_manager.dart';
import 'package:get_storage/get_storage.dart';
import 'package:inventory/tools/functions.dart';
import 'package:inventory/tools/interceptor.dart';
import 'package:inventory/tools/jwt.dart';
import 'package:inventory/tools/urls.dart';

import '../models/inner_models/user.dart';
import 'prefs.dart';

abstract class ApiService {
  Future<Response> get(String url);
  Future<Response> on(String url, String option, {dynamic data});
  Future<Response> post(String url, {dynamic data});
  Future<Response> patch(String url, {dynamic data});
  Future<Response> delete(String url, {dynamic data});
  Future<Response> download(String url,String savePath);
  Future<Response> retryLastRequest();
  void cancelLastRequest();
}

abstract class PrefService {
  Future<void> save(String key, dynamic value);
  Future<void> eraseAllExcept(List<String> key);
  Future<void> saveAll(Map<String, dynamic> maps);
  void listenToKey(String key, ValueSetter callback);
  T? get<T>(String key);
}

class MyPrefService extends GetxService implements PrefService {
  static final _prefs = GetStorage();

  @override
  T? get<T>(String key) {
    return _prefs.read<T>(key);
  }

  @override
  Future<void> save(String key, value) async {
    await _prefs.write(key, value);
  }

  @override
  Future<void> saveAll(Map<String, dynamic> maps) async {
    for (var element in maps.entries) {
      await _prefs.write(element.key, element.value);
    }
  }

  @override
  Future<void> eraseAllExcept(List<String> keys) async {
    final allKeys = List.from(_prefs.getKeys());
    for (var element in allKeys) {
      if (keys.contains(element)) continue;
      await _prefs.remove(element);
    }
  }

  @override
  listenToKey(String key, ValueSetter callback) {
    _prefs.listenKey(key, (j) {
      callback(j);
    });
  }
}

class DioApiService extends GetxService implements ApiService {
  final Dio _dio;
  RequestOptions? _lastRequestOptions;
  CancelToken _cancelToken = CancelToken();
  final prefService = Get.find<MyPrefService>();

  DioApiService()
      : _dio = Dio(
          BaseOptions(baseUrl: AppUrls.baseURL),
        ) {
    _dio.interceptors.add(AppDioInterceptor());
  }

  @override
  Future<Response> delete(String url, {data, bool hasToken = true}) async {
    final response = await _dio.delete(url,
        data: data,
        cancelToken: _cancelToken,
        options: Options(headers: _getHeader(hasToken)));
    _lastRequestOptions = response.requestOptions;

    return response;
  }

  @override
  Future<Response> get(String url, {bool hasToken = true}) async {
    final response = await _dio.get(url,
        cancelToken: _cancelToken,
        options: Options(headers: _getHeader(hasToken)));
    _lastRequestOptions = response.requestOptions;

    return response;
  }

    @override
  Future<Response> download(String url,String savePath, {bool hasToken = true}) async {
    final response = await _dio.download(url,savePath,
        cancelToken: _cancelToken,
        options: Options(headers: _getHeader(hasToken)));
    _lastRequestOptions = response.requestOptions;

    return response;
  }

  @override
  Future<Response> on(String url, String method,
      {data, bool hasToken = true}) async {
    final response = await _dio.request(url,
        cancelToken: _cancelToken,
        data: data,
        options: Options(
          headers: _getHeader(hasToken),
          method: method,
        ));
    _lastRequestOptions = response.requestOptions;

    return response;
  }

  @override
  Future<Response> patch(String url, {data, bool hasToken = true}) async {
    final response = await _dio.patch(url,
        data: data,
        cancelToken: _cancelToken,
        options: Options(headers: _getHeader(hasToken)));
    _lastRequestOptions = response.requestOptions;

    return response;
  }

  @override
  Future<Response> post(String url, {data, bool hasToken = true}) async {
    final response = await _dio.post(url,
        data: data,
        cancelToken: _cancelToken,
        options: Options(headers: _getHeader(hasToken)));
    _lastRequestOptions = response.requestOptions;

    return response;
  }

  @override
  Future<Response> retryLastRequest() async {
    if (_lastRequestOptions != null) {
      final response = await _dio.request(
        _lastRequestOptions!.path,
        data: _lastRequestOptions!.data,
        options: Options(
          method: _lastRequestOptions!.method,
          headers: _lastRequestOptions!.headers,
          // Add any other options if needed
        ),
        cancelToken: _cancelToken,
      );

      return response;
    }
    return Response(
        requestOptions: RequestOptions(),
        statusCode: 404,
        statusMessage: "No Last Request");
  }

  @override
  void cancelLastRequest() {
    _cancelToken.cancel('Request cancelled');
    _cancelToken = CancelToken();
  }

  isSuccess(int? statusCode) {
    return UtilFunctions.isSuccess(statusCode);
  }

  Map<String, dynamic>? _getHeader([bool hasToken = true]) {
    return hasToken
        ? {
            "Authorization":
                "Bearer ${prefService.get(MyPrefs.mpUserJWT) ?? ""}"
          }
        : {};
  }
}

class AppService extends GetxService {
  Rx<User> currentUser = User().obs;
  RxInt currentStation = 0.obs;
  RxBool hasOpenedOnboarding = false.obs;
  RxBool isLoggedIn = false.obs;
  RxBool isConnected = true.obs;

  final apiService = Get.find<DioApiService>();
  final prefService = Get.find<MyPrefService>();
  late StreamSubscription<List<ConnectivityResult>> subscription;

  initUserConfig() async {
    try {
      subscription = Connectivity()
          .onConnectivityChanged
          .listen((List<ConnectivityResult> result) {
        isConnected.value = !result.contains(ConnectivityResult.none);
      });
      _initStation();
      await _hasOpened();
      await _setLoginStatus();
      if (isLoggedIn.value) {
        await _setCurrentUser();
      }
    } catch (e) {
      print(e);
      isLoggedIn.value = false;
    }
  }

  loginUser(String jwt) async {
    await _saveJWT(jwt);
    await _setCurrentUser();
  }

  saveOnlyJWT(String jwt) async {
    await _saveJWT(jwt);
  }

  logout() async {
    await apiService.post("${AppUrls.logout}/${prefService.get(MyPrefs.mpUserID)}/${GetPlatform.isMobile ? "mobile":"pc"}");
    await _logout();
  }

  _hasOpened() async {
    bool a = prefService.get(MyPrefs.hasOpenedOnboarding) ?? false;
    if (a == false) {
      await prefService.save(MyPrefs.hasOpenedOnboarding, true);
    }
    hasOpenedOnboarding.value = a;
  }

  _initStation() {
    currentStation.value = prefService.get(MyPrefs.mpStation) ?? 1;
  }

  saveStation(int id)  async {
    await prefService.save(MyPrefs.mpStation, id);
    currentStation.value = id;
  }

  _logout() async {
    await prefService.eraseAllExcept([MyPrefs.hasOpenedOnboarding]);
  }

  _saveJWT(String jwt) async {
    final msg = Jwt.parseJwt(jwt);
    await prefService.saveAll({
      MyPrefs.mpLoginExpiry: msg["exp"],
      MyPrefs.mpUserID: msg["id"],
      MyPrefs.mpUserJWT: jwt,
      MyPrefs.mpIsLoggedIn: true,
    });
  }

  _setCurrentUser() async {
    final res = await apiService.post(
        "${AppUrls.getUser}/get/${prefService.get(MyPrefs.mpUserID)}",
        data: {"filter": {}});
    // print(res.data);
    currentUser.value = User.fromJson(res.data["data"]);
    await saveStation(currentUser.value.stationId);
  }

  refreshUser() async {
    final res = await apiService.post(
        "${AppUrls.getUser}/get/${prefService.get(MyPrefs.mpUserID)}",
        data: {"filter": {}});
    currentUser.value = User.fromJson(res.data["data"]);
    currentUser.refresh();
  }

  _setLoginStatus() async {
    final e = prefService.get(MyPrefs.mpLoginExpiry) ?? 0;
    isLoggedIn.value = prefService.get(MyPrefs.mpIsLoggedIn) ?? false;
    if (e != 0 && DateTime.now().millisecondsSinceEpoch > e * 1000) {
      // await _refreshToken();
      isLoggedIn.value = false;
    }
  }
}
