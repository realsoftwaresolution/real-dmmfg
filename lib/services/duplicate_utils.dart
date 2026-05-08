bool shouldSkipDuplicateCheck({
  required bool isEditMode,
   bool allowRowData = false,
  required Map<String, dynamic>? selectedRow,
  required Map<String, dynamic> newFields,
  required Map<String, String> fieldMapping,
}) {
  /// ── ADD MODE ──────────────────────────────

  if (!isEditMode || selectedRow == null) {
    return false;
  }

  final raw = allowRowData ?selectedRow['_raw'].toJson():selectedRow;

  /// ── CHECK ALL FIELDS ──────────────────────
  print(raw);

  for (final entry in fieldMapping.entries) {
    final apiField = entry.key;
    final modelField = entry.value;
    print(modelField);

    final oldValue = (raw[modelField] ?? '')
        .toString()
        .trim()
        .toUpperCase();

    final newValue = (newFields[apiField] ?? '')
        .toString()
        .trim()
        .toUpperCase();
print(oldValue);
print(newValue);
    /// FIELD CHANGED → API REQUIRED
    if (oldValue != newValue) {
      return false;
    }
  }

  /// ALL SAME → SKIP API
  return true;
}
