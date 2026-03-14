import '../utils/helper_functions.dart';

class HolidayModel {
  final int? holidayMstID;
  final int? holidayCode;
  final String? holidayName;
  final String? holidayDate;
  final String? sflag;
  final String? sdate;
  final int? logID;
  final String? pcID;
  final int? ever;
  final int? companyCode;
  final int? sortID;
  final bool? active;

  HolidayModel({
    this.holidayMstID,
    this.holidayCode,
    this.holidayName,
    this.holidayDate,
    this.sflag,
    this.sdate,
    this.logID,
    this.pcID,
    this.ever,
    this.companyCode,
    this.sortID,
    this.active,
  });

  factory HolidayModel.fromJson(Map<String, dynamic> json) {
    return HolidayModel(
      holidayMstID: json['HolidayMstID'],
      holidayCode: json['HolidayCode'],
      holidayName: json['HolidayName'],
      holidayDate: json['HolidayDate']?.toString(),
      sflag: json['Sflag'],
      sdate: json['Sdate']?.toString(),
      logID: json['LogID'],
      pcID: json['PcID'],
      ever: json['Ever'],
      companyCode: json['CompanyCode'],
      sortID: json['SortID'],
      active: json['Active'],
    );
  }

  Map<String, dynamic> toJson() {
    String? date;

    if (holidayDate != null && holidayDate!.isNotEmpty) {
      date = holidayDate!.substring(0, 10); // yyyy-MM-dd
    }
    return {
      'HolidayCode': holidayCode,
      'HolidayName': holidayName,
      'HolidayDate': date,
      'CompanyCode': companyCode,
      'SortID': sortID,
      'Active': active,
    };
  }

  Map<String, dynamic> toTableRow({String? companyName}) {
    // Format date for display: extract YYYY-MM-DD from ISO string
    String displayDate = '';
    if (holidayDate != null && holidayDate!.isNotEmpty) {
      try {
        displayDate = holidayDate!.substring(0, 10);
      } catch (_) {
        displayDate = holidayDate ?? '';
      }
    }
    return {
      'holidayCode': holidayCode,
      'holidayName': holidayName ?? '',
      'holidayDate': displayDate,
      'companyCode': companyName??companyCode?.toString() ?? '',
      'sortID': sortID?.toString() ?? '',
      'active': active == true ? 'Yes' : 'No',
      '_raw': this,
    };
  }

  static HolidayModel fromFormValues(Map<String, dynamic> v) {
    String? rawDate = v['holidayDate'];
    String? cleanDate;
    if (rawDate != null && rawDate.isNotEmpty) {
      cleanDate = rawDate.length >= 10 ? rawDate.substring(0, 10) : rawDate;
    }
    return HolidayModel(
      holidayCode: int.tryParse(v['holidayCode'] ?? ''),
      holidayName: v['holidayName'],
      holidayDate: cleanDate,
      companyCode: int.tryParse(v['companyCode'] ?? ''),
      sortID: int.tryParse(v['sortID'] ?? ''),
      // active: v['active'] == 'Y',
      active: parseBool(v['active']),

    );
  }
}