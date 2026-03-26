
class EmployeeDeptDetModel {
  final int? employeeDeptDetID;
  final int? employeeCode;
  final int? deptCode;

  EmployeeDeptDetModel({
    this.employeeDeptDetID,
    this.employeeCode,
    this.deptCode,
  });

  // 🔹 FROM JSON (API → Model)
  factory EmployeeDeptDetModel.fromJson(Map<String, dynamic> json) {
    return EmployeeDeptDetModel(
      employeeDeptDetID: json['EmployeeDeptDetID'],
      employeeCode: json['EmployeeCode'],
      deptCode: json['DeptCode'],
    );
  }

  // 🔹 TO JSON (Model → API)
  Map<String, dynamic> toJson() {
    return {
      'EmployeeCode': employeeCode,
      'DeptCode': deptCode,
    };
  }

  // 🔹 TABLE DATA (UI use)
  Map<String, dynamic> toTableRow({
    String? employeeName,
    String? deptName,
  }) {
    return {
      'employeeCode': employeeName ?? employeeCode?.toString() ?? '',
      'deptCode': deptName ?? deptCode?.toString() ?? '',
      '_raw': this,
    };
  }

  // 🔹 FORM VALUES → MODEL
  static EmployeeDeptDetModel fromFormValues(Map<String, dynamic> v) {
    return EmployeeDeptDetModel(
      employeeCode: int.tryParse(v['employeeCode'] ?? ''),
      deptCode: int.tryParse(v['deptCode'] ?? ''),
    );
  }
}