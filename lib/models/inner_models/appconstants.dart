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
  int version;

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
      "version": version
    };
  }

  @override
  List toTableRows() {
    return [];
  }

  @override
  bool validate() {
    return vat != 0;
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
      createdAt: DateTime.tryParse(json['createdAt']),
      updatedAt: DateTime.tryParse(json['updatedAt']),
    );
  }
}
