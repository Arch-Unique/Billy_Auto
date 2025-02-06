class Order {
  int customerId;
  int carId;
  int mileageOnReception;
  String? customerConcerns;
  String? observations;
  String? maintenanceType;
  String? fuelLevel;
  String? bodyCheck;
  List<int> servicesPerformed;
  DateTime createdAt;
  DateTime updatedAt;
  List<int> conditions;
  double lostSales;
  double cost;
  String customer,car;

  Order({
    required this.customerId,
    required this.customer,
    required this.carId,
    required this.car,
    required this.mileageOnReception,
    this.customerConcerns,
    this.observations,
    this.maintenanceType,
    this.fuelLevel,
    this.bodyCheck,
    required this.servicesPerformed,
    required this.createdAt,
    required this.updatedAt,
    required this.conditions,
    required this.lostSales,
    required this.cost,
  });

  // Convert Order object to JSON
  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'carId': carId,
      'mileageOnReception': mileageOnReception,
      'customerConcerns': customerConcerns,
      'observations': observations,
      'maintenanceType': maintenanceType,
      'fuelLevel': fuelLevel,
      'bodyCheck': bodyCheck,
      'servicesPerformed': servicesPerformed,
      'conditions': conditions,
      'lostSales': lostSales,
      'cost': cost,
    };
  }

  // Create Order object from JSON
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      customerId: json['customerId'],
      customer: json['customer'],
      carId: json['carId'] ?? 0,
      car: json['car'] ?? "",
      mileageOnReception: json['mileageOnReception']?? "",
      customerConcerns: json['customerConcerns']?? "",
      observations: json['observations']?? "",
      maintenanceType: json['maintenanceType']?? "",
      fuelLevel: json['fuelLevel']?? "",
      bodyCheck: json['bodyCheck'] ?? "",
      servicesPerformed: List<int>.from(json['servicesPerformed']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      conditions: List<int>.from(json['conditions']),
      lostSales: json['lostSales']?? "",
      cost: json['cost']?? 0,
    );
  }
}