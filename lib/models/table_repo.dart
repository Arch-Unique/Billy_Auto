import 'package:flutter/material.dart';

class TableModel<T>{
  List<String> headers;
  List<T> model;

  TableModel(this.headers,this.model);
}

class FilterModel{

  /// 0 - string/dropdown
  /// 1 - date/daterange
  int filterType; 
  String title;
  List<String>? options;
  DateTimeRange? dtr;
  TextEditingController? tec;

  FilterModel(this.title,this.filterType,{this.options,this.dtr,this.tec});
}