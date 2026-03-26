class EmployeeModel {
  final int? employeeMstID;
  final int? employeeCode;
  final String? employeeName;
  final String? aliasName;
  final String? address;

  final String? phone1;
  final String? phone2;
  final String? phone3;

  final String? mob1;
  final String? mob2;
  final String? mob3;

  final String? email1;

  final int? deptCode;

  final int? companyCode;
  final bool? active;

  final String? salaryType;
  final int? salary;

  final int? designationCode;

  EmployeeModel({
    this.employeeMstID,
    this.employeeCode,
    this.employeeName,
    this.aliasName,
    this.address,
    this.phone1,
    this.phone2,
    this.phone3,
    this.mob1,
    this.mob2,
    this.mob3,
    this.email1,
    this.deptCode,
    this.companyCode,
    this.active,
    this.salaryType,
    this.salary,
    this.designationCode,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      employeeMstID: json['EmployeeMstID'],
      employeeCode: json['EmployeeCode'],
      employeeName: json['EmployeeName'],
      aliasName: json['AliasName'],
      address: json['Address'],

      phone1: json['Phone1'],
      phone2: json['Phone2'],
      phone3: json['Phone3'],

      mob1: json['Mob1'],
      mob2: json['Mob2'],
      mob3: json['Mob3'],

      email1: json['Email1'],

      deptCode: json['DeptCode'],

      companyCode: json['CompanyCode'],
      active: json['Active'],

      salaryType: json['SalaryType'],
      salary: json['Salary'],

      designationCode: json['DesignationCode'],
    );
  }

  Map<String, dynamic> toJson() => {
    'EmployeeCode': employeeCode,
    'EmployeeName': employeeName,
    'AliasName': aliasName,
    'Address': address,

    'Phone1': phone1,
    'Phone2': phone2,
    'Phone3': phone3,

    'Mob1': mob1,
    'Mob2': mob2,
    'Mob3': mob3,

    'Email1': email1,

    'DeptCode': deptCode,

    'CompanyCode': companyCode,
    'Active': active,

    'SalaryType': salaryType,
    'Salary': salary,

    'DesignationCode': designationCode,
  };

  Map<String, dynamic> toTableRow() => {
    'employeeCode': employeeCode,
    'employeeName': employeeName ?? '',
    'mobile': mob1 ?? '',
    'department': deptCode?.toString() ?? '',
    'salary': salary?.toString() ?? '',
    'active': active == true ? 'Yes' : 'No',
    '_raw': this,
  };
}