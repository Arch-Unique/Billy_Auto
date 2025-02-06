import 'dart:convert';

class Order {
  int customerId;
  int carId;
  int id;
  int mileageOnReception;
  String? customerConcerns;
  String? observations;
  List<String> maintenanceType;
  String? fuelLevel;
  String? bodyCheck;
  List<int> servicesPerformed; //id of services
  DateTime createdAt;
  DateTime updatedAt;
  List<int> conditions; //0-false,1-true
  String lostSales;
  double cost;
  String customer,car;

  Order({
    required this.customerId,
    this.customer="",
    this.id=0,
    this.carId=0,
    this.car="",
    this.mileageOnReception=0,
    this.customerConcerns,
    this.observations,
    this.maintenanceType=const[],
    this.fuelLevel,
    this.bodyCheck,
    this.servicesPerformed=const [],
    required this.createdAt,
    required this.updatedAt,
    this.conditions=const[],
    this.lostSales="",
    this.cost=0,
  });

  // Convert Order object to JSON
  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'carId': carId,
      'mileageOnReception': mileageOnReception,
      'customerConcerns': customerConcerns,
      'observations': observations,
      'maintenanceType': jsonEncode(maintenanceType) ,
      'fuelLevel': fuelLevel,
      'bodyCheck': bodyCheck,
      'servicesPerformed': jsonEncode(servicesPerformed),
      'conditions': jsonEncode(conditions),
      'lostSales': lostSales,
      'cost': cost,
    };
  }

  // Create Order object from JSON
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      customerId: json['customerId'],
      customer: json['customer'],
      id: json['id'],
      carId: json['carId'] ?? 0,
      car: json['car'] ?? "",
      mileageOnReception: json['mileageOnReception']?? "",
      customerConcerns: json['customerConcerns']?? "",
      observations: json['observations']?? "",
      maintenanceType: List<String>.from(json['maintenanceType'] ?? []),
      fuelLevel: json['fuelLevel']?? "",
      bodyCheck: json['bodyCheck'] ?? "",
      servicesPerformed: List<int>.from(json['servicesPerformed'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      conditions: List<int>.from(json['conditions'] ?? []),
      lostSales: json['lostSales']?? "",
      cost: json['cost']?? 0,
    );
  }
}