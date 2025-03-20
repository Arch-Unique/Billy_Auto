import 'package:get/get.dart';

import '../../tools/service.dart';
import 'base_model.dart';

class AppConstants extends BaseModel {
  double vat,
      dailyProfitTarget,
      weeklyProfitTarget,
      monthlyProfitTarget,
      yearlyProfitTarget;
  double dailyOrdersTarget,
      weeklyOrdersTarget,
      monthlyOrdersTarget,
      yearlyOrdersTarget;
      String station;
  int version,stationId;

  AppConstants({
    this.vat = 7.5,
    this.dailyProfitTarget = 0,
    this.weeklyProfitTarget = 0,
    this.monthlyProfitTarget = 0,
    this.yearlyProfitTarget = 0,
    this.dailyOrdersTarget = 0,
    this.weeklyOrdersTarget = 0,
    this.monthlyOrdersTarget = 0,
    this.yearlyOrdersTarget = 0,
    this.version = 0,
    this.station="",
    this.stationId=0,
    super.id = 0,
    super.createdAt,
    super.updatedAt,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      "vat": vat,
      "dailyProfitTarget": dailyProfitTarget,
      "weeklyProfitTarget": weeklyProfitTarget,
      "monthlyProfitTarget": monthlyProfitTarget,
      "yearlyProfitTarget": yearlyProfitTarget,
      "dailyOrdersTarget": dailyOrdersTarget,
      "weeklyOrdersTarget": weeklyOrdersTarget,
      "monthlyOrdersTarget": monthlyOrdersTarget,
      "yearlyOrdersTarget": yearlyOrdersTarget,
      "stationId":Get.find<AppService>().currentStation.value,
      // "version": version
    };
  }

  @override
  List toTableRows() {
    return [];
  }

  @override
  List toExcelRows() {
    return [];
  }

  @override
  bool validate() {
    return vat != 0 && stationId != 0;
  }

  factory AppConstants.fromJson(Map<String, dynamic> json) {
    return AppConstants(
      id: json['id'] ?? 0,
      vat: double.parse((json['vat'] ?? 0).toString()),
      dailyProfitTarget:
          double.parse((json['dailyProfitTarget'] ?? 0).toString()),
      weeklyProfitTarget:
          double.parse((json['weeklyProfitTarget'] ?? 0).toString()),
      monthlyProfitTarget:
          double.parse((json['monthlyProfitTarget'] ?? 0).toString()),
      yearlyProfitTarget:
          double.parse((json['yearlyProfitTarget'] ?? 0).toString()),
      dailyOrdersTarget:
          double.parse((json['dailyOrdersTarget'] ?? 0).toString()),
      weeklyOrdersTarget:
          double.parse((json['weeklyOrdersTarget'] ?? 0).toString()),
      monthlyOrdersTarget:
          double.parse((json['monthlyOrdersTarget'] ?? 0).toString()),
      yearlyOrdersTarget:
          double.parse((json['yearlyOrdersTarget'] ?? 0).toString()),
      version: int.parse((json['version'] ?? 0).toString()),
      station: json['station'] ?? "",
      stationId: int.tryParse(json['stationId'].toString()) ?? 0,
      createdAt: DateTime.tryParse(json['createdAt']),
      updatedAt: DateTime.tryParse(json['updatedAt']),
    );
  }
}

class Stations extends BaseModel {
  String name, address, phone, email;

  Stations(
      {super.id,
      this.name="",
      this.address = "",
      this.phone = "",
      this.email = "",
      super.createdAt,
      super.updatedAt});

  @override
  List toExcelRows() {
    return [id, name, address, email, phone, createdAt];
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "address": address,
      "email": email,
      "phone": phone,
    };
  }

  @override
  List toTableRows() {
    return [id, name, address, email, phone, createdAt];
  }

  @override
  bool validate() {
    return name.isNotEmpty;
  }

  factory Stations.fromJson(Map<String, dynamic> json) {
    return Stations(
      id: json['id'] ?? 0,
      name: json["name"] ?? "",
      address: json["address"] ?? "",
      email: json["email"] ?? "",
      phone: json["phone"] ?? "",
      createdAt: DateTime.tryParse(json['createdAt']),
      updatedAt: DateTime.tryParse(json['updatedAt']),
    );
  }
}


class Locations extends BaseModel {
  String name,station;
  int stationId;

  Locations(
      {super.id,
      this.name="Store 1",
      this.station = "",
      this.stationId = 0,
      super.createdAt,
      super.updatedAt});

  @override
  List toExcelRows() {
    return [id, name, station, createdAt];
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "stationId": stationId
    };
  }

  @override
  List toTableRows() {
    return [id, name, station, createdAt];
  }

  @override
  bool validate() {
    return name.isNotEmpty && stationId != 0;
  }

  factory Locations.fromJson(Map<String, dynamic> json) {
    return Locations(
      id: json['id'] ?? 0,
      name: json["name"] ?? "",
      station: json["station"] ?? "",
      stationId: int.tryParse(json["stationId"].toString()) ?? 0,
      createdAt: DateTime.tryParse(json['createdAt']),
      updatedAt: DateTime.tryParse(json['updatedAt']),
    );
  }
}
