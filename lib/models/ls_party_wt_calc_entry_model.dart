import 'package:diam_mfg/utils/constants.dart';

class MstLsPartyWtCalcEntryModel {

  final int? lsPartyWtCalcMstId;

  final DateTime? lsPartyWtCalcDate;

  final int? crId;

  final int? remarksCode;

  final int? tops;

  final double? calcWt;

  final String? calcType;

  final double? pieCalcWt;

  final double? lsCalcWt;

  final String? remarksName;

  final int? remarkTOPS;

  final String? sflag;

  final String? sdate;

  final int? logID;

  final String? pcID;

  final int? ever;

  final int? companyCode;

  MstLsPartyWtCalcEntryModel({

    this.lsPartyWtCalcMstId,

    this.lsPartyWtCalcDate,

    this.crId,

    this.remarksCode,

    this.tops,

    this.calcWt,

    this.calcType,

    this.pieCalcWt,

    this.lsCalcWt,

    this.remarksName,

    this.remarkTOPS,

    this.sflag,

    this.sdate,

    this.logID,

    this.pcID,

    this.ever,

    this.companyCode,
  });

  factory MstLsPartyWtCalcEntryModel.fromJson(
      Map<String, dynamic> json,
      ) {

    return MstLsPartyWtCalcEntryModel(

      lsPartyWtCalcMstId:
      json['LsPartyWtCalcMstId'],

      lsPartyWtCalcDate:
      json['LsPartyWtCalcDate'] == null
          ? null
          : DateTime.tryParse(
        json['LsPartyWtCalcDate'],
      ),

      crId: json['CrId'],

      remarksCode:
      json['RemarksCode'],

      tops: json['TOPS'],

      calcWt:
      (json['CalcWt'] as num?)
          ?.toDouble(),

      calcType:
      json['CalcType'],

      pieCalcWt:
      (json['PieCalcWt'] as num?)
          ?.toDouble(),

      lsCalcWt:
      (json['LSCalcWt'] as num?)
          ?.toDouble(),

      remarksName:
      json['RemarksName'],

      remarkTOPS:
      json['RemarkTOPS'],

      sflag:
      json['Sflag'],

      sdate:
      json['Sdate']
          ?.toString(),

      logID:
      json['LogID'],

      pcID:
      json['PcID'],

      ever:
      json['Ever'],

      companyCode:
      json['CompanyCode'],
    );
  }

  Map<String, dynamic> toJson() {

    return {

      'LsPartyWtCalcMstId':
      lsPartyWtCalcMstId,

      'LsPartyWtCalcDate':
      lsPartyWtCalcDate
          ?.toIso8601String(),

      'CrId': crId,

      'RemarksCode':
      remarksCode,

      'TOPS': tops,

      'CalcWt': calcWt,

      'CalcType':
      calcType,

      'PieCalcWt':
      pieCalcWt,

      'LSCalcWt':
      lsCalcWt,

      'CompanyCode':
      companyCode,
    };
  }

  Map<String, dynamic> toTableRow() {

    return {

      'lsPartyWtCalcMstId':
      lsPartyWtCalcMstId
          ?.toString() ??
          '',

      'lsPartyWtCalcDate':
      lsPartyWtCalcDate == null
          ? ''
          : formatDisplayDate(
        lsPartyWtCalcDate!,
      ),

      'remarksName':
      remarksName ?? '',

      'remarkTOPS':
      remarkTOPS
          ?.toString() ??
          '',

      'calcType':
      calcType ?? '',

      'calcWt':
      calcWt
          ?.toStringAsFixed(3) ??
          '0.000',

      '_raw': this,
    };
  }

  static MstLsPartyWtCalcEntryModel fromFormValues(
      Map<String, dynamic> v,
      ) {

    return MstLsPartyWtCalcEntryModel(

      remarksCode:
      int.tryParse(
        v['remarks'] ?? '',
      ),

      crId:
      int.tryParse(
        v['crId'] ?? '',
      ),

      tops:
      int.tryParse(
        v['tops'] ?? '',
      ),

      calcWt:
      double.tryParse(
        v['calcWt'] ?? '',
      ),

      calcType:
      v['calcType'],

      companyCode:
      int.tryParse(
        v['companyCode'] ?? '',
      ),
    );
  }
}


class LsPartyRowModel {

  int srNo;

  double per;

  double calcWt;

  double piePer;

  double pieCalcWt;

  double lsPer;

  double lsCalcWt;

  LsPartyRowModel({

    required this.srNo,

    this.per = 0,

    this.calcWt = 0,

    this.piePer = 0,

    this.pieCalcWt = 0,

    this.lsPer = 0,

    this.lsCalcWt = 0,
  });
}