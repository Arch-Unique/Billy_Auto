import 'dart:convert';

import 'package:inventory/models/inner_models/barrel.dart';

import 'base_model.dart';

class Order extends BaseModel{
  int customerId;
  int carId;
  
  int mileageOnReception;
  String? customerConcerns;
  String? observations;
  DateTime? dispatchedAt;
  List<String> maintenanceType;
  String? fuelLevel, bodyCheck;
  int technicianId,serviceAdvisorId;
  List<int> servicesPerformed; //id of services
  
  
  List<int> conditions; //0-false,1-true
  String lostSales;
  double cost;
  String customer, car;

  Customer? customerDetails;
  CustomerCar? customerCar;
  String? technician,serviceAdvisor;
  List<BillyServices> allServices = [];

  bool get isDispatched => dispatchedAt != null;
  String get rdesc => "Vehicle:  $car\nConcern:  $customerConcerns";
  String get desc => "${rdesc.substring(0,rdesc.length > 64 ? 64 : rdesc.length)}...";
  String get title => "$customer-Order-$id";

  Order({
    required this.customerId,
    this.customer = "",
    super.id = 0,
    this.carId = 0,
    this.car = "",
    this.technicianId = 0,
    this.serviceAdvisorId = 0,
    this.mileageOnReception = 0,
    this.customerConcerns,
    this.observations,
    this.maintenanceType = const [],
    this.fuelLevel,
    this.dispatchedAt,
    this.bodyCheck,
    this.servicesPerformed = const [],
    super.createdAt,
    super.updatedAt,
    this.conditions = const [],
    this.lostSales = "",
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
      'maintenanceType': jsonEncode(maintenanceType),
      'fuelLevel': fuelLevel,
      'bodyCheck': bodyCheck,
      'servicesPerformed': jsonEncode(servicesPerformed),
      'conditions': jsonEncode(conditions),
      'lostSales': lostSales,
      'dispatchedAt': dispatchedAt?.toString(),
      'cost': cost,
      'technicianId': technicianId,
      'serviceAdvisorId': serviceAdvisorId,
    };
  }

      @override
List<dynamic> toTableRows(){
    return [id,customer,car,mileageOnReception,fuelLevel,createdAt];
  }

  @override
  bool validate() {
    return customerId != 0 && serviceAdvisorId != 0 && technicianId != 0;
  }

  // Create Order object from JSON
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      customerId: json['customerId'],
      customer: json['customer'],
      id: json['id'] ?? 0,
      carId: json['carId'] ?? 0,
      car: json['car'] ?? "",
      technicianId: json['technicianId'] ?? "",
      serviceAdvisorId: json['serviceAdvisorId'] ?? "",
      mileageOnReception: int.tryParse(json['mileageOnReception'] ?? "0") ?? 0,
      customerConcerns: json['customerConcerns'] ?? "",
      observations: json['observations'] ?? "",
      maintenanceType: List<String>.from(json['maintenanceType'] ?? []),
      fuelLevel: json['fuelLevel'] ?? "",
      bodyCheck: json['bodyCheck'] ?? "",
      dispatchedAt: DateTime.tryParse(json['dispatchedAt'] ?? ""),
      servicesPerformed: List<int>.from(json['servicesPerformed'] ?? []),
      createdAt: DateTime.tryParse(json['createdAt']),
      updatedAt: DateTime.tryParse(json['updatedAt']),
      conditions: List<int>.from(json['conditions'] ?? []),
      lostSales: json['lostSales'] ?? "",
      cost: double.parse((json['cost'] ?? 0).toString()),
    );
  }
}
