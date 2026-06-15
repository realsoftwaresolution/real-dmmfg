// lib/models/job_work_issue_model.dart

import '../utils/constants.dart';

/// Job Work Issue Master Model
class JobWorkRecMstModel {
  final int? jobWorkRecMstID;
  final String jobWorkRecDate;
  final String? time;

  final int partyMstID;
  final String? partyName;

  final int deptProcessCode;
  final String? deptProcessName;

  final String sflag;
  final int ever;

  // Summary fields
  final int? jno;
  final int? pkt;
  final int? totalPc;
  final double? totalWt;
  final int? issPc;
  final double? totalDmWt;
  final double? totalDmPer;

  const JobWorkRecMstModel({
    this.jobWorkRecMstID,
    required this.jobWorkRecDate,
    this.time,
    required this.partyMstID,
    this.partyName,
    required this.deptProcessCode,
    this.deptProcessName,
    required this.sflag,
    required this.ever,
    this.jno,
    this.pkt,
    this.totalPc,
    this.totalWt,
    this.issPc,
    this.totalDmWt,
    this.totalDmPer,
  });
  factory JobWorkRecMstModel.fromJson(Map<String, dynamic> json) {
    return JobWorkRecMstModel(
      jobWorkRecMstID: json['JobWorkRecMstID'],
      jobWorkRecDate: json['JobWorkRecDate'] ?? '',
      time: json['Time'],

      partyMstID: json['PartyMstID'] ?? 0,
      partyName: json['PartyName'],

      deptProcessCode: json['DeptProcessCode'] ?? 0,
      deptProcessName: json['DeptProcessName'],

      sflag: json['Sflag'] ?? 'I',
      ever: json['Ever'] ?? 1,

      jno: json['Jno'],
      pkt: json['Pkt'],

      totalPc: json['Pc'],
      totalWt: _toDouble(json['Wt']),

      issPc: json['IssPc'],

      totalDmWt: _toDouble(json['DmWt']),
      totalDmPer: _toDouble(json['DmPer']),
    );
  }
  Map<String, dynamic> toJson() => {
    'JobWorkRecMstID': jobWorkRecMstID,
    'JobWorkRecDate': jobWorkRecDate,
    'PartyMstID': partyMstID,
    'DeptProcessCode': deptProcessCode,
  };
}

/// Job Work Issue Detail Model
class JobWorkRecDetModel {
  final int? jobWorkRecDetID;
  final int? jobWorkRecMstID;
  final int? srno;

  // Cut & Package Info
  final String cutNo;
  final String mfgCut;
  final int bCode;
  final String pktNo;
  final int? pairNo;

  // Pieces & Weight
  final int pc;
  final double wt;
  final int issPc;
  final double issWt;

  // Diamond Info
  final int? purityCode;
  final int? charniCode;
  final int? colorCode;
  final int? shapeCode;
  final String? purityName;
  final String? charniName;
  final String? colorName;
  final String? shapeName;
  final double dmWt;
  final double dmPer;

  // Dimensions & Details
  final double size;
  final int? cutCode;
  final double diam;
  final double? height;
  final double length;

  // Quality & Measurements
  final int? polishCode;
  final int? symmetryCode;
  final int? fluoCode;
  final String qrCode;
  final String? cutName;
  final String? polishName;
  final String? symmetryName;
  final String? fluoName;

