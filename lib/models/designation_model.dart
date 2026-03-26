class DesignationModel {
  final int? designationCode;
  final String? designationName;
  final int? sortID;
  final bool? active;

  DesignationModel({
    this.designationCode,
    this.designationName,
    this.sortID,
    this.active,
  });

  factory DesignationModel.fromJson(Map<String, dynamic> json) {
    return DesignationModel(
      designationCode: json['DesignationCode'],
      designationName: json['DesignationName'],
      sortID: json['SortID'],
      active: json['Active'],
    );
  }

  Map<String, dynamic> toJson() => {
    'DesignationCode': designationCode,
    'DesignationName': designationName,
    'SortID': sortID,
    'Active': active,
  };

  Map<String, dynamic> toTableRow() => {
    'designationCode': designationCode,
    'designationName': designationName ?? '',
    'sortID': sortID?.toString() ?? '',
    'active': active == true ? 'Yes' : 'No',
    '_raw': this,
  };
}