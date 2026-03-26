// lib/models/packet_model.dart

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
    entryType:   json['EntryType'],
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
    'PacketDate': packetDate,
    'CutNo':      cutNo,
    'ClvCut':     clvCut,
    'Sflag':      sflag,
    'Sdate':      sdate,
    'LogID':      logID,
    'PcID':       pcID,
    'Ever':       ever,
    'PacketRec':  packetRec,
    'EntryType':  entryType,
    'SLType':     slType,
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

  // Map<String, dynamic> toJson() => {
  //   'PacketMstID':        packetMstID,
  //   'BCode':              bCode,
  //   'MainBCode':          mainBCode,
  //   'CutNo':              cutNo,
  //   'ClvCut':             clvCut,
  //   'LotNo':              lotNo,
  //   'LotCode':            lotCode,
  //   // PktNo excluded — computed column
  //   'Srno':               srno,
  //   'Pc':                 pc,
  //   'Wt':                 wt,
  //   'ColorCode':          colorCode,
  //   'TensionsCode':       tensionsCode,
  //   'IssRec':             issRec,
  //   'PacketRec':          packetRec,
  //   'LastProcess':        lastProcess,
  //   'LastLogID':          lastLogID,
  //   'PKTType':            pktType,
  //   'FromCrID':           fromCrID,
  //   'LastCrID':           lastCrID,
  //   'SPKDeptIssMstID':    spkDeptIssMstID,
  //   'EntryType':          entryType,
  //   'ID':                 id,
  //   'Jno':                jno,
  //   'PurityCode':         purityCode,
  //   'ShapeCode':          shapeCode,
  //   'DmWt':               dmWt,
  //   'DmPer':              dmPer,
  //   'SPKPktMixMstID':     spkPktMixMstID,
  //   'CharniCode':         charniCode,
  //   'Size':               size,
  //   'LastDmWt':           lastDmWt,
  //   'LastDmPer':          lastDmPer,
  //   'GenType':            genType,
  //   'GhatWt':             ghatWt,
  //   'GhatPer':            ghatPer,
  //   'PacketDate':         packetDate,
  //   'Sdate':              sdate,
  //   'LogID':              logID,
  //   'PcID':               pcID,
  //   'CompareGroup':       compareGroup,
  //   'CompareGrNo':        compareGrNo,
  //   'FromToLot':          fromToLot,
  //   'PktComparisionCode': pktComparisionCode,
  //   'AssCrId':            assCrId,
  //   'PktTypeCode':        pktTypeCode,
  //   'PartName':           partName,
  //   'CutCode':            cutCode,
  //   'LColorCode':         lColorCode,
  //   'Diam':               diam,
  //   'Acuraecy':           acuraecy,
  //   'Amt':                amt,
  //   'PDmPer':             pDmPer,
  //   'PDmWt':              pDmWt,
  //   'DmType':             dmType,
  //   'GhatDmWt':           ghatDmWt,
  //   'GhatDmPer':          ghatDmPer,
  //   'AmountRs':           amountRs,
  //   'RemarksCode':        remarksCode,
  //   'SPKPlanningDetID':   spkPlanningDetID,
  //   'FType':              fType,
  //   'PktValid':           pktValid,
  //   'InValidReason':      inValidReason,
  //   'OldPartName':        oldPartName,
  //   'Old_PartName':       oldPartName2,
  //   'Old_SPKPlanningDetID': oldSpkPlanningDetID,
  //   'FluoCode':           fluoCode,
  //   'QRCode':             qrCode,
  //   'OrderMstID':         orderMstID,
  //   'Length':             length,
  // };
  Map<String, dynamic> toJson() => {
    // ── Master link ──────────────────────────────────────────────────────────
    if (packetMstID != null) 'PacketMstID': packetMstID,

    // ── Lot identity (form se aata hai) ──────────────────────────────────────
    if (cutNo    != null) 'CutNo':   cutNo,
    if (lotNo    != null) 'LotNo':   lotNo,
    if (lotCode  != null) 'LotCode': lotCode,   // default 'A' already set in model
    if (srno     != null) 'Srno':    srno,
    'CharniCode':         charniCode,
    // ── Piece & Weight (form se) ──────────────────────────────────────────────
    if (pc != null) 'Pc': pc,
    if (wt != null) 'Wt': wt,

    // ── Type / Grading (form dropdowns) ──────────────────────────────────────
    if (pktType      != null && pktType!.isNotEmpty)  'PKTType':      pktType,
    if (colorCode    != null) 'ColorCode':    colorCode,
    if (tensionsCode != null) 'TensionsCode': tensionsCode,
    if (fluoCode     != null) 'FluoCode':     fluoCode,

    // ── Optional form fields (agar entry screen se aayein) ───────────────────
    'PurityCode':            (purityCode   == null || purityCode   == 0) ? 1 : purityCode,
    'ShapeCode':             (shapeCode    == null || shapeCode    == 0) ? 1 : shapeCode,

    // if (shapeCode  != null) 'ShapeCode':  shapeCode,
    if (charniCode != null) 'CharniCode': charniCode,
    if (pDmPer     != null) 'PDmPer':     pDmPer,
    if (pDmWt      != null) 'PDmWt':      pDmWt,
    if (remarksCode!= null) 'RemarksCode':remarksCode,
    if (orderMstID != null && orderMstID! > 0) 'OrderMstID': orderMstID,

    // ── Audit / process fields (screen mein set hote hain) ───────────────────
    if (entryType   != null) 'EntryType':   entryType,
    if (lastProcess != null) 'LastProcess': lastProcess,
    if (packetDate  != null) 'PacketDate':  packetDate,
    if (pktValid    != null) 'PktValid':    pktValid,
    if (jno         != null) 'Jno':         jno,
    if (logID       != null) 'LogID':       logID,
    if (pcID        != null) 'PcID':        pcID,

    // ── Edit-only: PacketDetID bhejo taaki UPDATE sahi row pe lage ───────────
    if (packetDetID != null) 'PacketDetID': packetDetID,
  };
  static double? _d(dynamic v) {
    if (v == null) return null;
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
    'entryType':   entryType  ?? '',
    'slType':      slType     ?? '',
    'totalWt':     totalWt.toStringAsFixed(3),
    'totalPc':     totalPc.toString(),
    '_raw': this,
  };
}