// lib/models/counter_type_model.dart

import '../utils/helper_functions.dart';

class CounterTypeModel {
  final int?    counterTypeMstID;
  final int?    counterTypeCode;
  final String? counterTypeName;
  final int?    sortID;
  final bool?   active;

  CounterTypeModel({
    this.counterTypeMstID,
    this.counterTypeCode,
    this.counterTypeName,
    this.sortID,
    this.active,
  });

  factory CounterTypeModel.fromJson(Map<String, dynamic> json) {
    return CounterTypeModel(
      counterTypeMstID: json['CounterTypeMstID'],
      counterTypeCode:  json['CounterTypeCode'],
      counterTypeName:  json['CounterTypeName'],
      sortID:           json['SortID'],
      active:           json['Active'] == true || json['Active'] == 1,
    );
  }

  Map<String, dynamic> toJson() => {
    'CounterTypeName': counterTypeName,
    'SortID':          sortID,
    'Active':          active,
  };

  Map<String, dynamic> toTableRow() => {
    'counterTypeCode': counterTypeCode?.toString() ?? '',
    'counterTypeName': counterTypeName ?? '',
    'sortID':          sortID?.toString() ?? '',
    'active':          active == true ? 'Yes' : 'No',
    '_raw':            this,
  };

  static CounterTypeModel fromFormValues(Map<String, dynamic> v) {
    return CounterTypeModel(
      counterTypeName: v['counterTypeName'],
      sortID:          int.tryParse(v['sortID']?.toString() ?? ''),
      active:          parseBool(v['active']),
    );
  }
}