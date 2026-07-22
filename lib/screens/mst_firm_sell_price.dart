import 'dart:convert';

import 'package:diam_mfg/models/sell_price_model.dart';
import 'package:diam_mfg/providers/article_provider.dart';
import 'package:diam_mfg/providers/color_provider.dart';
import 'package:diam_mfg/providers/company_provider.dart';
import 'package:diam_mfg/providers/purity_provider.dart';
import 'package:diam_mfg/providers/sell_price_provider.dart';
import 'package:erp_data_table/erp_data_table.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rs_dashboard/rs_dashboard.dart';

import '../bootstrap.dart';
import '../providers/shape_provider.dart';
import '../utils/app_images.dart';
import '../utils/delete_dialogue.dart';
import '../utils/msg_dialogue.dart';

class MstSellPrice extends StatefulWidget {
  const MstSellPrice({super.key});

  @override
  State<MstSellPrice> createState() => _MstSellPriceState();
}

class _MstSellPriceState extends State<MstSellPrice> {
  final GlobalKey<ErpFormState> _erpFormKey = GlobalKey<ErpFormState>();
  Map<String, dynamic>? _selectedRow;
  bool _isEditMode = false;

  // dynamic, NOT String -> multiselect fields (colorCode/purityCode) need
  // to hold a List<String>, which a Map<String, String> can't store.
  Map<String, String> _formValues = {};

  final List<Map<String, dynamic>> _entryGridRows = [];
  int? _editingGridIndex;

  List<String> get _gridColumns => [
    'sortID',
    'article',
    'color',
    'purity',
    'layoutName',
    'shape',
    'mm',
    'length',
    'diam',
    'height',
    'rate',
    'code',
    'active',
  ];

  Map<String, String> get _gridColumnLabels => {
    'sortID': 'SORT ID',
    'article': 'ARTICLE',
    'color': 'COLOR',
    'purity': 'PURITY',
    'layoutName': 'LAYOUT NAME',
    'shape': 'SHAPE',
    'mm': 'MM',
    'length': 'LENGTH',
    'diam': 'DIAM',
    'height': 'HEIGHT',
    'rate': 'PRICE',
    'code': 'CODE',
    'active': 'ACTIVE',
  };

  final String? token = AppStorage.getString("token");

  // Table columns matching SellPriceModel.toTableRow() keys.
  List<ErpColumnConfig> get _tableColumns => [
    ErpColumnConfig(key: 'articalName', label: 'ARTICLE', width: 160),
    ErpColumnConfig(key: 'sdate', label: 'DATE', width: 160),
    ErpColumnConfig(key: 'layoutName', label: 'LAYOUT NAME', width: 200),
  ];

