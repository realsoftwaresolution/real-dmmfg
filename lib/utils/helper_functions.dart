import 'package:intl/intl.dart';

import '../models/purity_model.dart';
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
    final parsed = DateTime.tryParse(v) ?? DateFormat('yyyy-MM-dd').parse(v);
    return DateFormat('dd/MM/yy').format(parsed);
  } catch (_) {
    return v;
  }
}

 bool parseBool(dynamic v) =>
v == true || v == 'true' || v == '1' || v == 'Y';

 String parseYN(dynamic v) =>
(v == true || v == 'true' || v == '1' || v == 'Y') ? 'Y' : 'N';