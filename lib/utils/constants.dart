import 'package:flutter/services.dart';
import 'package:intl/intl.dart';






DateTime _parseFlexibleDisplayDate(String v) {
  try {
    return DateFormat('dd/MM/yy').parseStrict(v);
  } catch (_) {
    try {
      return DateFormat('dd/MM/yyyy').parseStrict(v);
    } catch (_) {
      return DateTime.parse(v);
    }
  }
}

String toUtcIso(String? v) {
  if (v == null || v.isEmpty) return '';

  try {
    final parsed = _parseFlexibleDisplayDate(v);

    // attach time (optional: 00:00 or current time)
    final dt = DateTime(
      parsed.year,
      parsed.month,
      parsed.day,
      10, 30, 0, 0, // 👈 fixed time OR use DateTime.now()
    );

    return dt.toUtc().toIso8601String();
  } catch (_) {
    return v;
  }
}


String formatDecimal(dynamic value, {int decimal = 3}) {
  if (value == null) return '';
  final numVal = num.tryParse(value.toString());
  if (numVal == null) return '';
  return numVal.toStringAsFixed(decimal);
}

String formatDate(dynamic value) {
  try {
    return DateFormat('dd/MM/yy')
        .format(DateTime.parse(value.toString()));
  } catch (_) {
    return value?.toString() ?? '-';
  }
}


class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

String formatDisplayDate(dynamic value) {

  if (value == null) return '';

  final str = value.toString().trim();

  if (str.isEmpty) return '';

  try {

    final date = DateTime.parse(str);

    return DateFormat('dd/MM/yy').format(date);

  } catch (e) {

    return str;
  }
}

String toIsoDate(String value) {

  try {

    final date = _parseFlexibleDisplayDate(value).toUtc();

    return date.toIso8601String();

  } catch (e) {

    return value;
  }
}

String toIso(String? v) {
  if (v == null || v.isEmpty) return '';
  try {
    return DateFormat(
      'yyyy-MM-dd',
    ).format(_parseFlexibleDisplayDate(v));
  } catch (_) {
    return v;
  }
}

String? parseDateForApi(String? displayDate) {
  if (displayDate == null || displayDate.isEmpty) return null;

  try {
    final date = _parseFlexibleDisplayDate(displayDate);
    return DateFormat('yyyy-MM-dd').format(date);
  } catch (_) {
    return null;
  }
}


String f2TwoDecimal(double? v) => v == null ? '' : v.toStringAsFixed(2);

String fThreeDecimal(double? v) => v == null ? '' : v.toStringAsFixed(3);


// Helper functions
double? toDouble(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}