abstract class AppUrls {
  static const String baseURL = 'https://server.archyuniq.com/snitchit';


  static const String profile = "/profile";

  static const String user = "/user";
  static const String supplier = "/supplier$profile";
  static const String service = "/service$profile";
  static const String product = "/product$profile";
  static const String productType = "/product/type";
  static const String productCategory = "/product/category";
  static const String order = "/order$profile";
  static const String inventory = "/inventory$profile";
  static const String customer = "/customer$profile";
  static const String customerCar = "/customer/car";
  static const String condition = "/condition$profile";
  static const String conditionCategory = "/condition/category";
  static const String carMake = "/car/makes";
  static const String carModel = "/car/models";

  //auth repo
  static const String login = "$user/auth/login";
  static const String changePassword = "$user/auth/changePassword";
  
  static const String getUser = "$user$profile";


  static const String logout = "$user/auth/logout";
}
