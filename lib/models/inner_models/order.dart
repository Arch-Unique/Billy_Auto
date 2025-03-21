import 'dart:convert';

import 'package:get/get.dart';
import 'package:inventory/models/inner_models/barrel.dart';
import 'package:inventory/tools/extensions.dart';
import '../../tools/service.dart';
import 'base_model.dart';

class Order extends BaseModel{
  int customerId;
  int carId, stationId;
  
  int mileageOnReception;
  String? customerConcerns;
  String? observations;
  DateTime? dispatchedAt;
  // List<String> maintenanceType;
  String? fuelLevel, bodyCheck,customerImage,mileageImage;
  int technicianId,serviceAdvisorId;
  List<int> servicesPerformed; //id of services
  
  
  List<int> conditions; //0-false,1-true
  String lostSales;
  double cost;
  String customer, car, station;

  Customer? customerDetails;
  User? serviceAdvisorDetails;
  CustomerCar? customerCar;
  String? technician,serviceAdvisor;
  List<BillyServices> allServices = [];

  bool get isDispatched => dispatchedAt != null;
  String get rdesc => "Customer: $customer\nVehicle: $car\nConcern: $customerConcerns";
  String get desc => rdesc.trim();
  String get title => "ORD-${id.toString().padLeft(4,"0")}";

  Order({
    required this.customerId,
    this.customer = "",
    super.id = 0,
    this.carId = 0,
    this.car = "",
    this.technicianId = 0,
    this.serviceAdvisorId = 0,
    this.mileageOnReception = 0,
    this.customerImage,
    this.mileageImage,
    this.customerConcerns,
    this.observations,
    // this.maintenanceType = const [],
    this.fuelLevel,
    this.dispatchedAt,
    this.bodyCheck,
    this.servicesPerformed = const [],
    super.createdAt,
    super.updatedAt,
    this.conditions = const [],
    this.lostSales = "",
    this.station="",
    this.stationId =0,
    this.cost = 0,
  });

  // Convert Order object to JSON
  @override
Map<String, dynamic> toJson() {
  
    return {
      'customerId': customerId,
      'carId': carId,
      'mileageOnReception': mileageOnReception.toString(),
      'customerConcerns': customerConcerns,
      'observations': observations,
      // 'maintenanceType': jsonEncode(maintenanceType),
      'fuelLevel': fuelLevel,
      'bodyCheck': bodyCheck,
      'servicesPerformed': jsonEncode(servicesPerformed),
      'conditions': jsonEncode(conditions),
      'lostSales': lostSales,
      'dispatchedAt': dispatchedAt?.toSQLDate(),
      'cost': cost,
      'mileageImage': mileageImage,
      'customerImage': customerImage,
      'technicianId': technicianId,
      'serviceAdvisorId': serviceAdvisorId,
      "stationId": Get.find<AppService>().currentStation.value,
    };
  }

      @override
List<dynamic> toTableRows(){
    return [id,customer,car,isDispatched,createdAtRaw];
  }

        @override
List<dynamic> toExcelRows(){
    return [id,customer,car,mileageOnReception,fuelLevel,customerConcerns,observations,lostSales,technician,serviceAdvisor,isDispatched,createdAtRaw];
  }

  @override
  bool validate() {
    return customerId != 0 && serviceAdvisorId != 0 && technicianId != 0 && stationId != 0;
  }

  // Create Order object from JSON
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      customerId: int.tryParse(json['customerId'].toString()) ?? 0,
      customer: json['customer'] ?? "",
      id: json['id'] ?? 0,
      carId: int.tryParse(json['carId'].toString()) ?? 0,
      car: json['car'] ?? "",
      technicianId: int.tryParse(json['technicianId'].toString()) ?? 0,
      serviceAdvisorId: int.tryParse(json['serviceAdvisorId'].toString()) ?? 0,
      mileageOnReception: int.tryParse(json['mileageOnReception'] ?? "0") ?? 0,
      customerConcerns: json['customerConcerns'] ?? "",
      observations: json['observations'] ?? "",
      // maintenanceType: List<String>.from(json['maintenanceType'] ?? []),
      fuelLevel: json['fuelLevel'] ?? "",
      bodyCheck: json['bodyCheck'] ?? "",
      customerImage: json['customerImage'] ?? "",
      mileageImage: json['mileageImage'] ?? "",
      dispatchedAt: DateTime.tryParse(json['dispatchedAt'] ?? ""),
      servicesPerformed: List<int>.from(json['servicesPerformed'] ?? []),
      createdAt: DateTime.tryParse(json['createdAt']),
      updatedAt: DateTime.tryParse(json['updatedAt']),
      conditions: List<int>.from(json['conditions'] ?? []),
      lostSales: json['lostSales'] ?? "",
      cost: double.parse((json['cost'] ?? 0).toString()),
      station: json['station'] ?? "",
      stationId: int.tryParse(json['stationId'].toString()) ?? 0,
    );
  }
}
