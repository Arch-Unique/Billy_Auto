import 'package:intl/intl.dart';
import 'package:inventory/tools/functions.dart';

extension IntExtension on int {
  //For date
  //copied from somewhere
  String timeAgo({bool numericDates = true}) {
    final date2 = DateTime.now();
    final difference =
        date2.difference(DateTime.fromMillisecondsSinceEpoch(this));

    if ((difference.inDays / 7).floor() >= 1) {
      return (numericDates) ? '1 week ago' : 'Last week';
    } else if (difference.inDays >= 2) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays >= 1) {
      return (numericDates) ? '1 day ago' : 'Yesterday';
    } else if (difference.inHours >= 2) {
      return '${difference.inHours} hours ago';
    } else if (difference.inHours >= 1) {
      return (numericDates) ? '1 hour ago' : 'An hour ago';
    } else if (difference.inMinutes >= 2) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inMinutes >= 1) {
      return (numericDates) ? '1 minute ago' : 'A minute ago';
    } else if (difference.inSeconds >= 3) {
      return '${difference.inSeconds} seconds ago';
    } else {
      return 'Just now';
    }
  }

  bool isSuccess() {
    return UtilFunctions.isSuccess(this);
  }
}

extension NumExtension on num {
  ///returns value * (percentage/100)
  double percent(num percentage) => (this * (percentage / 100)).toDouble();

  double get negate => this * -1;

  String toCurrency() {
    NumberFormat myFormat = NumberFormat.decimalPattern('en_us');
    return "₦${myFormat.format(nearest10())}";
  }

  int nearest10() {
    return (this / 100).ceil() * 100;
  }

  String toCurrencyString(){
    return nearest10().toString();
  }
}

extension DateExtension on DateTime {
  String toSQLDate() {
    return DateFormat("yyyy-MM-dd hh:mm:ss").format(this);
  }
}
