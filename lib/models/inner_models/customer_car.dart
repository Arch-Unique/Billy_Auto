import 'base_model.dart';

class CustomerCar extends BaseModel{
  
  int makeId;
  int modelId;
  String desc, customer;
  String licenseNo, make, model, year;
  
  
  int customerId;

  CustomerCar({
    super.id = 0,
    required this.makeId,
    required this.modelId,
    this.desc = "",
    this.make = "",
    this.model = "",
    required this.year,
    this.customer = "",
    required this.licenseNo,
    super.createdAt,
    super.updatedAt,
    required this.customerId,
  });

  // Convert CustomerCar object to JSON
  @override
Map<String, dynamic> toJson() {
    return {
      'makeId': makeId,
      'modelId': modelId,
      'description': desc,
      'year': year,
      'licenseNo': licenseNo,
      'customerId': customerId,
    };
  }

      @override
List<dynamic> toTableRows(){
    return [id,make,model,year,licenseNo,customer,createdAt];
  }

  // Create CustomerCar object from JSON
  factory CustomerCar.fromJson(Map<String, dynamic> json) {
    return CustomerCar(
      id: json['id'],
      makeId: json['makeId'],
      modelId: json['modelId'],
      make: json['make'],
      desc: json['description'],
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