  // Job Details
  final int? jno;

// Receive Details
  final int? recPc;
  final double? recWt;

// Kapan / Breakage / Loss
  final int? kPc;
  final double? kWt;
  final int? brPc;
  final double? brWt;
  final int? lossPc;
  final double? lossWt;

// Percentage Details
  final double? recPer;
  final double? diffPer;
  final double? diffWt;

// Status
  final String? jobRec;

// IDs
  final int? polishCheckerRecMstID;
  final int? orderMstID;
  final int? markerMstID;
  final int? fromCrID;
  final int? lastCrID;
  final int? crID;

// Additional Quality Fields
  final int? tensionsCode;

// FC Details
  final String? topSide;
  final int? fcIntentCode;
  final int? fcOverCode;
  final int? fColorCode1;
  final int? fColorCode2;

// Other Details
  final String? ha;

// Transaction Details
  final String? jobWorkRecDate;
  final int? partyMstID;
  final int? deptCode;
  final int? deptProcessCode;
  final String? sflag;
  final String? sdate;
  final int? logID;
  final String? pcID;
  final int? ever;
  final String? time;

// Names
  final String? purity;
  final String? charni;
  final String? color;
  final String? shape;
  final String? cut;
  final String? polish;
  final String? symmetry;
  final String? fluo;

// Article Details
  final String? articalName;
  final int? articalCode;

// Rate Details
  final double? rate;
  final double? amount;
  final String? rateID;
  final String? rateon;

// Message
  final String? message;

  const JobWorkRecDetModel({
    this.jobWorkRecDetID,
    this.jobWorkRecMstID,
    this.srno,
    required this.cutNo,
    required this.mfgCut,
    required this.bCode,
    required this.pktNo,
    this.pairNo,
    required this.pc,
    required this.wt,
    required this.issPc,
    required this.issWt,
    this.purityCode,
    this.charniCode,
    this.colorCode,
    this.shapeCode,
    required this.dmWt,
    required this.dmPer,
    required this.size,
    this.cutCode,
    required this.diam,
    this.height,
    required this.length,
    this.polishCode,
    this.symmetryCode,
    this.fluoCode,
    required this.qrCode,
    this.purityName,
    this.charniName,
    this.colorName,
    this.shapeName,

    this.cutName,
    this.polishName,
    this.symmetryName,
    this.fluoName,
    this.jno,
    this.recPc,
    this.recWt,
    this.kPc,
    this.kWt,
    this.brPc,
    this.brWt,
    this.lossPc,
    this.lossWt,
    this.recPer,
    this.diffPer,
    this.diffWt,
    this.jobRec,
    this.polishCheckerRecMstID,
    this.orderMstID,
    this.markerMstID,
    this.fromCrID,
    this.lastCrID,
    this.crID,
    this.tensionsCode,
    this.topSide,
    this.fcIntentCode,
    this.fcOverCode,
    this.fColorCode1,
    this.fColorCode2,
    this.ha,
    this.jobWorkRecDate,
    this.partyMstID,
    this.deptCode,
    this.deptProcessCode,
    this.sflag,
    this.sdate,
    this.logID,
    this.pcID,
    this.ever,
    this.time,
    this.purity,
    this.charni,
    this.color,
    this.shape,
    this.cut,
    this.polish,
    this.symmetry,
    this.fluo,
    this.articalName,
    this.articalCode,
    this.rate,
    this.amount,
    this.rateID,
    this.rateon,
    this.message,
  });

