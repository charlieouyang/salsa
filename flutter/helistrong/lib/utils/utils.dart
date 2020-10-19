import 'package:intl/intl.dart';

String getFormattedDate(DateTime date) {
  DateFormat formatter = DateFormat('yyyy-MM-dd');
  String reviewDate = formatter.format(date);

  return reviewDate;
}

bool isNumeric(String s) {
  if (s == null) {
    return false;
  }
  return double.tryParse(s) != null;
}

bool isEmailValid(String s) {
  bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(s);

  return emailValid;
}