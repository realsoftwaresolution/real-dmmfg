// Future<void> _onSave(Map<String, dynamic> values) async {
//   final prov = context.read<SpkDeptIssProvider>();
//
//   String toIso(String? v) {
//     if (v == null || v.isEmpty) return '';
//     try { return DateFormat('yyyy-MM-dd').format(DateFormat('dd/MM/yyyy').parse(v)); }
//     catch (_) { return v; }
//   }
//
//   // To counter ka deptCode get karo
//   int? toDeptCode;
//   if (_toCrId != null) {
//     try {
//       toDeptCode = context.read<CounterProvider>().list
//           .firstWhere((c) => c.crId == _toCrId).deptCode;
//     } catch (_) {}
//   }
//
//   final merged = Map<String, dynamic>.from(values);
//   merged['spkDeptIssDate'] = toIso(merged['spkDeptIssDate']?.toString());
//   merged['fromCrID']       = _fromCrId?.toString() ?? '';
//   merged['toCrID']         = _toCrId?.toString() ?? '';
//   merged['deptCode']       = toDeptCode?.toString() ?? '';
//
//   bool success;
//   if (_isEditMode && _selectedMst != null) {
//     success = await prov.update(_selectedMst!.spkDeptIssMstID!, merged, _detRows);
//   } else {
//     success = await prov.create(merged, _detRows);
//   }
//   if (!mounted) return;
//   if (success) {
//     final wasEdit = _isEditMode;
//     _resetForm();
//     await ErpResultDialog.showSuccess(
//       context: context, theme: _theme,
//       title:   wasEdit ? 'Updated' : 'Saved',
//       message: wasEdit ? 'Dept Issue updated.' : 'Dept Issue saved.',
//     );
//   }
// }