  factory JobWorkRecDetModel.fromJson(Map<String, dynamic> json) {
    return JobWorkRecDetModel(
      jobWorkRecDetID: json['JobWorkRecDetID'],
      jobWorkRecMstID: json['JobWorkRecMstID'],
      srno: json['Srno'],
      cutNo: json['CutNo'] ?? '',
      mfgCut: json['MfgCut'] ?? '',
      bCode: json['BCode'] ?? 0,
      pktNo: json['PktNo'] ?? '',
      pairNo: json['PairNo'],
      pc: json['Pc'] ?? 0,
      wt: _toDouble(json['Wt']) ?? 0.0,
      issPc: json['IssPc'] ?? 0,
      issWt: _toDouble(json['IssWt']) ?? 0.0,
      purityCode: json['PurityCode'],
      charniCode: json['CharniCode'],
      colorCode: json['ColorCode'],
      shapeCode: json['ShapeCode'],
      dmWt: _toDouble(json['DmWt']) ?? 0.0,
      dmPer: _toDouble(json['DmPer']) ?? 0.0,
      size: _toDouble(json['Size']) ?? 0.0,
      cutCode: json['CutCode'],
      diam: _toDouble(json['Diam']) ?? 0.0,
      height: _toDouble(json['Height']),
      length: _toDouble(json['Length']) ?? 0.0,
      polishCode: json['PolishCode'],
      symmetryCode: json['SymmetryCode'],
      fluoCode: json['FluoCode'],
      qrCode: json['QRCode'] ?? '',
      purityName: json['PurityName'],
      charniName: json['CharniName'],
      colorName: json['ColorName'],
      shapeName: json['ShapeName'],
      cutName: json['CutName'],
      polishName: json['PolishName'],
      symmetryName: json['SymmetryName'],
      fluoName: json['FluoName'],
      jno: json['Jno'],

      recPc: json['RecPc'],
      recWt: _toDouble(json['RecWt']),

      kPc: json['KPc'],
      kWt: _toDouble(json['KWt']),

      brPc: json['BrPc'],
      brWt: _toDouble(json['BrWt']),

      lossPc: json['LossPc'],
      lossWt: _toDouble(json['LossWt']),

      recPer: _toDouble(json['RecPer']),
      diffPer: _toDouble(json['DiffPer']),
      diffWt: _toDouble(json['DiffWt']),

      jobRec: json['JobRec'],

      polishCheckerRecMstID: json['PolishCheckerRecMstID'],
      orderMstID: json['OrderMstID'],
      markerMstID: json['MarkerMstID'],
      fromCrID: json['FromCrID'],
      lastCrID: json['LastCrID'],
      crID: json['CrID'],

      tensionsCode: json['TensionsCode'],

      topSide: json['TopSide'],
      fcIntentCode: json['FcIntentCode'],
      fcOverCode: json['FcOverCode'],
      fColorCode1: json['FColorCode1'],
      fColorCode2: json['FColorCode2'],

      ha: json['HA'],

      jobWorkRecDate: json['JobWorkRecDate'],
      partyMstID: json['PartyMstID'],
      deptCode: json['DeptCode'],
      deptProcessCode: json['DeptProcessCode'],
      sflag: json['Sflag'],
      sdate: json['Sdate'],
      logID: json['LogID'],
      pcID: json['PcID'],
      ever: json['Ever'],
      time: json['Time'],

      purity: json['Purity'],
      charni: json['Charni'],
      color: json['Color'],
      shape: json['Shape'],
      cut: json['Cut'],
      polish: json['Polish'],
      symmetry: json['Symmetry'],
      fluo: json['Fluo'],

      articalName: json['ArticalName'],
      articalCode: json['ArticalCode'],

      rate: _toDouble(json['Rate']),
      amount: _toDouble(json['Amount']),

      rateID: json['RateID']?.toString(),
      rateon: json['Rateon'],

      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() => {
    'JobWorkRecDetID': jobWorkRecDetID,
    'JobWorkRecMstID': jobWorkRecMstID,
    'Srno': srno,
    'CutNo': cutNo,
    'MfgCut': mfgCut,
    'BCode': bCode,
    'PktNo': pktNo,
    'PairNo': pairNo ?? 0,
    'Pc': pc,
    'Wt': wt,
    'IssPc': issPc,
    'IssWt': issWt,
    'PurityCode': purityCode ?? 0,
    'CharniCode': charniCode ?? 0,
    'ColorCode': colorCode ?? 0,
    'ShapeCode': shapeCode ?? 0,
    'DmWt': dmWt,
    'DmPer': dmPer,
    'Size': size,
    'CutCode': cutCode ?? 0,
    'Diam': diam,
    'Height': height ?? 0.0,
    'Length': length,
    'PolishCode': polishCode ?? 0,
    'SymmetryCode': symmetryCode ?? 0,
    'FluoCode': fluoCode ?? 0,
    'QRCode': qrCode,
    'Jno': jno,

    'RecPc': recPc,
    'RecWt': recWt,

    'KPc': kPc,
    'KWt': kWt,

    'BrPc': brPc,
    'BrWt': brWt,

    'LossPc': lossPc,
    'LossWt': lossWt,

    'RecPer': recPer,
    'DiffPer': diffPer,
    'DiffWt': diffWt,

    'JobRec': jobRec,

    'PolishCheckerRecMstID': polishCheckerRecMstID,
    'OrderMstID': orderMstID,
    'MarkerMstID': markerMstID,
    'FromCrID': fromCrID,
    'LastCrID': lastCrID,
    'CrID': crID,

    'TensionsCode': tensionsCode,

    'TopSide': topSide,
    'FcIntentCode': fcIntentCode,
    'FcOverCode': fcOverCode,
    'FColorCode1': fColorCode1,
    'FColorCode2': fColorCode2,

    'HA': ha,

    'JobWorkRecDate': jobWorkRecDate,
    'PartyMstID': partyMstID,
    'DeptCode': deptCode,
    'DeptProcessCode': deptProcessCode,
    'Sflag': sflag,
    'Sdate': sdate,
    'LogID': logID,
    'PcID': pcID,
    'Ever': ever,
    'Time': time,

    'Purity': purity,
    'Charni': charni,
    'Color': color,
    'Shape': shape,
    'Cut': cut,
    'Polish': polish,
    'Symmetry': symmetry,
    'Fluo': fluo,

    'ArticalName': articalName,
    'ArticalCode': articalCode,

    'Rate': rate,
    'Amount': amount,

    'RateID': rateID,
    'Rateon': rateon,

    'message': message,
  };

  /// Convert to table row for display
  Map<String, dynamic> toTableRow() => {
    'srno': srno?.toString() ?? '',
    'cutNo': cutNo,
    'mfgCut': mfgCut,
    'qrCode': qrCode,
    'bCode': bCode.toString(),
    'pktNo': pktNo,
    'pairNo': pairNo?.toString() ?? '',
    'pc': pc.toString(),
    'wt': fThreeDecimal(wt),
    'issPc': issPc.toString(),
    'issWt': fThreeDecimal(issWt),
    'purityCode': purityName ?? '',
    'charniCode': charniName ?? '',
    'colorCode': colorName ?? '',
    'shapeCode': shapeName ?? '',
    'dmWt': fThreeDecimal(dmWt),
    'dmPer': dmPer.toStringAsFixed(2),
    'size': fThreeDecimal(size),
    'cutCode': cutName ?? '',
    'diam': diam.toString(),
    'height': height?.toString() ?? '',
    'length': length.toString(),
    'polishCode': polishName ?? '',
    'symmetryCode': symmetryName ?? '',
    'fluoCode': fluoName ?? '',

  };
  JobWorkRecDetModel copyWith({
    int? srno,
  }) {
    return JobWorkRecDetModel(
      jobWorkRecDetID: jobWorkRecDetID,
      jobWorkRecMstID: jobWorkRecMstID,
      jno: jno,
      srno: srno ?? this.srno,

      cutNo: cutNo,
      mfgCut: mfgCut,
      bCode: bCode,
      pktNo: pktNo,
      pairNo: pairNo,

      pc: pc,
      wt: wt,
      issPc: issPc,
      issWt: issWt,
      recPc: recPc,
      recWt: recWt,

      kPc: kPc,
      kWt: kWt,
      brPc: brPc,
      brWt: brWt,
      lossPc: lossPc,
      lossWt: lossWt,

      purityCode: purityCode,
      charniCode: charniCode,
      colorCode: colorCode,
      shapeCode: shapeCode,

      purityName: purityName,
      charniName: charniName,
      colorName: colorName,
      shapeName: shapeName,

      dmWt: dmWt,
      dmPer: dmPer,

      recPer: recPer,
      diffPer: diffPer,
      diffWt: diffWt,

      size: size,
      cutCode: cutCode,
      diam: diam,
      height: height,
      length: length,

      polishCode: polishCode,
      symmetryCode: symmetryCode,
      fluoCode: fluoCode,
      tensionsCode: tensionsCode,

      qrCode: qrCode,

      cutName: cutName,
      polishName: polishName,
      symmetryName: symmetryName,
      fluoName: fluoName,

      jobRec: jobRec,

      polishCheckerRecMstID: polishCheckerRecMstID,
      orderMstID: orderMstID,
      markerMstID: markerMstID,
      fromCrID: fromCrID,
      lastCrID: lastCrID,
      crID: crID,

      topSide: topSide,
      fcIntentCode: fcIntentCode,
      fcOverCode: fcOverCode,
      fColorCode1: fColorCode1,
      fColorCode2: fColorCode2,

      ha: ha,

      jobWorkRecDate: jobWorkRecDate,
      partyMstID: partyMstID,
      deptCode: deptCode,
      deptProcessCode: deptProcessCode,
      sflag: sflag,
      sdate: sdate,
      logID: logID,
      pcID: pcID,
      ever: ever,
      time: time,

      purity: purity,
      charni: charni,
      color: color,
      shape: shape,
      cut: cut,
      polish: polish,
      symmetry: symmetry,
      fluo: fluo,

      articalName: articalName,
      articalCode: articalCode,

      rate: rate,
      amount: amount,
      rateID: rateID,
      rateon: rateon,

      message: message,
    );
  }
}

/// Payload builder for create/update API
class JobWorkRecPayload {
  final String jobWorkRecDate;
  final int partyMstID;
  final int deptProcessCode;
  final String sflag;
  final int ever;
  final List<JobWorkRecDetModel> details;

  const JobWorkRecPayload({
    required this.jobWorkRecDate,
    required this.partyMstID,
    required this.deptProcessCode,
    required this.sflag,
    required this.ever,
    required this.details,
  });

  Map<String, dynamic> toJson() => {
    'JobWorkRecDate': jobWorkRecDate,
    'PartyMstID': partyMstID,
    'DeptProcessCode': deptProcessCode,
    'Sflag': sflag,
    'Ever': ever,
    'details': details.map((d) => d.toJson()).toList(),
  };
}

/// Summary Model
class JobWorkRecSummaryModel {
  final String partyName;
  final int totalPairNo;
  final int totalPc;
  final double totalWt;
  final double totalDmWt;
  final double totalDmPer;
  final List<JobWorkRecSummaryRow> summary;

  const JobWorkRecSummaryModel({
    required this.partyName,
    required this.totalPairNo,
    required this.totalPc,
    required this.totalWt,
    required this.totalDmWt,
    required this.totalDmPer,
    required this.summary,
  });

  factory JobWorkRecSummaryModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return JobWorkRecSummaryModel(
      partyName: data['PartyName']?.toString() ?? '',
      totalPairNo: data['TotalPairNo'] ?? 0,
      totalPc: data['TotalPc'] ?? 0,
      totalWt: _toDouble(data['TotalWt']) ?? 0.0,
      totalDmWt: _toDouble(data['TotalDmWt']) ?? 0.0,
      totalDmPer: _toDouble(data['TotalDmPer']) ?? 0.0,
      summary: (data['summary'] as List<dynamic>? ?? [])
          .map((e) => JobWorkRecSummaryRow.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class JobWorkRecSummaryRow {
  final int srno;
  final String cutNo;
  final String mfgCut;
  final int pairNo;
  final int pc;
  final double wt;
  final double dmWt;
  final double dmPer;

  bool get isGrandTotal => srno == -1; // Convention for grand total

  const JobWorkRecSummaryRow({
    required this.srno,
    required this.cutNo,
    required this.mfgCut,
    required this.pairNo,
    required this.pc,
    required this.wt,
    required this.dmWt,
    required this.dmPer,
  });

  factory JobWorkRecSummaryRow.fromJson(Map<String, dynamic> json) {
    return JobWorkRecSummaryRow(
      srno: json['Srno'] ?? 0,
      cutNo: json['CutNo']?.toString() ?? '',
      mfgCut: json['MfgCut']?.toString() ?? '',
      pairNo: json['PairNo'] ?? 0,
      pc: json['Pc'] ?? 0,
      wt: _toDouble(json['Wt']) ?? 0.0,
      dmWt: _toDouble(json['DmWt']) ?? 0.0,
      dmPer: _toDouble(json['DmPer']) ?? 0.0,
    );
  }
}

// Helper functions
double? _toDouble(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}