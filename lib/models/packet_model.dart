// lib/models/packet_model.dart

import '../utils/constants.dart';

class PacketMstModel {
  final int?    packetMstID;
  final String? packetDate;
  final String? cutNo;
  final String? clvCut;
  final String? sflag;
  final String? sdate;
  final int?    logID;
  final String? pcID;
  final int?    ever;
  final String? packetRec;
  final String? entryType;
  final String? slType;
  final double? totalWtDb;  // ✅ DB se aayega
  final int?    totalPcDb;  // ✅ DB se aayega
  final List<PacketDetModel> details;

  PacketMstModel({
    this.packetMstID,
    this.totalWtDb,
    this.totalPcDb,
    this.packetDate,
    this.cutNo,
    this.clvCut,
    this.sflag,
    this.sdate,
    this.logID,
    this.pcID,
    this.ever,
    this.packetRec,
    this.entryType,
    this.slType,
    this.details = const [],
  });

  // ── Total helpers ──────────────────────────────────────────────────────────
  double get totalWt => totalWtDb ?? details.fold(0.0, (s, d) => s + (d.wt ?? 0));
  int    get totalPc => totalPcDb ?? details.fold(0,   (s, d) => s + (d.pc ?? 0));

  factory PacketMstModel.fromJson(Map<String, dynamic> json) => PacketMstModel(
    packetMstID: json['PacketMstID'],
    packetDate:  _dateOnly(json['PacketDate']),
    cutNo:       json['CutNo'],
    clvCut:      json['ClvCut'],
    sflag:       json['Sflag'],
    sdate:       _dateOnly(json['Sdate']),
    logID:       json['LogID'],
    pcID:        json['PcID'],
    ever:        json['Ever'],
    packetRec:   json['PacketRec'],
    entryType:   json['EntryType'] ?? 'Packet Create',
    slType:      json['SLType'],
    totalWtDb: json['TotalWt'] != null
        ? double.tryParse(json['TotalWt'].toString())
        : null,
    totalPcDb: json['TotalPc'] != null
        ? (json['TotalPc'] as num).toInt()
        : null,
    details: (json['details'] as List? ?? [])
        .map((e) => PacketDetModel.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  static String? _dateOnly(dynamic v) {
    if (v == null) return null;
    final s = v.toString();
    return s.length >= 10 ? s.substring(0, 10) : s;
  }

  Map<String, dynamic> toJson() => {
    'PacketDate': packetDate ?? '',
    'CutNo': cutNo ?? '',
    'ClvCut': clvCut ?? '',
    'Sflag': sflag ?? '',
    'Ever': ever ?? 1,
    'PacketRec': packetRec ?? '',
    'EntryType': entryType ?? '',
    'SLType': slType ?? '',
  };
}

// ─────────────────────────────────────────────────────────────────────────────
//  PacketDetModel
// ─────────────────────────────────────────────────────────────────────────────
class PacketDetModel {
  final int?    packetDetID;
  final int?    packetMstID;
  final int?    bCode;
  final int?    mainBCode;
  final String? cutNo;
  final String? clvCut;
  final int?    lotNo;
  final String? lotCode;
  final String? pktNo;       // computed — read only
  final int?    srno;
  final int?    pc;
  final double? wt;
  final int?    colorCode;
  final int?    tensionsCode;
  final String? issRec;
  final String? packetRec;
  final String? lastProcess;
  final int?    lastLogID;
  final String? pktType;
  final int?    fromCrID;
  final int?    lastCrID;
  final int?    spkDeptIssMstID;
  final String? entryType;
  final int?    id;
  final int?    jno;
  final int?    purityCode;
  final int?    shapeCode;
  final double? dmWt;
  final double? dmPer;
  final int?    spkPktMixMstID;
  final int?    charniCode;
  final double? size;
  final double? lastDmWt;
  final double? lastDmPer;
  final String? genType;
  final double? ghatWt;
  final double? ghatPer;
  final String? packetDate;
  final String? sdate;
  final int?    logID;
  final String? pcID;
  final String? compareGroup;
  final int?    compareGrNo;
  final String? fromToLot;
  final int?    pktComparisionCode;
  final int?    assCrId;
  final int?    pktTypeCode;
  final int?    partName;
  final int?    cutCode;
  final int?    lColorCode;
  final double? diam;
  final double? acuraecy;
  final double? amt;
  final double? pDmPer;
  final double? pDmWt;
  final String? dmType;
  final double? ghatDmWt;
  final double? ghatDmPer;
  final double? amountRs;
  final int?    remarksCode;
  final int?    spkPlanningDetID;
  final String? fType;
  final String? pktValid;
  final String? inValidReason;
  final int?    oldPartName;
  final int?    oldPartName2;
  final int?    oldSpkPlanningDetID;
  final int?    fluoCode;
  final String? qrCode;
  final int?    orderMstID;
  final double? length;

  PacketDetModel({
    this.packetDetID,
    this.packetMstID,
    this.bCode,
    this.mainBCode,
    this.cutNo,
    this.clvCut,
    this.lotNo,
    this.lotCode,
    this.pktNo,
    this.srno,
    this.pc,
    this.wt,
    this.colorCode,
    this.tensionsCode,
    this.issRec,
    this.packetRec,
    this.lastProcess,
    this.lastLogID,
    this.pktType,
    this.fromCrID,
    this.lastCrID,
    this.spkDeptIssMstID,
    this.entryType,
    this.id,
    this.jno,
    this.purityCode,
    this.shapeCode,
    this.dmWt,
    this.dmPer,
    this.spkPktMixMstID,
    this.charniCode,
    this.size,
    this.lastDmWt,
    this.lastDmPer,
    this.genType,
    this.ghatWt,
    this.ghatPer,
    this.packetDate,
    this.sdate,
    this.logID,
    this.pcID,
    this.compareGroup,
    this.compareGrNo,
    this.fromToLot,
    this.pktComparisionCode,
    this.assCrId,
    this.pktTypeCode,
    this.partName,
    this.cutCode,
    this.lColorCode,
    this.diam,
    this.acuraecy,
    this.amt,
    this.pDmPer,
    this.pDmWt,
    this.dmType,
    this.ghatDmWt,
    this.ghatDmPer,
    this.amountRs,
    this.remarksCode,
    this.spkPlanningDetID,
    this.fType,
    this.pktValid,
    this.inValidReason,
    this.oldPartName,
    this.oldPartName2,
    this.oldSpkPlanningDetID,
    this.fluoCode,
    this.qrCode,
    this.orderMstID,
    this.length,
  });

  factory PacketDetModel.fromJson(Map<String, dynamic> json) => PacketDetModel(
    packetDetID:         json['PacketDetID'],
    packetMstID:         json['PacketMstID'],
    bCode:               json['BCode'],
    mainBCode:           json['MainBCode'],
    cutNo:               json['CutNo'],
    clvCut:              json['ClvCut'],
    lotNo:               json['LotNo'],
    lotCode:             json['LotCode'],
    pktNo:               json['PktNo'],
    srno:                json['Srno'],
    pc:                  json['Pc'],
    wt:                  _d(json['Wt']),
    colorCode:           json['ColorCode'],
    tensionsCode:        json['TensionsCode'],
    issRec:              json['IssRec'],
    packetRec:           json['PacketRec'],
    lastProcess:         json['LastProcess'],
    lastLogID:           json['LastLogID'],
    pktType:             json['PKTType'],
    fromCrID:            json['FromCrID'],
    lastCrID:            json['LastCrID'],
    spkDeptIssMstID:     json['SPKDeptIssMstID'],
    entryType:           json['EntryType'],
    id:                  json['ID'],
    jno:                 json['Jno'],
    purityCode:          json['PurityCode'],
    shapeCode:           json['ShapeCode'],
    dmWt:                _d(json['DmWt']),
    dmPer:               _d(json['DmPer']),
    spkPktMixMstID:      json['SPKPktMixMstID'],
    charniCode:          json['CharniCode'],
    size:                _d(json['Size']),
    lastDmWt:            _d(json['LastDmWt']),
    lastDmPer:           _d(json['LastDmPer']),
    genType:             json['GenType'],
    ghatWt:              _d(json['GhatWt']),
    ghatPer:             _d(json['GhatPer']),
    packetDate:          _dateOnly(json['PacketDate']),
    sdate:               _dateOnly(json['Sdate']),
    logID:               json['LogID'],
    pcID:                json['PcID'],
    compareGroup:        json['CompareGroup'],
    compareGrNo:         json['CompareGrNo'],
    fromToLot:           json['FromToLot'],
    pktComparisionCode:  json['PktComparisionCode'],
    assCrId:             json['AssCrId'],
    pktTypeCode:         json['PktTypeCode'],
    partName:            json['PartName'],
    cutCode:             json['CutCode'],
    lColorCode:          json['LColorCode'],
    diam:                _d(json['Diam']),
    acuraecy:            _d(json['Acuraecy']),
    amt:                 _d(json['Amt']),
    pDmPer:              _d(json['PDmPer']),
    pDmWt:               _d(json['PDmWt']),
    dmType:              json['DmType'],
    ghatDmWt:            _d(json['GhatDmWt']),
    ghatDmPer:           _d(json['GhatDmPer']),
    amountRs:            _d(json['AmountRs']),
    remarksCode:         json['RemarksCode'],
    spkPlanningDetID:    json['SPKPlanningDetID'],
    fType:               json['FType'],
    pktValid:            json['PktValid'],
    inValidReason:       json['InValidReason'],
    oldPartName:         json['OldPartName'],
    oldPartName2:        json['Old_PartName'],
    oldSpkPlanningDetID: json['Old_SPKPlanningDetID'],
    fluoCode:            json['FluoCode'],
    qrCode:              json['QRCode'],
    orderMstID:          json['OrderMstID'],
    length:              _d(json['Length']),
  );

  Map<String, dynamic> toJson() => {

    'PacketMstID': packetMstID ?? 0,

    'CutNo': cutNo ?? '',

    'LotNo': lotNo ?? 0,

    'LotCode': lotCode ?? '',
    'PktTypeCode': pktTypeCode ?? '',

    'Srno': srno ?? 0,

    'Pc': pc ?? 0,

    'Wt': wt ?? 0,

    'PKTType': pktType ?? '',

    'ColorCode': colorCode ?? 0,

    'TensionsCode': tensionsCode ?? 0,

    'FluoCode': fluoCode ?? 0,

    'PurityCode': purityCode ?? 1,

    'ShapeCode': shapeCode ?? 1,

    'CharniCode': charniCode ?? 0,

    'PDmPer': pDmPer ?? 0,

    'PDmWt': pDmWt ?? 0,

    'RemarksCode': remarksCode ?? 0,

    'OrderMstID': orderMstID ?? 0,

    'EntryType': entryType ?? '',

    'LastProcess': lastProcess ?? '',

    'PacketDate': packetDate ?? '',

    'PktValid': pktValid ?? '',

    'Jno': jno ?? 0,
    'PacketDetID': packetDetID ?? 0,
  };



  static double? _d(dynamic v) {
    if (v == null) return 0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString());
  }

  static String? _dateOnly(dynamic v) {
    if (v == null) return null;
    final s = v.toString();
    return s.length >= 10 ? s.substring(0, 10) : s;
  }
}

extension PacketMstModelExt on PacketMstModel {
  Map<String, dynamic> toTableRow() => {
    'packetMstID': packetMstID,
    'packetDate':  packetDate ?? '',
    'cutNo':       cutNo      ?? '',
    'clvCut':      clvCut     ?? '',
    'entryType':   entryType  ?? 'Packet Create',
    'slType':      slType     ?? '',
    'totalWt':     fThreeDecimal(totalWt),
    'totalPc':     totalPc.toString(),
    '_raw': this,
  };
}