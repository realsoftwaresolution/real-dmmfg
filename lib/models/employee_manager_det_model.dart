
class EmployeeManagerDetModel {
  final int? employeeManagerDetID;
  final int? employeeCode;
  final int? crId;
  final int? deptProcessCode;
  final int? deptCode;

  EmployeeManagerDetModel({
    this.employeeManagerDetID,
    this.employeeCode,
    this.crId,
    this.deptProcessCode,
    this.deptCode,
  });

  // 🔹 FROM JSON
  factory EmployeeManagerDetModel.fromJson(Map<String, dynamic> json) {
    return EmployeeManagerDetModel(
      employeeManagerDetID: json['EmployeeManagerDetID'],
      employeeCode: json['EmployeeCode'],
      crId: json['CrId'],
      deptProcessCode: json['DeptProcessCode'],
      deptCode: json['DeptCode'],
    );
  }

  // 🔹 TO JSON
  Map<String, dynamic> toJson() {
    return {
      'EmployeeCode': employeeCode,
      'CrId': crId,
      'DeptProcessCode': deptProcessCode,
      'DeptCode': deptCode,
    };
  }

  // 🔹 TABLE ROW (UI)
  Map<String, dynamic> toTableRow({
    String? employeeName,
    String? crName,
    String? processName,
    String? deptName,
  }) {
    return {
      'employeeCode': employeeName ?? employeeCode?.toString() ?? '',
      'crId': crName ?? crId?.toString() ?? '',
      'deptProcessCode': processName ?? deptProcessCode?.toString() ?? '',
      'deptCode': deptName ?? deptCode?.toString() ?? '',
      '_raw': this,
    };
  }

  // 🔹 FORM → MODEL
  static EmployeeManagerDetModel fromFormValues(Map<String, dynamic> v) {
    return EmployeeManagerDetModel(
      employeeCode: int.tryParse(v['employeeCode'] ?? ''),
      crId: int.tryParse(v['crId'] ?? ''),
      deptProcessCode: int.tryParse(v['deptProcessCode'] ?? ''),
      deptCode: int.tryParse(v['deptCode'] ?? ''),
    );
  }
}