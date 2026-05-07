// lib/models/report_config.dart

import 'package:erp_data_table/erp_data_table.dart'; // for ColumnAlign

class ReportColumnDef {
  final String key;
  final String label;
  final double? width;
  final ColumnAlign align;
  final bool isDate;
  final bool required;

  const ReportColumnDef({
    required this.key,
    required this.label,
    this.width,
    this.align = ColumnAlign.left,
    this.isDate = false,
    this.required = false,
  });

  /// Convert to ErpColumnConfig for the table
  ErpColumnConfig toErpColumn() => ErpColumnConfig(
    key: key,
    label: label,
    width: width ?? 140,
    align: align,
    isDate: isDate,
    required: required,
  );
}

typedef ReportMapper =
    List<Map<String, dynamic>> Function(List<Map<String, dynamic>> raw);

class ReportConfig {
  final String reportTypeCode;
  final String endpoint;
  final List<ReportColumnDef> columns;
  final ReportMapper mapper;

  const ReportConfig({
    required this.reportTypeCode,
    required this.endpoint,
    required this.columns,
    required this.mapper,
  });
}
