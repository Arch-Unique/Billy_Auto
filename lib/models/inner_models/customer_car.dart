class CustomerCar {
  int id;
  int makeId;
  int modelId;
  String desc,customer;
  String licenseNo,make,model,year;
  DateTime createdAt;
  DateTime updatedAt;
  int customerId;

  CustomerCar({
    required this.id,
    required this.makeId,
    required this.modelId,
    required this.desc,
    required this.make,
    required this.model,
    required this.year,
    this.customer="",
    required this.licenseNo,
    required this.createdAt,
    required this.updatedAt,
    required this.customerId,
  });

  // Convert CustomerCar object to JSON
  Map<String, dynamic> toJson() {
    return {
      'makeId': makeId,
      'modelId': modelId,
      'desc': desc,
      'year': year,
      'licenseNo': licenseNo,
      'customerId': customerId,
    };
  }

  // Create CustomerCar object from JSON
  factory CustomerCar.fromJson(Map<String, dynamic> json) {
    return CustomerCar(
      id: json['id'],
      makeId: json['makeId'],
      modelId: json['modelId'],
      make: json['make'],
      desc: json['desc'],
      model: json['model'],
      year: json['year'] ?? "",
      licenseNo: json['licenseNo'] ?? "",
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      customerId: json['customerId'],
      customer: json['customer'] ?? "",
    );
  }
}