  // Form fields
  List<List<ErpFieldConfig>> _buildFormRows() {
    final shapeProvider = context.read<ShapeProvider>();
    final articleProvider = context.read<ArticleProvider>();
    final colorProv = context.read<ColorProvider>();
    final purityProv = context.read<PurityProvider>();

    return [
      [
        ErpFieldConfig(
          key: 'articleCode',
          label: 'ARTICLE',
          type: ErpFieldType.dropdown,
          readOnly: _entryGridRows.isNotEmpty,
          dropdownItems: articleProvider.list
              .where((e) => e.active == true)
              .map(
                (e) => ErpDropdownItem(
                  label: e.articalName ?? '',
                  value: e.articalCode?.toString() ?? '',
                ),
              )
              .toList(),
          sectionIndex: 0,
        ),
        ErpFieldConfig(
          key: 'colorCode',
          label: 'COLOR',
          readOnly: _entryGridRows.isNotEmpty,
          type: ErpFieldType.multiselectDropdown,
          dropdownItems: colorProv.list
              .where((e) => e.active == true && [1].contains(e.colorRptGroupCode))
              .map(
                (e) => ErpDropdownItem(
                  label: e.colorName ?? '',
                  value: e.colorCode?.toString() ?? '',
                ),
              )
              .toList(),
          sectionIndex: 0,
        ),
        ErpFieldConfig(
          key: 'purityCode',
          label: 'PURITY',
          readOnly: _entryGridRows.isNotEmpty,
          type: ErpFieldType.multiselectDropdown,
          dropdownItems: purityProv.list
              .where((e) => e.active == true && [1].contains(e.purityGroupCode))
              .map(
                (e) => ErpDropdownItem(
                  label: e.purityName ?? '',
                  value: e.purityCode?.toString() ?? '',
                ),
              )
              .toList(),
          sectionIndex: 0,
        ),
        ErpFieldConfig(
          key: 'layoutName',
          label: 'LAYOUT NAME',
          type: ErpFieldType.text,
          readOnly: true,
          sectionIndex: 0,
        ),
        ErpFieldConfig(
          key: 'shapeCode',
          label: 'SHAPE',
          type: ErpFieldType.dropdown,
          sectionIndex: 0,
          dropdownItems: shapeProvider.list
              .where((e) => e.active == true)
              .map(
                (e) => ErpDropdownItem(
                  label: e.shapeName ?? '',
                  value: e.shapeCode?.toString() ?? '',
                ),
              )
              .toList(),
        ),
      ],
      [
        ErpFieldConfig(
          key: 'length',
          label: 'LENGTH',
          type: ErpFieldType.amount,
          sectionIndex: 1,
          flex: 1,
        ),
        ErpFieldConfig(
          key: 'diam',
          label: 'DIAM',
          type: ErpFieldType.amount,
          sectionIndex: 1,
          flex: 1,
        ),
        ErpFieldConfig(
          key: 'height',
          label: 'HEIGHT',
          type: ErpFieldType.amount,
          sectionIndex: 1,
          flex: 1,
        ),
        ErpFieldConfig(
          key: 'rate',
          label: 'PRICE',
          type: ErpFieldType.amount,
          sectionIndex: 0,
        ),
        ErpFieldConfig(
          key: 'code',
          label: 'CODE',
          type: ErpFieldType.text,
          sectionIndex: 1,
          flex: 1,
        ),
      ],
      [
        ErpFieldConfig(
          key: 'active',
          label: 'ACTIVE',
          type: ErpFieldType.checkbox,
          checkboxDbType: 'BIT',
          skipFocus: true,
          sectionIndex: 2,
          initialBoolValue: true,
          width: 160,
        ),
        ErpFieldConfig(
          key: 'sortID',
          label: 'SORT ID',
          type: ErpFieldType.number,
          sectionIndex: 2,
          width: 160,
          readOnly: true,
          showAddButton: true,
           isEntryRequired: true,
          isEntryField: true
        ),
      ],
    ];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.wait([
        context.read<SellPriceProvider>().loadSellPrice(),
        context.read<PurityProvider>().load(),
        context.read<ColorProvider>().load(),
        context.read<ArticleProvider>().load(),
        context.read<ShapeProvider>().load(),
      ]);
      _setDefaultSortId();
    });
  }

  Future<void> _onRowTap(Map<String, dynamic> row) async {
    final raw = row['_raw'] as SellPriceModel;
    print(raw.sortID);
    setState(() {
      _selectedRow = row;
      _isEditMode = true;
      _entryGridRows.clear();

      _formValues = {
        'articleCode': raw.articalCode?.toString() ?? '',
        'colorCode': raw.colorCodes.join(','),
        'purityCode': raw.purityCodes.join(','),
        'layoutName': raw.layoutName,
      };
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final entry in _formValues.entries) {
        _erpFormKey.currentState?.updateFieldValue(entry.key, entry.value);
      }
    });

    if (Responsive.isMobile(context)) {
      setState(() => _showTableOnMobile = false);
    }

    if (raw.sellPriceListMstID != null) {
      final details = await context
          .read<SellPriceProvider>()
          .loadSellPriceDetail(raw.sellPriceListMstID!);
      if (details != null && mounted) {
        setState(() {
          _entryGridRows.clear();
          for (final detail in details) {
            _entryGridRows.add({
              'article': detail.articalName ?? raw.articalName ?? '',
              'color': detail.colors ?? raw.colors ?? '',
              'purity': detail.purities ?? raw.purities ?? '',
              'layoutName': detail.layoutNameField != null && detail.layoutNameField!.isNotEmpty
                  ? detail.layoutName
                  : raw.layoutName,
              'shape': detail.shapeName ?? '',
              'mm': detail.mm ?? '',
              'length': detail.length?.toString() ?? '',
              'diam': detail.width?.toString() ?? '',
              'height': detail.height?.toString() ?? '',
              'rate': detail.rate?.toString() ?? '',
              'code': detail.sellCode ?? '',
              'sortID': detail.sortID?.toString() ?? '',
              'active': detail.active == true ? 'Yes' : 'No',

              '_articleCode': (detail.articalCode ?? raw.articalCode)?.toString() ?? '',
              '_shapeCode': detail.shapeCode?.toString() ?? '',
              '_colorCodes': detail.colorCodes.isNotEmpty ? detail.colorCodes : raw.colorCodes,
              '_purityCodes': detail.purityCodes.isNotEmpty ? detail.purityCodes : raw.purityCodes,
              '_length': detail.length ?? 0.0,
              '_diam': detail.width ?? 0.0,
              '_height': detail.height ?? 0.0,
              '_rate': detail.rate ?? 0.0,
              '_sortID': detail.sortID ?? 0,
              '_active': detail.active == true,
              '_mm': detail.mm ?? '',
            });
          }
        });
      }
      _formValues['sortID'] = (_entryGridRows.length + 1).toString();
      _erpFormKey.currentState?.updateFieldValue('sortID', (_entryGridRows.length + 1).toString());
    }
  }

  void _generateCode() {
    final articleProvider = context.read<ArticleProvider>();
    final shapeProvider = context.read<ShapeProvider>();

    final articleCode = _formValues['articleCode'];
    final shapeCode = _formValues['shapeCode'];

    if (articleCode == null || shapeCode == null) return;

    final article = articleProvider.list.firstWhere(
      (e) => e.articalCode.toString() == articleCode,
      orElse: () => throw Exception(),
    );

    final shape = shapeProvider.list.firstWhere(
      (e) => e.shapeCode.toString() == shapeCode,
      orElse: () => throw Exception(),
    );

    // First letter from Article
    final articleLetter = (article.articalName?.isNotEmpty ?? false)
        ? article.articalName![0].toUpperCase()
        : '';

    // First 2 letters from Shape
    final shapeLetters = shape.certiCode ?? ((shape.shapeName?.length ?? 0) >= 2
        ? shape.shapeName!.substring(0, 2).toUpperCase()
        : (shape.shapeName ?? '').toUpperCase());

    final length = double.tryParse(_formValues['length'] ?? '') ?? 0;

    final width = double.tryParse(_formValues['diam'] ?? '') ?? 0;

    final lengthPart = getTwoDigitValue(length);
    final widthPart = getTwoDigitValue(width);

    final code = '$articleLetter$shapeLetters$lengthPart$widthPart';

    _formValues['code'] = code;

    _erpFormKey.currentState?.updateFieldValue('code', code);
  }

  String _formatMmToDecimal(String val) {
    if (val.isEmpty) return '';
    final parts = val.split('*');
    final formattedParts = <String>[];
    for (final part in parts) {
      final numValue = double.tryParse(part.trim()) ?? 0.0;
      formattedParts.add(numValue.toStringAsFixed(2));
    }
    return formattedParts.join('*');
  }

  void _generateMm() {
    final lengthStr = _formValues['length'] ?? '';
    final diamStr = _formValues['diam'] ?? '';
    final heightStr = _formValues['height'] ?? '';

    if (lengthStr.isNotEmpty && diamStr.isNotEmpty && heightStr.isNotEmpty) {
      final computedMm = _formatMmToDecimal('$lengthStr*$diamStr*$heightStr');
      _formValues['mm'] = computedMm;
      _erpFormKey.currentState?.updateFieldValue('mm', computedMm);
    } else {
      _formValues['mm'] = '';
      _erpFormKey.currentState?.updateFieldValue('mm', '');
    }
  }

  void _generateLayoutName() {
    final articleProvider = context.read<ArticleProvider>();
    final colorProv = context.read<ColorProvider>();
    final purityProv = context.read<PurityProvider>();

    final articleCode = _formValues['articleCode'];
    final colorCodesStr = _formValues['colorCode'] ?? '';
    final purityCodesStr = _formValues['purityCode'] ?? '';

    String articleName = '';
    if (articleCode != null && articleCode.isNotEmpty) {
      for (final item in articleProvider.list) {
        if (item.articalCode?.toString() == articleCode) {
          articleName = item.articalName ?? '';
          break;
        }
      }
    }

    String colorsStr = '';
    if (colorCodesStr.isNotEmpty) {
      final ids = colorCodesStr.split(',').where((e) => e.isNotEmpty);
      final names = <String>[];
      for (final id in ids) {
        for (final item in colorProv.list) {
          if (item.colorCode?.toString() == id) {
            names.add(item.colorName ?? '');
            break;
          }
        }
      }
      colorsStr = names.join('/');
    }

    String puritiesStr = '';
    if (purityCodesStr.isNotEmpty) {
      final ids = purityCodesStr.split(',').where((e) => e.isNotEmpty);
      final names = <String>[];
      for (final id in ids) {
        for (final item in purityProv.list) {
          if (item.purityCode?.toString() == id) {
            names.add(item.purityName ?? '');
            break;
          }
        }
      }
      puritiesStr = names.join('/');
    }

    final layOutName = '$articleName-$colorsStr-$puritiesStr';
    _formValues['layoutName'] = layOutName;
    _erpFormKey.currentState?.updateFieldValue('layoutName', layOutName);
  }

  void _addEntry() {
    final articleProvider = context.read<ArticleProvider>();
    final shapeProvider = context.read<ShapeProvider>();
    final colorProv = context.read<ColorProvider>();
    final purityProv = context.read<PurityProvider>();

    final articleCode = _formValues['articleCode'];
    final shapeCode = _formValues['shapeCode'];
    final colorCodesStr = _formValues['colorCode'] ?? '';
    final purityCodesStr = _formValues['purityCode'] ?? '';
    final code = _formValues['code'] ?? '';
    final rateStr = _formValues['rate'] ?? '';
    final lengthStr = _formValues['length'] ?? '';
    final diamStr = _formValues['diam'] ?? '';
    final heightStr = _formValues['height'] ?? '';
    final sortIDStr = _formValues['sortID'] ?? '';
    final activeStr = _formValues['active'] ?? 'true';
    final mmStr = _formValues['mm'] ?? '';

    if (articleCode == null || articleCode.isEmpty) {
      _showSnack('Please select an Article');
      return;
    }
    if (shapeCode == null || shapeCode.isEmpty) {
      _showSnack('Please select a Shape');
      return;
    }
    if (colorCodesStr.isEmpty) {
      _showSnack('Please select at least one Color');
      return;
    }
    if (purityCodesStr.isEmpty) {
      _showSnack('Please select at least one Purity');
      return;
    }
    final rate = double.tryParse(rateStr) ?? 0;
    if (rate <= 0) {
      _showSnack('Rate must be greater than 0');
      return;
    }

    String articleName = '';
    for (final item in articleProvider.list) {
      if (item.articalCode?.toString() == articleCode) {
        articleName = item.articalName ?? '';
        break;
      }
    }

    String shapeName = '';
    for (final item in shapeProvider.list) {
      if (item.shapeCode?.toString() == shapeCode) {
        shapeName = item.shapeName ?? '';
        break;
      }
    }

    String colorsStr = '';
    final colorIds = colorCodesStr
        .split(',')
        .where((e) => e.isNotEmpty)
        .toList();
    final colorNames = <String>[];
    for (final id in colorIds) {
      for (final item in colorProv.list) {
        if (item.colorCode?.toString() == id) {
          colorNames.add(item.colorName ?? '');
          break;
        }
      }
    }
    colorsStr = colorNames.join('/');

    String puritiesStr = '';
    final purityIds = purityCodesStr
        .split(',')
        .where((e) => e.isNotEmpty)
        .toList();
    final purityNames = <String>[];
    for (final id in purityIds) {
      for (final item in purityProv.list) {
        if (item.purityCode?.toString() == id) {
          purityNames.add(item.purityName ?? '');
          break;
        }
      }
    }
    puritiesStr = purityNames.join('/');

    final layOutName = '$articleName-$colorsStr-$puritiesStr';
    final computedMm = _formatMmToDecimal(
      mmStr.isNotEmpty
          ? mmStr
          : (lengthStr.isNotEmpty && diamStr.isNotEmpty && heightStr.isNotEmpty
              ? '$lengthStr*$diamStr*$heightStr'
              : ''),
    );

    if (computedMm.isNotEmpty) {
      final isDuplicate = _entryGridRows.asMap().entries.any((entry) {
        final index = entry.key;
        final row = entry.value;
        if (index == _editingGridIndex) return false;
        
        final existingMm = row['mm']?.toString().trim().toLowerCase();
        final existingShapeCode = row['_shapeCode']?.toString().trim();
        
        return existingMm == computedMm.trim().toLowerCase() &&
            existingShapeCode == shapeCode.trim();
      });
      if (isDuplicate) {
        _showSnack('Duplicate entry with same MM ($computedMm) and Shape is not allowed.');
        return;
      }
    }

    if (code.isNotEmpty) {
      final isDuplicateCode = _entryGridRows.asMap().entries.any((entry) {
        final index = entry.key;
        final row = entry.value;
        if (index == _editingGridIndex) return false;
        
        final existingCode = row['code']?.toString().trim().toLowerCase();
        return existingCode == code.trim().toLowerCase();
      });
      if (isDuplicateCode) {
        _showSnack('Duplicate entry with same Sell Code ($code) is not allowed.');
        return;
      }
    }


    final newRow = {
      'article': articleName,
      'color': colorsStr,
      'purity': puritiesStr,
      'layoutName': layOutName,
      'shape': shapeName,
      'mm': computedMm,
      'length': lengthStr,
      'diam': diamStr,
      'height': heightStr,
      'rate': rateStr,
      'code': code,
      'sortID': sortIDStr,
      'active': activeStr == 'true' ? 'Yes' : 'No',

      '_articleCode': articleCode,
      '_shapeCode': shapeCode,
      '_colorCodes': colorIds.map(int.parse).toList(),
      '_purityCodes': purityIds.map(int.parse).toList(),
      '_length': double.tryParse(lengthStr) ?? 0,
      '_diam': double.tryParse(diamStr) ?? 0,
      '_height': double.tryParse(heightStr) ?? 0,
      '_rate': rate,
      '_sortID': int.tryParse(sortIDStr) ?? 0,
      '_active': activeStr == 'true' || activeStr == '1',
      '_mm': computedMm,
    };

    setState(() {
      if (_editingGridIndex != null) {
        _entryGridRows[_editingGridIndex!] = newRow;
        _editingGridIndex = null;
      } else {
        _entryGridRows.add(newRow);
      }

      // Reset entry fields for next addition
      _formValues['mm'] = '';
      _formValues['length'] = '';
      _formValues['diam'] = '';
      _formValues['height'] = '';
      _formValues['rate'] = '';
      _formValues['code'] = '';
    });

    _erpFormKey.currentState?.updateFieldValue('mm', '');
    _erpFormKey.currentState?.updateFieldValue('length', '');
    _erpFormKey.currentState?.updateFieldValue('diam', '');
    _erpFormKey.currentState?.updateFieldValue('height', '');
    _erpFormKey.currentState?.updateFieldValue('rate', '');
    _erpFormKey.currentState?.updateFieldValue('code', '');

    _setDefaultSortId();

    Future.delayed(const Duration(milliseconds: 50), () {
      _erpFormKey.currentState?.focusField('length');
    });
  }

  void _deleteGridRow(int index) {
    setState(() {
      _entryGridRows.removeAt(index);
      if (_editingGridIndex == index) {
        _editingGridIndex = null;
      }
    });
  }

  void _editGridRow(int index) {
    final row = _entryGridRows[index];
    setState(() {
      _editingGridIndex = index;
      _formValues['articleCode'] = row['_articleCode']?.toString() ?? '';
      _formValues['shapeCode'] = row['_shapeCode']?.toString() ?? '';
      _formValues['colorCode'] = (row['_colorCodes'] as List).join(',');
      _formValues['purityCode'] = (row['_purityCodes'] as List).join(',');
      _formValues['layOutName'] = row['layoutName'] ?? '';
      _formValues['mm'] = row['_mm'] ?? row['mm'] ?? '';
      _formValues['length'] = row['length'] ?? '';
      _formValues['diam'] = row['diam'] ?? '';
      _formValues['height'] = row['height'] ?? '';
      _formValues['rate'] = row['rate'] ?? '';
      _formValues['code'] = row['code'] ?? '';
      _formValues['sortID'] = row['sortID'] ?? '';
      _formValues['active'] = row['_active'] == true ? 'true' : 'false';
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final entry in _formValues.entries) {
        _erpFormKey.currentState?.updateFieldValue(entry.key, entry.value);
      }
    });
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String getTwoDigitValue(double value) {
    final str = value.toStringAsFixed(2).replaceAll('.', '');

    return str.substring(0, 2);
  }

  Future<void> _onSave(Map<String, dynamic> values) async {
    final provider = context.read<SellPriceProvider>();

    if (_isEditMode && _selectedRow != null) {
      final raw = _selectedRow!['_raw'] as SellPriceModel;
      final payload = {
        "ArticalCode":
            int.tryParse(values['articleCode']?.toString() ?? '') ?? 0,
        "layoutname": values['layoutName']?.toString() ?? '',
        "CompanyCode": context.read<CompanyProvider>().selectedCompanyCode ?? 0,
        "Active": values['active'] == 'true' ||
                values['active'] == true ||
                values['active'] == '1'
            ? 1
            : 0,
        "colors": (_formValues['colorCode'] ?? '')
            .split(',')
            .where((e) => e.isNotEmpty)
            .map(int.parse)
            .toList(),
        "purities": (_formValues['purityCode'] ?? '')
            .split(',')
            .where((e) => e.isNotEmpty)
            .map(int.parse)
            .toList(),
        "details": _entryGridRows.isNotEmpty
            ? _entryGridRows.map((row) {
                return {
                  "ShapeCode": int.tryParse(row['_shapeCode']?.toString() ?? '') ?? 0,
                  "SellCode": row['code']?.toString() ?? '',
                  "mm": row['_mm']?.toString() ?? '',
                  "Length": row['_length'] as double,
                  "Width": row['_diam'] as double,
                  "Height": row['_height'] as double,
                  "Rate": row['_rate'] as double,
                  "SortID": int.tryParse(row['_sortID']?.toString() ?? '') ?? 0,
                  "Active": row['_active'] == true ? 1 : 0,
                };
              }).toList()
            : [
                {
                  "ShapeCode": int.tryParse(values['shapeCode']?.toString() ?? '') ?? 0,
                  "SellCode": values['code']?.toString() ?? '',
                  "mm": values['mm']?.toString() ?? '',
                  "Length": double.tryParse(values['length']?.toString() ?? '') ?? 0,
                  "Width": double.tryParse(values['diam']?.toString() ?? '') ?? 0,
                  "Height": double.tryParse(values['height']?.toString() ?? '') ?? 0,
                  "Rate": double.tryParse(values['rate']?.toString() ?? '') ?? 0,
                  "SortID": int.tryParse(values['sortID']?.toString() ?? '') ?? 0,
                  "Active": values['active'] == 'true' ||
                          values['active'] == true ||
                          values['active'] == '1'
                      ? 1
                      : 0,
                }
              ],
      };

      final success = await provider.updateSellPrice(
        raw.sellPriceListMstID!,
        payload,
      );
      if (!mounted) return;
      if (success) {
        _resetForm();
        await ErpResultDialog.showSuccess(
          context: context,
          theme: context.erpTheme,
          title: 'Updated',
          message: 'Sell Price updated successfully.',
        );
      } else {
        await ErpResultDialog.showError(
          context: context,
          theme: context.erpTheme,
          title: 'Error',
          message: 'Failed to update Sell Price.',
        );
      }
    } else {
      if (_entryGridRows.isEmpty) {
        _showSnack('Entry grid is empty. Please add items to the grid first.');
        return;
      }

      final firstRow = _entryGridRows.first;
      final payload = {
        "ArticalCode":
            int.tryParse(firstRow['_articleCode']?.toString() ?? '') ?? 0,
        "layoutname": firstRow['layoutName']?.toString() ?? '',
        "CompanyCode": context.read<CompanyProvider>().selectedCompanyCode ?? 0,
        "Active": firstRow['_active'] == true ? 1 : 0,
        "colors": firstRow['_colorCodes'] as List<int>,
        "purities": firstRow['_purityCodes'] as List<int>,
        "details": _entryGridRows.map((row) {
          return {
            "ShapeCode": int.tryParse(row['_shapeCode']?.toString() ?? '') ?? 0,
            "SellCode": row['code']?.toString() ?? '',
            "mm": row['_mm']?.toString() ?? '',
            "Length": row['_length'] as double,
            "Width": row['_diam'] as double,
            "Height": row['_height'] as double,
            "Rate": row['_rate'] as double,
            "Active": row['_active'] == true ? 1 : 0,
            "SortID": int.tryParse(row['sortID']?.toString() ?? '') ?? 0,
          };
        }).toList(),
      };

      final success = await provider.createSellPrice(payload);
      if (!mounted) return;
      if (success) {
        setState(() {
          _entryGridRows.clear();
        });
        _resetForm();
        await ErpResultDialog.showSuccess(
          context: context,
          theme: context.erpTheme,
          title: 'Saved',
          message: 'Sell Price saved successfully.',
        );
      } else {
        await ErpResultDialog.showError(
          context: context,
          theme: context.erpTheme,
          title: 'Error',
          message: 'Failed to save Sell Price.',
        );
      }
    }
  }

  Future<void> _onDelete() async {
    final raw = _selectedRow?['_raw'] as SellPriceModel?;

    if (raw?.sellPriceListMstID == null) return;

    final confirm = await ErpDeleteDialog.show(
      context: context,
      theme: context.erpTheme,
      title: 'Sell Price',
      itemName: raw!.sellCode ?? '',
    );

    if (confirm != true || !mounted) return;

    final success = await context.read<SellPriceProvider>().deleteSellPrice(
      raw.sellPriceListMstID!,
    );

    if (success && mounted) {
      await ErpResultDialog.showDeleted(
        context: context,
        theme: context.erpTheme,
        itemName: raw.sellCode ?? '',
      );

      _resetForm();
    }
  }

  void _resetForm() {
    setState(() {
      _selectedRow = null;
      _isEditMode = false;
      _formValues = {};
      _showTableOnMobile = false;
      _entryGridRows.clear();
      _editingGridIndex = null;
    });
    _erpFormKey.currentState?.resetForm();
    _setDefaultSortId();
  }

  void _setDefaultSortId() {
    int nextSortId = 1;
    for (final row in _entryGridRows) {
      final gridSortVal = int.tryParse(row['sortID']?.toString() ?? '') ?? 0;
      if (gridSortVal >= nextSortId) {
        nextSortId = gridSortVal + 1;
      }
    }

    final value = nextSortId.toString();

    setState(() {
      _formValues['sortID'] = value;
      _formValues['active'] = 'true';
    });
    Future.delayed(const Duration(milliseconds: 50), () {
      _erpFormKey.currentState?.updateFieldValue('sortID', value);
      _erpFormKey.currentState?.updateFieldValue('active', 'true');
    });
  }

  bool _showTableOnMobile = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<SellPriceProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child: Responsive.isMobile(context)
              ? _showTableOnMobile
                    ? buildErpDataTable(provider)
                    : ErpForm(
                        logo: AppImages.logo,
                        key: _erpFormKey,
                        title: 'SELL PRICE MASTER',
                        subtitle: 'Sell Price configuration',
                        initialTabIndex: 0,
                        addButtonSections: const {2},
                        onFieldSubmitted: (key, value) {
                          if (key == 'code') {
                            _addEntry();
                          }
                        },
                        onEntryAdd: (sectionIndex) {
                          if (sectionIndex == 2) {
                            _addEntry();
                          }
                        },

                        onSearch: () =>
                            setState(() => _showTableOnMobile = true),
                        tabBarBackgroundColor: const Color(0xfff2f0ef),
                        tabBarSelectedColor:
                            context.erpTheme.primaryGradient.first,
                        tabBarSelectedTxtColor: Colors.white,
                        rows: _buildFormRows(),
                        initialValues: _formValues,
                        isEditMode: _isEditMode,
                        onFieldChanged: _onFieldChanged,
                        onSave: _onSave,
                        onCancel: _resetForm,
                        onDelete: _isEditMode ? _onDelete : null,
                        detailBuilder: (ctx) {
                          if (_entryGridRows.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 12),
                              ErpEntryGrid(
                                data: _entryGridRows,
                                columns: _gridColumns,
                                title: '',
                                showTitleBar: false,
                                theme: ctx.erpTheme,
                                onDeleteRow: _deleteGridRow,
                                onEditRow: _editGridRow,
                                editingIndex: _editingGridIndex,
                                columnLabels: _gridColumnLabels,
                                allowCheckBoxOnTable: false,
                                columnWidths: {
                                  'layoutName': 160,
                                  'purity': 80,
                                  'shape': 150,
                                  'sortID': 40,
                                  'mm':110
                                },
                              ),
                            ],
                          );
                        },
                      )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: ErpForm(
                        logo: AppImages.logo,
                        key: _erpFormKey,
                        title: 'SELL PRICE MASTER',
                        subtitle: 'Sell Price configuration',
                        initialTabIndex: 0,
                        addButtonSections: const {2},
                        onEntryAdd: (sectionIndex) {
                          if (sectionIndex == 2) {
                            _addEntry();
                          }
                        },
                        onFieldSubmitted: (key, value) {
                          if (key == 'code') {
                            _addEntry();
                          }
                        },
                        tabBarBackgroundColor: const Color(0xfff2f0ef),
                        tabBarSelectedColor:
                            context.erpTheme.primaryGradient.first,
                        tabBarSelectedTxtColor: Colors.white,
                        rows: _buildFormRows(),
                        initialValues: _formValues,
                        isEditMode: _isEditMode,
                        onFieldChanged: _onFieldChanged,
                        onSave: _onSave,
                        onCancel: _resetForm,
                        onDelete: _isEditMode ? _onDelete : null,
                        detailBuilder: (ctx) {
                          if (_entryGridRows.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 12),
                              ErpEntryGrid(
                                data: _entryGridRows,
                                columns: _gridColumns,
                                title: '',
                                showTitleBar: false,
                                theme: ctx.erpTheme,
                                onDeleteRow: _deleteGridRow,
                                onEditRow: _editGridRow,
                                editingIndex: _editingGridIndex,
                                columnLabels: _gridColumnLabels,
                                // columnWidths: {
                                //   'layoutName': 160,
                                //   'purity': 80,
                                //   'shape': 150,
                                //   'sortID': 40,
                                //   'mm':110
                                // },
                                allowCheckBoxOnTable: false,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(flex: 1, child: buildErpDataTable(provider)),
                  ],
                ),
        );
      },
    );
  }

  void _onFieldChanged(String key, dynamic value) {
    if (value is List) {
      _formValues[key] = value.join(',');
    } else {
      _formValues[key] = value?.toString() ?? '';
    }

    if (['articleCode', 'shapeCode', 'length', 'diam'].contains(key)) {
      _generateCode();
    }

    if (['articleCode', 'colorCode', 'purityCode'].contains(key)) {
      _generateLayoutName();
    }

    if (['length', 'diam', 'height'].contains(key)) {
      _generateMm();
    }

    // Auto-advance focus through the form in entry order.
    if (key == 'articleCode') {
      Future.delayed(const Duration(milliseconds: 50), () {
        _erpFormKey.currentState?.focusField('colorCode');
      });
    }

    if (key == 'shapeCode') {
      Future.delayed(const Duration(milliseconds: 50), () {
        _erpFormKey.currentState?.focusField('length');
      });
    }
  }

  ErpDataTable buildErpDataTable(SellPriceProvider provider) {
    return ErpDataTable(
      isReportRow: false,
      token: token ?? '',
      url: baseUrl,
      title: 'SELL PRICE LIST',
      columns: _tableColumns,
      data: provider.tableData,
      showSearch: true,
      selectedRow: _selectedRow,
      onRowTap: _onRowTap,
      emptyMessage: provider.isLoaded ? 'No data found' : 'Loading...',
    );
  }
}
