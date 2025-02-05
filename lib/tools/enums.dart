import 'package:flutter/material.dart';

enum DashboardModes {
  
  dashboard("Dashboard",Icons.dashboard),
  inventory("Inventory",Icons.book),
  product("Products",Icons.work),
  order("Orders",Icons.calendar_today_sharp),
  settings("Settings",Icons.settings);

  final String title;
  final IconData icon;
  const DashboardModes(this.title,this.icon);
}

enum FPL {
  email(TextInputType.emailAddress),
  number(TextInputType.number),
  text(TextInputType.text),
  password(TextInputType.number),
  multi(TextInputType.multiline, maxLength: 1000, maxLines: 5),
  phone(TextInputType.phone),
  money(TextInputType.number),

  //card details
  cvv(TextInputType.number, maxLength: 4),
  cardNo(TextInputType.number, maxLength: 20),
  dateExpiry(TextInputType.datetime, maxLength: 5);

  final TextInputType textType;
  final int? maxLength, maxLines;

  const FPL(this.textType, {this.maxLength, this.maxLines = 1});
}


enum ChecklistModes {
  customer("Customer Registration","Get the customers personal information.","Start by registering the customer's details, including their name, contact information, and customer type (individual or corporate). This helps us keep track of their service history and provide personalized support."),
  car("Vehicle Registration","Add vehicle details.","Add the vehicle's details, such as make, model, and license plate number. This ensures we have accurate information about the car being serviced and can provide tailored maintenance recommendations."),
  concerns("Customer Concerns","Let the customer describe the issues.","Let the customer describe any issues or concerns they have with their vehicle. This helps our technicians focus on the problem areas and provide a comprehensive solution."),
  carConditons("Vehicle Condition Check","Record the current condition of the vehicle.","Record the current condition of the vehicle, including mileage, fuel level, and any visible damage. This helps us assess the overall state of the car before starting any work."),
  freeInspection("10-Point Free Inspection","Inspection for your vehicle to ensure safety.","Our technicians will perform a thorough 10-point inspection of essential components, including the engine, brakes, tires, and lights. This ensures your vehicle is safe and in optimal condition."),
  servicePlan("Service Plan","Our diagnosis plan","Based on the inspection and customer concerns, we'll outline the services to be performed. This includes routine maintenance, repairs, and any additional recommendations to keep your vehicle running smoothly."),
  maintenance("Maintenance Recommendations","Detailed list of maintenance tasks.","We'll provide a detailed list of maintenance tasks that should be completed, either now or in the future. This helps you stay on top of your vehicle's health and avoid costly repairs down the road.");

  final String title,desc2,desc;
  const ChecklistModes(this.title,this.desc2,this.desc);
  }