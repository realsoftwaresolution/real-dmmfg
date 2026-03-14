import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/purity_model.dart';
import '../providers/purity_provider.dart';

String? formatDate(String? date) {
  if (date == null || date.isEmpty) return null;

  final parts = date.split('-'); // dd-mm-yyyy
  if (parts.length == 3) {
    return "${parts[2]}-${parts[1]}-${parts[0]}"; // yyyy-mm-dd
  }
  return date;
}
String? formatDate1(String? date) {
  if (date == null || date.isEmpty) return null;

  final parts = date.split('-'); // dd-MM-yyyy
  if (parts.length == 3) {
    return "${parts[2]}-${parts[1]}-${parts[0]}"; // yyyy-MM-dd
  }

  return date;
}

String getPurityName(List<PurityModel> list, int? purityCode) {
  if (purityCode == null) return '';

  final purity = list.firstWhere(
        (e) => e.purityCode == purityCode,
    orElse: () => PurityModel(),
  );

  return purity.purityName ?? '';
}
String toDisplayDate(String? v) {
  if (v == null || v.isEmpty) return '';
  try {
    return DateFormat('dd/MM/yyyy')
        .format(DateFormat('yyyy-MM-dd').parse(v));
  } catch (_) {
    return v;
  }
}

 bool parseBool(dynamic v) =>
v == true || v == 'true' || v == '1' || v == 'Y';

 String parseYN(dynamic v) =>
(v == true || v == 'true' || v == '1' || v == 'Y') ? 'Y' : 'N';