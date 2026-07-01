// lib/utils/report_registry.dart

import 'package:diam_mfg/models/ReportConfig.dart';
import 'package:diam_mfg/utils/constants.dart';

class ReportRegistry {
  static final Map<String, ReportConfig> _configs = {
    // ── ROUGH DETAIL ─────────────────────────────────────────────────────── 1
    'ROUGH_DETAIL': ReportConfig(
      reportTypeCode: 'ROUGH_DETAIL',
      endpoint: '/reports/rough-detail',
      columns: const [
        ReportColumnDef(
          key: 'mstID',
          label: 'Mst ID',
          width: 120,
          required: true,
        ),
        ReportColumnDef(key: 'date', label: 'Date', width: 140, isDate: true),
        ReportColumnDef(key: 'time', label: 'Time', width: 140),
        ReportColumnDef(key: 'jno', label: 'Jno', width: 120),
        ReportColumnDef(key: 'kapanNo', label: 'Kapan No', width: 160),
        ReportColumnDef(key: 'mainCutNo', label: 'Main Cut No', width: 180),
        ReportColumnDef(key: 'site', label: 'Site', width: 140),
        ReportColumnDef(key: 'partyName', label: 'Party Name', width: 180),
        ReportColumnDef(key: 'roughTypeName', label: 'Rough Type', width: 180),
        ReportColumnDef(key: 'articalName', label: 'Artical Name', width: 180),
        ReportColumnDef(
          key: 'jangadCharniName',
          label: 'Jangad Charni Name',
          width: 200,
        ),
        ReportColumnDef(key: 'charniName', label: 'Charni Name', width: 180),
        ReportColumnDef(key: 'pc', label: 'Pc', width: 120),
        ReportColumnDef(key: 'wt', label: 'Wt', width: 120),
        ReportColumnDef(key: 'per', label: 'Per', width: 120),
        ReportColumnDef(key: 'dueDay', label: 'Due Day', width: 140),
        ReportColumnDef(
          key: 'dueDate',
          label: 'Due Date',
          width: 160,
          isDate: true,
        ),
        ReportColumnDef(key: 'remarks', label: 'Remarks', width: 160),
      ],
      mapper: (raw) => raw
          .map(
            (e) => {
              'mstID': '${e['MstID'] ?? '-'}',
              'date': e['Date'] ?? '-',
              'time': e['Time'] ?? '-',
              'jno': '${e['Jno'] ?? '-'}',
              'kapanNo': e['KapanNo'] ?? '-',
              'mainCutNo': e['MainCutNo'] ?? '-',
              'site': e['Site'] ?? '-',
              'partyName': e['PartyName'] ?? '-',
              'roughTypeName': e['RoughTypeName'] ?? '-',
              'articalName': e['ArticalName'] ?? '-',
              'jangadCharniName': e['JangadCharniName'] ?? '-',
              'charniName': e['CharniName'] ?? '-',
              'pc': '${e['Pc'] ?? 0}',
              'wt': formatDecimal(e['Wt'], decimal: 3),
              'per': formatDecimal(e['Per'], decimal: 2),
              'dueDay': '${e['DueDay'] ?? '-'}',
              'dueDate': e['DueDate'] ?? '-',
              'remarks': e['Remarks'] ?? '-',
            },
          )
          .toList(),
    ),

    // ── ROUGH REPORT ─────────────────────────────────────────────────────── 2
    'ROUGH_REPORT': ReportConfig(
      reportTypeCode: 'ROUGH_REPORT',
      endpoint: '/reports/rough-report',
      columns: const [
        ReportColumnDef(key: 'kapanNo', label: 'Kapan No', width: 160),
        ReportColumnDef(key: 'jno', label: 'Jno', width: 120),
        ReportColumnDef(key: 'wt', label: 'Wt', width: 120),
        ReportColumnDef(key: 'issWt', label: 'Iss Wt', width: 140),
        ReportColumnDef(key: 'pendWt', label: 'Pend Wt', width: 160),
      ],
      mapper: (raw) => raw
          .map(
            (e) => {
              'kapanNo': '${e['KapanNo'] ?? '-'}',
              'jno': e['Jno'] ?? '-',
              'wt': formatDecimal(e['Wt'], decimal: 3),
              'issWt': formatDecimal(e['IssWt'], decimal: 3),
              'pendWt': formatDecimal(e['PendWt'], decimal: 3),
            },
          )
          .toList(),
    ),

    // ── CUT CREATE DETAIL ─────────────────────────────────────────────────────── 3
    'CUT_CREATE_DETAIL': ReportConfig(
      reportTypeCode: 'CUT_CREATE_DETAIL',
      endpoint: '/reports/cutcreate-detail-report',
      columns: const [
        ReportColumnDef(key: 'MstID', label: 'Mst ID', width: 140),
        ReportColumnDef(key: 'Date', label: 'Date', width: 140),
        ReportColumnDef(key: 'Time', label: 'Time', width: 140),

        ReportColumnDef(key: 'Jno', label: 'Jno', width: 120),

        ReportColumnDef(key: 'KapanNo', label: 'Kapan No', width: 140),

        ReportColumnDef(key: 'CutType', label: 'Cut Type', width: 140),
        ReportColumnDef(key: 'CutNo', label: 'Cut No', width: 140),
        ReportColumnDef(key: 'ClvCut', label: 'Clv Cut', width: 140),
        ReportColumnDef(key: 'MfgCut', label: 'Mfg Cut', width: 140),

        ReportColumnDef(key: 'Pc', label: 'Pc', width: 120),
        ReportColumnDef(key: 'Wt', label: 'Wt', width: 120),

        ReportColumnDef(key: 'WtLoss', label: 'Wt Loss', width: 140),
        ReportColumnDef(key: 'Out', label: 'Out', width: 140),

        ReportColumnDef(key: 'PurityName', label: 'Purity', width: 140),
        ReportColumnDef(key: 'Manager', label: 'Manager', width: 180),

        ReportColumnDef(key: 'Finish', label: 'Finish', width: 120),
        ReportColumnDef(key: 'FinishDate', label: 'Finish Date', width: 160),
      ],
      mapper: (raw) => raw.map((e) => {
        'MstID': '${e['MstID'] ?? 0}',

        'Date': formatDate(e['Date']),
        'Time': e['Time'] ?? '-',

        'Jno': '${e['Jno'] ?? 0}',

        'KapanNo': e['KapanNo'] ?? '-',

        'CutType': e['CutType'] ?? '-',
        'CutNo': e['CutNo'] ?? '-',
        'ClvCut': e['ClvCut'] ?? '-',
        'MfgCut': e['MfgCut'] ?? '-',

        'Pc': formatDecimal(e['Pc'], decimal: 0),
        'Wt': formatDecimal(e['Wt'], decimal: 3),

        'WtLoss': formatDecimal(e['WtLoss'], decimal: 3),
        'Out': e['Out'] ?? '-',

        'PurityName': e['PurityName'] ?? '-',
        'Manager': e['Manager'] ?? '-',

        'Finish': e['Finish'] ?? '-',
        'FinishDate': formatDate(e['FinishDate']),
      }).toList(),
    ),

    // ── KAPAN STOCK ─────────────────────────────────────────────────────── 4
    'KAPAN_STOCK': ReportConfig(
      reportTypeCode: 'KAPAN_STOCK',
      endpoint: '/reports/kapan-stock',
      columns: const [
        ReportColumnDef(key: 'kapanNo', label: 'Kapan No', width: 140),
        ReportColumnDef(key: 'semiPc', label: 'Semi Pc', width: 140),
        ReportColumnDef(key: 'semiWt', label: 'Semi Wt', width: 140),
        ReportColumnDef(key: 'cutPc', label: 'Cut Pc', width: 140),
        ReportColumnDef(key: 'cutWt', label: 'Cut Wt', width: 140),
        ReportColumnDef(key: 'pendPc', label: 'Pending Pc', width: 160),
        ReportColumnDef(key: 'pendWt', label: 'Pending Wt', width: 160),
      ],
      mapper: (raw) => raw
          .map(
            (e) => {
              'kapanNo': '${e['KapanNo'] ?? '-'}',
              'semiPc': formatDecimal(e['SemiPc'], decimal: 0),
              'cutPc': formatDecimal(e['CutPc'], decimal: 0),
              'semiWt': formatDecimal(e['SemiWt'], decimal: 3),
              'cutWt': formatDecimal(e['CutWt'], decimal: 3),
              'pendWt': formatDecimal(e['PendWt'], decimal: 3),
              'pendPc': formatDecimal(e['PendPc'], decimal: 0),
            },
          )
          .toList(),
    ),


    // ── PACKET DETAIL ─────────────────────────────────────────────────────── 6
    'PACKET_DETAIL': ReportConfig(
      reportTypeCode: 'PACKET_DETAIL',
      endpoint: '/reports/packet-detail',
      columns: const [
        ReportColumnDef(
          key: 'mstID',
          label: 'Mst ID',
          width: 120,
          required: true,
        ),
        ReportColumnDef(key: 'date', label: 'Date', width: 120, isDate: true),
        ReportColumnDef(key: 'time', label: 'Time', width: 120),
        ReportColumnDef(key: 'cutNo', label: 'Cut No', width: 140),
        ReportColumnDef(key: 'clvCut', label: 'Clv Cut', width: 140),
        ReportColumnDef(key: 'bCode', label: 'B Code', width: 140),
        ReportColumnDef(key: 'pktNo', label: 'Pkt No', width: 140),
        ReportColumnDef(key: 'pc', label: 'Pc', width: 140),
        ReportColumnDef(key: 'wt', label: 'Wt', width: 140),
        ReportColumnDef(key: 'type', label: 'Type', width: 160),
        ReportColumnDef(key: 'colorName', label: 'Color', width: 160),
        ReportColumnDef(key: 'tensionsName', label: 'Tension', width: 160),
        ReportColumnDef(key: 'pktType', label: 'Pkt Type', width: 160),
        ReportColumnDef(key: 'toMan', label: 'To Man', width: 160),
      ],
      mapper: (raw) => raw
          .map(
            (e) => {
              'mstID': '${e['MstID'] ?? '-'}',
              'date': e['Date'] ?? '-',
              'time': e['Time'] ?? '-',
              'cutNo': e['CutNo'] ?? '-',
              'clvCut': e['ClvCut'] ?? '-',
              'bCode': '${e['BCode'] ?? '-'}',
              'pktNo': e['PktNo'] ?? '-',
              'pc': '${e['Pc'] ?? 0}',
              'wt': formatDecimal(e['Wt'], decimal: 3),
              'type': e['Type'] ?? '-',
              'colorName': e['ColorName'] ?? '-',
              'tensionsName': e['TensionsName'] ?? '-',
              'pktType': e['PKTType'] ?? '-',
              'toMan': e['ToMan'] ?? '-',
            },
          )
          .toList(),
    ),

    // ── PACKET STOCK ─────────────────────────────────────────────────────── 7
    'PACKET_STOCK': ReportConfig(
      reportTypeCode: 'PACKET_STOCK',
      endpoint: '/reports/packet-stock',
      columns: const [
        ReportColumnDef(
          key: 'mstID',
          label: 'Mst ID',
          width: 120,
          required: true,
        ),
        ReportColumnDef(key: 'date', label: 'Date', width: 120, isDate: true),
        ReportColumnDef(key: 'time', label: 'Time', width: 120),
        ReportColumnDef(key: 'cutNo', label: 'Cut No', width: 140),
        ReportColumnDef(key: 'clvCut', label: 'Clv Cut', width: 140),
        ReportColumnDef(key: 'bCode', label: 'B Code', width: 140),
        ReportColumnDef(key: 'mainBCode', label: 'Main B Code', width: 180),
        ReportColumnDef(key: 'pktNo', label: 'Pkt No', width: 140),
        ReportColumnDef(key: 'pc', label: 'Pc', width: 120),
        ReportColumnDef(key: 'wt', label: 'Wt', width: 120),
        ReportColumnDef(key: 'dmWt', label: 'Dm Wt', width: 140),
        ReportColumnDef(key: 'dmPer', label: 'Dm Per', width: 140),
        ReportColumnDef(key: 'size', label: 'Size', width: 140),
        ReportColumnDef(key: 'fromMan', label: 'From Man', width: 160),
        ReportColumnDef(key: 'toMan', label: 'To Man', width: 140),
        ReportColumnDef(key: 'toDept', label: 'To Dept', width: 140),
        ReportColumnDef(key: 'type', label: 'Type', width: 140),
        ReportColumnDef(key: 'colorName', label: 'Color', width: 140),
        ReportColumnDef(key: 'purityName', label: 'Purity', width: 140),
        ReportColumnDef(key: 'shapeName', label: 'Shape', width: 140),
        ReportColumnDef(key: 'charniName', label: 'Charni', width: 140),
        ReportColumnDef(key: 'tensionsName', label: 'Tension', width: 140),
        ReportColumnDef(key: 'pktType', label: 'Pkt Type', width: 160),
        ReportColumnDef(key: 'entryType', label: 'Entry Type', width: 160),
        ReportColumnDef(key: 'remarksName', label: 'Remarks', width: 160),
      ],
      mapper: (raw) => raw
          .map(
            (e) => {
              'mstID': '${e['MstID'] ?? '-'}',
              'date': e['Date'] ?? '-',
              'time': e['Time'] ?? '-',
              'cutNo': e['CutNo'] ?? '-',
              'clvCut': e['ClvCut'] ?? '-',
              'bCode': '${e['BCode'] ?? '-'}',
              'mainBCode': '${e['MainBCode'] ?? '-'}',
              'pktNo': e['PktNo'] ?? '-',
              'pc': '${e['Pc'] ?? 0}',
              'wt': formatDecimal(e['Wt'], decimal: 3),
              'dmWt': formatDecimal(e['DmWt'], decimal: 3),
              'dmPer': formatDecimal(e['DmPer'], decimal: 2),
              'size': formatDecimal(e['Size'], decimal: 2),
              'fromMan': e['FromMan'] ?? '-',
              'toMan': e['ToMan'] ?? '-',
              'toDept': e['ToDept'] ?? '-',
              'type': e['Type'] ?? '-',
              'colorName': e['ColorName'] ?? '-',
              'purityName': e['PurityName'] ?? '-',
              'shapeName': e['ShapeName'] ?? '-',
              'charniName': e['CharniName'] ?? '-',
              'tensionsName': e['TensionsName'] ?? '-',
              'pktType': e['PKTType'] ?? '-',
              'entryType': e['EntryType'] ?? '-',
              'remarksName': e['RemarksName'] ?? '-',
            },
          )
          .toList(),
    ),

    // ── PACKET SUMMARY ─────────────────────────────────────────────────────── 8
    'PACKET_DATE_AND_ID_SUMMARY': ReportConfig(
      reportTypeCode: 'PACKET_DATE_AND_ID_SUMMARY',
      endpoint: '/reports/packet-summary',
      columns: const [
        ReportColumnDef(
          key: 'mstID',
          label: 'Mst ID',
          width: 120,
          required: true,
        ),
        ReportColumnDef(key: 'date', label: 'Date', width: 140, isDate: true),
        ReportColumnDef(key: 'cutNo', label: 'Cut No', width: 140),
        ReportColumnDef(key: 'kapanNo', label: 'Kapan No', width: 140),
        ReportColumnDef(key: 'pkt', label: 'Pkt', width: 120),
        ReportColumnDef(key: 'pc', label: 'Pc', width: 120),
        ReportColumnDef(key: 'wt', label: 'Wt', width: 120),
        ReportColumnDef(key: 'users', label: 'Users', width: 140),
      ],
      mapper: (raw) => raw
          .map(
            (e) => {
              'mstID': '${e['MstID'] ?? '-'}',
              'date': e['Date'] ?? '-',
              'cutNo': e['CutNo'] ?? '-',
              'kapanNo': e['KapanNo'] ?? '-',
              'pkt': '${e['Pkt'] ?? 0}',
              'pc': '${e['Pc'] ?? 0}',
              'wt': formatDecimal(e['Wt'], decimal: 3),
              'users': e['Users'] ?? '-',
            },
          )
          .toList(),
    ),

    // ── MANAGER WISE STOCK SUMMARY ─────────────────────────────────────────────────────── 9
    'MANAGERWISE_STOCK_SUMMARY': ReportConfig(
      reportTypeCode: 'MANAGERWISE_STOCK_SUMMARY',
      endpoint: '/reports/packet-managerwise-summary',
      columns: const [
        ReportColumnDef(key: 'kapanNo', label: 'Kapan No', width: 160),
        ReportColumnDef(key: 'cutNo', label: 'Cut No', width: 140),
        ReportColumnDef(key: 'toMan', label: 'To Man', width: 140),
        ReportColumnDef(key: 'wt', label: 'Wt', width: 120),
        ReportColumnDef(key: 'pkt', label: 'Pkt', width: 120),
        ReportColumnDef(key: 'pc', label: 'Pc', width: 120),
      ],
      mapper: (raw) => raw
          .map(
            (e) => {
              'kapanNo': '${e['KapanNo'] ?? '-'}',
              'cutNo': e['CutNo'] ?? '-',
              'toMan': e['ToMan'] ?? '-',
              'pkt': e['Pkt'] ?? '-',
              'wt': formatDecimal(e['Wt'], decimal: 3),
              'pc': formatDecimal(e['Pc'], decimal: 0),
            },
          )
          .toList(),
    ),

    // ── DEPT ISS DETAIL ─────────────────────────────────────────────────────── 10
    'DEPT_ISS_DETAIL': ReportConfig(
      reportTypeCode: 'DEPT_ISS_DETAIL',
      endpoint: '/reports/dept-iss-detail',
      columns: const [
        ReportColumnDef(key: 'MstID', label: 'Mst ID', width: 140),
        ReportColumnDef(key: 'Date', label: 'Date', width: 140),
        ReportColumnDef(key: 'Time', label: 'Time', width: 120),
        ReportColumnDef(key: 'FormType', label: 'Form Type', width: 160),
        ReportColumnDef(key: 'FromMan', label: 'From Man', width: 160),
        ReportColumnDef(key: 'ToMan', label: 'To Man', width: 160),
        ReportColumnDef(
          key: 'DeptProcessName',
          label: 'Dept Process',
          width: 180,
        ),
        ReportColumnDef(key: 'DeptName', label: 'Dept Name', width: 160),
        ReportColumnDef(key: 'CutMan', label: 'Cut Man', width: 160),
        ReportColumnDef(key: 'Signer', label: 'Signer', width: 140),
        ReportColumnDef(key: 'CheckerMan', label: 'Checker Man', width: 180),
        ReportColumnDef(key: 'SignerMan', label: 'Signer Man', width: 160),
        ReportColumnDef(key: 'BCode', label: 'Kapan No', width: 160),
        ReportColumnDef(key: 'PktNo', label: 'Pkt No', width: 140),
        ReportColumnDef(key: 'CutNo', label: 'Cut No', width: 140),
        ReportColumnDef(key: 'Wt', label: 'Wt', width: 120),
        ReportColumnDef(key: 'Pc', label: 'Pc', width: 120),
        ReportColumnDef(key: 'LossWt', label: 'Loss Wt', width: 140),
        ReportColumnDef(key: 'LossPer', label: 'Loss %', width: 140),
        ReportColumnDef(key: 'RemarksName', label: 'Remarks', width: 180),
      ],

      mapper: (raw) => raw
          .map(
            (e) => {
              'MstID': e['MstID'] ?? '-',
              'Date': formatDate(e['Date']),
              'Time': e['Time'] ?? '-',
              'FormType': e['FormType'] ?? '-',
              'FromMan': e['FromMan'] ?? '-',
              'ToMan': e['ToMan'] ?? '-',
              'DeptProcessName': e['DeptProcessName'] ?? '-',
              'DeptName': e['DeptName'] ?? '-',
              'CutMan': e['CutMan'] ?? '-',
              'Signer': e['Signer'] ?? '-',
              'CheckerMan': e['CheckerMan'] ?? '-',
              'SignerMan': e['SignerMan'] ?? '-',
              'BCode': e['BCode'] ?? '-',
              'PktNo': e['PktNo'] ?? '-',
              'CutNo': e['CutNo'] ?? '-',
              'Wt': formatDecimal(e['Wt'], decimal: 3),
              'Pc': formatDecimal(e['Pc'], decimal: 0),
              'LossWt': formatDecimal(e['LossWt'], decimal: 3),
              'LossPer': formatDecimal(e['LossPer'], decimal: 2),
              'RemarksName': e['RemarksName'] ?? '-',
            },
          )
          .toList(),
    ),

    // ── DEPT ISS ID WISE SUMMARY ─────────────────────────────────────────────────────── 11
    'DEPT_ISS_IDWISE_SUMMARY': ReportConfig(
      reportTypeCode: 'DEPT_ISS_IDWISE_SUMMARY',
      endpoint: '/reports/dept-iss-idwise-summary',
      columns: const [
        ReportColumnDef(key: 'MstID', label: 'Mst ID', width: 140),
        ReportColumnDef(key: 'Date', label: 'Date', width: 140),
        ReportColumnDef(key: 'Time', label: 'Time', width: 120),
        ReportColumnDef(key: 'FromMan', label: 'From Man', width: 160),
        ReportColumnDef(key: 'ToMan', label: 'To Man', width: 160),
        ReportColumnDef(
          key: 'DeptProcessName',
          label: 'Dept Process',
          width: 180,
        ),
        ReportColumnDef(key: 'DeptName', label: 'Dept Name', width: 160),

        // 🔥 Actual fields from API
        ReportColumnDef(key: 'CutNo', label: 'Cut No', width: 140),
        ReportColumnDef(key: 'TotPkt', label: 'Tot Pkt', width: 140),
        ReportColumnDef(key: 'Pc', label: 'Pc', width: 120),
        ReportColumnDef(key: 'Wt', label: 'Wt', width: 120),
        ReportColumnDef(key: 'IssPc', label: 'Iss Pc', width: 140),
        ReportColumnDef(key: 'IssWt', label: 'Iss Wt', width: 140),
        ReportColumnDef(key: 'RecPc', label: 'Rec Pc', width: 140),
        ReportColumnDef(key: 'RecWt', label: 'Rec Wt', width: 140),
        ReportColumnDef(key: 'DmWt', label: 'DM Wt', width: 140),
        ReportColumnDef(key: 'DmPer', label: 'DM %', width: 140),
        ReportColumnDef(key: 'RecPer', label: 'Rec %', width: 140),
        ReportColumnDef(key: 'DiffPer', label: 'Diff %', width: 140),
        ReportColumnDef(key: 'LossWt', label: 'Loss Wt', width: 140),
        ReportColumnDef(key: 'LossPer', label: 'Loss %', width: 140),
        ReportColumnDef(key: 'RemarksName', label: 'Remarks', width: 180),
      ],

      mapper: (raw) => raw
          .map(
            (e) => {
              'MstID': e['MstID'] ?? '-',
              'Date': formatDate(e['Date']),
              'Time': e['Time'] ?? '-',
              'FromMan': e['FromMan'] ?? '-',
              'ToMan': e['ToMan'] ?? '-',
              'DeptProcessName': e['DeptProcessName'] ?? '-',
              'DeptName': e['DeptName'] ?? '-',

              // 🔥 Correct mapping (only API keys)
              'CutNo': e['CutNo'] ?? '-',
              'TotPkt': e['TotPkt'] ?? '-',
              'Pc': formatDecimal(e['Pc'], decimal: 0),
              'Wt': formatDecimal(e['Wt'], decimal: 3),
              'IssPc': formatDecimal(e['IssPc'], decimal: 0),
              'IssWt': formatDecimal(e['IssWt'], decimal: 3),
              'RecPc': formatDecimal(e['RecPc'], decimal: 0),
              'RecWt': formatDecimal(e['RecWt'], decimal: 3),
              'DmWt': formatDecimal(e['DmWt'], decimal: 3),
              'DmPer': formatDecimal(e['DmPer'], decimal: 2),
              'RecPer': formatDecimal(e['RecPer'], decimal: 2),
              'DiffPer': formatDecimal(e['DiffPer'], decimal: 2),
              'LossWt': formatDecimal(e['LossWt'], decimal: 3),
              'LossPer': formatDecimal(e['LossPer'], decimal: 2),
              'RemarksName': e['RemarksName'] ?? '-',
            },
          )
          .toList(),
    ),

    // ── DEPT ISS DETAIL [CONFIRM] ─────────────────────────────────────────────────────── 12
    'DEPT_ISS_DETAIL_[CONFIRM]': ReportConfig(
      reportTypeCode: 'DEPT_ISS_DETAIL_[CONFIRM]',
      endpoint: '/reports/dept-iss-details-confirm',
      columns: const [
        ReportColumnDef(key: 'MstID', label: 'Mst ID', width: 140),
        ReportColumnDef(key: 'Date', label: 'Date', width: 140),
        ReportColumnDef(key: 'Time', label: 'Time', width: 140),
        ReportColumnDef(key: 'FormType', label: 'Form Type', width: 160),
        ReportColumnDef(key: 'FromMan', label: 'From Man', width: 160),
        ReportColumnDef(key: 'ToMan', label: 'To Man', width: 160),
        ReportColumnDef(
          key: 'DeptProcessName',
          label: 'Dept Process',
          width: 180,
        ),
        ReportColumnDef(key: 'DeptName', label: 'Dept Name', width: 160),
        ReportColumnDef(key: 'CutMan', label: 'Cut Man', width: 140),
        ReportColumnDef(key: 'Signer', label: 'Signer', width: 140),
        ReportColumnDef(key: 'CheckerMan', label: 'Checker Man', width: 160),
        ReportColumnDef(key: 'SignerMan', label: 'Signer Man', width: 160),

        // 🔥 Actual fields
        ReportColumnDef(key: 'BCode', label: 'Kapan No', width: 160),
        ReportColumnDef(key: 'PktNo', label: 'Pkt No', width: 140),
        ReportColumnDef(key: 'CutNo', label: 'Cut No', width: 140),

        ReportColumnDef(key: 'Pc', label: 'Pc', width: 120),
        ReportColumnDef(key: 'Wt', label: 'Wt', width: 120),
        ReportColumnDef(key: 'IssPc', label: 'Iss Pc', width: 140),
        ReportColumnDef(key: 'IssWt', label: 'Iss Wt', width: 140),
        ReportColumnDef(key: 'RecPc', label: 'Rec Pc', width: 140),
        ReportColumnDef(key: 'RecWt', label: 'Rec Wt', width: 140),

        ReportColumnDef(key: 'DmWt', label: 'DM Wt', width: 140),
        ReportColumnDef(key: 'DmPer', label: 'DM %', width: 140),
        ReportColumnDef(key: 'RecPer', label: 'Rec %', width: 140),
        ReportColumnDef(key: 'DiffPer', label: 'Diff %', width: 140),

        ReportColumnDef(key: 'LossWt', label: 'Loss Wt', width: 140),
        ReportColumnDef(key: 'LossPer', label: 'Loss %', width: 140),

        ReportColumnDef(key: 'PurityName', label: 'Purity', width: 140),
        ReportColumnDef(key: 'CharniName', label: 'Charni', width: 140),
        ReportColumnDef(key: 'RemarksName', label: 'Remarks', width: 180),
      ],

      mapper: (raw) => raw
          .map(
            (e) => {
              'MstID': e['MstID'] ?? '-',
              'Date': formatDate(e['Date']),
              'Time': e['Time'] ?? '-',
              'FormType': e['FormType'] ?? '-',
              'FromMan': e['FromMan'] ?? '-',
              'ToMan': e['ToMan'] ?? '-',
              'DeptProcessName': e['DeptProcessName'] ?? '-',
              'DeptName': e['DeptName'] ?? '-',
              'CutMan': e['CutMan'] ?? '-',
              'Signer': e['Signer'] ?? '-',
              'CheckerMan': e['CheckerMan'] ?? '-',
              'SignerMan': e['SignerMan'] ?? '-',

              'BCode': e['BCode'] ?? '-',
              'PktNo': e['PktNo'] ?? '-',
              'CutNo': e['CutNo'] ?? '-',

              'Pc': formatDecimal(e['Pc'], decimal: 0),
              'Wt': formatDecimal(e['Wt'], decimal: 3),
              'IssPc': formatDecimal(e['IssPc'], decimal: 0),
              'IssWt': formatDecimal(e['IssWt'], decimal: 3),
              'RecPc': formatDecimal(e['RecPc'], decimal: 0),
              'RecWt': formatDecimal(e['RecWt'], decimal: 3),

              'DmWt': formatDecimal(e['DmWt'], decimal: 3),
              'DmPer': formatDecimal(e['DmPer'], decimal: 2),
              'RecPer': formatDecimal(e['RecPer'], decimal: 2),
              'DiffPer': formatDecimal(e['DiffPer'], decimal: 2),

              'LossWt': formatDecimal(e['LossWt'], decimal: 3),
              'LossPer': formatDecimal(e['LossPer'], decimal: 2),

              'PurityName': e['PurityName'] ?? '-',
              'CharniName': e['CharniName'] ?? '-',
              'RemarksName': e['RemarksName'] ?? '-',
            },
          )
          .toList(),
    ),

    // ── DEPT ISS ID WISE SUMMARY [CONFIRM] ─────────────────────────────────────────────────────── 13
    'DEPT_ISS_IDWISE_SUMMARY_[CONFIRM]': ReportConfig(
      reportTypeCode: 'DEPT_ISS_IDWISE_SUMMARY_[CONFIRM]',
      endpoint: '/reports/dept-iss-idwise-summary-confirm',
      columns: const [
        ReportColumnDef(key: 'MstID', label: 'Mst ID', width: 140),
        ReportColumnDef(key: 'Date', label: 'Date', width: 140),
        ReportColumnDef(key: 'Time', label: 'Time', width: 120),
        ReportColumnDef(key: 'FromMan', label: 'From Man', width: 160),
        ReportColumnDef(key: 'ToMan', label: 'To Man', width: 160),
        ReportColumnDef(
          key: 'DeptProcessName',
          label: 'Dept Process',
          width: 180,
        ),
        ReportColumnDef(key: 'DeptName', label: 'Dept Name', width: 160),

        // 🔥 Actual API fields
        ReportColumnDef(key: 'CutNo', label: 'Cut No', width: 140),
        ReportColumnDef(key: 'TotPkt', label: 'Tot Pkt', width: 140),

        ReportColumnDef(key: 'Pc', label: 'Pc', width: 120),
        ReportColumnDef(key: 'Wt', label: 'Wt', width: 120),

        ReportColumnDef(key: 'IssPc', label: 'Iss Pc', width: 140),
        ReportColumnDef(key: 'IssWt', label: 'Iss Wt', width: 140),

        ReportColumnDef(key: 'RecPc', label: 'Rec Pc', width: 140),
        ReportColumnDef(key: 'RecWt', label: 'Rec Wt', width: 140),

        ReportColumnDef(key: 'DmWt', label: 'DM Wt', width: 140),
        ReportColumnDef(key: 'DmPer', label: 'DM %', width: 140),

        ReportColumnDef(key: 'RecPer', label: 'Rec %', width: 140),
        ReportColumnDef(key: 'DiffPer', label: 'Diff %', width: 140),

        ReportColumnDef(key: 'LossWt', label: 'Loss Wt', width: 140),
        ReportColumnDef(key: 'LossPer', label: 'Loss %', width: 140),

        ReportColumnDef(key: 'RemarksName', label: 'Remarks', width: 180),
      ],

      mapper: (raw) => raw
          .map(
            (e) => {
              'MstID': e['MstID'] ?? '-',
              'Date': formatDate(e['Date']),
              'Time': e['Time'] ?? '-',
              'FromMan': e['FromMan'] ?? '-',
              'ToMan': e['ToMan'] ?? '-',
              'DeptProcessName': e['DeptProcessName'] ?? '-',
              'DeptName': e['DeptName'] ?? '-',

              'CutNo': e['CutNo'] ?? '-',
              'TotPkt': e['TotPkt'] ?? '-',

              'Pc': formatDecimal(e['Pc'], decimal: 0),
              'Wt': formatDecimal(e['Wt'], decimal: 3),

              'IssPc': formatDecimal(e['IssPc'], decimal: 0),
              'IssWt': formatDecimal(e['IssWt'], decimal: 3),

              'RecPc': formatDecimal(e['RecPc'], decimal: 0),
              'RecWt': formatDecimal(e['RecWt'], decimal: 3),

              'DmWt': formatDecimal(e['DmWt'], decimal: 3),
              'DmPer': formatDecimal(e['DmPer'], decimal: 2),

              'RecPer': formatDecimal(e['RecPer'], decimal: 2),
              'DiffPer': formatDecimal(e['DiffPer'], decimal: 2),

              'LossWt': formatDecimal(e['LossWt'], decimal: 3),
              'LossPer': formatDecimal(e['LossPer'], decimal: 2),

              'RemarksName': e['RemarksName'] ?? '-',
            },
          )
          .toList(),
    ),

    // ── ISS CUT WISE SUMMARY ─────────────────────────────────────────────────────── 14
    'ISS_CUTWISE_SUMMARY': ReportConfig(
      reportTypeCode: 'ISS_CUTWISE_SUMMARY',
      endpoint: '/reports/dept-iss-cutwise-summary',
      columns: const [
        ReportColumnDef(key: 'CutNo', label: 'Cut No', width: 140),
        ReportColumnDef(key: 'Pkt', label: 'Pkt', width: 120),

        ReportColumnDef(key: 'Pc', label: 'Pc', width: 120),
        ReportColumnDef(key: 'Wt', label: 'Wt', width: 120),

        ReportColumnDef(key: 'IssPc', label: 'Iss Pc', width: 140),
        ReportColumnDef(key: 'IssWt', label: 'Iss Wt', width: 140),

        ReportColumnDef(key: 'RecPc', label: 'Rec Pc', width: 140),
        ReportColumnDef(key: 'RecWt', label: 'Rec Wt', width: 140),

        ReportColumnDef(key: 'DmWt', label: 'DM Wt', width: 140),
        ReportColumnDef(key: 'DmPer', label: 'DM %', width: 140),

        ReportColumnDef(key: 'RecPer', label: 'Rec %', width: 140),

        ReportColumnDef(key: 'KPc', label: 'K Pc', width: 140),
        ReportColumnDef(key: 'KWt', label: 'K Wt', width: 140),

        ReportColumnDef(key: 'BrPc', label: 'Br Pc', width: 140),
        ReportColumnDef(key: 'BrWt', label: 'Br Wt', width: 140),

        ReportColumnDef(key: 'LossPc', label: 'Loss Pc', width: 140),
        ReportColumnDef(key: 'LossWt', label: 'Loss Wt', width: 140),

        ReportColumnDef(key: 'TopsPc', label: 'Tops Pc', width: 140),
        ReportColumnDef(key: 'TopsWt', label: 'Tops Wt', width: 140),
      ],

      mapper: (raw) => raw
          .map(
            (e) => {
              'CutNo': e['CutNo'] ?? '-',
              'Pkt': formatDecimal(e['Pkt'], decimal: 0),

              'Pc': formatDecimal(e['Pc'], decimal: 0),
              'Wt': formatDecimal(e['Wt'], decimal: 3),

              'IssPc': formatDecimal(e['IssPc'], decimal: 0),
              'IssWt': formatDecimal(e['IssWt'], decimal: 3),

              'RecPc': formatDecimal(e['RecPc'], decimal: 0),
              'RecWt': formatDecimal(e['RecWt'], decimal: 3),

              'DmWt': formatDecimal(e['DmWt'], decimal: 3),
              'DmPer': formatDecimal(e['DmPer'], decimal: 2),

              'RecPer': formatDecimal(e['RecPer'], decimal: 2),

              'KPc': formatDecimal(e['KPc'], decimal: 0),
              'KWt': formatDecimal(e['KWt'], decimal: 3),

              'BrPc': formatDecimal(e['BrPc'], decimal: 0),
              'BrWt': formatDecimal(e['BrWt'], decimal: 3),

              'LossPc': formatDecimal(e['LossPc'], decimal: 0),
              'LossWt': formatDecimal(e['LossWt'], decimal: 3),

              'TopsPc': formatDecimal(e['TopsPc'], decimal: 0),
              'TopsWt': formatDecimal(e['TopsWt'], decimal: 3),
            },
          )
          .toList(),
    ),

    // ── ISS DEPT WISE SUMMARY ─────────────────────────────────────────────────────── 15
    'ISS_DEPTWISE_SUMMARY': ReportConfig(
      reportTypeCode: 'ISS_DEPTWISE_SUMMARY',
      endpoint: '/reports/dept-iss-deptwise-summary',
      columns: const [
        ReportColumnDef(key: 'Department', label: 'Department', width: 180),

        ReportColumnDef(key: 'Pkt', label: 'Pkt', width: 120),
        ReportColumnDef(key: 'Pc', label: 'Pc', width: 120),
        ReportColumnDef(key: 'Wt', label: 'Wt', width: 120),

        ReportColumnDef(key: 'IssPc', label: 'Iss Pc', width: 140),
        ReportColumnDef(key: 'IssWt', label: 'Iss Wt', width: 140),

        ReportColumnDef(key: 'RecPc', label: 'Rec Pc', width: 140),
        ReportColumnDef(key: 'RecWt', label: 'Rec Wt', width: 140),

        ReportColumnDef(key: 'DmWt', label: 'DM Wt', width: 140),
        ReportColumnDef(key: 'DmPer', label: 'DM %', width: 140),

        ReportColumnDef(key: 'RecPer', label: 'Rec %', width: 140),

        ReportColumnDef(key: 'KPc', label: 'K Pc', width: 140),
        ReportColumnDef(key: 'KWt', label: 'K Wt', width: 140),

        ReportColumnDef(key: 'BrPc', label: 'Br Pc', width: 140),
        ReportColumnDef(key: 'BrWt', label: 'Br Wt', width: 140),

        ReportColumnDef(key: 'LossPc', label: 'Loss Pc', width: 140),
        ReportColumnDef(key: 'LossWt', label: 'Loss Wt', width: 140),

        ReportColumnDef(key: 'TopsPc', label: 'Tops Pc', width: 140),
        ReportColumnDef(key: 'TopsWt', label: 'Tops Wt', width: 140),
      ],

      mapper: (raw) => raw
          .map(
            (e) => {
              'Department': e['Department'] ?? '-',

              'Pkt': formatDecimal(e['Pkt'], decimal: 0),
              'Pc': formatDecimal(e['Pc'], decimal: 0),
              'Wt': formatDecimal(e['Wt'], decimal: 3),

              'IssPc': formatDecimal(e['IssPc'], decimal: 0),
              'IssWt': formatDecimal(e['IssWt'], decimal: 3),

              'RecPc': formatDecimal(e['RecPc'], decimal: 0),
              'RecWt': formatDecimal(e['RecWt'], decimal: 3),

              'DmWt': formatDecimal(e['DmWt'], decimal: 3),
              'DmPer': formatDecimal(e['DmPer'], decimal: 2),

              'RecPer': formatDecimal(e['RecPer'], decimal: 2),

              'KPc': formatDecimal(e['KPc'], decimal: 0),
              'KWt': formatDecimal(e['KWt'], decimal: 3),

              'BrPc': formatDecimal(e['BrPc'], decimal: 0),
              'BrWt': formatDecimal(e['BrWt'], decimal: 3),

              'LossPc': formatDecimal(e['LossPc'], decimal: 0),
              'LossWt': formatDecimal(e['LossWt'], decimal: 3),

              'TopsPc': formatDecimal(e['TopsPc'], decimal: 0),
              'TopsWt': formatDecimal(e['TopsWt'], decimal: 3),
            },
          )
          .toList(),
    ),

    // ── ISS_MANAGERWISE_SUMMARY ─────────────────────────────────────────────────────── 16
    'ISS_MANAGERWISE_SUMMARY': ReportConfig(
      reportTypeCode: 'ISS_MANAGERWISE_SUMMARY',
      endpoint: '/reports/dept-iss-managerwise-summary',
      columns: const [
        ReportColumnDef(key: 'Manager', label: 'Manager', width: 180),

        ReportColumnDef(key: 'Pkt', label: 'Pkt', width: 120),
        ReportColumnDef(key: 'Pc', label: 'Pc', width: 120),
        ReportColumnDef(key: 'Wt', label: 'Wt', width: 120),

        ReportColumnDef(key: 'IssPc', label: 'Iss Pc', width: 140),
        ReportColumnDef(key: 'IssWt', label: 'Iss Wt', width: 140),

        ReportColumnDef(key: 'RecPc', label: 'Rec Pc', width: 140),
        ReportColumnDef(key: 'RecWt', label: 'Rec Wt', width: 140),

        ReportColumnDef(key: 'DmWt', label: 'DM Wt', width: 140),
        ReportColumnDef(key: 'DmPer', label: 'DM %', width: 140),

        ReportColumnDef(key: 'RecPer', label: 'Rec %', width: 140),

        ReportColumnDef(key: 'KPc', label: 'K Pc', width: 140),
        ReportColumnDef(key: 'KWt', label: 'K Wt', width: 140),

        ReportColumnDef(key: 'BrPc', label: 'Br Pc', width: 140),
        ReportColumnDef(key: 'BrWt', label: 'Br Wt', width: 140),

        ReportColumnDef(key: 'LossPc', label: 'Loss Pc', width: 140),
        ReportColumnDef(key: 'LossWt', label: 'Loss Wt', width: 140),

        ReportColumnDef(key: 'TopsPc', label: 'Tops Pc', width: 140),
        ReportColumnDef(key: 'TopsWt', label: 'Tops Wt', width: 140),
      ],

      mapper: (raw) => raw
          .map(
            (e) => {
              'Manager': e['Manager'] ?? '-',

              'Pkt': formatDecimal(e['Pkt'], decimal: 0),
              'Pc': formatDecimal(e['Pc'], decimal: 0),
              'Wt': formatDecimal(e['Wt'], decimal: 3),

              'IssPc': formatDecimal(e['IssPc'], decimal: 0),
              'IssWt': formatDecimal(e['IssWt'], decimal: 3),

              'RecPc': formatDecimal(e['RecPc'], decimal: 0),
              'RecWt': formatDecimal(e['RecWt'], decimal: 3),

              'DmWt': formatDecimal(e['DmWt'], decimal: 3),
              'DmPer': formatDecimal(e['DmPer'], decimal: 2),

              'RecPer': formatDecimal(e['RecPer'], decimal: 2),

              'KPc': formatDecimal(e['KPc'], decimal: 0),
              'KWt': formatDecimal(e['KWt'], decimal: 3),

              'BrPc': formatDecimal(e['BrPc'], decimal: 0),
              'BrWt': formatDecimal(e['BrWt'], decimal: 3),

              'LossPc': formatDecimal(e['LossPc'], decimal: 0),
              'LossWt': formatDecimal(e['LossWt'], decimal: 3),

              'TopsPc': formatDecimal(e['TopsPc'], decimal: 0),
              'TopsWt': formatDecimal(e['TopsWt'], decimal: 3),
            },
          )
          .toList(),
    ),

    // ── DEPT CONFIRM DETAIL ─────────────────────────────────────────────────────── 17
    'DEPT_CONFIRM_DETAIL': ReportConfig(
      reportTypeCode: 'DEPT_CONFIRM_DETAIL',
      endpoint: '/reports/dept-rec-confirm-detail',
      columns: const [
        ReportColumnDef(
          key: 'mstID',
          label: 'Mst ID',
          width: 120,
          required: true,
        ),
        ReportColumnDef(key: 'lottingID', label: 'Lotting ID', width: 160),
        ReportColumnDef(key: 'date', label: 'Date', width: 140, isDate: true),
        ReportColumnDef(key: 'time', label: 'Time', width: 120),
        ReportColumnDef(key: 'formType', label: 'Form Type', width: 180),
        ReportColumnDef(key: 'fromMan', label: 'From Man', width: 160),
        ReportColumnDef(key: 'toMan', label: 'To Man', width: 160),
        ReportColumnDef(key: 'deptProcessName', label: 'Process', width: 160),
        ReportColumnDef(key: 'deptName', label: 'Dept', width: 160),
        ReportColumnDef(key: 'cutMan', label: 'Cut Man', width: 160),
        ReportColumnDef(key: 'signer', label: 'Signer', width: 140),
        ReportColumnDef(key: 'checkerMan', label: 'Checker', width: 140),
        ReportColumnDef(key: 'signerMan', label: 'Signer Man', width: 160),
        ReportColumnDef(key: 'id', label: 'ID', width: 120),
        ReportColumnDef(key: 'jno', label: 'Jno', width: 140),
        ReportColumnDef(key: 'bCode', label: 'B Code', width: 160),
        ReportColumnDef(key: 'pktNo', label: 'Pkt No', width: 160),
        ReportColumnDef(key: 'cutNo', label: 'Cut No', width: 160),
        ReportColumnDef(key: 'clvCut', label: 'Clv Cut', width: 160),
        ReportColumnDef(key: 'pc', label: 'Pc', width: 140),
        ReportColumnDef(key: 'wt', label: 'Wt', width: 140),
        ReportColumnDef(key: 'issPc', label: 'Iss Pc', width: 140),
        ReportColumnDef(key: 'issWt', label: 'Iss Wt', width: 140),
        ReportColumnDef(key: 'recPc', label: 'Rec Pc', width: 140),
        ReportColumnDef(key: 'recWt', label: 'Rec Wt', width: 140),
        ReportColumnDef(key: 'dmWt', label: 'Dm Wt', width: 140),
        ReportColumnDef(key: 'dmPer', label: 'Dm %', width: 140),
        ReportColumnDef(key: 'recPer', label: 'Rec %', width: 140),
        ReportColumnDef(key: 'diffPer', label: 'Diff %', width: 140),
        ReportColumnDef(key: 'kPc', label: 'K Pc', width: 140),
        ReportColumnDef(key: 'kWt', label: 'K Wt', width: 140),
        ReportColumnDef(key: 'brPc', label: 'Br Pc', width: 140),
        ReportColumnDef(key: 'brWt', label: 'Br Wt', width: 140),
        ReportColumnDef(key: 'topsPc', label: 'Tops Pc', width: 140),
        ReportColumnDef(key: 'topsWt', label: 'Tops Wt', width: 140),
        ReportColumnDef(key: 'lossPc', label: 'Loss Pc', width: 140),
        ReportColumnDef(key: 'lossWt', label: 'Loss Wt', width: 140),
        ReportColumnDef(key: 'lossPer', label: 'Loss %', width: 140),
        ReportColumnDef(key: 'jnoRecPc', label: 'Jno Rec Pc', width: 160),
        ReportColumnDef(key: 'remarksName', label: 'Remarks', width: 160),
        ReportColumnDef(key: 'dueDay', label: 'Due Day', width: 140),
        ReportColumnDef(key: 'purityName', label: 'Purity', width: 140),
        ReportColumnDef(key: 'charniName', label: 'Charni', width: 140),
      ],
      mapper: (raw) => raw
          .map(
            (e) => {
              'mstID': '${e['MstID'] ?? '-'}',
              'lottingID': '${e['LottingID'] ?? '-'}',
              'date': formatDate(e['Date']),
              'time': e['Time'] ?? '-',
              'formType': e['FormType'] ?? '-',
              'fromMan': e['FromMan'] ?? '-',
              'toMan': e['ToMan'] ?? '-',
              'deptProcessName': e['DeptProcessName'] ?? '-',
              'deptName': e['DeptName'] ?? '-',
              'cutMan': e['CutMan'] ?? '-',
              'signer': e['Signer'] ?? '-',
              'checkerMan': e['CheckerMan'] ?? '-',
              'signerMan': e['SignerMan'] ?? '-',
              'id': '${e['ID'] ?? '-'}',
              'jno': '${e['Jno'] ?? '-'}',
              'bCode': '${e['BCode'] ?? '-'}',
              'pktNo': e['PktNo'] ?? '-',
              'cutNo': e['CutNo'] ?? '-',
              'clvCut': e['ClvCut'] ?? '-',
              'pc': '${e['Pc'] ?? 0}',
              'wt': formatDecimal(e['Wt'], decimal: 3),
              'issPc': '${e['IssPc'] ?? 0}',
              'issWt': formatDecimal(e['IssWt'], decimal: 3),
              'recPc': '${e['RecPc'] ?? 0}',
              'recWt': formatDecimal(e['RecWt'], decimal: 3),
              'dmWt': formatDecimal(e['DmWt'], decimal: 3),
              'dmPer': formatDecimal(e['DmPer'], decimal: 2),
              'recPer': formatDecimal(e['RecPer'], decimal: 2),
              'diffPer': formatDecimal(e['DiffPer'], decimal: 2),
              'kPc': '${e['KPc'] ?? '-'}',
              'kWt': formatDecimal(e['KWt'], decimal: 3),
              'brPc': '${e['BrPc'] ?? '-'}',
              'brWt': formatDecimal(e['BrWt'], decimal: 3),
              'topsPc': '${e['TopsPc'] ?? '-'}',
              'topsWt': formatDecimal(e['TopsWt'], decimal: 3),
              'lossPc': '${e['LossPc'] ?? '-'}',
              'lossWt': formatDecimal(e['LossWt'], decimal: 3),
              'lossPer': formatDecimal(e['LossPer'], decimal: 2),
              'jnoRecPc': '${e['JnoRecPc'] ?? 0}',
              'remarksName': e['RemarksName'] ?? '-',
              'dueDay': '${e['DueDay'] ?? '-'}',
              'purityName': e['PurityName'] ?? '-',
              'charniName': e['CharniName'] ?? '-',
            },
          )
          .toList(),
    ),

    // ── DEPT_CONFIRM_PENDING_[DAY_LIMIT] ─────────────────────────────────────────────────────── 18
    'DEPT_CONFIRM_PENDING_[DAY_LIMIT]': ReportConfig(
      reportTypeCode: 'DEPT_CONFIRM_PENDING_[DAY_LIMIT]',

      endpoint: '/reports/dept-rec-confirm-pending-day-limit',

      columns: const [
        ReportColumnDef(key: 'ToMan', label: 'Manager', width: 180),
        ReportColumnDef(key: 'Days', label: 'Days', width: 120),
        ReportColumnDef(key: 'TotPkt', label: 'Pkt', width: 120),
        ReportColumnDef(key: 'Pc', label: 'Pc', width: 120),
        ReportColumnDef(key: 'Wt', label: 'Wt', width: 140),
        ReportColumnDef(key: 'DmWt', label: 'DM Wt', width: 140),
        ReportColumnDef(key: 'DmPer', label: 'DM %', width: 140),
      ],

      mapper: (raw) => raw
          .map(
            (e) => {
              'ToMan': e['ToMan'] ?? '-',
              'Days': formatDecimal(e['Days'], decimal: 0),
              'TotPkt': formatDecimal(e['TotPkt'], decimal: 0),
              'Pc': formatDecimal(e['Pc'], decimal: 0),
              'Wt': formatDecimal(e['Wt'], decimal: 3),
              'DmWt': formatDecimal(e['DmWt'], decimal: 3),
              'DmPer': formatDecimal(e['DmPer'], decimal: 2),
            },
          )
          .toList(),
    ),

    // ── DEPT_ISS_DETAIL_[BUNCH_CREATE] ─────────────────────────────────────────────────────── 19
    'DEPT_ISS_DETAIL_[BUNCH_CREATE]': ReportConfig(
      reportTypeCode: 'DEPT_ISS_DETAIL_[BUNCH_CREATE]',
      endpoint: '/reports/dept-rec-bunch-create-detail',
      columns: const [
        ReportColumnDef(key: 'MstID', label: 'Mst ID', width: 160),
        ReportColumnDef(key: 'LottingID', label: 'Lotting ID', width: 160),
        ReportColumnDef(key: 'Date', label: 'Date', width: 140),
        ReportColumnDef(key: 'Time', label: 'Time', width: 120),
        ReportColumnDef(key: 'FormType', label: 'Form Type', width: 160),
        ReportColumnDef(key: 'FromMan', label: 'From Manager', width: 180),
        ReportColumnDef(key: 'ToMan', label: 'To Manager', width: 180),
        ReportColumnDef(key: 'DeptProcessName', label: 'Process', width: 180),
        ReportColumnDef(key: 'DeptName', label: 'Department', width: 180),
        ReportColumnDef(key: 'CheckerMan', label: 'Checker', width: 160),
        ReportColumnDef(key: 'SignerMan', label: 'Signer', width: 160),
        ReportColumnDef(key: 'ID', label: 'ID', width: 100),
        ReportColumnDef(key: 'Jno', label: 'Jno', width: 120),
        ReportColumnDef(key: 'BCode', label: 'BCode', width: 140),
        ReportColumnDef(key: 'PktNo', label: 'Pkt No', width: 140),
        ReportColumnDef(key: 'CutNo', label: 'Cut No', width: 140),
        ReportColumnDef(key: 'RecPc', label: 'Rec Pc', width: 140),
        ReportColumnDef(key: 'RecWt', label: 'Rec Wt', width: 140),
        ReportColumnDef(key: 'DmWt', label: 'DM Wt', width: 140),
        ReportColumnDef(key: 'DmPer', label: 'DM %', width: 140),
        ReportColumnDef(key: 'CharniName', label: 'Charni', width: 140),
        ReportColumnDef(key: 'Process', label: 'Process Name', width: 180),
      ],

      mapper: (raw) => raw
          .map(
            (e) => {
              'MstID': '${e['MstID'] ?? '-'}',
              'LottingID': '${e['LottingID'] ?? '-'}',
              'Date': e['Date'] ?? '-',
              'Time': e['Time'] ?? '-',
              'FormType': e['FormType'] ?? '-',
              'FromMan': e['FromMan'] ?? '-',
              'ToMan': e['ToMan'] ?? '-',
              'DeptProcessName': e['DeptProcessName'] ?? '-',
              'DeptName': e['DeptName'] ?? '-',
              'CheckerMan': e['CheckerMan'] ?? '-',
              'SignerMan': e['SignerMan'] ?? '-',
              'ID': '${e['ID'] ?? 0}',
              'Jno': '${e['Jno'] ?? 0}',
              'BCode': '${e['BCode'] ?? 0}',
              'PktNo': e['PktNo'] ?? '-',
              'CutNo': e['CutNo'] ?? '-',
              'RecPc': formatDecimal(e['RecPc'], decimal: 0),
              'RecWt': formatDecimal(e['RecWt'], decimal: 3),
              'DmWt': formatDecimal(e['DmWt'], decimal: 3),
              'DmPer': formatDecimal(e['DmPer'], decimal: 2),
              'CharniName': e['CharniName'] ?? '-',
              'Process': e['Process'] ?? '-',
            },
          )
          .toList(),
    ),

    // ── LABOUR_DETAIL ─────────────────────────────────────────────────────── 20
    'LABOUR_DETAIL': ReportConfig(
      reportTypeCode: 'LABOUR_DETAIL',
      endpoint: '/reports/dept-rec-labour-detail',
      columns: const [
        ReportColumnDef(key: 'Manager', label: 'Manager', width: 160),
        ReportColumnDef(key: 'DeptName', label: 'Department', width: 180),
        ReportColumnDef(key: 'DeptProcessName', label: 'Process', width: 180),
        ReportColumnDef(key: 'BCode', label: 'BCode', width: 140),
        ReportColumnDef(key: 'CutNo', label: 'Cut No', width: 140),
        ReportColumnDef(key: 'PktNo', label: 'Pkt No', width: 140),
        ReportColumnDef(key: 'IssPc', label: 'Iss Pc', width: 140),
        ReportColumnDef(key: 'IssWt', label: 'Iss Wt', width: 140),
        ReportColumnDef(key: 'RecPc', label: 'Rec Pc', width: 140),
        ReportColumnDef(key: 'RecWt', label: 'Rec Wt', width: 140),
        ReportColumnDef(key: 'LossWt', label: 'Loss Wt', width: 140),
        ReportColumnDef(key: 'RateID', label: 'Rate ID', width: 140),
        ReportColumnDef(key: 'Rateon', label: 'Rate On', width: 140),
        ReportColumnDef(key: 'Rate', label: 'Rate', width: 120),
        ReportColumnDef(key: 'Amount', label: 'Amount', width: 140),
      ],

      mapper: (raw) => raw
          .map(
            (e) => {
              'Manager': e['Manager'] ?? '-',
              'DeptName': e['DeptName'] ?? '-',
              'DeptProcessName': e['DeptProcessName'] ?? '-',
              'BCode': '${e['BCode'] ?? 0}',
              'CutNo': e['CutNo'] ?? '-',
              'PktNo': e['PktNo'] ?? '-',
              'IssPc': formatDecimal(e['IssPc'], decimal: 0),
              'IssWt': formatDecimal(e['IssWt'], decimal: 3),
              'RecPc': formatDecimal(e['RecPc'], decimal: 0),
              'RecWt': formatDecimal(e['RecWt'], decimal: 3),
              'LossWt': formatDecimal(e['LossWt'], decimal: 3),
              'RateID': e['RateID'] ?? '-',
              'Rateon': e['Rateon'] ?? '-',
              'Rate': formatDecimal(e['Rate'], decimal: 2),
              'Amount': formatDecimal(e['Amount'], decimal: 2),
            },
          )
          .toList(),
    ),

    // ── LABOUR_SUMMARY ─────────────────────────────────────────────────────── 21
    'LABOUR_SUMMARY': ReportConfig(
      reportTypeCode: 'LABOUR_SUMMARY',
      endpoint: '/reports/dept-rec-labour-summary',
      columns: const [
        ReportColumnDef(key: 'Manager', label: 'Manager', width: 160),
        ReportColumnDef(key: 'DeptName', label: 'Department', width: 180),
        ReportColumnDef(key: 'DeptProcessName', label: 'Process', width: 180),
        ReportColumnDef(key: 'IssPc', label: 'Iss Pc', width: 140),
        ReportColumnDef(key: 'IssWt', label: 'Iss Wt', width: 140),
        ReportColumnDef(key: 'RecPc', label: 'Rec Pc', width: 140),
        ReportColumnDef(key: 'RecWt', label: 'Rec Wt', width: 140),
        ReportColumnDef(key: 'LossWt', label: 'Loss Wt', width: 140),
        ReportColumnDef(key: 'RateID', label: 'Rate ID', width: 140),
        ReportColumnDef(key: 'Rateon', label: 'Rate On', width: 140),
        ReportColumnDef(key: 'Rate', label: 'Rate', width: 120),
        ReportColumnDef(key: 'Amount', label: 'Amount', width: 140),
      ],
      mapper: (raw) => raw
          .map(
            (e) => {
              'Manager': e['Manager'] ?? '-',
              'DeptName': e['DeptName'] ?? '-',
              'DeptProcessName': e['DeptProcessName'] ?? '-',
              'IssPc': formatDecimal(e['IssPc'], decimal: 0),
              'IssWt': formatDecimal(e['IssWt'], decimal: 3),
              'RecPc': formatDecimal(e['RecPc'], decimal: 0),
              'RecWt': formatDecimal(e['RecWt'], decimal: 3),
              'LossWt': formatDecimal(e['LossWt'], decimal: 3),
              'RateID': e['RateID'] ?? '-',
              'Rateon': e['Rateon'] ?? '-',
              'Rate': formatDecimal(e['Rate'], decimal: 2),
              'Amount': formatDecimal(e['Amount'], decimal: 2),
            },
          )
          .toList(),
    ),

    // ── REC_CUTWISE_SUMMARY ─────────────────────────────────────────────────────── 22
    'REC_CUTWISE_SUMMARY': ReportConfig(
      reportTypeCode: 'REC_CUTWISE_SUMMARY',
      endpoint: '/reports/dept-rec-cutwise-summary',
      columns: const [
        ReportColumnDef(key: 'CutNo', label: 'Cut No', width: 140),
        ReportColumnDef(key: 'Pkt', label: 'Pkt', width: 140),
        ReportColumnDef(key: 'Pc', label: 'Pc', width: 120),
        ReportColumnDef(key: 'Wt', label: 'Wt', width: 120),
        ReportColumnDef(key: 'IssPc', label: 'Iss Pc', width: 140),
        ReportColumnDef(key: 'IssWt', label: 'Iss Wt', width: 140),
        ReportColumnDef(key: 'RecPc', label: 'Rec Pc', width: 140),
        ReportColumnDef(key: 'RecWt', label: 'Rec Wt', width: 140),
        ReportColumnDef(key: 'DmWt', label: 'DM Wt', width: 140),
        ReportColumnDef(key: 'DmPer', label: 'DM %', width: 140),
        ReportColumnDef(key: 'RecPer', label: 'Rec %', width: 140),
        ReportColumnDef(key: 'KPc', label: 'K Pc', width: 140),
        ReportColumnDef(key: 'KWt', label: 'K Wt', width: 140),
        ReportColumnDef(key: 'BrPc', label: 'Br Pc', width: 140),
        ReportColumnDef(key: 'BrWt', label: 'Br Wt', width: 140),
        ReportColumnDef(key: 'LossPc', label: 'Loss Pc', width: 140),
        ReportColumnDef(key: 'LossWt', label: 'Loss Wt', width: 140),
        ReportColumnDef(key: 'TopsPc', label: 'Tops Pc', width: 140),
        ReportColumnDef(key: 'TopsWt', label: 'Tops Wt', width: 140),
      ],

      mapper: (raw) => raw
          .map(
            (e) => {
              'CutNo': e['CutNo'] ?? '-',
              'Pkt': formatDecimal(e['Pkt'], decimal: 0),
              'Pc': formatDecimal(e['Pc'], decimal: 0),
              'Wt': formatDecimal(e['Wt'], decimal: 3),
              'IssPc': formatDecimal(e['IssPc'], decimal: 0),
              'IssWt': formatDecimal(e['IssWt'], decimal: 3),
              'RecPc': formatDecimal(e['RecPc'], decimal: 0),
              'RecWt': formatDecimal(e['RecWt'], decimal: 3),
              'DmWt': formatDecimal(e['DmWt'], decimal: 3),
              'DmPer': formatDecimal(e['DmPer'], decimal: 2),
              'RecPer': formatDecimal(e['RecPer'], decimal: 2),
              'KPc': formatDecimal(e['KPc'], decimal: 0),
              'KWt': formatDecimal(e['KWt'], decimal: 3),
              'BrPc': formatDecimal(e['BrPc'], decimal: 0),
              'BrWt': formatDecimal(e['BrWt'], decimal: 3),
              'LossPc': formatDecimal(e['LossPc'], decimal: 0),
              'LossWt': formatDecimal(e['LossWt'], decimal: 3),
              'TopsPc': formatDecimal(e['TopsPc'], decimal: 0),
              'TopsWt': formatDecimal(e['TopsWt'], decimal: 3),
            },
          )
          .toList(),
    ),

    // ── REC_DEPTWISE_SUMMARY ─────────────────────────────────────────────────────── 23
    'REC_DEPTWISE_SUMMARY': ReportConfig(
      reportTypeCode: 'REC_DEPTWISE_SUMMARY',
      endpoint: '/reports/dept-rec-deptwise-summary',
      columns: const [
        ReportColumnDef(key: 'Department', label: 'Department', width: 180),
        ReportColumnDef(key: 'Pkt', label: 'Pkt', width: 120),
        ReportColumnDef(key: 'Pc', label: 'Pc', width: 120),
        ReportColumnDef(key: 'Wt', label: 'Wt', width: 120),
        ReportColumnDef(key: 'IssPc', label: 'Iss Pc', width: 140),
        ReportColumnDef(key: 'IssWt', label: 'Iss Wt', width: 140),
        ReportColumnDef(key: 'RecPc', label: 'Rec Pc', width: 140),
        ReportColumnDef(key: 'RecWt', label: 'Rec Wt', width: 140),
        ReportColumnDef(key: 'DmWt', label: 'DM Wt', width: 140),
        ReportColumnDef(key: 'DmPer', label: 'DM %', width: 140),
        ReportColumnDef(key: 'RecPer', label: 'Rec %', width: 140),
        ReportColumnDef(key: 'KPc', label: 'K Pc', width: 140),
        ReportColumnDef(key: 'KWt', label: 'K Wt', width: 140),
        ReportColumnDef(key: 'BrPc', label: 'Br Pc', width: 140),
        ReportColumnDef(key: 'BrWt', label: 'Br Wt', width: 140),
        ReportColumnDef(key: 'LossPc', label: 'Loss Pc', width: 140),
        ReportColumnDef(key: 'LossWt', label: 'Loss Wt', width: 140),
        ReportColumnDef(key: 'TopsPc', label: 'Tops Pc', width: 140),
        ReportColumnDef(key: 'TopsWt', label: 'Tops Wt', width: 140),
      ],

      mapper: (raw) => raw
          .map(
            (e) => {
              'Department': e['Department'] ?? '-',
              'Pkt': formatDecimal(e['Pkt'], decimal: 0),
              'Pc': formatDecimal(e['Pc'], decimal: 0),
              'Wt': formatDecimal(e['Wt'], decimal: 3),
              'IssPc': formatDecimal(e['IssPc'], decimal: 0),
              'IssWt': formatDecimal(e['IssWt'], decimal: 3),
              'RecPc': formatDecimal(e['RecPc'], decimal: 0),
              'RecWt': formatDecimal(e['RecWt'], decimal: 3),
              'DmWt': formatDecimal(e['DmWt'], decimal: 3),
              'DmPer': formatDecimal(e['DmPer'], decimal: 2),
              'RecPer': formatDecimal(e['RecPer'], decimal: 2),
              'KPc': formatDecimal(e['KPc'], decimal: 0),
              'KWt': formatDecimal(e['KWt'], decimal: 3),
              'BrPc': formatDecimal(e['BrPc'], decimal: 0),
              'BrWt': formatDecimal(e['BrWt'], decimal: 3),
              'LossPc': formatDecimal(e['LossPc'], decimal: 0),
              'LossWt': formatDecimal(e['LossWt'], decimal: 3),
              'TopsPc': formatDecimal(e['TopsPc'], decimal: 0),
              'TopsWt': formatDecimal(e['TopsWt'], decimal: 3),
            },
          )
          .toList(),
    ),

    // ── REC_MANAGERWISE_SUMMARY ─────────────────────────────────────────────────────── 24
    'REC_MANAGERWISE_SUMMARY': ReportConfig(
      reportTypeCode: 'REC_MANAGERWISE_SUMMARY',
      endpoint: '/reports/dept-rec-managerwise-summary',
      columns: const [
        ReportColumnDef(key: 'Manager', label: 'Manager', width: 180),
        ReportColumnDef(key: 'Pkt', label: 'Pkt', width: 120),
        ReportColumnDef(key: 'Pc', label: 'Pc', width: 120),
        ReportColumnDef(key: 'Wt', label: 'Wt', width: 120),
        ReportColumnDef(key: 'IssPc', label: 'Iss Pc', width: 140),
        ReportColumnDef(key: 'IssWt', label: 'Iss Wt', width: 140),
        ReportColumnDef(key: 'RecPc', label: 'Rec Pc', width: 140),
        ReportColumnDef(key: 'RecWt', label: 'Rec Wt', width: 140),
        ReportColumnDef(key: 'DmWt', label: 'DM Wt', width: 140),
        ReportColumnDef(key: 'DmPer', label: 'DM %', width: 140),
        ReportColumnDef(key: 'RecPer', label: 'Rec %', width: 140),
        ReportColumnDef(key: 'KPc', label: 'K Pc', width: 140),
        ReportColumnDef(key: 'KWt', label: 'K Wt', width: 140),
        ReportColumnDef(key: 'BrPc', label: 'Br Pc', width: 140),
        ReportColumnDef(key: 'BrWt', label: 'Br Wt', width: 140),
        ReportColumnDef(key: 'LossPc', label: 'Loss Pc', width: 140),
        ReportColumnDef(key: 'LossWt', label: 'Loss Wt', width: 140),
        ReportColumnDef(key: 'TopsPc', label: 'Tops Pc', width: 140),
        ReportColumnDef(key: 'TopsWt', label: 'Tops Wt', width: 140),
      ],

      mapper: (raw) => raw
          .map(
            (e) => {
              'Manager': e['Manager'] ?? '-',
              'Pkt': formatDecimal(e['Pkt'], decimal: 0),
              'Pc': formatDecimal(e['Pc'], decimal: 0),
              'Wt': formatDecimal(e['Wt'], decimal: 3),
              'IssPc': formatDecimal(e['IssPc'], decimal: 0),
              'IssWt': formatDecimal(e['IssWt'], decimal: 3),
              'RecPc': formatDecimal(e['RecPc'], decimal: 0),
              'RecWt': formatDecimal(e['RecWt'], decimal: 3),
              'DmWt': formatDecimal(e['DmWt'], decimal: 3),
              'DmPer': formatDecimal(e['DmPer'], decimal: 2),
              'RecPer': formatDecimal(e['RecPer'], decimal: 2),
              'KPc': formatDecimal(e['KPc'], decimal: 0),
              'KWt': formatDecimal(e['KWt'], decimal: 3),
              'BrPc': formatDecimal(e['BrPc'], decimal: 0),
              'BrWt': formatDecimal(e['BrWt'], decimal: 3),
              'LossPc': formatDecimal(e['LossPc'], decimal: 0),
              'LossWt': formatDecimal(e['LossWt'], decimal: 3),
              'TopsPc': formatDecimal(e['TopsPc'], decimal: 0),
              'TopsWt': formatDecimal(e['TopsWt'], decimal: 3),
            },
          )
          .toList(),
    ),

    // ── LASER_REC_IDWISE_SUMMARY ─────────────────────────────────────────────────────── 25
    'LASER_REC_IDWISE_SUMMARY': ReportConfig(
      reportTypeCode: 'LASER_REC_IDWISE_SUMMARY',
      endpoint: '/reports/dept-rec-laser-idwise-summary',
      columns: const [
        ReportColumnDef(key: 'Manager', label: 'Manager', width: 180),
        ReportColumnDef(key: 'Pkt', label: 'Pkt', width: 120),
        ReportColumnDef(key: 'Pc', label: 'Pc', width: 120),
        ReportColumnDef(key: 'Wt', label: 'Wt', width: 120),
        ReportColumnDef(key: 'IssPc', label: 'Iss Pc', width: 140),
        ReportColumnDef(key: 'IssWt', label: 'Iss Wt', width: 140),
        ReportColumnDef(key: 'RecPc', label: 'Rec Pc', width: 140),
        ReportColumnDef(key: 'RecWt', label: 'Rec Wt', width: 140),
        ReportColumnDef(key: 'DmWt', label: 'DM Wt', width: 140),
        ReportColumnDef(key: 'DmPer', label: 'DM %', width: 140),
        ReportColumnDef(key: 'RecPer', label: 'Rec %', width: 140),
        ReportColumnDef(key: 'KPc', label: 'K Pc', width: 140),
        ReportColumnDef(key: 'KWt', label: 'K Wt', width: 140),
        ReportColumnDef(key: 'BrPc', label: 'Br Pc', width: 140),
        ReportColumnDef(key: 'BrWt', label: 'Br Wt', width: 140),
        ReportColumnDef(key: 'LossPc', label: 'Loss Pc', width: 140),
        ReportColumnDef(key: 'LossWt', label: 'Loss Wt', width: 140),
        ReportColumnDef(key: 'TopsPc', label: 'Tops Pc', width: 140),
        ReportColumnDef(key: 'TopsWt', label: 'Tops Wt', width: 140),
      ],

      mapper: (raw) => raw
          .map(
            (e) => {
              'Manager': e['Manager'] ?? '-',
              'Pkt': formatDecimal(e['Pkt'], decimal: 0),
              'Pc': formatDecimal(e['Pc'], decimal: 0),
              'Wt': formatDecimal(e['Wt'], decimal: 3),
              'IssPc': formatDecimal(e['IssPc'], decimal: 0),
              'IssWt': formatDecimal(e['IssWt'], decimal: 3),
              'RecPc': formatDecimal(e['RecPc'], decimal: 0),
              'RecWt': formatDecimal(e['RecWt'], decimal: 3),
              'DmWt': formatDecimal(e['DmWt'], decimal: 3),
              'DmPer': formatDecimal(e['DmPer'], decimal: 2),
              'RecPer': formatDecimal(e['RecPer'], decimal: 2),
              'KPc': formatDecimal(e['KPc'], decimal: 0),
              'KWt': formatDecimal(e['KWt'], decimal: 3),
              'BrPc': formatDecimal(e['BrPc'], decimal: 0),
              'BrWt': formatDecimal(e['BrWt'], decimal: 3),
              'LossPc': formatDecimal(e['LossPc'], decimal: 0),
              'LossWt': formatDecimal(e['LossWt'], decimal: 3),
              'TopsPc': formatDecimal(e['TopsPc'], decimal: 0),
              'TopsWt': formatDecimal(e['TopsWt'], decimal: 3),
            },
          )
          .toList(),
    ),

    // ── LASER_REC_BCODEWISE_DETAIL ─────────────────────────────────────────────────────── 26
    'LASER_REC_BCODEWISE_DETAIL': ReportConfig(
      reportTypeCode: 'LASER_REC_BCODEWISE_DETAIL',
      endpoint: '/reports/dept-rec-laser-bcodewise-detail',
      columns: const [
        ReportColumnDef(key: 'IssDate', label: 'Issue Date', width: 140),

        ReportColumnDef(key: 'Manager', label: 'Manager', width: 180),
        ReportColumnDef(key: 'RecutEmp', label: 'Recut Emp', width: 180),

        ReportColumnDef(key: 'ID', label: 'ID', width: 120),

        ReportColumnDef(key: 'CutNo', label: 'Cut No', width: 140),
        ReportColumnDef(key: 'CutWt', label: 'Cut Wt', width: 140),

        ReportColumnDef(key: 'PktNo', label: 'Pkt No', width: 140),
        ReportColumnDef(key: 'BCode', label: 'BCode', width: 140),

        ReportColumnDef(key: 'IssPc', label: 'Iss Pc', width: 140),
        ReportColumnDef(key: 'IssWt', label: 'Iss Wt', width: 140),

        ReportColumnDef(key: 'Remarks', label: 'Remarks', width: 200),

        ReportColumnDef(key: 'RecDate', label: 'Rec Date', width: 140),
        ReportColumnDef(key: 'RecPc', label: 'Rec Pc', width: 140),
        ReportColumnDef(key: 'RecWt', label: 'Rec Wt', width: 140),

        ReportColumnDef(key: 'TopsPc', label: 'Tops Pc', width: 140),
        ReportColumnDef(key: 'TopsWt', label: 'Tops Wt', width: 140),

        ReportColumnDef(key: 'LossWt', label: 'Loss Wt', width: 140),
        ReportColumnDef(key: 'LossPer', label: 'Loss %', width: 140),

        ReportColumnDef(key: 'NetLossPer', label: 'Net Loss %', width: 140),
      ],
      mapper: (raw) => raw.map((e) => {
        'IssDate': formatDate(e['IssDate']),

        'Manager': e['Manager'] ?? '-',
        'RecutEmp': e['RecutEmp'] ?? '-',

        'ID': '${e['ID'] ?? 0}',

        'CutNo': e['CutNo'] ?? '-',
        'CutWt': formatDecimal(e['CutWt'], decimal: 3),

        'PktNo': e['PktNo'] ?? '-',
        'BCode': '${e['BCode'] ?? 0}',

        'IssPc': formatDecimal(e['IssPc'], decimal: 0),
        'IssWt': formatDecimal(e['IssWt'], decimal: 3),

        'Remarks': e['Remarks'] ?? '-',

        'RecDate': e['RecDate'] != null
            ? formatDate(e['RecDate'])
            : '-',

        'RecPc': formatDecimal(e['RecPc'], decimal: 0),
        'RecWt': formatDecimal(e['RecWt'], decimal: 3),

        'TopsPc': formatDecimal(e['TopsPc'], decimal: 0),
        'TopsWt': formatDecimal(e['TopsWt'], decimal: 3),

        'LossWt': formatDecimal(e['LossWt'], decimal: 3),
        'LossPer': formatDecimal(e['LossPer'], decimal: 2),

        'NetLossPer': e['NetLossPer'] ?? '-',
      }).toList(),
    ),

    // ── DEPT_REC_DETAIL ─────────────────────────────────────────────────────── 27
    'DEPT_REC_DETAIL': ReportConfig(
      reportTypeCode: 'DEPT_REC_DETAIL',
      endpoint: '/reports/dept-rec-detail',
      columns: const [
        ReportColumnDef(key: 'MstID', label: 'Mst ID', width: 120),
        ReportColumnDef(key: 'LottingID', label: 'Lotting ID', width: 140),
        ReportColumnDef(key: 'Date', label: 'Date', width: 140),
        ReportColumnDef(key: 'Time', label: 'Time', width: 140),
        ReportColumnDef(key: 'FormType', label: 'Form Type', width: 180),
        ReportColumnDef(key: 'FromMan', label: 'From Manager', width: 180),
        ReportColumnDef(key: 'ToMan', label: 'To Manager', width: 180),
        ReportColumnDef(key: 'DeptProcessName', label: 'Process', width: 180),
        ReportColumnDef(key: 'DeptName', label: 'Department', width: 180),
        ReportColumnDef(key: 'CutMan', label: 'Cut Manager', width: 180),
        ReportColumnDef(key: 'Signer', label: 'Signer', width: 140),
        ReportColumnDef(key: 'CheckerMan', label: 'Checker', width: 160),
        ReportColumnDef(key: 'SignerMan', label: 'Signer Manager', width: 160),
        ReportColumnDef(key: 'BCode', label: 'BCode', width: 140),
        ReportColumnDef(key: 'PktNo', label: 'Pkt No', width: 140),
        ReportColumnDef(key: 'CutNo', label: 'Cut No', width: 140),
        ReportColumnDef(key: 'ClvCut', label: 'Clv Cut', width: 140),
        ReportColumnDef(key: 'Pc', label: 'Pc', width: 120),
        ReportColumnDef(key: 'Wt', label: 'Wt', width: 120),
        ReportColumnDef(key: 'IssPc', label: 'Iss Pc', width: 140),
        ReportColumnDef(key: 'IssWt', label: 'Iss Wt', width: 140),
        ReportColumnDef(key: 'RecPc', label: 'Rec Pc', width: 140),
        ReportColumnDef(key: 'RecWt', label: 'Rec Wt', width: 140),
        ReportColumnDef(key: 'DmWt', label: 'DM Wt', width: 140),
        ReportColumnDef(key: 'DmPer', label: 'DM %', width: 140),
        ReportColumnDef(key: 'RecPer', label: 'Rec %', width: 140),
        ReportColumnDef(key: 'DiffPer', label: 'Diff %', width: 140),
        ReportColumnDef(key: 'KPc', label: 'K Pc', width: 140),
        ReportColumnDef(key: 'KWt', label: 'K Wt', width: 140),
        ReportColumnDef(key: 'BrPc', label: 'Br Pc', width: 140),
        ReportColumnDef(key: 'BrWt', label: 'Br Wt', width: 140),
        ReportColumnDef(key: 'TopsPc', label: 'Tops Pc', width: 140),
        ReportColumnDef(key: 'TopsWt', label: 'Tops Wt', width: 140),
        ReportColumnDef(key: 'LossPc', label: 'Loss Pc', width: 140),
        ReportColumnDef(key: 'LossWt', label: 'Loss Wt', width: 140),
        ReportColumnDef(key: 'LossPer', label: 'Loss %', width: 140),
        ReportColumnDef(key: 'JnoRecPc', label: 'Jno Rec Pc', width: 160),
        ReportColumnDef(key: 'RemarksName', label: 'Remarks', width: 160),
        ReportColumnDef(key: 'DueDay', label: 'Due Day', width: 140),
        ReportColumnDef(key: 'PurityName', label: 'Purity', width: 140),
        ReportColumnDef(key: 'CharniName', label: 'Charni', width: 140),
      ],

      mapper: (raw) => raw
          .map(
            (e) => {
              'MstID': '${e['MstID'] ?? '-'}',
              'LottingID': '${e['LottingID'] ?? '-'}',
              'Date': formatDate(e['Date']),
              'Time': e['Time'] ?? '-',
              'FormType': e['FormType'] ?? '-',
              'FromMan': e['FromMan'] ?? '-',
              'ToMan': e['ToMan'] ?? '-',
              'DeptProcessName': e['DeptProcessName'] ?? '-',
              'DeptName': e['DeptName'] ?? '-',
              'CutMan': e['CutMan'] ?? '-',
              'Signer': e['Signer'] ?? '-',
              'CheckerMan': e['CheckerMan'] ?? '-',
              'SignerMan': e['SignerMan'] ?? '-',
              'BCode': '${e['BCode'] ?? 0}',
              'PktNo': e['PktNo'] ?? '-',
              'CutNo': e['CutNo'] ?? '-',
              'ClvCut': e['ClvCut'] ?? '-',
              'Pc': formatDecimal(e['Pc'], decimal: 0),
              'Wt': formatDecimal(e['Wt'], decimal: 3),
              'IssPc': formatDecimal(e['IssPc'], decimal: 0),
              'IssWt': formatDecimal(e['IssWt'], decimal: 3),
              'RecPc': formatDecimal(e['RecPc'], decimal: 0),
              'RecWt': formatDecimal(e['RecWt'], decimal: 3),
              'DmWt': formatDecimal(e['DmWt'], decimal: 3),
              'DmPer': formatDecimal(e['DmPer'], decimal: 2),
              'RecPer': formatDecimal(e['RecPer'], decimal: 2),
              'DiffPer': formatDecimal(e['DiffPer'], decimal: 2),
              'KPc': formatDecimal(e['KPc'], decimal: 0),
              'KWt': formatDecimal(e['KWt'], decimal: 3),
              'BrPc': formatDecimal(e['BrPc'], decimal: 0),
              'BrWt': formatDecimal(e['BrWt'], decimal: 3),
              'TopsPc': formatDecimal(e['TopsPc'], decimal: 0),
              'TopsWt': formatDecimal(e['TopsWt'], decimal: 3),
              'LossPc': formatDecimal(e['LossPc'], decimal: 0),
              'LossWt': formatDecimal(e['LossWt'], decimal: 3),
              'LossPer': formatDecimal(e['LossPer'], decimal: 2),
              'JnoRecPc': formatDecimal(e['JnoRecPc'], decimal: 0),
              'RemarksName': e['RemarksName'] ?? '-',
              'DueDay': '${e['DueDay'] ?? '-'}',
              'PurityName': e['PurityName'] ?? '-',
              'CharniName': e['CharniName'] ?? '-',
            },
          )
          .toList(),
    ),

    // ── SIGNER_LABOUR_DETAIL ─────────────────────────────────────────────────────── 28
    'SIGNER_LABOUR_DETAIL': ReportConfig(
      reportTypeCode: 'SIGNER_LABOUR_DETAIL',
      endpoint: '/reports/dept-rec-signer-labour-detail',
      columns: const [
        ReportColumnDef(key: 'Manager', label: 'Manager', width: 180),
        ReportColumnDef(key: 'Pkt', label: 'Pkt', width: 120),
        ReportColumnDef(key: 'Pc', label: 'Pc', width: 120),
        ReportColumnDef(key: 'Wt', label: 'Wt', width: 120),
        ReportColumnDef(key: 'IssPc', label: 'Iss Pc', width: 140),
        ReportColumnDef(key: 'IssWt', label: 'Iss Wt', width: 140),
        ReportColumnDef(key: 'RecPc', label: 'Rec Pc', width: 140),
        ReportColumnDef(key: 'RecWt', label: 'Rec Wt', width: 140),
        ReportColumnDef(key: 'DmWt', label: 'DM Wt', width: 140),
        ReportColumnDef(key: 'DmPer', label: 'DM %', width: 140),
        ReportColumnDef(key: 'RecPer', label: 'Rec %', width: 140),
        ReportColumnDef(key: 'KPc', label: 'K Pc', width: 140),
        ReportColumnDef(key: 'KWt', label: 'K Wt', width: 140),
        ReportColumnDef(key: 'BrPc', label: 'Br Pc', width: 140),
        ReportColumnDef(key: 'BrWt', label: 'Br Wt', width: 140),
        ReportColumnDef(key: 'LossPc', label: 'Loss Pc', width: 140),
        ReportColumnDef(key: 'LossWt', label: 'Loss Wt', width: 140),
        ReportColumnDef(key: 'TopsPc', label: 'Tops Pc', width: 140),
        ReportColumnDef(key: 'TopsWt', label: 'Tops Wt', width: 140),
      ],

      mapper: (raw) => raw
          .map(
            (e) => {
              'Manager': e['Manager'] ?? '-',
              'Pkt': formatDecimal(e['Pkt'], decimal: 0),
              'Pc': formatDecimal(e['Pc'], decimal: 0),
              'Wt': formatDecimal(e['Wt'], decimal: 3),
              'IssPc': formatDecimal(e['IssPc'], decimal: 0),
              'IssWt': formatDecimal(e['IssWt'], decimal: 3),
              'RecPc': formatDecimal(e['RecPc'], decimal: 0),
              'RecWt': formatDecimal(e['RecWt'], decimal: 3),
              'DmWt': formatDecimal(e['DmWt'], decimal: 3),
              'DmPer': formatDecimal(e['DmPer'], decimal: 2),
              'RecPer': formatDecimal(e['RecPer'], decimal: 2),
              'KPc': formatDecimal(e['KPc'], decimal: 0),
              'KWt': formatDecimal(e['KWt'], decimal: 3),
              'BrPc': formatDecimal(e['BrPc'], decimal: 0),
              'BrWt': formatDecimal(e['BrWt'], decimal: 3),
              'LossPc': formatDecimal(e['LossPc'], decimal: 0),
              'LossWt': formatDecimal(e['LossWt'], decimal: 3),
              'TopsPc': formatDecimal(e['TopsPc'], decimal: 0),
              'TopsWt': formatDecimal(e['TopsWt'], decimal: 3),
            },
          )
          .toList(),
    ),

    // ── SIGNER_LABOUR_SUMMARY ─────────────────────────────────────────────────────── 29
    'SIGNER_LABOUR_SUMMARY': ReportConfig(
      reportTypeCode: 'SIGNER_LABOUR_SUMMARY',
      endpoint: '/reports/dept-rec-signer-labour-summary',
      columns: const [
        ReportColumnDef(key: 'Manager', label: 'Manager', width: 180),
        ReportColumnDef(key: 'Pkt', label: 'Pkt', width: 120),
        ReportColumnDef(key: 'Pc', label: 'Pc', width: 120),
        ReportColumnDef(key: 'Wt', label: 'Wt', width: 120),
        ReportColumnDef(key: 'IssPc', label: 'Iss Pc', width: 140),
        ReportColumnDef(key: 'IssWt', label: 'Iss Wt', width: 140),
        ReportColumnDef(key: 'RecPc', label: 'Rec Pc', width: 140),
        ReportColumnDef(key: 'RecWt', label: 'Rec Wt', width: 140),
        ReportColumnDef(key: 'DmWt', label: 'DM Wt', width: 140),
        ReportColumnDef(key: 'DmPer', label: 'DM %', width: 140),
        ReportColumnDef(key: 'RecPer', label: 'Rec %', width: 140),
        ReportColumnDef(key: 'KPc', label: 'K Pc', width: 140),
        ReportColumnDef(key: 'KWt', label: 'K Wt', width: 140),
        ReportColumnDef(key: 'BrPc', label: 'Br Pc', width: 140),
        ReportColumnDef(key: 'BrWt', label: 'Br Wt', width: 140),
        ReportColumnDef(key: 'LossPc', label: 'Loss Pc', width: 140),
        ReportColumnDef(key: 'LossWt', label: 'Loss Wt', width: 140),
        ReportColumnDef(key: 'TopsPc', label: 'Tops Pc', width: 140),
        ReportColumnDef(key: 'TopsWt', label: 'Tops Wt', width: 140),
      ],

      mapper: (raw) => raw
          .map(
            (e) => {
              'Manager': e['Manager'] ?? '-',
              'Pkt': formatDecimal(e['Pkt'], decimal: 0),
              'Pc': formatDecimal(e['Pc'], decimal: 0),
              'Wt': formatDecimal(e['Wt'], decimal: 3),
              'IssPc': formatDecimal(e['IssPc'], decimal: 0),
              'IssWt': formatDecimal(e['IssWt'], decimal: 3),
              'RecPc': formatDecimal(e['RecPc'], decimal: 0),
              'RecWt': formatDecimal(e['RecWt'], decimal: 3),
              'DmWt': formatDecimal(e['DmWt'], decimal: 3),
              'DmPer': formatDecimal(e['DmPer'], decimal: 2),
              'RecPer': formatDecimal(e['RecPer'], decimal: 2),
              'KPc': formatDecimal(e['KPc'], decimal: 0),
              'KWt': formatDecimal(e['KWt'], decimal: 3),
              'BrPc': formatDecimal(e['BrPc'], decimal: 0),
              'BrWt': formatDecimal(e['BrWt'], decimal: 3),
              'LossPc': formatDecimal(e['LossPc'], decimal: 0),
              'LossWt': formatDecimal(e['LossWt'], decimal: 3),
              'TopsPc': formatDecimal(e['TopsPc'], decimal: 0),
              'TopsWt': formatDecimal(e['TopsWt'], decimal: 3),
            },
          )
          .toList(),
    ),

    // ── RECUT_LABOUR_DETAIL ─────────────────────────────────────────────────────── 30
    'RECUT_LABOUR_DETAIL': ReportConfig(
      reportTypeCode: 'RECUT_LABOUR_DETAIL',
      endpoint: '/reports/dept-rec-recut-labour-detail',
      columns: const [
        ReportColumnDef(key: 'Manager', label: 'Manager', width: 16),
        ReportColumnDef(key: 'DeptName', label: 'Department', width: 180),
        ReportColumnDef(key: 'DeptProcessName', label: 'Process', width: 180),
        ReportColumnDef(key: 'Employee', label: 'Employee', width: 160),
        ReportColumnDef(key: 'BCode', label: 'BCode', width: 140),
        ReportColumnDef(key: 'CutNo', label: 'Cut No', width: 140),
        ReportColumnDef(key: 'PktNo', label: 'Pkt No', width: 140),
        ReportColumnDef(key: 'IssPc', label: 'Iss Pc', width: 140),
        ReportColumnDef(key: 'IssWt', label: 'Iss Wt', width: 140),
        ReportColumnDef(key: 'RecPc', label: 'Rec Pc', width: 140),
        ReportColumnDef(key: 'RecWt', label: 'Rec Wt', width: 140),
        ReportColumnDef(key: 'LossWt', label: 'Loss Wt', width: 140),
        ReportColumnDef(key: 'RateID', label: 'Rate ID', width: 140),
        ReportColumnDef(key: 'Rateon', label: 'Rate On', width: 140),
        ReportColumnDef(key: 'Rate', label: 'Rate', width: 140),
        ReportColumnDef(key: 'Amount', label: 'Amount', width: 140),
      ],

      mapper: (raw) => raw
          .map(
            (e) => {
              'Manager': e['Manager'] ?? '-',
              'DeptName': e['DeptName'] ?? '-',
              'DeptProcessName': e['DeptProcessName'] ?? '-',
              'Employee': e['Employee'] ?? '-',
              'BCode': '${e['BCode'] ?? 0}',
              'CutNo': e['CutNo'] ?? '-',
              'PktNo': e['PktNo'] ?? '-',
              'IssPc': formatDecimal(e['IssPc'], decimal: 0),
              'IssWt': formatDecimal(e['IssWt'], decimal: 3),
              'RecPc': formatDecimal(e['RecPc'], decimal: 0),
              'RecWt': formatDecimal(e['RecWt'], decimal: 3),
              'LossWt': formatDecimal(e['LossWt'], decimal: 3),
              'RateID': e['RateID'] ?? '-',
              'Rateon': e['Rateon'] ?? '-',
              'Rate': formatDecimal(e['Rate'], decimal: 2),
              'Amount': formatDecimal(e['Amount'], decimal: 2),
            },
          )
          .toList(),
    ),

    // ── RECUT_LABOUR_SUMMARY ─────────────────────────────────────────────────────── 31
    'RECUT_LABOUR_SUMMARY': ReportConfig(
      reportTypeCode: 'RECUT_LABOUR_SUMMARY',
      endpoint: '/reports/dept-rec-recut-labour-summary',
      columns: const [
        ReportColumnDef(key: 'Employee', label: 'Employee', width: 180),
        ReportColumnDef(key: 'IssPc', label: 'Iss Pc', width: 120),
        ReportColumnDef(key: 'IssWt', label: 'Iss Wt', width: 120),
        ReportColumnDef(key: 'RecPc', label: 'Rec Pc', width: 120),
        ReportColumnDef(key: 'RecWt', label: 'Rec Wt', width: 120),
        ReportColumnDef(key: 'LossWt', label: 'Loss Wt', width: 140),
        ReportColumnDef(key: 'RateID', label: 'Rate ID', width: 120),
        ReportColumnDef(key: 'Rateon', label: 'Rate On', width: 140),
        ReportColumnDef(key: 'Rate', label: 'Rate', width: 120),
        ReportColumnDef(key: 'Amount', label: 'Amount', width: 140),
      ],

      mapper: (raw) => raw
          .map(
            (e) => {
              'Employee': e['Employee'] ?? '-',
              'IssPc': formatDecimal(e['IssPc'], decimal: 0),
              'IssWt': formatDecimal(e['IssWt'], decimal: 3),
              'RecPc': formatDecimal(e['RecPc'], decimal: 0),
              'RecWt': formatDecimal(e['RecWt'], decimal: 3),
              'LossWt': formatDecimal(e['LossWt'], decimal: 3),
              'RateID': e['RateID'] ?? '-',
              'Rateon': e['Rateon'] ?? '-',
              'Rate': formatDecimal(e['Rate'], decimal: 2),
              'Amount': formatDecimal(e['Amount'], decimal: 2),
            },
          )
          .toList(),
    ),

    // ── SIGNER_LABOUR_SUMMARY_[CUTWISE] ─────────────────────────────────────────────────────── 32
    'SIGNER_LABOUR_SUMMARY_[CUTWISE]': ReportConfig(
      reportTypeCode: 'SIGNER_LABOUR_SUMMARY_[CUTWISE]',
      endpoint: '/reports/dept-rec-signer-labour-summary-cutwise',
      columns: const [
        ReportColumnDef(key: 'Manager', label: 'Manager', width: 180),
        ReportColumnDef(key: 'Pkt', label: 'Pkt', width: 120),
        ReportColumnDef(key: 'Pc', label: 'Pc', width: 120),
        ReportColumnDef(key: 'Wt', label: 'Wt', width: 120),
        ReportColumnDef(key: 'IssPc', label: 'Iss Pc', width: 140),
        ReportColumnDef(key: 'IssWt', label: 'Iss Wt', width: 140),
        ReportColumnDef(key: 'RecPc', label: 'Rec Pc', width: 140),
        ReportColumnDef(key: 'RecWt', label: 'Rec Wt', width: 140),
        ReportColumnDef(key: 'DmWt', label: 'DM Wt', width: 140),
        ReportColumnDef(key: 'DmPer', label: 'DM %', width: 140),
        ReportColumnDef(key: 'RecPer', label: 'Rec %', width: 140),
        ReportColumnDef(key: 'KPc', label: 'K Pc', width: 140),
        ReportColumnDef(key: 'KWt', label: 'K Wt', width: 140),
        ReportColumnDef(key: 'BrPc', label: 'Br Pc', width: 140),
        ReportColumnDef(key: 'BrWt', label: 'Br Wt', width: 140),
        ReportColumnDef(key: 'LossPc', label: 'Loss Pc', width: 140),
        ReportColumnDef(key: 'LossWt', label: 'Loss Wt', width: 140),
        ReportColumnDef(key: 'TopsPc', label: 'Tops Pc', width: 140),
        ReportColumnDef(key: 'TopsWt', label: 'Tops Wt', width: 140),
      ],

      mapper: (raw) => raw
          .map(
            (e) => {
              'Manager': e['Manager'] ?? '-',
              'Pkt': formatDecimal(e['Pkt'], decimal: 0),
              'Pc': formatDecimal(e['Pc'], decimal: 0),
              'Wt': formatDecimal(e['Wt'], decimal: 3),
              'IssPc': formatDecimal(e['IssPc'], decimal: 0),
              'IssWt': formatDecimal(e['IssWt'], decimal: 3),
              'RecPc': formatDecimal(e['RecPc'], decimal: 0),
              'RecWt': formatDecimal(e['RecWt'], decimal: 3),
              'DmWt': formatDecimal(e['DmWt'], decimal: 3),
              'DmPer': formatDecimal(e['DmPer'], decimal: 2),
              'RecPer': formatDecimal(e['RecPer'], decimal: 2),
              'KPc': formatDecimal(e['KPc'], decimal: 0),
              'KWt': formatDecimal(e['KWt'], decimal: 3),
              'BrPc': formatDecimal(e['BrPc'], decimal: 0),
              'BrWt': formatDecimal(e['BrWt'], decimal: 3),
              'LossPc': formatDecimal(e['LossPc'], decimal: 0),
              'LossWt': formatDecimal(e['LossWt'], decimal: 3),
              'TopsPc': formatDecimal(e['TopsPc'], decimal: 0),
              'TopsWt': formatDecimal(e['TopsWt'], decimal: 3),
            },
          )
          .toList(),
    ),

    // ── MAKABLE_DETAIL ─────────────────────────────────────────────────────── 33
    'MAKABLE_DETAIL': ReportConfig(
      reportTypeCode: 'MAKABLE_DETAIL',
      endpoint: '/reports/dept-rec-makable-detail',
      columns: const [
        ReportColumnDef(key: 'ToManager', label: 'To Manager', width: 180),

        ReportColumnDef(key: 'Date', label: 'Date', width: 140),

        ReportColumnDef(key: 'CutNo', label: 'Cut No', width: 140),
        ReportColumnDef(key: 'CutMan', label: 'Cut Man', width: 140),

        ReportColumnDef(key: 'PktNo', label: 'Pkt No', width: 140),
        ReportColumnDef(key: 'BCode', label: 'BCode', width: 140),

        ReportColumnDef(key: 'IssPc', label: 'Iss Pc', width: 140),
        ReportColumnDef(key: 'IssWt', label: 'Iss Wt', width: 140),

        ReportColumnDef(key: 'RecPc', label: 'Rec Pc', width: 140),
        ReportColumnDef(key: 'RecWt', label: 'Rec Wt', width: 140),

        ReportColumnDef(key: 'DmWt', label: 'DM Wt', width: 140),
        ReportColumnDef(key: 'DmPer', label: 'DM %', width: 140),

        ReportColumnDef(key: 'ShapeName', label: 'Shape', width: 140),
        ReportColumnDef(key: 'ColorName', label: 'Color', width: 140),
        ReportColumnDef(key: 'PurityName', label: 'Purity', width: 140),

        ReportColumnDef(key: 'CutName', label: 'Cut', width: 140),

        ReportColumnDef(key: 'Diam', label: 'Diam', width: 140),
        ReportColumnDef(key: 'Acuraecy', label: 'Accuracy', width: 140),

        ReportColumnDef(key: 'AmountRs', label: 'Amount Rs', width: 140),
      ],

      mapper: (raw) => raw.map((e) => {
        'ToManager': e['ToManager'] ?? '-',

        'Date': formatDate(e['Date']),

        'CutNo': e['CutNo'] ?? '-',
        'CutMan': e['CutMan'] ?? '-',

        'PktNo': e['PktNo'] ?? '-',
        'BCode': '${e['BCode'] ?? 0}',

        'IssPc': formatDecimal(e['IssPc'], decimal: 0),
        'IssWt': formatDecimal(e['IssWt'], decimal: 3),

        'RecPc': formatDecimal(e['RecPc'], decimal: 0),
        'RecWt': formatDecimal(e['RecWt'], decimal: 3),

        'DmWt': formatDecimal(e['DmWt'], decimal: 3),
        'DmPer': formatDecimal(e['DmPer'], decimal: 2),

        'ShapeName': e['ShapeName'] ?? '-',
        'ColorName': e['ColorName'] ?? '-',
        'PurityName': e['PurityName'] ?? '-',

        'CutName': e['CutName'] ?? '-',

        'Diam': formatDecimal(e['Diam'], decimal: 2),
        'Acuraecy': formatDecimal(e['Acuraecy'], decimal: 2),

        'AmountRs': formatDecimal(e['AmountRs'], decimal: 2),
      }).toList(),
    ),

    // ── DEPT_CONFIRM_PENDING ─────────────────────────────────────────────────────── 34
    'DEPT_CONFIRM_PENDING': ReportConfig(
      reportTypeCode: 'DEPT_CONFIRM_PENDING',
      endpoint: '/reports/dept-pen-confirm-pending',
      columns: const [
        ReportColumnDef(key: 'Manager', label: 'Manager', width: 180),
        ReportColumnDef(key: 'Pkt', label: 'Pkt', width: 120),
        ReportColumnDef(key: 'Pc', label: 'Pc', width: 120),
        ReportColumnDef(key: 'Wt', label: 'Wt', width: 120),
        ReportColumnDef(key: 'IssPc', label: 'Iss Pc', width: 140),
        ReportColumnDef(key: 'IssWt', label: 'Iss Wt', width: 140),
        ReportColumnDef(key: 'RecPc', label: 'Rec Pc', width: 140),
        ReportColumnDef(key: 'RecWt', label: 'Rec Wt', width: 140),
        ReportColumnDef(key: 'DmWt', label: 'DM Wt', width: 140),
        ReportColumnDef(key: 'DmPer', label: 'DM %', width: 140),
        ReportColumnDef(key: 'RecPer', label: 'Rec %', width: 140),
        ReportColumnDef(key: 'KPc', label: 'K Pc', width: 140),
        ReportColumnDef(key: 'KWt', label: 'K Wt', width: 140),
        ReportColumnDef(key: 'BrPc', label: 'Br Pc', width: 140),
        ReportColumnDef(key: 'BrWt', label: 'Br Wt', width: 140),
        ReportColumnDef(key: 'LossPc', label: 'Loss Pc', width: 140),
        ReportColumnDef(key: 'LossWt', label: 'Loss Wt', width: 140),
        ReportColumnDef(key: 'TopsPc', label: 'Tops Pc', width: 140),
        ReportColumnDef(key: 'TopsWt', label: 'Tops Wt', width: 140),
      ],

      mapper: (raw) => raw
          .map(
            (e) => {
              'Manager': e['Manager'] ?? '-',
              'Pkt': formatDecimal(e['Pkt'], decimal: 0),
              'Pc': formatDecimal(e['Pc'], decimal: 0),
              'Wt': formatDecimal(e['Wt'], decimal: 3),
              'IssPc': formatDecimal(e['IssPc'], decimal: 0),
              'IssWt': formatDecimal(e['IssWt'], decimal: 3),
              'RecPc': formatDecimal(e['RecPc'], decimal: 0),
              'RecWt': formatDecimal(e['RecWt'], decimal: 3),
              'DmWt': formatDecimal(e['DmWt'], decimal: 3),
              'DmPer': formatDecimal(e['DmPer'], decimal: 2),
              'RecPer': formatDecimal(e['RecPer'], decimal: 2),
              'KPc': formatDecimal(e['KPc'], decimal: 0),
              'KWt': formatDecimal(e['KWt'], decimal: 3),
              'BrPc': formatDecimal(e['BrPc'], decimal: 0),
              'BrWt': formatDecimal(e['BrWt'], decimal: 3),
              'LossPc': formatDecimal(e['LossPc'], decimal: 0),
              'LossWt': formatDecimal(e['LossWt'], decimal: 3),
              'TopsPc': formatDecimal(e['TopsPc'], decimal: 0),
              'TopsWt': formatDecimal(e['TopsWt'], decimal: 3),
            },
          )
          .toList(),
    ),

    // ── DEPT_REC_PENDING_SUMMARY ─────────────────────────────────────────────────────── 35
    'DEPT_REC_PENDING_SUMMARY': ReportConfig(
      reportTypeCode: 'DEPT_REC_PENDING_SUMMARY',
      endpoint: '/reports/dept-pen-pending-summary',
      columns: const [
        ReportColumnDef(key: 'MstID', label: 'Mst ID', width: 140),
        ReportColumnDef(key: 'Date', label: 'Date', width: 140),
        ReportColumnDef(key: 'Time', label: 'Time', width: 140),
        ReportColumnDef(key: 'FromMan', label: 'From Manager', width: 180),
        ReportColumnDef(key: 'ToMan', label: 'To Manager', width: 180),
        ReportColumnDef(key: 'DeptProcessName', label: 'Process', width: 180),
        ReportColumnDef(key: 'DeptName', label: 'Department', width: 180),
        ReportColumnDef(key: 'CutNo', label: 'Cut No', width: 140),
        ReportColumnDef(key: 'ClvCut', label: 'Clv Cut', width: 160),
        ReportColumnDef(key: 'ID', label: 'ID', width: 140),
        ReportColumnDef(key: 'Jno', label: 'Jno', width: 140),
        ReportColumnDef(key: 'TotPkt', label: 'Total Pkt', width: 160),
        ReportColumnDef(key: 'Pc', label: 'Pc', width: 120),
        ReportColumnDef(key: 'Wt', label: 'Wt', width: 120),
        ReportColumnDef(key: 'IssPc', label: 'Iss Pc', width: 140),
        ReportColumnDef(key: 'IssWt', label: 'Iss Wt', width: 140),
        ReportColumnDef(key: 'RecPc', label: 'Rec Pc', width: 140),
        ReportColumnDef(key: 'RecWt', label: 'Rec Wt', width: 140),
        ReportColumnDef(key: 'DmWt', label: 'DM Wt', width: 140),
        ReportColumnDef(key: 'DmPer', label: 'DM %', width: 140),
        ReportColumnDef(key: 'RecPer', label: 'Rec %', width: 140),
        ReportColumnDef(key: 'DiffPer', label: 'Diff %', width: 140),
        ReportColumnDef(key: 'LossWt', label: 'Loss Wt', width: 140),
        ReportColumnDef(key: 'LossPer', label: 'Loss %', width: 140),
        ReportColumnDef(key: 'JnoRecPc', label: 'Jno Rec Pc', width: 160),
        ReportColumnDef(key: 'RemarksName', label: 'Remarks', width: 180),
        ReportColumnDef(key: 'ConfRec', label: 'Conf Rec', width: 160),
      ],
      mapper: (raw) => raw
          .map(
            (e) => {
              'MstID': '${e['MstID'] ?? '-'}',
              'Date': formatDate(e['Date']),
              'Time': e['Time'] ?? '-',
              'FromMan': e['FromMan'] ?? '-',
              'ToMan': e['ToMan'] ?? '-',
              'DeptProcessName': e['DeptProcessName'] ?? '-',
              'DeptName': e['DeptName'] ?? '-',
              'CutNo': e['CutNo'] ?? '-',
              'ClvCut': e['ClvCut'] ?? '-',
              'ID': '${e['ID'] ?? 0}',
              'Jno': '${e['Jno'] ?? 0}',
              'TotPkt': formatDecimal(e['TotPkt'], decimal: 0),
              'Pc': formatDecimal(e['Pc'], decimal: 0),
              'Wt': formatDecimal(e['Wt'], decimal: 3),
              'IssPc': formatDecimal(e['IssPc'], decimal: 0),
              'IssWt': formatDecimal(e['IssWt'], decimal: 3),
              'RecPc': formatDecimal(e['RecPc'], decimal: 0),
              'RecWt': formatDecimal(e['RecWt'], decimal: 3),
              'DmWt': formatDecimal(e['DmWt'], decimal: 3),
              'DmPer': formatDecimal(e['DmPer'], decimal: 2),
              'RecPer': formatDecimal(e['RecPer'], decimal: 2),
              'DiffPer': formatDecimal(e['DiffPer'], decimal: 2),
              'LossWt': formatDecimal(e['LossWt'], decimal: 3),
              'LossPer': formatDecimal(e['LossPer'], decimal: 2),
              'JnoRecPc': formatDecimal(e['JnoRecPc'], decimal: 0),
              'RemarksName': e['RemarksName'] ?? '-',
              'ConfRec': e['ConfRec'] ?? '-',
            },
          )
          .toList(),
    ),

   /* Factory Iss.......................................................................... */

    // ── ISSUE_DETAIL ─────────────────────────────────────────────────────── 36
    'ISSUE_DETAIL': ReportConfig(
      reportTypeCode: 'ISSUE_DETAIL',
      endpoint: '/reports/factory-iss-detail',
      columns: const [
        ReportColumnDef(key: 'Jno', label: 'Jno', width: 120),
        ReportColumnDef(key: 'Date', label: 'Date', width: 140),
        ReportColumnDef(key: 'Time', label: 'Time', width: 140),
        ReportColumnDef(key: 'SelectType', label: 'Select Type', width: 180),
        ReportColumnDef(key: 'FactoryName', label: 'Factory Name', width: 180),
        ReportColumnDef(key: 'FactoryType', label: 'Factory Type', width: 180),
        ReportColumnDef(key: 'EntryType', label: 'Entry Type', width: 180),
        ReportColumnDef(key: 'KapanNo', label: 'Kapan No', width: 160),
        ReportColumnDef(key: 'CutNo', label: 'Cut No', width: 140),
        ReportColumnDef(key: 'MfgCut', label: 'Mfg Cut', width: 140),
        ReportColumnDef(key: 'BCode', label: 'BCode', width: 140),
        ReportColumnDef(key: 'PktNo', label: 'Pkt No', width: 140),
        ReportColumnDef(key: 'Pc', label: 'Pc', width: 120),
        ReportColumnDef(key: 'Wt', label: 'Wt', width: 120),
        ReportColumnDef(key: 'IssPc', label: 'Iss Pc', width: 140),
        ReportColumnDef(key: 'IssWt', label: 'Iss Wt', width: 140),
        ReportColumnDef(key: 'DmWt', label: 'DM Wt', width: 140),
        ReportColumnDef(key: 'DmPer', label: 'DM %', width: 140),
        ReportColumnDef(key: 'Size', label: 'Size', width: 140),
        ReportColumnDef(key: 'PurityName', label: 'Purity', width: 140),
        ReportColumnDef(key: 'CharniName', label: 'Charni', width: 140),
        ReportColumnDef(key: 'ColorName', label: 'Color', width: 140),
        ReportColumnDef(key: 'ShapeName', label: 'Shape', width: 140),
        ReportColumnDef(key: 'RateID', label: 'Rate ID', width: 140),
        ReportColumnDef(key: 'Rateon', label: 'Rate On', width: 140),
        ReportColumnDef(key: 'Rate', label: 'Rate', width: 140),
        ReportColumnDef(key: 'Amount', label: 'Amount', width: 140),
        ReportColumnDef(key: 'Rec', label: 'Rec', width: 140),
      ],

      mapper: (raw) => raw.map((e) => {
        'Jno': '${e['Jno'] ?? 0}',
        'Date': formatDate(e['Date']),
        'Time': e['Time'] ?? '-',
        'SelectType': e['SelectType'] ?? '-',
        'FactoryName': e['FactoryName'] ?? '-',
        'FactoryType': e['FactoryType'] ?? '-',
        'EntryType': e['EntryType'] ?? '-',
        'KapanNo': e['KapanNo'] ?? '-',
        'CutNo': e['CutNo'] ?? '-',
        'MfgCut': e['MfgCut'] ?? '-',
        'BCode': '${e['BCode'] ?? 0}',
        'PktNo': e['PktNo'] ?? '-',
        'Pc': formatDecimal(e['Pc'], decimal: 0),
        'Wt': formatDecimal(e['Wt'], decimal: 3),
        'IssPc': formatDecimal(e['IssPc'], decimal: 0),
        'IssWt': formatDecimal(e['IssWt'], decimal: 3),
        'DmWt': formatDecimal(e['DmWt'], decimal: 3),
        'DmPer': formatDecimal(e['DmPer'], decimal: 2),
        'Size': formatDecimal(e['Size'], decimal: 2),
        'PurityName': e['PurityName'] ?? '-',
        'CharniName': e['CharniName'] ?? '-',
        'ColorName': e['ColorName'] ?? '-',
        'ShapeName': e['ShapeName'] ?? '-',
        'RateID': e['RateID'] ?? '-',
        'Rateon': e['Rateon'] ?? '-',
        'Rate': formatDecimal(e['Rate'], decimal: 2),
        'Amount': formatDecimal(e['Amount'], decimal: 2),
        'Rec': e['Rec'] ?? '-',
      }).toList(),
    ),

    // ── ISSUE_KAPANWISE ─────────────────────────────────────────────────────── 37
    'ISSUE_KAPANWISE': ReportConfig(
      reportTypeCode: 'ISSUE_KAPANWISE',
      endpoint: '/reports/factory-iss-kapanwise',
      columns: const [
        ReportColumnDef(key: 'KapanNo', label: 'Kapan No', width: 160),
        ReportColumnDef(key: 'Pkt', label: 'Pkt', width: 140),
        ReportColumnDef(key: 'Pc', label: 'Pc', width: 120),
        ReportColumnDef(key: 'Wt', label: 'Wt', width: 120),
        ReportColumnDef(key: 'IssPc', label: 'Iss Pc', width: 140),
        ReportColumnDef(key: 'IssWt', label: 'Iss Wt', width: 140),
        ReportColumnDef(key: 'DmWt', label: 'DM Wt', width: 140),
        ReportColumnDef(key: 'DmPer', label: 'DM %', width: 140),
        ReportColumnDef(key: 'Size', label: 'Size', width: 120),
      ],
      mapper: (raw) => raw.map((e) => {
        'KapanNo': e['KapanNo'] ?? '-',
        'Pkt': formatDecimal(e['Pkt'], decimal: 0),
        'Pc': formatDecimal(e['Pc'], decimal: 0),
        'Wt': formatDecimal(e['Wt'], decimal: 3),
        'IssPc': formatDecimal(e['IssPc'], decimal: 0),
        'IssWt': formatDecimal(e['IssWt'], decimal: 3),
        'DmWt': formatDecimal(e['DmWt'], decimal: 3),
        'DmPer': formatDecimal(e['DmPer'], decimal: 2),
        'Size': formatDecimal(e['Size'], decimal: 2),
      }).toList(),
    ),

    // ── ISSUE_CUTWISE ─────────────────────────────────────────────────────── 38
    'ISSUE_CUTWISE': ReportConfig(
      reportTypeCode: 'ISSUE_CUTWISE',
      endpoint: '/reports/factory-iss-cutwise',
      columns: const [
        ReportColumnDef(key: 'KapanNo', label: 'Kapan No', width: 160),
        ReportColumnDef(key: 'CutNo', label: 'Cut No', width: 140),
        ReportColumnDef(key: 'CutWt', label: 'Cut Wt', width: 140),
        ReportColumnDef(key: 'Pkt', label: 'Pkt', width: 140),
        ReportColumnDef(key: 'Pc', label: 'Pc', width: 120),
        ReportColumnDef(key: 'Wt', label: 'Wt', width: 120),
        ReportColumnDef(key: 'IssPc', label: 'Iss Pc', width: 140),
        ReportColumnDef(key: 'IssWt', label: 'Iss Wt', width: 140),
        ReportColumnDef(key: 'DmWt', label: 'DM Wt', width: 140),
        ReportColumnDef(key: 'DmPer', label: 'DM %', width: 140),
        ReportColumnDef(key: 'Size', label: 'Size', width: 120),
      ],
      mapper: (raw) => raw.map((e) => {
        'KapanNo': e['KapanNo'] ?? '-',
        'CutNo': e['CutNo'] ?? '-',
        'CutWt': formatDecimal(e['CutWt'], decimal: 3),
        'Pkt': formatDecimal(e['Pkt'], decimal: 0),
        'Pc': formatDecimal(e['Pc'], decimal: 0),
        'Wt': formatDecimal(e['Wt'], decimal: 3),
        'IssPc': formatDecimal(e['IssPc'], decimal: 0),
        'IssWt': formatDecimal(e['IssWt'], decimal: 3),
        'DmWt': formatDecimal(e['DmWt'], decimal: 3),
        'DmPer': formatDecimal(e['DmPer'], decimal: 2),
        'Size': formatDecimal(e['Size'], decimal: 2),
      }).toList(),
    ),

    // ── ISSUE_FACTORYWISE ─────────────────────────────────────────────────────── 39
    'ISSUE_FACTORYWISE': ReportConfig(
      reportTypeCode: 'ISSUE_FACTORYWISE',
      endpoint: '/reports/factory-iss-factorywise',
      columns: const [
        ReportColumnDef(key: 'FactoryName', label: 'Factory Name', width: 180),
        ReportColumnDef(key: 'Pkt', label: 'Pkt', width: 120),
        ReportColumnDef(key: 'Pc', label: 'Pc', width: 120),
        ReportColumnDef(key: 'Wt', label: 'Wt', width: 120),
        ReportColumnDef(key: 'IssPc', label: 'Iss Pc', width: 140),
        ReportColumnDef(key: 'IssWt', label: 'Iss Wt', width: 140),
        ReportColumnDef(key: 'DmWt', label: 'DM Wt', width: 140),
        ReportColumnDef(key: 'DmPer', label: 'DM %', width: 140),
        ReportColumnDef(key: 'Size', label: 'Size', width: 120),
      ],
      mapper: (raw) => raw.map((e) => {
        'FactoryName': e['FactoryName'] ?? '-',
        'Pkt': formatDecimal(e['Pkt'], decimal: 0),
        'Pc': formatDecimal(e['Pc'], decimal: 0),
        'Wt': formatDecimal(e['Wt'], decimal: 3),
        'IssPc': formatDecimal(e['IssPc'], decimal: 0),
        'IssWt': formatDecimal(e['IssWt'], decimal: 3),
        'DmWt': formatDecimal(e['DmWt'], decimal: 3),
        'DmPer': formatDecimal(e['DmPer'], decimal: 2),
        'Size': formatDecimal(e['Size'], decimal: 2),
      }).toList(),
    ),

    // ── ISSUE_DETAIL_[BUNCH_CREATE] ─────────────────────────────────────────────────────── 40
    'ISSUE_DETAIL_[BUNCH_CREATE]': ReportConfig(
      reportTypeCode: 'ISSUE_DETAIL_[BUNCH_CREATE]',
      endpoint: '/reports/factory-iss-bunch-create',
      columns: const [
        ReportColumnDef(key: 'Factory', label: 'Factory', width: 180),
        ReportColumnDef(key: 'Pc', label: 'Pc', width: 120),
        ReportColumnDef(key: 'Wt', label: 'Wt', width: 120),
        ReportColumnDef(key: 'IssPc', label: 'Iss Pc', width: 140),
        ReportColumnDef(key: 'IssWt', label: 'Iss Wt', width: 140),
        ReportColumnDef(key: 'DmWt', label: 'DM Wt', width: 140),
        ReportColumnDef(key: 'DmPer', label: 'DM %', width: 140),
        ReportColumnDef(key: 'RateID', label: 'Rate ID', width: 140),
        ReportColumnDef(key: 'Rateon', label: 'Rate On', width: 140),
        ReportColumnDef(key: 'Rate', label: 'Rate', width: 120),
        ReportColumnDef(key: 'Amount', label: 'Amount', width: 140),
      ],
      mapper: (raw) => raw.map((e) => {
        'Factory': e['Factory'] ?? '-',
        'Pc': formatDecimal(e['Pc'], decimal: 0),
        'Wt': formatDecimal(e['Wt'], decimal: 3),
        'IssPc': formatDecimal(e['IssPc'], decimal: 0),
        'IssWt': formatDecimal(e['IssWt'], decimal: 3),
        'DmWt': formatDecimal(e['DmWt'], decimal: 3),
        'DmPer': formatDecimal(e['DmPer'], decimal: 2),
        'RateID': e['RateID'] ?? '-',
        'Rateon': e['Rateon'] ?? '-',
        'Rate': formatDecimal(e['Rate'], decimal: 2),
        'Amount': formatDecimal(e['Amount'], decimal: 2),
      }).toList(),
    ),

    // ── FACTORY_ISS_LABOUR_SUMMARY ─────────────────────────────────────────────────────── 41
    'FACTORY_ISS_LABOUR_SUMMARY': ReportConfig(
      reportTypeCode: 'FACTORY_ISS_LABOUR_SUMMARY',
      endpoint: '/reports/factory-iss-labour-summary',
      columns: const [
        ReportColumnDef(key: 'Factory', label: 'Factory', width: 180),
        ReportColumnDef(key: 'Pc', label: 'Pc', width: 120),
        ReportColumnDef(key: 'Wt', label: 'Wt', width: 120),
        ReportColumnDef(key: 'IssPc', label: 'Iss Pc', width: 140),
        ReportColumnDef(key: 'IssWt', label: 'Iss Wt', width: 140),
        ReportColumnDef(key: 'DmWt', label: 'DM Wt', width: 140),
        ReportColumnDef(key: 'DmPer', label: 'DM %', width: 140),
        ReportColumnDef(key: 'RateID', label: 'Rate ID', width: 140),
        ReportColumnDef(key: 'Rateon', label: 'Rate On', width: 140),
        ReportColumnDef(key: 'Rate', label: 'Rate', width: 120),
        ReportColumnDef(key: 'Amount', label: 'Amount', width: 140),
      ],
      mapper: (raw) => raw.map((e) => {
        'Factory': e['Factory'] ?? '-',
        'Pc': formatDecimal(e['Pc'], decimal: 0),
        'Wt': formatDecimal(e['Wt'], decimal: 3),
        'IssPc': formatDecimal(e['IssPc'], decimal: 0),
        'IssWt': formatDecimal(e['IssWt'], decimal: 3),
        'DmWt': formatDecimal(e['DmWt'], decimal: 3),
        'DmPer': formatDecimal(e['DmPer'], decimal: 2),
        'RateID': e['RateID'] ?? '-',
        'Rateon': e['Rateon'] ?? '-',
        'Rate': formatDecimal(e['Rate'], decimal: 2),
        'Amount': formatDecimal(e['Amount'], decimal: 2),
      }).toList(),
    ),


    /* Factory Rec.......................................................................... */

    // ── RECEIVE_DETAIL ─────────────────────────────────────────────────────── 42
    'RECEIVE_DETAIL': ReportConfig(
      reportTypeCode: 'RECEIVE_DETAIL',
      endpoint: '/reports/factory-rec-detail',
      columns: const [
        ReportColumnDef(key: 'Jno', label: 'Jno', width: 120),
        ReportColumnDef(key: 'Date', label: 'Date', width: 140),
        ReportColumnDef(key: 'Time', label: 'Time', width: 140),

        ReportColumnDef(key: 'FactoryName', label: 'Factory Name', width: 180),

        ReportColumnDef(key: 'KapanNo', label: 'Kapan No', width: 160),
        ReportColumnDef(key: 'CutNo', label: 'Cut No', width: 140),

        ReportColumnDef(key: 'BCode', label: 'BCode', width: 140),
        ReportColumnDef(key: 'PktNo', label: 'Pkt No', width: 140),

        ReportColumnDef(key: 'Pc', label: 'Pc', width: 120),
        ReportColumnDef(key: 'Wt', label: 'Wt', width: 120),

        ReportColumnDef(key: 'IssPc', label: 'Iss Pc', width: 140),
        ReportColumnDef(key: 'IssWt', label: 'Iss Wt', width: 140),

        ReportColumnDef(key: 'GhatWt', label: 'Ghat Wt', width: 140),

        ReportColumnDef(key: 'DmWt', label: 'DM Wt', width: 140),
        ReportColumnDef(key: 'DmPer', label: 'DM %', width: 140),

        ReportColumnDef(key: 'RecPc', label: 'Rec Pc', width: 140),
        ReportColumnDef(key: 'RecWt', label: 'Rec Wt', width: 140),
        ReportColumnDef(key: 'RecPer', label: 'Rec %', width: 140),

        ReportColumnDef(key: 'DiffPer', label: 'Diff %', width: 140),
        ReportColumnDef(key: 'PolishLossPer', label: 'Polish Loss %', width: 180),

        ReportColumnDef(key: 'GhatDmGunak', label: 'Ghat DM Gunak', width: 180),
        ReportColumnDef(key: 'GhatWtPer', label: 'Ghat Wt %', width: 180),

        ReportColumnDef(key: 'RusianWt', label: 'Rusian Wt', width: 160),
        ReportColumnDef(key: 'RusianPer', label: 'Rusian %', width: 160),
        ReportColumnDef(key: 'GhatRusianPer', label: 'Ghat Rusian %', width: 180),

        ReportColumnDef(key: 'Size', label: 'Size', width: 140),
        ReportColumnDef(key: 'PolishSize', label: 'Polish Size', width: 140),

        ReportColumnDef(key: 'KPc', label: 'K Pc', width: 140),
        ReportColumnDef(key: 'KWt', label: 'K Wt', width: 140),

        ReportColumnDef(key: 'BrPc', label: 'Br Pc', width: 140),
        ReportColumnDef(key: 'BrWt', label: 'Br Wt', width: 140),

        ReportColumnDef(key: 'LossPc', label: 'Loss Pc', width: 140),
        ReportColumnDef(key: 'LossWt', label: 'Loss Wt', width: 140),

        ReportColumnDef(key: 'DiffWt', label: 'Diff Wt', width: 140),
        ReportColumnDef(key: 'DiffDmWt', label: 'Diff DM Wt', width: 140),
        ReportColumnDef(key: 'DiffDmPer', label: 'Diff DM %', width: 140),

        ReportColumnDef(key: 'GDmWt', label: 'G DM Wt', width: 140),
        ReportColumnDef(key: 'GDmPer', label: 'G DM %', width: 140),
        ReportColumnDef(key: 'GDiffPer', label: 'G Diff %', width: 140),

        ReportColumnDef(key: 'PoDiffPer', label: 'Po Diff %', width: 140),

        ReportColumnDef(key: 'PurityName', label: 'Purity', width: 140),
        ReportColumnDef(key: 'CharniName', label: 'Charni', width: 140),
        ReportColumnDef(key: 'ColorName', label: 'Color', width: 140),
        ReportColumnDef(key: 'ShapeName', label: 'Shape', width: 140),

        ReportColumnDef(key: 'SarinEmp', label: 'Sarin Emp', width: 140),
        ReportColumnDef(key: 'StichEmp', label: 'Stich Emp', width: 140),
        ReportColumnDef(key: 'OptEmp', label: 'Opt Emp', width: 140),

        ReportColumnDef(key: 'RateID', label: 'Rate ID', width: 140),
        ReportColumnDef(key: 'Rateon', label: 'Rate On', width: 140),
        ReportColumnDef(key: 'Rate', label: 'Rate', width: 140),
        ReportColumnDef(key: 'Amount', label: 'Amount', width: 140),
      ],
      mapper: (raw) => raw.map((e) => {
        'Jno': '${e['Jno'] ?? 0}',
        'Date': formatDate(e['Date']),
        'Time': e['Time'] ?? '-',

        'FactoryName': e['FactoryName'] ?? '-',

        'KapanNo': e['KapanNo'] ?? '-',
        'CutNo': e['CutNo'] ?? '-',

        'BCode': '${e['BCode'] ?? 0}',
        'PktNo': e['PktNo'] ?? '-',

        'Pc': formatDecimal(e['Pc'], decimal: 0),
        'Wt': formatDecimal(e['Wt'], decimal: 3),

        'IssPc': formatDecimal(e['IssPc'], decimal: 0),
        'IssWt': formatDecimal(e['IssWt'], decimal: 3),

        'GhatWt': formatDecimal(e['GhatWt'], decimal: 3),

        'DmWt': formatDecimal(e['DmWt'], decimal: 3),
        'DmPer': formatDecimal(e['DmPer'], decimal: 2),

        'RecPc': formatDecimal(e['RecPc'], decimal: 0),
        'RecWt': formatDecimal(e['RecWt'], decimal: 3),
        'RecPer': formatDecimal(e['RecPer'], decimal: 2),

        'DiffPer': formatDecimal(e['DiffPer'], decimal: 2),
        'PolishLossPer': formatDecimal(e['PolishLossPer'], decimal: 2),

        'GhatDmGunak': formatDecimal(e['GhatDmGunak'], decimal: 2),
        'GhatWtPer': formatDecimal(e['GhatWtPer'], decimal: 2),

        'RusianWt': formatDecimal(e['RusianWt'], decimal: 3),
        'RusianPer': formatDecimal(e['RusianPer'], decimal: 2),
        'GhatRusianPer': formatDecimal(e['GhatRusianPer'], decimal: 2),

        'Size': formatDecimal(e['Size'], decimal: 2),
        'PolishSize': formatDecimal(e['PolishSize'], decimal: 2),

        'KPc': formatDecimal(e['KPc'], decimal: 0),
        'KWt': formatDecimal(e['KWt'], decimal: 3),

        'BrPc': formatDecimal(e['BrPc'], decimal: 0),
        'BrWt': formatDecimal(e['BrWt'], decimal: 3),

        'LossPc': formatDecimal(e['LossPc'], decimal: 0),
        'LossWt': formatDecimal(e['LossWt'], decimal: 3),

        'DiffWt': formatDecimal(e['DiffWt'], decimal: 3),
        'DiffDmWt': formatDecimal(e['DiffDmWt'], decimal: 3),
        'DiffDmPer': formatDecimal(e['DiffDmPer'], decimal: 2),

        'GDmWt': formatDecimal(e['GDmWt'], decimal: 3),
        'GDmPer': formatDecimal(e['GDmPer'], decimal: 2),
        'GDiffPer': formatDecimal(e['GDiffPer'], decimal: 2),

        'PoDiffPer': formatDecimal(e['PoDiffPer'], decimal: 2),

        'PurityName': e['PurityName'] ?? '-',
        'CharniName': e['CharniName'] ?? '-',
        'ColorName': e['ColorName'] ?? '-',
        'ShapeName': e['ShapeName'] ?? '-',

        'SarinEmp': e['SarinEmp'] ?? '-',
        'StichEmp': e['StichEmp'] ?? '-',
        'OptEmp': e['OptEmp'] ?? '-',

        'RateID': e['RateID'] ?? '-',
        'Rateon': e['Rateon'] ?? '-',
        'Rate': formatDecimal(e['Rate'], decimal: 2),
        'Amount': formatDecimal(e['Amount'], decimal: 2),
      }).toList(),
    ),

    // ── REC_KAPANWISE ─────────────────────────────────────────────────────── 43
    'REC_KAPANWISE': ReportConfig(
      reportTypeCode: 'REC_KAPANWISE',
      endpoint: '/reports/factory-rec-kapanwise',
      columns: const [
        ReportColumnDef(key: 'KapanNo', label: 'Kapan No', width: 160),
        ReportColumnDef(key: 'Pkt', label: 'Pkt', width: 140),
        ReportColumnDef(key: 'Pc', label: 'Pc', width: 120),
        ReportColumnDef(key: 'Wt', label: 'Wt', width: 120),
        ReportColumnDef(key: 'IssPc', label: 'Iss Pc', width: 140),
        ReportColumnDef(key: 'IssWt', label: 'Iss Wt', width: 140),
        ReportColumnDef(key: 'DmWt', label: 'DM Wt', width: 140),
        ReportColumnDef(key: 'DmPer', label: 'DM %', width: 140),
        ReportColumnDef(key: 'Size', label: 'Size', width: 120),
      ],
      mapper: (raw) => raw.map((e) => {
        'KapanNo': e['KapanNo'] ?? '-',
        'Pkt': formatDecimal(e['Pkt'], decimal: 0),
        'Pc': formatDecimal(e['Pc'], decimal: 0),
        'Wt': formatDecimal(e['Wt'], decimal: 3),
        'IssPc': formatDecimal(e['IssPc'], decimal: 0),
        'IssWt': formatDecimal(e['IssWt'], decimal: 3),
        'DmWt': formatDecimal(e['DmWt'], decimal: 3),
        'DmPer': formatDecimal(e['DmPer'], decimal: 2),
        'Size': formatDecimal(e['Size'], decimal: 2),
      }).toList(),
    ),

    // ── REC_CUTWISE ─────────────────────────────────────────────────────── 44
    'REC_CUTWISE': ReportConfig(
      reportTypeCode: 'REC_CUTWISE',
      endpoint: '/reports/factory-rec-cutwise',
      columns: const [
        ReportColumnDef(key: 'KapanNo', label: 'Kapan No', width: 160),
        ReportColumnDef(key: 'CutNo', label: 'Cut No', width: 140),
        ReportColumnDef(key: 'CutWt', label: 'Cut Wt', width: 140),
        ReportColumnDef(key: 'Pkt', label: 'Pkt', width: 140),
        ReportColumnDef(key: 'Pc', label: 'Pc', width: 120),
        ReportColumnDef(key: 'Wt', label: 'Wt', width: 120),
        ReportColumnDef(key: 'IssPc', label: 'Iss Pc', width: 140),
        ReportColumnDef(key: 'IssWt', label: 'Iss Wt', width: 140),
        ReportColumnDef(key: 'DmWt', label: 'DM Wt', width: 140),
        ReportColumnDef(key: 'DmPer', label: 'DM %', width: 140),
        ReportColumnDef(key: 'Size', label: 'Size', width: 120),
      ],
      mapper: (raw) => raw.map((e) => {
        'KapanNo': e['KapanNo'] ?? '-',
        'CutNo': e['CutNo'] ?? '-',
        'CutWt': formatDecimal(e['CutWt'], decimal: 3),
        'Pkt': formatDecimal(e['Pkt'], decimal: 0),
        'Pc': formatDecimal(e['Pc'], decimal: 0),
        'Wt': formatDecimal(e['Wt'], decimal: 3),
        'IssPc': formatDecimal(e['IssPc'], decimal: 0),
        'IssWt': formatDecimal(e['IssWt'], decimal: 3),
        'DmWt': formatDecimal(e['DmWt'], decimal: 3),
        'DmPer': formatDecimal(e['DmPer'], decimal: 2),
        'Size': formatDecimal(e['Size'], decimal: 2),
      }).toList(),
    ),

    // ── REC_FACTORYWISE ─────────────────────────────────────────────────────── 45
    'REC_FACTORYWISE': ReportConfig(
      reportTypeCode: 'REC_FACTORYWISE',
      endpoint: '/reports/factory-rec-factorywise',
      columns: const [
        ReportColumnDef(key: 'FactoryName', label: 'Factory Name', width: 180),
        ReportColumnDef(key: 'Pkt', label: 'Pkt', width: 120),
        ReportColumnDef(key: 'Pc', label: 'Pc', width: 120),
        ReportColumnDef(key: 'Wt', label: 'Wt', width: 120),
        ReportColumnDef(key: 'IssPc', label: 'Iss Pc', width: 140),
        ReportColumnDef(key: 'IssWt', label: 'Iss Wt', width: 140),
        ReportColumnDef(key: 'DmWt', label: 'DM Wt', width: 140),
        ReportColumnDef(key: 'DmPer', label: 'DM %', width: 140),
        ReportColumnDef(key: 'Size', label: 'Size', width: 120),
      ],
      mapper: (raw) => raw.map((e) => {
        'FactoryName': e['FactoryName'] ?? '-',
        'Pkt': formatDecimal(e['Pkt'], decimal: 0),
        'Pc': formatDecimal(e['Pc'], decimal: 0),
        'Wt': formatDecimal(e['Wt'], decimal: 3),
        'IssPc': formatDecimal(e['IssPc'], decimal: 0),
        'IssWt': formatDecimal(e['IssWt'], decimal: 3),
        'DmWt': formatDecimal(e['DmWt'], decimal: 3),
        'DmPer': formatDecimal(e['DmPer'], decimal: 2),
        'Size': formatDecimal(e['Size'], decimal: 2),
      }).toList(),
    ),

    // ── RECEIVE_DETAIL_[BUNCH_CREATE] ─────────────────────────────────────────────────────── 46
    'RECEIVE_DETAIL_[BUNCH_CREATE]': ReportConfig(
      reportTypeCode: 'RECEIVE_DETAIL_[BUNCH_CREATE]',
      endpoint: '/reports/factory-rec-bunch-create',
      columns: const [
        ReportColumnDef(key: 'Factory', label: 'Factory', width: 180),
        ReportColumnDef(key: 'Pc', label: 'Pc', width: 120),
        ReportColumnDef(key: 'Wt', label: 'Wt', width: 120),
        ReportColumnDef(key: 'IssPc', label: 'Iss Pc', width: 140),
        ReportColumnDef(key: 'IssWt', label: 'Iss Wt', width: 140),
        ReportColumnDef(key: 'DmWt', label: 'DM Wt', width: 140),
        ReportColumnDef(key: 'DmPer', label: 'DM %', width: 140),
        ReportColumnDef(key: 'RateID', label: 'Rate ID', width: 140),
        ReportColumnDef(key: 'Rateon', label: 'Rate On', width: 140),
        ReportColumnDef(key: 'Rate', label: 'Rate', width: 120),
        ReportColumnDef(key: 'Amount', label: 'Amount', width: 140),
      ],
      mapper: (raw) => raw.map((e) => {
        'Factory': e['Factory'] ?? '-',
        'Pc': formatDecimal(e['Pc'], decimal: 0),
        'Wt': formatDecimal(e['Wt'], decimal: 3),
        'IssPc': formatDecimal(e['IssPc'], decimal: 0),
        'IssWt': formatDecimal(e['IssWt'], decimal: 3),
        'DmWt': formatDecimal(e['DmWt'], decimal: 3),
        'DmPer': formatDecimal(e['DmPer'], decimal: 2),
        'RateID': e['RateID'] ?? '-',
        'Rateon': e['Rateon'] ?? '-',
        'Rate': formatDecimal(e['Rate'], decimal: 2),
        'Amount': formatDecimal(e['Amount'], decimal: 2),
      }).toList(),
    ),

    // ── FACTORY_REC_LABOUR_SUMMARY ─────────────────────────────────────────────────────── 47
    'FACTORY_REC_LABOUR_SUMMARY': ReportConfig(
      reportTypeCode: 'FACTORY_REC_LABOUR_SUMMARY',
      endpoint: '/reports/factory-rec-labour-summary',
      columns: const [
        ReportColumnDef(key: 'Factory', label: 'Factory', width: 180),
        ReportColumnDef(key: 'Pc', label: 'Pc', width: 120),
        ReportColumnDef(key: 'Wt', label: 'Wt', width: 120),
        ReportColumnDef(key: 'IssPc', label: 'Iss Pc', width: 140),
        ReportColumnDef(key: 'IssWt', label: 'Iss Wt', width: 140),
        ReportColumnDef(key: 'DmWt', label: 'DM Wt', width: 140),
        ReportColumnDef(key: 'DmPer', label: 'DM %', width: 140),
        ReportColumnDef(key: 'RateID', label: 'Rate ID', width: 140),
        ReportColumnDef(key: 'Rateon', label: 'Rate On', width: 140),
        ReportColumnDef(key: 'Rate', label: 'Rate', width: 120),
        ReportColumnDef(key: 'Amount', label: 'Amount', width: 140),
      ],
      mapper: (raw) => raw.map((e) => {
        'Factory': e['Factory'] ?? '-',
        'Pc': formatDecimal(e['Pc'], decimal: 0),
        'Wt': formatDecimal(e['Wt'], decimal: 3),
        'IssPc': formatDecimal(e['IssPc'], decimal: 0),
        'IssWt': formatDecimal(e['IssWt'], decimal: 3),
        'DmWt': formatDecimal(e['DmWt'], decimal: 3),
        'DmPer': formatDecimal(e['DmPer'], decimal: 2),
        'RateID': e['RateID'] ?? '-',
        'Rateon': e['Rateon'] ?? '-',
        'Rate': formatDecimal(e['Rate'], decimal: 2),
        'Amount': formatDecimal(e['Amount'], decimal: 2),
      }).toList(),
    ),


    // ── REC_DATEWISE ─────────────────────────────────────────────────────── 48
    'REC_DATEWISE': ReportConfig(
      reportTypeCode: 'REC_DATEWISE',
      endpoint: '/reports/factory-rec-datewise',
      columns: const [
        ReportColumnDef(key: 'Date', label: 'Date', width: 140),

        ReportColumnDef(key: 'Pkt', label: 'Pkt', width: 140),

        ReportColumnDef(key: 'Pc', label: 'Pc', width: 120),
        ReportColumnDef(key: 'Wt', label: 'Wt', width: 120),

        ReportColumnDef(key: 'IssPc', label: 'Iss Pc', width: 140),
        ReportColumnDef(key: 'IssWt', label: 'Iss Wt', width: 140),

        ReportColumnDef(key: 'RecPc', label: 'Rec Pc', width: 140),
        ReportColumnDef(key: 'RecWt', label: 'Rec Wt', width: 140),
        ReportColumnDef(key: 'RecPer', label: 'Rec %', width: 140),

        ReportColumnDef(key: 'KPc', label: 'K Pc', width: 140),
        ReportColumnDef(key: 'KWt', label: 'K Wt', width: 140),

        ReportColumnDef(key: 'BrPc', label: 'Br Pc', width: 140),
        ReportColumnDef(key: 'BrWt', label: 'Br Wt', width: 140),

        ReportColumnDef(key: 'LossPc', label: 'Loss Pc', width: 140),
        ReportColumnDef(key: 'LossWt', label: 'Loss Wt', width: 140),

        ReportColumnDef(key: 'DmWt', label: 'DM Wt', width: 140),
        ReportColumnDef(key: 'DmPer', label: 'DM %', width: 140),

        ReportColumnDef(key: 'DiffWt', label: 'Diff Wt', width: 140),
        ReportColumnDef(key: 'DiffPer', label: 'Diff %', width: 140),

        ReportColumnDef(key: 'Size', label: 'Size', width: 140),
        ReportColumnDef(key: 'PoDiffPer', label: 'Po Diff %', width: 140),
      ],
      mapper: (raw) => raw.map((e) => {
        'Date': formatDate(e['Date']),

        'Pkt': formatDecimal(e['Pkt'], decimal: 0),

        'Pc': formatDecimal(e['Pc'], decimal: 0),
        'Wt': formatDecimal(e['Wt'], decimal: 3),

        'IssPc': formatDecimal(e['IssPc'], decimal: 0),
        'IssWt': formatDecimal(e['IssWt'], decimal: 3),

        'RecPc': formatDecimal(e['RecPc'], decimal: 0),
        'RecWt': formatDecimal(e['RecWt'], decimal: 3),
        'RecPer': formatDecimal(e['RecPer'], decimal: 2),

        'KPc': formatDecimal(e['KPc'], decimal: 0),
        'KWt': formatDecimal(e['KWt'], decimal: 3),

        'BrPc': formatDecimal(e['BrPc'], decimal: 0),
        'BrWt': formatDecimal(e['BrWt'], decimal: 3),

        'LossPc': formatDecimal(e['LossPc'], decimal: 0),
        'LossWt': formatDecimal(e['LossWt'], decimal: 3),

        'DmWt': formatDecimal(e['DmWt'], decimal: 3),
        'DmPer': formatDecimal(e['DmPer'], decimal: 2),

        'DiffWt': formatDecimal(e['DiffWt'], decimal: 3),
        'DiffPer': formatDecimal(e['DiffPer'], decimal: 2),

        'Size': formatDecimal(e['Size'], decimal: 2),
        'PoDiffPer': formatDecimal(e['PoDiffPer'], decimal: 2),
      }).toList(),
    ),

    // ── REC_STICH_EMP_SUMMARY ─────────────────────────────────────────────────────── 49
    'REC_STICH_EMP_SUMMARY': ReportConfig(
      reportTypeCode: 'REC_STICH_EMP_SUMMARY',
      endpoint: '/reports/factory-rec-stich-emp-summary',
      columns: const [
        ReportColumnDef(key: 'StichEmp', label: 'Stich Emp', width: 180),

        ReportColumnDef(key: 'Pkt', label: 'Pkt', width: 140),

        ReportColumnDef(key: 'Pc', label: 'Pc', width: 120),
        ReportColumnDef(key: 'Wt', label: 'Wt', width: 120),

        ReportColumnDef(key: 'IssPc', label: 'Iss Pc', width: 140),
        ReportColumnDef(key: 'IssWt', label: 'Iss Wt', width: 140),

        ReportColumnDef(key: 'GhatWt', label: 'Ghat Wt', width: 140),

        ReportColumnDef(key: 'RecPc', label: 'Rec Pc', width: 140),
        ReportColumnDef(key: 'RecWt', label: 'Rec Wt', width: 140),
        ReportColumnDef(key: 'RecPer', label: 'Rec %', width: 140),

        ReportColumnDef(key: 'KPc', label: 'K Pc', width: 140),
        ReportColumnDef(key: 'KWt', label: 'K Wt', width: 140),

        ReportColumnDef(key: 'BrPc', label: 'Br Pc', width: 140),
        ReportColumnDef(key: 'BrWt', label: 'Br Wt', width: 140),

        ReportColumnDef(key: 'LossPc', label: 'Loss Pc', width: 140),
        ReportColumnDef(key: 'LossWt', label: 'Loss Wt', width: 140),

        ReportColumnDef(key: 'DmWt', label: 'DM Wt', width: 140),
        ReportColumnDef(key: 'DmPer', label: 'DM %', width: 140),

        ReportColumnDef(key: 'DiffWt', label: 'Diff Wt', width: 140),
        ReportColumnDef(key: 'DiffPer', label: 'Diff %', width: 140),

        ReportColumnDef(key: 'GP', label: 'GP', width: 140),
        ReportColumnDef(key: 'GD', label: 'GD', width: 140),
        ReportColumnDef(key: 'GhatDiff', label: 'Ghat Diff', width: 140),

        ReportColumnDef(key: 'Size', label: 'Size', width: 140),
        ReportColumnDef(key: 'PoDiffPer', label: 'Po Diff %', width: 140),
      ],
      mapper: (raw) => raw.map((e) => {
        'StichEmp': e['StichEmp'] ?? '-',

        'Pkt': formatDecimal(e['Pkt'], decimal: 0),

        'Pc': formatDecimal(e['Pc'], decimal: 0),
        'Wt': formatDecimal(e['Wt'], decimal: 3),

        'IssPc': formatDecimal(e['IssPc'], decimal: 0),
        'IssWt': formatDecimal(e['IssWt'], decimal: 3),

        'GhatWt': formatDecimal(e['GhatWt'], decimal: 3),

        'RecPc': formatDecimal(e['RecPc'], decimal: 0),
        'RecWt': formatDecimal(e['RecWt'], decimal: 3),
        'RecPer': formatDecimal(e['RecPer'], decimal: 2),

        'KPc': formatDecimal(e['KPc'], decimal: 0),
        'KWt': formatDecimal(e['KWt'], decimal: 3),

        'BrPc': formatDecimal(e['BrPc'], decimal: 0),
        'BrWt': formatDecimal(e['BrWt'], decimal: 3),

        'LossPc': formatDecimal(e['LossPc'], decimal: 0),
        'LossWt': formatDecimal(e['LossWt'], decimal: 3),

        'DmWt': formatDecimal(e['DmWt'], decimal: 3),
        'DmPer': formatDecimal(e['DmPer'], decimal: 2),

        'DiffWt': formatDecimal(e['DiffWt'], decimal: 3),
        'DiffPer': formatDecimal(e['DiffPer'], decimal: 2),

        'GP': formatDecimal(e['GP'], decimal: 2),
        'GD': formatDecimal(e['GD'], decimal: 2),
        'GhatDiff': formatDecimal(e['GhatDiff'], decimal: 2),

        'Size': formatDecimal(e['Size'], decimal: 2),
        'PoDiffPer': formatDecimal(e['PoDiffPer'], decimal: 2),
      }).toList(),
    ),

    // ── REC_OPT_EMP_SUMMARY ─────────────────────────────────────────────────────── 50
    'REC_OPT_EMP_SUMMARY': ReportConfig(
      reportTypeCode: 'REC_OPT_EMP_SUMMARY',
      endpoint: '/reports/factory-rec-opt-emp-summary',
      columns: const [
        ReportColumnDef(key: 'OptEmp', label: 'Opt Emp', width: 180),

        ReportColumnDef(key: 'Pkt', label: 'Pkt', width: 140),

        ReportColumnDef(key: 'Pc', label: 'Pc', width: 120),
        ReportColumnDef(key: 'Wt', label: 'Wt', width: 120),

        ReportColumnDef(key: 'IssPc', label: 'Iss Pc', width: 140),
        ReportColumnDef(key: 'IssWt', label: 'Iss Wt', width: 140),

        ReportColumnDef(key: 'GhatWt', label: 'Ghat Wt', width: 140),

        ReportColumnDef(key: 'RecPc', label: 'Rec Pc', width: 140),
        ReportColumnDef(key: 'RecWt', label: 'Rec Wt', width: 140),
        ReportColumnDef(key: 'RecPer', label: 'Rec %', width: 140),

        ReportColumnDef(key: 'KPc', label: 'K Pc', width: 140),
        ReportColumnDef(key: 'KWt', label: 'K Wt', width: 140),

        ReportColumnDef(key: 'BrPc', label: 'Br Pc', width: 140),
        ReportColumnDef(key: 'BrWt', label: 'Br Wt', width: 140),

        ReportColumnDef(key: 'LossPc', label: 'Loss Pc', width: 140),
        ReportColumnDef(key: 'LossWt', label: 'Loss Wt', width: 140),

        ReportColumnDef(key: 'DmWt', label: 'DM Wt', width: 140),
        ReportColumnDef(key: 'DmPer', label: 'DM %', width: 140),

        ReportColumnDef(key: 'DiffWt', label: 'Diff Wt', width: 140),
        ReportColumnDef(key: 'DiffPer', label: 'Diff %', width: 140),

        ReportColumnDef(key: 'PolishLossPer', label: 'Polish Loss %', width: 140),

        ReportColumnDef(key: 'GP', label: 'GP', width: 140),
        ReportColumnDef(key: 'GD', label: 'GD', width: 140),
        ReportColumnDef(key: 'GhatDiff', label: 'Ghat Diff', width: 140),

        ReportColumnDef(key: 'Size', label: 'Size', width: 140),
        ReportColumnDef(key: 'PoDiffPer', label: 'Po Diff %', width: 140),
      ],
      mapper: (raw) => raw.map((e) => {
        'OptEmp': e['OptEmp'] ?? '-',

        'Pkt': formatDecimal(e['Pkt'], decimal: 0),

        'Pc': formatDecimal(e['Pc'], decimal: 0),
        'Wt': formatDecimal(e['Wt'], decimal: 3),

        'IssPc': formatDecimal(e['IssPc'], decimal: 0),
        'IssWt': formatDecimal(e['IssWt'], decimal: 3),

        'GhatWt': formatDecimal(e['GhatWt'], decimal: 3),

        'RecPc': formatDecimal(e['RecPc'], decimal: 0),
        'RecWt': formatDecimal(e['RecWt'], decimal: 3),
        'RecPer': formatDecimal(e['RecPer'], decimal: 2),

        'KPc': formatDecimal(e['KPc'], decimal: 0),
        'KWt': formatDecimal(e['KWt'], decimal: 3),

        'BrPc': formatDecimal(e['BrPc'], decimal: 0),
        'BrWt': formatDecimal(e['BrWt'], decimal: 3),

        'LossPc': formatDecimal(e['LossPc'], decimal: 0),
        'LossWt': formatDecimal(e['LossWt'], decimal: 3),

        'DmWt': formatDecimal(e['DmWt'], decimal: 3),
        'DmPer': formatDecimal(e['DmPer'], decimal: 2),

        'DiffWt': formatDecimal(e['DiffWt'], decimal: 3),
        'DiffPer': formatDecimal(e['DiffPer'], decimal: 2),

        'PolishLossPer': formatDecimal(e['PolishLossPer'], decimal: 2),

        'GP': formatDecimal(e['GP'], decimal: 2),
        'GD': formatDecimal(e['GD'], decimal: 2),
        'GhatDiff': formatDecimal(e['GhatDiff'], decimal: 2),

        'Size': formatDecimal(e['Size'], decimal: 2),
        'PoDiffPer': formatDecimal(e['PoDiffPer'], decimal: 2),
      }).toList(),
    ),


    /* Factory pending .......................................................................... */

    // ── ISSUE_PENDING ─────────────────────────────────────────────────────── 51
    'ISSUE_PENDING': ReportConfig(
      reportTypeCode: 'ISSUE_PENDING',
      endpoint: '/reports/factory-pen-issue-pending',
      columns: const [
        ReportColumnDef(key: 'CutNo', label: 'Cut No', width: 140),
        ReportColumnDef(key: 'BCode', label: 'BCode', width: 140),
        ReportColumnDef(key: 'LotNo', label: 'Lot No', width: 140),

        ReportColumnDef(key: 'Pc', label: 'Pc', width: 120),
        ReportColumnDef(key: 'Wt', label: 'Wt', width: 120),

        ReportColumnDef(key: 'DmWt', label: 'DM Wt', width: 140),
        ReportColumnDef(key: 'DmPer', label: 'DM %', width: 140),

        ReportColumnDef(key: 'EntryType', label: 'Entry Type', width: 180),

        ReportColumnDef(key: 'ShapeName', label: 'Shape', width: 140),
        ReportColumnDef(key: 'PurityName', label: 'Purity', width: 140),
      ],
      mapper: (raw) => raw.map((e) => {
        'CutNo': e['CutNo'] ?? '-',

        'BCode': '${e['BCode'] ?? 0}',
        'LotNo': '${e['LotNo'] ?? 0}',

        'Pc': formatDecimal(e['Pc'], decimal: 0),
        'Wt': formatDecimal(e['Wt'], decimal: 3),

        'DmWt': formatDecimal(e['DmWt'], decimal: 3),
        'DmPer': formatDecimal(e['DmPer'], decimal: 2),

        'EntryType': e['EntryType'] ?? '-',

        'ShapeName': e['ShapeName'] ?? '-',
        'PurityName': e['PurityName'] ?? '-',
      }).toList(),
    ),

    // ── JAMA_PENDING ─────────────────────────────────────────────────────── 52
    'JAMA_PENDING': ReportConfig(
      reportTypeCode: 'JAMA_PENDING',
      endpoint: '/reports/factory-pen-jama-pending',
      columns: const [
        ReportColumnDef(key: 'Jno', label: 'Jno', width: 120),
        ReportColumnDef(key: 'Date', label: 'Date', width: 140),
        ReportColumnDef(key: 'Time', label: 'Time', width: 140),

        ReportColumnDef(key: 'SelectType', label: 'Select Type', width: 180),
        ReportColumnDef(key: 'FactoryName', label: 'Factory Name', width: 180),
        ReportColumnDef(key: 'FactoryType', label: 'Factory Type', width: 180),
        ReportColumnDef(key: 'EntryType', label: 'Entry Type', width: 180),

        ReportColumnDef(key: 'KapanNo', label: 'Kapan No', width: 160),
        ReportColumnDef(key: 'CutNo', label: 'Cut No', width: 140),
        ReportColumnDef(key: 'MfgCut', label: 'Mfg Cut', width: 140),

        ReportColumnDef(key: 'BCode', label: 'BCode', width: 140),
        ReportColumnDef(key: 'PktNo', label: 'Pkt No', width: 140),

        ReportColumnDef(key: 'Pc', label: 'Pc', width: 120),
        ReportColumnDef(key: 'Wt', label: 'Wt', width: 120),

        ReportColumnDef(key: 'IssPc', label: 'Iss Pc', width: 140),
        ReportColumnDef(key: 'IssWt', label: 'Iss Wt', width: 140),

        ReportColumnDef(key: 'DmWt', label: 'DM Wt', width: 140),
        ReportColumnDef(key: 'DmPer', label: 'DM %', width: 140),

        ReportColumnDef(key: 'Size', label: 'Size', width: 140),

        ReportColumnDef(key: 'PurityName', label: 'Purity', width: 140),
        ReportColumnDef(key: 'CharniName', label: 'Charni', width: 140),
        ReportColumnDef(key: 'ColorName', label: 'Color', width: 140),
        ReportColumnDef(key: 'ShapeName', label: 'Shape', width: 140),

        ReportColumnDef(key: 'RateID', label: 'Rate ID', width: 140),
        ReportColumnDef(key: 'Rateon', label: 'Rate On', width: 140),
        ReportColumnDef(key: 'Rate', label: 'Rate', width: 140),
        ReportColumnDef(key: 'Amount', label: 'Amount', width: 140),

        ReportColumnDef(key: 'Rec', label: 'Rec', width: 140),
      ],
      mapper: (raw) => raw.map((e) => {
        'Jno': '${e['Jno'] ?? 0}',
        'Date': formatDate(e['Date']),
        'Time': e['Time'] ?? '-',

        'SelectType': e['SelectType'] ?? '-',
        'FactoryName': e['FactoryName'] ?? '-',
        'FactoryType': e['FactoryType'] ?? '-',
        'EntryType': e['EntryType'] ?? '-',

        'KapanNo': e['KapanNo'] ?? '-',
        'CutNo': e['CutNo'] ?? '-',
        'MfgCut': e['MfgCut'] ?? '-',

        'BCode': '${e['BCode'] ?? 0}',
        'PktNo': e['PktNo'] ?? '-',

        'Pc': formatDecimal(e['Pc'], decimal: 0),
        'Wt': formatDecimal(e['Wt'], decimal: 3),

        'IssPc': formatDecimal(e['IssPc'], decimal: 0),
        'IssWt': formatDecimal(e['IssWt'], decimal: 3),

        'DmWt': formatDecimal(e['DmWt'], decimal: 3),
        'DmPer': formatDecimal(e['DmPer'], decimal: 2),

        'Size': formatDecimal(e['Size'], decimal: 2),

        'PurityName': e['PurityName'] ?? '-',
        'CharniName': e['CharniName'] ?? '-',
        'ColorName': e['ColorName'] ?? '-',
        'ShapeName': e['ShapeName'] ?? '-',

        'RateID': e['RateID'] ?? '-',
        'Rateon': e['Rateon'] ?? '-',
        'Rate': formatDecimal(e['Rate'], decimal: 2),
        'Amount': formatDecimal(e['Amount'], decimal: 2),

        'Rec': e['Rec'] ?? '-',
      }).toList(),
    ),

    // ── JAMA_PENDING ─────────────────────────────────────────────────────── 53
    'JAMA_KAPANWISE_PENDING': ReportConfig(
      reportTypeCode: 'JAMA_KAPANWISE_PENDING',
      endpoint: '/reports/factory-pen-jama-kapanwise-pending',
      columns: const [
        ReportColumnDef(key: 'KapanNo', label: 'Kapan No', width: 160),

        ReportColumnDef(key: 'Pkt', label: 'Pkt', width: 140),

        ReportColumnDef(key: 'Pc', label: 'Pc', width: 120),
        ReportColumnDef(key: 'Wt', label: 'Wt', width: 120),

        ReportColumnDef(key: 'IssPc', label: 'Iss Pc', width: 140),
        ReportColumnDef(key: 'IssWt', label: 'Iss Wt', width: 140),

        ReportColumnDef(key: 'DmWt', label: 'DM Wt', width: 140),
        ReportColumnDef(key: 'DmPer', label: 'DM %', width: 140),

        ReportColumnDef(key: 'Size', label: 'Size', width: 140),
      ],
      mapper: (raw) => raw.map((e) => {
        'KapanNo': e['KapanNo'] ?? '-',

        'Pkt': formatDecimal(e['Pkt'], decimal: 0),

        'Pc': formatDecimal(e['Pc'], decimal: 0),
        'Wt': formatDecimal(e['Wt'], decimal: 3),

        'IssPc': formatDecimal(e['IssPc'], decimal: 0),
        'IssWt': formatDecimal(e['IssWt'], decimal: 3),

        'DmWt': formatDecimal(e['DmWt'], decimal: 3),
        'DmPer': formatDecimal(e['DmPer'], decimal: 2),

        'Size': formatDecimal(e['Size'], decimal: 2),
      }).toList(),
    ),

    // ── JAMA_CUTWISE_PENDING ─────────────────────────────────────────────────────── 54
    'JAMA_CUTWISE_PENDING': ReportConfig(
      reportTypeCode: 'JAMA_CUTWISE_PENDING',
      endpoint: '/reports/factory-pen-jama-cutwise-pending',
      columns: const [
        ReportColumnDef(key: 'KapanNo', label: 'Kapan No', width: 160),
        ReportColumnDef(key: 'CutNo', label: 'Cut No', width: 140),
        ReportColumnDef(key: 'CutWt', label: 'Cut Wt', width: 140),

        ReportColumnDef(key: 'Pkt', label: 'Pkt', width: 140),

        ReportColumnDef(key: 'Pc', label: 'Pc', width: 120),
        ReportColumnDef(key: 'Wt', label: 'Wt', width: 120),

        ReportColumnDef(key: 'IssPc', label: 'Iss Pc', width: 140),
        ReportColumnDef(key: 'IssWt', label: 'Iss Wt', width: 140),

        ReportColumnDef(key: 'DmWt', label: 'DM Wt', width: 140),
        ReportColumnDef(key: 'DmPer', label: 'DM %', width: 140),

        ReportColumnDef(key: 'Size', label: 'Size', width: 140),
      ],
      mapper: (raw) => raw.map((e) => {
        'KapanNo': e['KapanNo'] ?? '-',
        'CutNo': e['CutNo'] ?? '-',

        'CutWt': formatDecimal(e['CutWt'], decimal: 3),

        'Pkt': formatDecimal(e['Pkt'], decimal: 0),

        'Pc': formatDecimal(e['Pc'], decimal: 0),
        'Wt': formatDecimal(e['Wt'], decimal: 3),

        'IssPc': formatDecimal(e['IssPc'], decimal: 0),
        'IssWt': formatDecimal(e['IssWt'], decimal: 3),

        'DmWt': formatDecimal(e['DmWt'], decimal: 3),
        'DmPer': formatDecimal(e['DmPer'], decimal: 2),

        'Size': formatDecimal(e['Size'], decimal: 2),
      }).toList(),
    ),

    // ── JAMA_FACTORYWISE_PENDING ─────────────────────────────────────────────────────── 55
    'JAMA_FACTORYWISE_PENDING': ReportConfig(
      reportTypeCode: 'JAMA_FACTORYWISE_PENDING',
      endpoint: '/reports/factory-pen-jama-factorywise-pending',
      columns: const [
        ReportColumnDef(key: 'FactoryName', label: 'Factory Name', width: 180),

        ReportColumnDef(key: 'Pkt', label: 'Pkt', width: 140),

        ReportColumnDef(key: 'Pc', label: 'Pc', width: 120),
        ReportColumnDef(key: 'Wt', label: 'Wt', width: 120),

        ReportColumnDef(key: 'IssPc', label: 'Iss Pc', width: 140),
        ReportColumnDef(key: 'IssWt', label: 'Iss Wt', width: 140),

        ReportColumnDef(key: 'DmWt', label: 'DM Wt', width: 140),
        ReportColumnDef(key: 'DmPer', label: 'DM %', width: 140),

        ReportColumnDef(key: 'Size', label: 'Size', width: 140),
      ],
      mapper: (raw) => raw.map((e) => {
        'FactoryName': e['FactoryName'] ?? '-',

        'Pkt': formatDecimal(e['Pkt'], decimal: 0),

        'Pc': formatDecimal(e['Pc'], decimal: 0),
        'Wt': formatDecimal(e['Wt'], decimal: 3),

        'IssPc': formatDecimal(e['IssPc'], decimal: 0),
        'IssWt': formatDecimal(e['IssWt'], decimal: 3),

        'DmWt': formatDecimal(e['DmWt'], decimal: 3),
        'DmPer': formatDecimal(e['DmPer'], decimal: 2),

        'Size': formatDecimal(e['Size'], decimal: 2),
      }).toList(),
    ),

    /* Job Work .......................................................................... */

    // ── JOBWORK_ISSUE_DETAIL ─────────────────────────────────────────────────────── 56
    'JOBWORK_ISSUE_DETAIL': ReportConfig(
      reportTypeCode: 'JOBWORK_ISSUE_DETAIL',
      endpoint: '/reports/jobwork-iss-detail',
      columns: const [
        ReportColumnDef(key: 'Jno', label: 'Jno', width: 120),
        ReportColumnDef(key: 'Date', label: 'Date', width: 140),
        ReportColumnDef(key: 'Time', label: 'Time', width: 140),

        ReportColumnDef(key: 'PartyName', label: 'Party Name', width: 180),
        ReportColumnDef(key: 'DeptName', label: 'Dept Name', width: 180),
        ReportColumnDef(key: 'DeptProcessName', label: 'Dept Process', width: 180),

        ReportColumnDef(key: 'ArticalName', label: 'Article', width: 180),

        ReportColumnDef(key: 'CutNo', label: 'Cut No', width: 140),
        ReportColumnDef(key: 'MfgCut', label: 'Mfg Cut', width: 140),

        ReportColumnDef(key: 'BCode', label: 'BCode', width: 140),
        ReportColumnDef(key: 'PktNo', label: 'Pkt No', width: 140),
        ReportColumnDef(key: 'PairNo', label: 'Pair No', width: 140),

        ReportColumnDef(key: 'PurityName', label: 'Purity', width: 140),
        ReportColumnDef(key: 'CharniName', label: 'Charni', width: 140),
        ReportColumnDef(key: 'ColorName', label: 'Color', width: 140),
        ReportColumnDef(key: 'ShapeName', label: 'Shape', width: 140),

        ReportColumnDef(key: 'CutName', label: 'Cut', width: 140),
        ReportColumnDef(key: 'PolishName', label: 'Polish', width: 140),
        ReportColumnDef(key: 'SymmetryName', label: 'Symmetry', width: 140),
        ReportColumnDef(key: 'FluoName', label: 'Fluo', width: 140),
        ReportColumnDef(key: 'TensionsName', label: 'Tensions', width: 180),

        ReportColumnDef(key: 'Pc', label: 'Pc', width: 120),
        ReportColumnDef(key: 'Wt', label: 'Wt', width: 120),

        ReportColumnDef(key: 'IssPc', label: 'Iss Pc', width: 140),
        ReportColumnDef(key: 'IssWt', label: 'Iss Wt', width: 140),

        ReportColumnDef(key: 'RecPc', label: 'Rec Pc', width: 140),
        ReportColumnDef(key: 'RecWt', label: 'Rec Wt', width: 140),

        ReportColumnDef(key: 'KPc', label: 'K Pc', width: 140),
        ReportColumnDef(key: 'KWt', label: 'K Wt', width: 140),

        ReportColumnDef(key: 'BrPc', label: 'Br Pc', width: 140),
        ReportColumnDef(key: 'BrWt', label: 'Br Wt', width: 140),

        ReportColumnDef(key: 'LossPc', label: 'Loss Pc', width: 140),
        ReportColumnDef(key: 'LossWt', label: 'Loss Wt', width: 140),

        ReportColumnDef(key: 'DmWt', label: 'DM Wt', width: 140),
        ReportColumnDef(key: 'DmPer', label: 'DM %', width: 140),

        ReportColumnDef(key: 'Size', label: 'Size', width: 140),

        ReportColumnDef(key: 'RecPer', label: 'Rec %', width: 140),
        ReportColumnDef(key: 'DiffPer', label: 'Diff %', width: 140),
        ReportColumnDef(key: 'DiffWt', label: 'Diff Wt', width: 140),

        ReportColumnDef(key: 'Diam', label: 'Diam', width: 140),
        ReportColumnDef(key: 'Length', label: 'Length', width: 140),
        ReportColumnDef(key: 'Height', label: 'Height', width: 140),
        ReportColumnDef(key: 'TopSide', label: 'Top Side', width: 140),

        ReportColumnDef(key: 'HA', label: 'HA', width: 100),
        ReportColumnDef(key: 'QRCode', label: 'QR Code', width: 180),
        ReportColumnDef(key: 'JobRec', label: 'Job Rec', width: 120),
      ],
      mapper: (raw) => raw.map((e) => {
        'Jno': '${e['Jno'] ?? 0}',
        'Date': formatDate(e['Date']),
        'Time': e['Time'] ?? '-',

        'PartyName': e['PartyName'] ?? '-',
        'DeptName': e['DeptName'] ?? '-',
        'DeptProcessName': e['DeptProcessName'] ?? '-',

        'ArticalName': e['ArticalName'] ?? '-',

        'CutNo': e['CutNo'] ?? '-',
        'MfgCut': e['MfgCut'] ?? '-',

        'BCode': '${e['BCode'] ?? 0}',
        'PktNo': e['PktNo'] ?? '-',
        'PairNo': '${e['PairNo'] ?? 0}',

        'PurityName': e['PurityName'] ?? '-',
        'CharniName': e['CharniName'] ?? '-',
        'ColorName': e['ColorName'] ?? '-',
        'ShapeName': e['ShapeName'] ?? '-',

        'CutName': e['CutName'] ?? '-',
        'PolishName': e['PolishName'] ?? '-',
        'SymmetryName': e['SymmetryName'] ?? '-',
        'FluoName': e['FluoName'] ?? '-',
        'TensionsName': e['TensionsName'] ?? '-',

        'Pc': formatDecimal(e['Pc'], decimal: 0),
        'Wt': formatDecimal(e['Wt'], decimal: 3),

        'IssPc': formatDecimal(e['IssPc'], decimal: 0),
        'IssWt': formatDecimal(e['IssWt'], decimal: 3),

        'RecPc': formatDecimal(e['RecPc'], decimal: 0),
        'RecWt': formatDecimal(e['RecWt'], decimal: 3),

        'KPc': formatDecimal(e['KPc'], decimal: 0),
        'KWt': formatDecimal(e['KWt'], decimal: 3),

        'BrPc': formatDecimal(e['BrPc'], decimal: 0),
        'BrWt': formatDecimal(e['BrWt'], decimal: 3),

        'LossPc': formatDecimal(e['LossPc'], decimal: 0),
        'LossWt': formatDecimal(e['LossWt'], decimal: 3),

        'DmWt': formatDecimal(e['DmWt'], decimal: 3),
        'DmPer': formatDecimal(e['DmPer'], decimal: 2),

        'Size': formatDecimal(e['Size'], decimal: 2),

        'RecPer': formatDecimal(e['RecPer'], decimal: 2),
        'DiffPer': formatDecimal(e['DiffPer'], decimal: 2),
        'DiffWt': formatDecimal(e['DiffWt'], decimal: 3),

        'Diam': formatDecimal(e['Diam'], decimal: 2),
        'Length': formatDecimal(e['Length'], decimal: 2),
        'Height': formatDecimal(e['Height'], decimal: 2),
        'TopSide': e['TopSide'] ?? '-',

        'HA': e['HA'] ?? '-',
        'QRCode': e['QRCode'] ?? '',
        'JobRec': e['JobRec'] ?? '-',
      }).toList(),
    ),

    // ── JOBWORK_RECEIVE_DETAIL ─────────────────────────────────────────────────────── 57
    'JOBWORK_RECEIVE_DETAIL': ReportConfig(
      reportTypeCode: 'JOBWORK_RECEIVE_DETAIL',
      endpoint: '/reports/jobwork-rec-detail',
      columns: const [
        ReportColumnDef(key: 'Jno', label: 'Jno', width: 120),
        ReportColumnDef(key: 'Date', label: 'Date', width: 140),
        ReportColumnDef(key: 'Time', label: 'Time', width: 140),

        ReportColumnDef(key: 'PartyName', label: 'Party Name', width: 180),
        ReportColumnDef(key: 'DeptName', label: 'Dept Name', width: 180),
        ReportColumnDef(key: 'DeptProcessName', label: 'Dept Process', width: 180),

        ReportColumnDef(key: 'ArticalName', label: 'Article', width: 180),

        ReportColumnDef(key: 'CutNo', label: 'Cut No', width: 140),
        ReportColumnDef(key: 'MfgCut', label: 'Mfg Cut', width: 140),

        ReportColumnDef(key: 'BCode', label: 'BCode', width: 140),
        ReportColumnDef(key: 'PktNo', label: 'Pkt No', width: 140),
        ReportColumnDef(key: 'PairNo', label: 'Pair No', width: 140),

        ReportColumnDef(key: 'PurityName', label: 'Purity', width: 140),
        ReportColumnDef(key: 'CharniName', label: 'Charni', width: 140),
        ReportColumnDef(key: 'ColorName', label: 'Color', width: 140),
        ReportColumnDef(key: 'ShapeName', label: 'Shape', width: 140),

        ReportColumnDef(key: 'CutName', label: 'Cut', width: 140),
        ReportColumnDef(key: 'PolishName', label: 'Polish', width: 140),
        ReportColumnDef(key: 'SymmetryName', label: 'Symmetry', width: 140),
        ReportColumnDef(key: 'FluoName', label: 'Fluo', width: 140),
        ReportColumnDef(key: 'TensionsName', label: 'Tensions', width: 180),

        ReportColumnDef(key: 'Pc', label: 'Pc', width: 120),
        ReportColumnDef(key: 'Wt', label: 'Wt', width: 120),

        ReportColumnDef(key: 'IssPc', label: 'Iss Pc', width: 140),
        ReportColumnDef(key: 'IssWt', label: 'Iss Wt', width: 140),

        ReportColumnDef(key: 'RecPc', label: 'Rec Pc', width: 140),
        ReportColumnDef(key: 'RecWt', label: 'Rec Wt', width: 140),

        ReportColumnDef(key: 'KPc', label: 'K Pc', width: 140),
        ReportColumnDef(key: 'KWt', label: 'K Wt', width: 140),

        ReportColumnDef(key: 'BrPc', label: 'Br Pc', width: 140),
        ReportColumnDef(key: 'BrWt', label: 'Br Wt', width: 140),

        ReportColumnDef(key: 'LossPc', label: 'Loss Pc', width: 140),
        ReportColumnDef(key: 'LossWt', label: 'Loss Wt', width: 140),

        ReportColumnDef(key: 'DmWt', label: 'DM Wt', width: 140),
        ReportColumnDef(key: 'DmPer', label: 'DM %', width: 140),

        ReportColumnDef(key: 'Size', label: 'Size', width: 140),

        ReportColumnDef(key: 'RecPer', label: 'Rec %', width: 140),
        ReportColumnDef(key: 'DiffPer', label: 'Diff %', width: 140),
        ReportColumnDef(key: 'DiffWt', label: 'Diff Wt', width: 140),

        ReportColumnDef(key: 'Diam', label: 'Diam', width: 140),
        ReportColumnDef(key: 'Length', label: 'Length', width: 140),
        ReportColumnDef(key: 'Height', label: 'Height', width: 140),
        ReportColumnDef(key: 'TopSide', label: 'Top Side', width: 140),

        ReportColumnDef(key: 'HA', label: 'HA', width: 100),
        ReportColumnDef(key: 'QRCode', label: 'QR Code', width: 180),
        ReportColumnDef(key: 'JobRec', label: 'Job Rec', width: 120),
      ],
      mapper: (raw) => raw.map((e) => {
        'Jno': '${e['Jno'] ?? 0}',
        'Date': formatDate(e['Date']),
        'Time': e['Time'] ?? '-',

        'PartyName': e['PartyName'] ?? '-',
        'DeptName': e['DeptName'] ?? '-',
        'DeptProcessName': e['DeptProcessName'] ?? '-',

        'ArticalName': e['ArticalName'] ?? '-',

        'CutNo': e['CutNo'] ?? '-',
        'MfgCut': e['MfgCut'] ?? '-',

        'BCode': '${e['BCode'] ?? 0}',
        'PktNo': e['PktNo'] ?? '-',
        'PairNo': '${e['PairNo'] ?? 0}',

        'PurityName': e['PurityName'] ?? '-',
        'CharniName': e['CharniName'] ?? '-',
        'ColorName': e['ColorName'] ?? '-',
        'ShapeName': e['ShapeName'] ?? '-',

        'CutName': e['CutName'] ?? '-',
        'PolishName': e['PolishName'] ?? '-',
        'SymmetryName': e['SymmetryName'] ?? '-',
        'FluoName': e['FluoName'] ?? '-',
        'TensionsName': e['TensionsName'] ?? '-',

        'Pc': formatDecimal(e['Pc'], decimal: 0),
        'Wt': formatDecimal(e['Wt'], decimal: 3),

        'IssPc': formatDecimal(e['IssPc'], decimal: 0),
        'IssWt': formatDecimal(e['IssWt'], decimal: 3),

        'RecPc': formatDecimal(e['RecPc'], decimal: 0),
        'RecWt': formatDecimal(e['RecWt'], decimal: 3),

        'KPc': formatDecimal(e['KPc'], decimal: 0),
        'KWt': formatDecimal(e['KWt'], decimal: 3),

        'BrPc': formatDecimal(e['BrPc'], decimal: 0),
        'BrWt': formatDecimal(e['BrWt'], decimal: 3),

        'LossPc': formatDecimal(e['LossPc'], decimal: 0),
        'LossWt': formatDecimal(e['LossWt'], decimal: 3),

        'DmWt': formatDecimal(e['DmWt'], decimal: 3),
        'DmPer': formatDecimal(e['DmPer'], decimal: 2),

        'Size': formatDecimal(e['Size'], decimal: 2),

        'RecPer': formatDecimal(e['RecPer'], decimal: 2),
        'DiffPer': formatDecimal(e['DiffPer'], decimal: 2),
        'DiffWt': formatDecimal(e['DiffWt'], decimal: 3),

        'Diam': formatDecimal(e['Diam'], decimal: 2),
        'Length': formatDecimal(e['Length'], decimal: 2),
        'Height': formatDecimal(e['Height'], decimal: 2),
        'TopSide': e['TopSide'] ?? '-',

        'HA': e['HA'] ?? '-',
        'QRCode': e['QRCode'] ?? '',
        'JobRec': e['JobRec'] ?? '-',
      }).toList(),
    ),

    // ── JOBWORK_PENDING_DETAIL ─────────────────────────────────────────────────────── 58
    'JOBWORK_PENDING_DETAIL': ReportConfig(
      reportTypeCode: 'JOBWORK_PENDING_DETAIL',
      endpoint: '/reports/jobwork-pen-detail',
      columns: const [
        ReportColumnDef(key: 'Jno', label: 'Jno', width: 120),
        ReportColumnDef(key: 'Date', label: 'Date', width: 140),
        ReportColumnDef(key: 'Time', label: 'Time', width: 140),

        ReportColumnDef(key: 'PartyName', label: 'Party Name', width: 180),
        ReportColumnDef(key: 'DeptName', label: 'Dept Name', width: 180),
        ReportColumnDef(key: 'DeptProcessName', label: 'Dept Process', width: 180),

        ReportColumnDef(key: 'ArticalName', label: 'Article', width: 180),

        ReportColumnDef(key: 'CutNo', label: 'Cut No', width: 140),
        ReportColumnDef(key: 'MfgCut', label: 'Mfg Cut', width: 140),

        ReportColumnDef(key: 'BCode', label: 'BCode', width: 140),
        ReportColumnDef(key: 'PktNo', label: 'Pkt No', width: 140),
        ReportColumnDef(key: 'PairNo', label: 'Pair No', width: 140),

        ReportColumnDef(key: 'PurityName', label: 'Purity', width: 140),
        ReportColumnDef(key: 'CharniName', label: 'Charni', width: 140),
        ReportColumnDef(key: 'ColorName', label: 'Color', width: 140),
        ReportColumnDef(key: 'ShapeName', label: 'Shape', width: 140),

        ReportColumnDef(key: 'CutName', label: 'Cut', width: 140),
        ReportColumnDef(key: 'PolishName', label: 'Polish', width: 140),
        ReportColumnDef(key: 'SymmetryName', label: 'Symmetry', width: 140),
        ReportColumnDef(key: 'FluoName', label: 'Fluo', width: 140),
        ReportColumnDef(key: 'TensionsName', label: 'Tensions', width: 180),

        ReportColumnDef(key: 'Pc', label: 'Pc', width: 120),
        ReportColumnDef(key: 'Wt', label: 'Wt', width: 120),

        ReportColumnDef(key: 'IssPc', label: 'Iss Pc', width: 140),
        ReportColumnDef(key: 'IssWt', label: 'Iss Wt', width: 140),

        ReportColumnDef(key: 'RecPc', label: 'Rec Pc', width: 140),
        ReportColumnDef(key: 'RecWt', label: 'Rec Wt', width: 140),

        ReportColumnDef(key: 'KPc', label: 'K Pc', width: 140),
        ReportColumnDef(key: 'KWt', label: 'K Wt', width: 140),

        ReportColumnDef(key: 'BrPc', label: 'Br Pc', width: 140),
        ReportColumnDef(key: 'BrWt', label: 'Br Wt', width: 140),

        ReportColumnDef(key: 'LossPc', label: 'Loss Pc', width: 140),
        ReportColumnDef(key: 'LossWt', label: 'Loss Wt', width: 140),

        ReportColumnDef(key: 'DmWt', label: 'DM Wt', width: 140),
        ReportColumnDef(key: 'DmPer', label: 'DM %', width: 140),

        ReportColumnDef(key: 'Size', label: 'Size', width: 140),

        ReportColumnDef(key: 'RecPer', label: 'Rec %', width: 140),
        ReportColumnDef(key: 'DiffPer', label: 'Diff %', width: 140),
        ReportColumnDef(key: 'DiffWt', label: 'Diff Wt', width: 140),

        ReportColumnDef(key: 'Diam', label: 'Diam', width: 140),
        ReportColumnDef(key: 'Length', label: 'Length', width: 140),
        ReportColumnDef(key: 'Height', label: 'Height', width: 140),
        ReportColumnDef(key: 'TopSide', label: 'Top Side', width: 140),

        ReportColumnDef(key: 'HA', label: 'HA', width: 100),
        ReportColumnDef(key: 'QRCode', label: 'QR Code', width: 180),
        ReportColumnDef(key: 'JobRec', label: 'Job Rec', width: 120),
      ],
      mapper: (raw) => raw.map((e) => {
        'Jno': '${e['Jno'] ?? 0}',
        'Date': formatDate(e['Date']),
        'Time': e['Time'] ?? '-',

        'PartyName': e['PartyName'] ?? '-',
        'DeptName': e['DeptName'] ?? '-',
        'DeptProcessName': e['DeptProcessName'] ?? '-',

        'ArticalName': e['ArticalName'] ?? '-',

        'CutNo': e['CutNo'] ?? '-',
        'MfgCut': e['MfgCut'] ?? '-',

        'BCode': '${e['BCode'] ?? 0}',
        'PktNo': e['PktNo'] ?? '-',
        'PairNo': '${e['PairNo'] ?? 0}',

        'PurityName': e['PurityName'] ?? '-',
        'CharniName': e['CharniName'] ?? '-',
        'ColorName': e['ColorName'] ?? '-',
        'ShapeName': e['ShapeName'] ?? '-',

        'CutName': e['CutName'] ?? '-',
        'PolishName': e['PolishName'] ?? '-',
        'SymmetryName': e['SymmetryName'] ?? '-',
        'FluoName': e['FluoName'] ?? '-',
        'TensionsName': e['TensionsName'] ?? '-',

        'Pc': formatDecimal(e['Pc'], decimal: 0),
        'Wt': formatDecimal(e['Wt'], decimal: 3),

        'IssPc': formatDecimal(e['IssPc'], decimal: 0),
        'IssWt': formatDecimal(e['IssWt'], decimal: 3),

        'RecPc': formatDecimal(e['RecPc'], decimal: 0),
        'RecWt': formatDecimal(e['RecWt'], decimal: 3),

        'KPc': formatDecimal(e['KPc'], decimal: 0),
        'KWt': formatDecimal(e['KWt'], decimal: 3),

        'BrPc': formatDecimal(e['BrPc'], decimal: 0),
        'BrWt': formatDecimal(e['BrWt'], decimal: 3),

        'LossPc': formatDecimal(e['LossPc'], decimal: 0),
        'LossWt': formatDecimal(e['LossWt'], decimal: 3),

        'DmWt': formatDecimal(e['DmWt'], decimal: 3),
        'DmPer': formatDecimal(e['DmPer'], decimal: 2),

        'Size': formatDecimal(e['Size'], decimal: 2),

        'RecPer': formatDecimal(e['RecPer'], decimal: 2),
        'DiffPer': formatDecimal(e['DiffPer'], decimal: 2),
        'DiffWt': formatDecimal(e['DiffWt'], decimal: 3),

        'Diam': formatDecimal(e['Diam'], decimal: 2),
        'Length': formatDecimal(e['Length'], decimal: 2),
        'Height': formatDecimal(e['Height'], decimal: 2),
        'TopSide': e['TopSide'] ?? '-',

        'HA': e['HA'] ?? '-',
        'QRCode': e['QRCode'] ?? '',
        'JobRec': e['JobRec'] ?? '-',
      }).toList(),
    ),

    /* Packet Wise Planning .......................................................................... */

    // ── PACKET_WISE_PLANNING_SUMMARY ─────────────────────────────────────────────────────── 59
    'PACKET_WISE_PLANNING_SUMMARY': ReportConfig(
      reportTypeCode: 'PACKET_WISE_PLANNING_SUMMARY',
      endpoint: '/reports/packet-wise-planning-summary',
      columns: const [
        ReportColumnDef(key: 'KapanNo', label: 'Kapan No', width: 160),
        ReportColumnDef(key: 'ClvCut', label: 'Clv Cut', width: 160),
        ReportColumnDef(key: 'Cut', label: 'Cut', width: 120),
        ReportColumnDef(key: 'Manager', label: 'Manager', width: 180),
        ReportColumnDef(key: 'LotNo', label: 'Lot No', width: 140),
        ReportColumnDef(key: 'OrgWt', label: 'Org Wt', width: 140),
        ReportColumnDef(key: 'RgWt', label: 'Rg Wt', width: 140),
        ReportColumnDef(key: 'Pc', label: 'Pc', width: 100),
        ReportColumnDef(key: 'PoWt', label: 'Po Wt', width: 140),
        ReportColumnDef(key: 'PoPer', label: 'Po %', width: 140),
        ReportColumnDef(key: 'RTOP', label: 'RTOP', width: 140),
        ReportColumnDef(key: 'Amount', label: 'Amount', width: 140),
      ],
      mapper: (raw) => raw.map((e) => {
        'KapanNo': e['KapanNo'] ?? '-',
        'ClvCut': e['ClvCut'] ?? '-',
        'Cut': e['Cut'] ?? '-',
        'Manager': e['Manager'] ?? '-',
        'LotNo': formatDecimal(e['LotNo'], decimal: 0),
        'OrgWt': formatDecimal(e['OrgWt'], decimal: 3),
        'RgWt': formatDecimal(e['RgWt'], decimal: 3),
        'Pc': formatDecimal(e['Pc'], decimal: 0),
        'PoWt': formatDecimal(e['PoWt'], decimal: 3),
        'PoPer': formatDecimal(e['PoPer'], decimal: 2),
        'RTOP': formatDecimal(e['RTOP'], decimal: 2),
        'Amount': formatDecimal(e['Amount'], decimal: 2),
      }).toList(),
    ),

    // ── PACKET_WISE_PLANNING_DETAIL ─────────────────────────────────────────────────────── 60
    'PACKET_WISE_PLANNING_DETAIL': ReportConfig(
      reportTypeCode: 'PACKET_WISE_PLANNING_DETAIL',
      endpoint: '/reports/packet-wise-planning-detail',
      columns: const [
        ReportColumnDef(key: 'KapanNo', label: 'Kapan No', width: 160),
        ReportColumnDef(key: 'ClvCut', label: 'Clv Cut', width: 140),
        ReportColumnDef(key: 'Cut', label: 'Cut', width: 120),
        ReportColumnDef(key: 'Manager', label: 'Manager', width: 180),
        ReportColumnDef(key: 'LotNo', label: 'Lot No', width: 140),
        ReportColumnDef(key: 'Date', label: 'Date', width: 140),
        ReportColumnDef(key: 'OrgWt', label: 'Org Wt', width: 140),
        ReportColumnDef(key: 'RgWt', label: 'Rg Wt', width: 140),
        ReportColumnDef(key: 'Pc', label: 'Pc', width: 120),
        ReportColumnDef(key: 'PoWt', label: 'Po Wt', width: 140),
        ReportColumnDef(key: 'PoPer', label: 'Po %', width: 120),
        ReportColumnDef(key: 'AmountRs', label: 'Amount', width: 140),
        ReportColumnDef(key: 'ColorName', label: 'Color', width: 140),
        ReportColumnDef(key: 'PurityName', label: 'Purity', width: 140),
        ReportColumnDef(key: 'RoughTypeName', label: 'Rough Type', width: 160),
        ReportColumnDef(key: 'CutName', label: 'Cut Name', width: 160),
        ReportColumnDef(key: 'ShapeName', label: 'Shape', width: 140),
        ReportColumnDef(key: 'Diameter', label: 'Diameter', width: 160),
        ReportColumnDef(key: 'Length', label: 'Length', width: 140),
        ReportColumnDef(key: 'Height', label: 'Height', width: 140),
      ],
      mapper: (raw) => raw.map((e) => {
        'KapanNo': e['KapanNo'] ?? '-',
        'ClvCut': e['ClvCut'] ?? '-',
        'Cut': e['Cut'] ?? '-',
        'Manager': e['Manager'] ?? '-',
        'LotNo': formatDecimal(e['LotNo'], decimal: 0),
        'Date': formatDate(e['Date']),
        'OrgWt': formatDecimal(e['OrgWt'], decimal: 3),
        'RgWt': formatDecimal(e['RgWt'], decimal: 3),
        'Pc': formatDecimal(e['Pc'], decimal: 0),
        'PoWt': formatDecimal(e['PoWt'], decimal: 3),
        'PoPer': formatDecimal(e['PoPer'], decimal: 2),
        'AmountRs': formatDecimal(e['AmountRs'], decimal: 2),
        'ColorName': e['ColorName'] ?? '-',
        'PurityName': e['PurityName'] ?? '-',
        'RoughTypeName': e['RoughTypeName'] ?? '-',
        'CutName': e['CutName'] ?? '-',
        'ShapeName': e['ShapeName'] ?? '-',
        'Diameter': formatDecimal(e['Diameter'], decimal: 2),
        'Length': formatDecimal(e['Length'], decimal: 2),
        'Height': formatDecimal(e['Height'], decimal: 2),
      }).toList(),
    ),

    // ── KAPAN_PERFORMANCE ─────────────────────────────────────────────────────── 61
    'KAPAN_PERFORMANCE': ReportConfig(
      reportTypeCode: 'KAPAN_PERFORMANCE',
      endpoint: '/reports/kapan-performance',
      isPdf: true, // 🔥 ADD THIS
      columns: const [],
      mapper: (raw) => [],
      queryBuilder: (filter) => {
        'kapanNos': filter['kNo'],
      },
    ),

    // ── SELL_PRICE ─────────────────────────────────────────────────────── 61
    'SELL_PRICE': ReportConfig(
      reportTypeCode: 'SELL_PRICE',
      endpoint: '/reports/sell-price-report',
      isPdf: true, // 🔥 ADD THIS
      columns: const [],
      mapper: (raw) => [],
      queryBuilder: (filter) => {
        'kapanNos': filter['kNo'],
        'shapecodes': filter['shapeCode'],
        'colors': filter['colorCode'],
        'purities': filter['purityCode'],
      },
    ),
  };

  static ReportConfig? of(String? code) => code == null ? null : _configs[code];

  static Set<String> get allCodes => _configs.keys.toSet();
}
