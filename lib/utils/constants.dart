import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

String toUtcIso(String? v) {
  if (v == null || v.isEmpty) return '';

  try {
    final parsed = DateFormat('dd/MM/yyyy').parse(v);

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
    return DateFormat('dd-MM-yyyy')
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