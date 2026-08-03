import 'dart:convert';
import 'package:flutter/services.dart';

import 'package:collection/collection.dart';
import 'package:diam_mfg/models/user_visibility_model.dart';
import 'package:diam_mfg/providers/ReportProvider.dart';
import 'package:diam_mfg/providers/charni_provider.dart';
import 'package:diam_mfg/providers/color_provider.dart';
import 'package:diam_mfg/providers/counter_display_det_provider.dart';
import 'package:diam_mfg/providers/counter_manager_det_provider.dart';
import 'package:diam_mfg/providers/counter_provider.dart';
import 'package:diam_mfg/providers/cut_create_provider.dart';
import 'package:diam_mfg/providers/cut_provider.dart';
import 'package:diam_mfg/providers/dept_group_provider.dart';
import 'package:diam_mfg/providers/dept_process_provider.dart';
import 'package:diam_mfg/providers/dept_provider.dart';
import 'package:diam_mfg/providers/division_provider.dart';
import 'package:diam_mfg/providers/employee_provider.dart';
import 'package:diam_mfg/providers/factory_provider.dart';
import 'package:diam_mfg/providers/factory_receive_provider.dart';
import 'package:diam_mfg/providers/fluo_provider.dart';
import 'package:diam_mfg/providers/polish_provider.dart';
import 'package:diam_mfg/providers/purity_provider.dart';
import 'package:diam_mfg/providers/symmetry_provider.dart';
import 'package:diam_mfg/providers/remarks_provider.dart';
import 'package:diam_mfg/providers/report_mst_provider.dart';
import 'package:diam_mfg/providers/report_type_provider.dart';
import 'package:diam_mfg/providers/rough_provider.dart';
import 'package:diam_mfg/providers/shape_provider.dart';
import 'package:diam_mfg/providers/tensions_provider.dart';
import 'package:diam_mfg/providers/test_provider.dart';
import 'package:diam_mfg/providers/user_visibility_provider.dart';
import 'package:diam_mfg/utils/ReportRegistry.dart';
import 'package:diam_mfg/utils/app_images.dart';
import 'package:dio/dio.dart';
import 'package:erp_data_table/erp_data_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:rs_dashboard/rs_dashboard.dart';

import 'dart:typed_data';

import 'package:universal_html/html.dart' as html;
import 'package:pdfx/pdfx.dart';

import '../bootstrap.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

// ─────────────────────────────────────────────────────────────────────────────
//  STATE
// ─────────────────────────────────────────────────────────────────────────────

class _ReportScreenState extends State<ReportScreen> {
  // ── Theme ──────────────────────────────────────────────────────────────────
  final ErpThemeVariant _themeVariant = ErpThemeVariant.frost;

  ErpTheme get _theme => ErpTheme(_themeVariant);

  // ── Form ───────────────────────────────────────────────────────────────────
  // ⚠️  Never reassign _erpFormKey inside setState — that causes the
  //     "_elements.contains(element)" assertion.  Use a stable key always.
  //     To force a clean widget rebuild on reset, increment _formResetCount
  //     which is passed as the ValueKey on ErpForm.
  final GlobalKey<ErpFormState> _erpFormKey = GlobalKey<ErpFormState>();
  GlobalKey<ScaffoldState>? _scaffoldKey;

  GlobalKey<ScaffoldState> get scaffoldKey =>
      _scaffoldKey ??= GlobalKey<ScaffoldState>();
  int _formResetCount = 0; // ← bumped on reset to give ErpForm a new ValueKey
  Map<String, String> _formValues = {};
  final Map<String, String> _entryVals = {};

  /// Parallel map that keeps the raw List<String> for every multi-select field.
  /// _formValues[key] holds the comma-joined string (for display / reset).
  /// _multiSelectValues[key] holds the typed list (for API calls).
  Map<String, List<String>>? _multiSelectValues; // ← ADD
  int? _selectedTestCode;
  int? _selectedReportTypeCode;
  String? _activeReportType = '';
  bool _isAdvancedFiltersExpanded = false;

  // ── Auth ───────────────────────────────────────────────────────────────────
  final String? token = AppStorage.getString('token');

  // ── From / To counter ─────────────────────────────────────────────────────
  int? _fromCrId;
  String? _fromDeptName;
  int? _fromDeptCode;

  int? _toCrId;
  String? _toDeptName;
  int? _toDeptCodeVal;

  int? _editingDetIndex;

  // ── PAIR_REPORT Editing state ──────────────────────────────────────────────
  // ── PAIR_REPORT Editing state ──────────────────────────────────────────────
  int? _pairEditingRowIndex;
  final Map<String, TextEditingController> _pairControllers = {
    'DetID': TextEditingController(),
    'KapanNo': TextEditingController(),
    'PktNo': TextEditingController(),
    'PairNo': TextEditingController(),
    'GroupType': TextEditingController(),
    'Shape': TextEditingController(),
    'Wt': TextEditingController(),
    'IssWt': TextEditingController(),
    'RecWt': TextEditingController(),
    'Color': TextEditingController(),
    'Clarity': TextEditingController(),
    'Cut': TextEditingController(),
    'Polish': TextEditingController(),
    'Symmetry': TextEditingController(),
    'Flou': TextEditingController(),
    'SellPrice': TextEditingController(),
    'SellAmount': TextEditingController(),
    'Length': TextEditingController(),
    'Dia': TextEditingController(),
    'Height': TextEditingController(),
    'TopSide': TextEditingController(),
    'Certificate': TextEditingController(),
    'CertiNo': TextEditingController(),

    // Legacy/Alias controllers for backward compatibility
    'Id': TextEditingController(),
    'packetNo': TextEditingController(),
    'weight': TextEditingController(),
    'color': TextEditingController(),
    'purity': TextEditingController(),
    'cut': TextEditingController(),
    'polish': TextEditingController(),
    'symmetry': TextEditingController(),
    'florence': TextEditingController(),
    'sellPrice': TextEditingController(),
    'totalPrice': TextEditingController(),
    'mm': TextEditingController(),
    'topsSide': TextEditingController(),
    'category': TextEditingController(),
    'certificate': TextEditingController(),
    'certificateNo': TextEditingController(),
    'pairNo': TextEditingController(),
  };

  @override
  void dispose() {
    for (final controller in _pairControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  // ── Master lists for pair dropdowns ─────────────────────────────────────────
  List<String> _getColorList() {
    try {
      final colorProv = context.read<ColorProvider>();
      return colorProv.list
          .where(
            (e) =>
                e.active == true &&
                e.colorName != null &&
                e.colorName!.isNotEmpty,
          )
          .map((e) => e.colorName!)
          .toList();
    } catch (_) {
      return [];
    }
  }

  List<String> _getPurityList() {
    try {
      final purityProv = context.read<PurityProvider>();
      return purityProv.list
          .where(
            (e) =>
                e.active == true &&
                e.purityName != null &&
                e.purityName!.isNotEmpty,
          )
          .map((e) => e.purityName!)
          .toList();
    } catch (_) {
      return [];
    }
  }

  List<String> _getCutList() {
    try {
      final cutProv = context.read<CutProvider>();
      return cutProv.cuts
          .where(
            (e) =>
                e.active == true && e.cutName != null && e.cutName!.isNotEmpty,
          )
          .map((e) => e.cutName!)
          .toList();
    } catch (_) {
      return [];
    }
  }

  List<String> _getPolishList() {
    try {
      final polishProv = context.read<PolishProvider>();
      return polishProv.polishs
          .where(
            (e) =>
                e.active == true &&
                e.polishName != null &&
                e.polishName!.isNotEmpty,
          )
          .map((e) => e.polishName!)
          .toList();
    } catch (_) {
      return [];
    }
  }

  List<String> _getSymmetryList() {
    try {
      final symmetryProv = context.read<SymmetryProvider>();
      return symmetryProv.symmetrys
          .where(
            (e) =>
                e.active == true &&
                e.symmetryName != null &&
                e.symmetryName!.isNotEmpty,
          )
          .map((e) => e.symmetryName!)
          .toList();
    } catch (_) {
      return [];
    }
  }

  List<String> _getFluoList() {
    try {
      final fluoProv = context.read<FluoProvider>();
      return fluoProv.list
          .where(
            (e) =>
                e.active == true &&
                e.fluoName != null &&
                e.fluoName!.isNotEmpty,
          )
          .map((e) => e.fluoName!)
          .toList();
    } catch (_) {
      return [];
    }
  }

  List<String> _getShapeList() {
    try {
      final shapeProv = context.read<ShapeProvider>();
      return shapeProv.list
          .where(
            (e) =>
                e.active == true &&
                e.shapeName != null &&
                e.shapeName!.isNotEmpty,
          )
          .map((e) => e.shapeName!)
          .toList();
    } catch (_) {
      return [];
    }
  }

  List<String> _getKapanList() {
    try {
      final prov = context.read<ReportProvider>();
      final kapansFromData = prov.tableData
          .map((e) => e['KapanNo']?.toString() ?? e['kapanNo']?.toString())
          .whereType<String>()
          .where((s) => s.isNotEmpty && s != '-')
          .toSet()
          .toList();
      if (kapansFromData.isNotEmpty) return kapansFromData;
    } catch (_) {}
    return [];
  }

  List<String> _getDropdownOptions({
    required List<String> providerItems,
    required String? currentVal,
    required List<String> defaults,
  }) {
    final set = <String>{...providerItems, ...defaults};
    if (currentVal != null && currentVal.isNotEmpty && currentVal != '-') {
      set.add(currentVal);
    }
    final list = set.toList();
    list.sort();
    return list;
  }

  void _onPairRowDoubleTap(Map<String, dynamic> row, int index) {
    _openPairReportDialog(context, row, index);
  }

  void _openPairReportDialog(
    BuildContext context,
    Map<String, dynamic>? row,
    int? index,
  ) {
    _pairEditingRowIndex = index;

    final detIdVal = row != null
        ? '${row['DetID'] ?? row['detID'] ?? row['Id'] ?? row['id'] ?? ''}'
        : '';
    final kapanNoVal = row != null
        ? '${row['KapanNo'] ?? row['kapanNo'] ?? ''}'
        : '';
    final pktNoVal = row != null
        ? '${row['PktNo'] ?? row['pktNo'] ?? row['packetNo'] ?? row['PacketNo'] ?? ''}'
        : '';
    final pairNoVal = row != null
        ? '${row['PairNo'] ?? row['pairNo'] ?? ''}'
        : '';
    final groupTypeVal = row != null
        ? '${row['GroupType'] ?? row['groupType'] ?? row['category'] ?? ''}'
        : '';
    final shapeVal = row != null ? '${row['Shape'] ?? row['shape'] ?? ''}' : '';
    final wtVal = row != null
        ? '${row['Wt'] ?? row['wt'] ?? row['weight'] ?? row['Weight'] ?? ''}'
        : '';
    final issWtVal = row != null ? '${row['IssWt'] ?? row['issWt'] ?? ''}' : '';
    final recWtVal = row != null ? '${row['RecWt'] ?? row['recWt'] ?? ''}' : '';
    final colorVal = row != null ? '${row['Color'] ?? row['color'] ?? ''}' : '';
    final clarityVal = row != null
        ? '${row['Clarity'] ?? row['clarity'] ?? row['purity'] ?? row['Purity'] ?? ''}'
        : '';
    final cutVal = row != null ? '${row['Cut'] ?? row['cut'] ?? ''}' : '';
    final polishVal = row != null
        ? '${row['Polish'] ?? row['polish'] ?? ''}'
        : '';
    final symmetryVal = row != null
        ? '${row['Symmetry'] ?? row['symmetry'] ?? ''}'
        : '';
    final flouVal = row != null
        ? '${row['Flou'] ?? row['flou'] ?? row['florence'] ?? row['Florence'] ?? ''}'
        : '';
    final sellPriceVal = row != null
        ? '${row['SellPrice'] ?? row['sellPrice'] ?? ''}'
        : '';
    final sellAmountVal = row != null
        ? '${row['SellAmount'] ?? row['sellAmount'] ?? row['totalPrice'] ?? ''}'
        : '';
    final lengthVal = row != null
        ? '${row['Length'] ?? row['length'] ?? ''}'
        : '';
    final diaVal = row != null ? '${row['Dia'] ?? row['dia'] ?? ''}' : '';
    final heightVal = row != null
        ? '${row['Height'] ?? row['height'] ?? ''}'
        : '';
    final topSideVal = row != null
        ? '${row['TopSide'] ?? row['topSide'] ?? row['topsSide'] ?? ''}'
        : '';
    final certificateVal = row != null
        ? '${row['Certificate'] ?? row['certificate'] ?? ''}'
        : '';
    final certiNoVal = row != null
        ? '${row['CertiNo'] ?? row['certiNo'] ?? row['certificateNo'] ?? ''}'
        : '';

    _pairControllers['DetID']?.text = detIdVal;
    _pairControllers['PktNo']?.text = pktNoVal;
    _pairControllers['KapanNo']?.text = kapanNoVal;
    _pairControllers['PairNo']?.text = pairNoVal;
    _pairControllers['GroupType']?.text = groupTypeVal;
    _pairControllers['Wt']?.text = wtVal;
    _pairControllers['IssWt']?.text = issWtVal;
    _pairControllers['RecWt']?.text = recWtVal;
    _pairControllers['SellPrice']?.text = sellPriceVal;
    _pairControllers['SellAmount']?.text = sellAmountVal;
    _pairControllers['Length']?.text = lengthVal;
    _pairControllers['Dia']?.text = diaVal;
    _pairControllers['Height']?.text = heightVal;
    _pairControllers['TopSide']?.text = topSideVal;
    _pairControllers['Certificate']?.text = certificateVal;
    _pairControllers['CertiNo']?.text = certiNoVal;

    String? selectedColor = colorVal.isNotEmpty ? colorVal : null;
    String? selectedPurity = clarityVal.isNotEmpty ? clarityVal : null;
    String? selectedCut = cutVal.isNotEmpty ? cutVal : null;
    String? selectedPolish = polishVal.isNotEmpty ? polishVal : null;
    String? selectedSymmetry = symmetryVal.isNotEmpty ? symmetryVal : null;
    String? selectedFlou = flouVal.isNotEmpty ? flouVal : null;
    String? selectedShape = shapeVal.isNotEmpty ? shapeVal : null;
    String? selectedKapanNo = kapanNoVal.isNotEmpty ? kapanNoVal : null;
    String? selectedGroupType = groupTypeVal.isNotEmpty ? groupTypeVal : null;
    String? selectedCertificate = certificateVal.isNotEmpty
        ? certificateVal
        : null;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final theme = _theme;

            final colorOptions = _getDropdownOptions(
              providerItems: _getColorList(),
              currentVal: selectedColor,
              defaults: const [],
            );

            final purityOptions = _getDropdownOptions(
              providerItems: _getPurityList(),
              currentVal: selectedPurity,
              defaults: const [],
            );

            final cutOptions = _getDropdownOptions(
              providerItems: _getCutList(),
              currentVal: selectedCut,
              defaults: const [],
            );

            final polishOptions = _getDropdownOptions(
              providerItems: _getPolishList(),
              currentVal: selectedPolish,
              defaults: const [],
            );

            final symmetryOptions = _getDropdownOptions(
              providerItems: _getSymmetryList(),
              currentVal: selectedSymmetry,
              defaults: const [],
            );

            final fluoOptions = _getDropdownOptions(
              providerItems: _getFluoList(),
              currentVal: selectedFlou,
              defaults: const [],
            );

            final shapeOptions = _getDropdownOptions(
              providerItems: _getShapeList(),
              currentVal: selectedShape,
              defaults: const [],
            );

            final groupTypeOptions = _getDropdownOptions(
              providerItems: const [],
              currentVal: selectedGroupType,
              defaults: const [
                'Matching Pair',
                'Fancy Shape',
                'Salt & Paper',
                'Black Diamond',
                'Loos Diamond',
              ],
            );

            final certificateOptions = _getDropdownOptions(
              providerItems: const [],
              currentVal: selectedCertificate,
              defaults: const ['GIA', 'IGI', 'NON'],
            );

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: theme.surface,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.height * 0.6,
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Dialog Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.edit_note,
                                color: theme.primary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              index != null
                                  ? 'Edit Pair Record (#${index + 1})'
                                  : 'Add New Pair Record',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.text,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(dialogCtx).pop(),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // Scrollable Fields
                    Flexible(
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          alignment: WrapAlignment.start,
                          children: [
                            _buildTextField(
                              'DetID',
                              'DET ID',
                              theme,
                              isNumeric: true,
                              readOnly: true,
                            ),
                            _buildTextField(
                              'KapanNo',
                              'KAPAN NO',
                              theme,
                              readOnly: true,
                            ),
                            _buildTextField(
                              'PktNo',
                              'PKT NO',
                              theme,
                              readOnly: true,
                            ),
                            _buildTextField(
                              'PairNo',
                              'PAIR NO',
                              theme,
                              isNumeric: true,
                            ),
                            _buildDropdownField(
                              'GROUP TYPE',
                              selectedGroupType,
                              groupTypeOptions,
                              theme,
                              (val) {
                                setDialogState(() => selectedGroupType = val);
                              },
                            ),
                            _buildDropdownField(
                              'SHAPE',
                              selectedShape,
                              shapeOptions,
                              theme,
                              (val) {
                                setDialogState(() => selectedShape = val);
                              },
                            ),
                            _buildTextField('Wt', 'WT', theme, isNumeric: true),
                            _buildTextField(
                              'IssWt',
                              'ISS WT',
                              theme,
                              isNumeric: true,
                            ),
                            _buildTextField(
                              'RecWt',
                              'REC WT',
                              theme,
                              isNumeric: true,
                            ),
                            _buildDropdownField(
                              'COLOR',
                              selectedColor,
                              colorOptions,
                              theme,
                              (val) {
                                setDialogState(() => selectedColor = val);
                              },
                            ),
                            _buildDropdownField(
                              'PURITY / CLARITY',
                              selectedPurity,
                              purityOptions,
                              theme,
                              (val) {
                                setDialogState(() => selectedPurity = val);
                              },
                            ),
                            _buildDropdownField(
                              'CUT',
                              selectedCut,
                              cutOptions,
                              theme,
                              (val) {
                                setDialogState(() => selectedCut = val);
                              },
                            ),
                            _buildDropdownField(
                              'POLISH',
                              selectedPolish,
                              polishOptions,
                              theme,
                              (val) {
                                setDialogState(() => selectedPolish = val);
                              },
                            ),
                            _buildDropdownField(
                              'SYMMETRY',
                              selectedSymmetry,
                              symmetryOptions,
                              theme,
                              (val) {
                                setDialogState(() => selectedSymmetry = val);
                              },
                            ),
                            _buildDropdownField(
                              'FLOU',
                              selectedFlou,
                              fluoOptions,
                              theme,
                              (val) {
                                setDialogState(() => selectedFlou = val);
                              },
                            ),
                            _buildTextField(
                              'SellPrice',
                              'SELL PRICE',
                              theme,
                              isNumeric: true,
                            ),
                            _buildTextField(
                              'SellAmount',
                              'SELL AMOUNT',
                              theme,
                              isNumeric: true,
                            ),
                            _buildTextField(
                              'Length',
                              'LENGTH',
                              theme,
                              isNumeric: true,
                            ),
                            _buildTextField(
                              'Dia',
                              'DIA',
                              theme,
                              isNumeric: true,
                            ),
                            _buildTextField(
                              'Height',
                              'HEIGHT',
                              theme,
                              isNumeric: true,
                            ),
                            _buildTextField('TopSide', 'TOP SIDE', theme),
                            _buildDropdownField(
                              'CERTIFICATE',
                              selectedCertificate,
                              certificateOptions,
                              theme,
                              (val) {
                                setDialogState(() => selectedCertificate = val);
                              },
                            ),
                            _buildTextField('CertiNo', 'CERTI NO', theme),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Dialog Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            setDialogState(() {
                              for (final controller
                                  in _pairControllers.values) {
                                controller.clear();
                              }
                              selectedColor = null;
                              selectedPurity = null;
                              selectedCut = null;
                              selectedPolish = null;
                              selectedSymmetry = null;
                              selectedFlou = null;
                              selectedShape = null;
                              selectedKapanNo = null;
                              selectedGroupType = null;
                              selectedCertificate = null;
                            });
                          },
                          child: const Text('CLEAR'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: () => Navigator.of(dialogCtx).pop(),
                          child: const Text('CANCEL'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () async {
                            await _savePairRowFromDialog(
                              originalRow: row,
                              index: index,
                              color: selectedColor,
                              purity: selectedPurity,
                              cut: selectedCut,
                              polish: selectedPolish,
                              symmetry: selectedSymmetry,
                              flou: selectedFlou,
                              shape: selectedShape,
                              kapanNo: selectedKapanNo,
                              groupType: selectedGroupType,
                              certificate: selectedCertificate,
                            );
                            if (context.mounted) {
                              Navigator.of(dialogCtx).pop();
                            }
                          },
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('SAVE'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDropdownField(
    String label,
    String? selectedValue,
    List<String> items,
    ErpTheme theme,
    ValueChanged<String?> onChanged,
  ) {
    final validValue = (selectedValue != null && items.contains(selectedValue))
        ? selectedValue
        : null;

    return SizedBox(
      width: 170,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: theme.text,
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 28,
            child: DropdownButtonFormField<String>(
              value: validValue,
              isDense: true,
              isExpanded: true,
              hint: Text(
                'Select',
                style: TextStyle(fontSize: 11, color: theme.primary),
              ),
              style: TextStyle(fontSize: 12, color: theme.primary),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: theme.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: theme.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: theme.primary, width: 1.5),
                ),
                filled: true,
                fillColor: theme.surface,
              ),
              items: items
                  .map(
                    (val) => DropdownMenuItem<String>(
                      value: val,
                      child: Text(
                        val,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: theme.text),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String key,
    String label,
    ErpTheme theme, {
    bool isNumeric = false,
    bool readOnly = false,
  }) {
    if (!_pairControllers.containsKey(key)) {
      _pairControllers[key] = TextEditingController();
    }

    return SizedBox(
      width: 170,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: theme.text,
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 38,
            child: TextField(
              readOnly: readOnly,
              controller: _pairControllers[key],
              keyboardType: isNumeric
                  ? const TextInputType.numberWithOptions(decimal: true)
                  : TextInputType.text,
              style: TextStyle(fontSize: 12, color: theme.primary),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: theme.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: theme.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: theme.primary, width: 1.5),
                ),
                filled: true,
                fillColor: theme.surface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _resolveColorCode(String? name, dynamic fallback) {
    if (name != null && name.isNotEmpty) {
      try {
        final item = context.read<ColorProvider>().list.firstWhereOrNull(
          (e) => e.colorName == name,
        );
        if (item?.colorCode != null) return item!.colorCode!;
      } catch (_) {}
    }
    return (fallback is num)
        ? fallback.toInt()
        : (int.tryParse(fallback?.toString() ?? '') ?? 0);
  }

  int _resolvePurityCode(String? name, dynamic fallback) {
    if (name != null && name.isNotEmpty) {
      try {
        final item = context.read<PurityProvider>().list.firstWhereOrNull(
          (e) => e.purityName == name,
        );
        if (item?.purityCode != null) return item!.purityCode!;
      } catch (_) {}
    }
    return (fallback is num)
        ? fallback.toInt()
        : (int.tryParse(fallback?.toString() ?? '') ?? 0);
  }

  int _resolveCutCode(String? name, dynamic fallback) {
    if (name != null && name.isNotEmpty) {
      try {
        final item = context.read<CutProvider>().cuts.firstWhereOrNull(
          (e) => e.cutName == name,
        );
        if (item?.cutCode != null) return item!.cutCode!;
      } catch (_) {}
    }
    return (fallback is num)
        ? fallback.toInt()
        : (int.tryParse(fallback?.toString() ?? '') ?? 0);
  }

  int _resolvePolishCode(String? name, dynamic fallback) {
    if (name != null && name.isNotEmpty) {
      try {
        final item = context.read<PolishProvider>().polishs.firstWhereOrNull(
          (e) => e.polishName == name,
        );
        if (item?.polishCode != null) return item!.polishCode!;
      } catch (_) {}
    }
    return (fallback is num)
        ? fallback.toInt()
        : (int.tryParse(fallback?.toString() ?? '') ?? 0);
  }

  int _resolveSymmetryCode(String? name, dynamic fallback) {
    if (name != null && name.isNotEmpty) {
      try {
        final item = context
            .read<SymmetryProvider>()
            .symmetrys
            .firstWhereOrNull((e) => e.symmetryName == name);
        if (item?.symmetryCode != null) return item!.symmetryCode!;
      } catch (_) {}
    }
    return (fallback is num)
        ? fallback.toInt()
        : (int.tryParse(fallback?.toString() ?? '') ?? 0);
  }

  int _resolveFluoCode(String? name, dynamic fallback) {
    if (name != null && name.isNotEmpty) {
      try {
        final item = context.read<FluoProvider>().list.firstWhereOrNull(
          (e) => e.fluoName == name,
        );
        if (item?.fluoCode != null) return item!.fluoCode!;
      } catch (_) {}
    }
    return (fallback is num)
        ? fallback.toInt()
        : (int.tryParse(fallback?.toString() ?? '') ?? 0);
  }

  int _resolveShapeCode(String? name, dynamic fallback) {
    if (name != null && name.isNotEmpty) {
      try {
        final item = context.read<ShapeProvider>().list.firstWhereOrNull(
          (e) => e.shapeName == name,
        );
        if (item?.shapeCode != null) return item!.shapeCode!;
      } catch (_) {}
    }
    return (fallback is num)
        ? fallback.toInt()
        : (int.tryParse(fallback?.toString() ?? '') ?? 0);
  }

  Future<void> _savePairRowFromDialog({
    required Map<String, dynamic>? originalRow,
    required int? index,
    required String? color,
    required String? purity,
    required String? cut,
    required String? polish,
    required String? symmetry,
    required String? flou,
    required String? shape,
    required String? kapanNo,
    required String? groupType,
    required String? certificate,
  }) async {
    final reportProv = context.read<ReportProvider>();
    final existingRow =
        originalRow ??
        ((index != null && index >= 0 && index < reportProv.tableData.length)
            ? reportProv.tableData[index]
            : null);

    final detIdVal =
        int.tryParse(_pairControllers['DetID']?.text.trim() ?? '') ??
        (existingRow?['DetID'] is num
            ? existingRow!['DetID'].toInt()
            : int.tryParse(existingRow?['DetID']?.toString() ?? '') ?? 0);
    final mstIdVal =
        int.tryParse(_pairControllers['MstID']?.text.trim() ?? '') ??
        (existingRow?['MstID'] is num
            ? existingRow!['MstID'].toInt()
            : int.tryParse(existingRow?['MstID']?.toString() ?? '') ?? 0);
    final bCodeVal =
        int.tryParse(_pairControllers['BCode']?.text.trim() ?? '') ??
        (existingRow?['BCode'] is num
            ? existingRow!['BCode'].toInt()
            : int.tryParse(existingRow?['BCode']?.toString() ?? '') ?? 0);

    final pktNoText = _pairControllers['PktNo']?.text.trim();
    final pktNoVal = (pktNoText != null && pktNoText.isNotEmpty)
        ? pktNoText
        : (existingRow?['PktNo'] ?? existingRow?['packetNo'] ?? '-');

    final wtText = _pairControllers['Wt']?.text.trim();
    final wtVal = (wtText != null && wtText.isNotEmpty)
        ? (double.tryParse(wtText) ?? 0.0)
        : (existingRow?['Wt'] is num
              ? existingRow!['Wt'].toDouble()
              : double.tryParse(existingRow?['Wt']?.toString() ?? '') ?? 0.0);

    final issWtText = _pairControllers['IssWt']?.text.trim();
    final issWtVal = (issWtText != null && issWtText.isNotEmpty)
        ? (double.tryParse(issWtText) ?? 0.0)
        : (existingRow?['IssWt'] is num
              ? existingRow!['IssWt'].toDouble()
              : double.tryParse(existingRow?['IssWt']?.toString() ?? '') ??
                    0.0);

    final recWtText = _pairControllers['RecWt']?.text.trim();
    final recWtVal = (recWtText != null && recWtText.isNotEmpty)
        ? (double.tryParse(recWtText) ?? 0.0)
        : (existingRow?['RecWt'] is num
              ? existingRow!['RecWt'].toDouble()
              : double.tryParse(existingRow?['RecWt']?.toString() ?? '') ??
                    0.0);

    final colorVal = (color != null && color.isNotEmpty)
        ? color
        : existingRow?['Color'];
    final purityVal = (purity != null && purity.isNotEmpty)
        ? purity
        : existingRow?['Clarity'];
    final cutVal = (cut != null && cut.isNotEmpty) ? cut : existingRow?['Cut'];
    final polishVal = (polish != null && polish.isNotEmpty)
        ? polish
        : existingRow?['Polish'];
    final symmetryVal = (symmetry != null && symmetry.isNotEmpty)
        ? symmetry
        : existingRow?['Symmetry'];
    final flouVal = (flou != null && flou.isNotEmpty)
        ? flou
        : existingRow?['Flou'];
    final shapeVal = (shape != null && shape.isNotEmpty)
        ? shape
        : existingRow?['Shape'];

    final colorCodeVal = _resolveColorCode(colorVal, existingRow?['ColorCode']);
    final purityCodeVal = _resolvePurityCode(
      purityVal,
      existingRow?['PurityCode'],
    );
    final cutCodeVal = _resolveCutCode(cutVal, existingRow?['CutCode']);
    final polishCodeVal = _resolvePolishCode(
      polishVal,
      existingRow?['PolishCode'],
    );
    final symmetryCodeVal = _resolveSymmetryCode(
      symmetryVal,
      existingRow?['SymmetryCode'],
    );
    final fluoCodeVal = _resolveFluoCode(flouVal, existingRow?['FluoCode']);
    final shapeCodeVal = _resolveShapeCode(shapeVal, existingRow?['ShapeCode']);

    final sellPriceText = _pairControllers['SellPrice']?.text.trim();
    final sellPriceVal = (sellPriceText != null && sellPriceText.isNotEmpty)
        ? double.tryParse(sellPriceText)
        : (existingRow?['SellPrice'] is num
              ? existingRow!['SellPrice'].toDouble()
              : double.tryParse(existingRow?['SellPrice']?.toString() ?? ''));

    final sellAmountText = _pairControllers['SellAmount']?.text.trim();
    final sellAmountVal = (sellAmountText != null && sellAmountText.isNotEmpty)
        ? double.tryParse(sellAmountText)
        : (existingRow?['SellAmount'] is num
              ? existingRow!['SellAmount'].toDouble()
              : double.tryParse(existingRow?['SellAmount']?.toString() ?? ''));

    final lengthText = _pairControllers['Length']?.text.trim();
    final lengthVal = (lengthText != null && lengthText.isNotEmpty)
        ? double.tryParse(lengthText)
        : (existingRow?['Length'] is num
              ? existingRow!['Length'].toDouble()
              : double.tryParse(existingRow?['Length']?.toString() ?? ''));

    final diaText = _pairControllers['Dia']?.text.trim();
    final diaVal = (diaText != null && diaText.isNotEmpty)
        ? double.tryParse(diaText)
        : (existingRow?['Dia'] is num
              ? existingRow!['Dia'].toDouble()
              : double.tryParse(existingRow?['Dia']?.toString() ?? ''));

    final heightText = _pairControllers['Height']?.text.trim();
    final heightVal = (heightText != null && heightText.isNotEmpty)
        ? double.tryParse(heightText)
        : (existingRow?['Height'] is num
              ? existingRow!['Height'].toDouble()
              : double.tryParse(existingRow?['Height']?.toString() ?? ''));

    final topSideText = _pairControllers['TopSide']?.text.trim();
    final topSideVal = (topSideText != null && topSideText.isNotEmpty)
        ? topSideText
        : existingRow?['TopSide'];

    final groupTypeText = _pairControllers['GroupType']?.text.trim();
    final groupTypeVal = (groupType != null && groupType.isNotEmpty)
        ? groupType
        : ((groupTypeText != null && groupTypeText.isNotEmpty)
              ? groupTypeText
              : existingRow?['GroupType']);

    final certText = _pairControllers['Certificate']?.text.trim();
    final certVal = (certificate != null && certificate.isNotEmpty)
        ? certificate
        : ((certText != null && certText.isNotEmpty)
              ? certText
              : existingRow?['Certificate']);

    final certiNoText = _pairControllers['CertiNo']?.text.trim();
    final certiNoVal = (certiNoText != null && certiNoText.isNotEmpty)
        ? certiNoText
        : existingRow?['CertiNo'];

    final pairNoText = _pairControllers['PairNo']?.text.trim();
    final pairNoVal = (pairNoText != null && pairNoText.isNotEmpty)
        ? (int.tryParse(pairNoText) ?? 0)
        : (existingRow?['PairNo'] is num
              ? existingRow!['PairNo'].toInt()
              : int.tryParse(existingRow?['PairNo']?.toString() ?? '') ?? 0);

    final kapanVal = (kapanNo != null && kapanNo.isNotEmpty)
        ? kapanNo
        : (_pairControllers['KapanNo']?.text.trim().isNotEmpty ?? false
              ? _pairControllers['KapanNo']!.text.trim()
              : existingRow?['KapanNo']);

    final Map<String, dynamic> payload = {
      "FactoryRecDetID": detIdVal,
      "FactoryRecMstID": mstIdVal,
      "BCode": bCodeVal,
      "ColorCode": colorCodeVal,
      "PurityCode": purityCodeVal,
      "CutCode": cutCodeVal,
      "PolishCode": polishCodeVal,
      "SymmetryCode": symmetryCodeVal,
      "FluoCode": fluoCodeVal,
      "SellRate": sellPriceVal,
      "SellAmount": sellAmountVal,
      "Length": lengthVal,
      "Diam": diaVal,
      "Height": heightVal,
      "TopSide": topSideVal,
      "GroupType": groupTypeVal,
      "Certificate": certVal,
      "CertiNo": certiNoVal,
      "PairNo": pairNoVal.toString(),
      "ShapeCode": shapeCodeVal,
    };

    final factoryProv = context.read<FactoryReceivedEntryProvider>();
    final success = await factoryProv.updateFactoryRecPairData(
      payload,
      _theme,
      context,
    );

    if (success) {
      final updatedRow = Map<String, dynamic>.from(existingRow ?? {});

      String fmtNum(dynamic n, int dec) {
        if (n == null) return '-';
        if (n is num) return n.toStringAsFixed(dec);
        final d = double.tryParse(n.toString());
        return d != null ? d.toStringAsFixed(dec) : n.toString();
      }

      final wtStr = fmtNum(wtVal, 3);
      final issWtStr = fmtNum(issWtVal, 3);
      final recWtStr = fmtNum(recWtVal, 3);
      final sellPriceStr = sellPriceVal != null ? fmtNum(sellPriceVal, 2) : '-';
      final sellAmountStr = sellAmountVal != null
          ? fmtNum(sellAmountVal, 2)
          : '-';
      final lengthStr = lengthVal != null ? fmtNum(lengthVal, 2) : '-';
      final diaStr = diaVal != null ? fmtNum(diaVal, 2) : '-';
      final heightStr = heightVal != null ? fmtNum(heightVal, 2) : '-';

      updatedRow['DetID'] = '$detIdVal';
      updatedRow['FactoryRecDetID'] = detIdVal;
      updatedRow['MstID'] = mstIdVal;
      updatedRow['FactoryRecMstID'] = mstIdVal;
      updatedRow['BCode'] = bCodeVal;
      updatedRow['KapanNo'] = kapanVal ?? '-';
      updatedRow['PktNo'] = pktNoVal ?? '-';
      updatedRow['PairNo'] = '$pairNoVal';
      updatedRow['GroupType'] = groupTypeVal ?? '-';
      updatedRow['ShapeCode'] = shapeCodeVal;
      updatedRow['Shape'] = shapeVal ?? '-';
      updatedRow['Wt'] = wtStr;
      updatedRow['IssWt'] = issWtStr;
      updatedRow['RecWt'] = recWtStr;
      updatedRow['ColorCode'] = colorCodeVal;
      updatedRow['Color'] = colorVal ?? '-';
      updatedRow['PurityCode'] = purityCodeVal;
      updatedRow['Clarity'] = purityVal ?? '-';
      updatedRow['CutCode'] = cutCodeVal;
      updatedRow['Cut'] = cutVal ?? '-';
      updatedRow['PolishCode'] = polishCodeVal;
      updatedRow['Polish'] = polishVal ?? '-';
      updatedRow['SymmetryCode'] = symmetryCodeVal;
      updatedRow['Symmetry'] = symmetryVal ?? '-';
      updatedRow['FluoCode'] = fluoCodeVal;
      updatedRow['Flou'] = flouVal ?? '-';
      updatedRow['SellPrice'] = sellPriceStr;
      updatedRow['SellAmount'] = sellAmountStr;
      updatedRow['Length'] = lengthStr;
      updatedRow['Dia'] = diaStr;
      updatedRow['Height'] = heightStr;
      updatedRow['TopSide'] = topSideVal ?? '-';
      updatedRow['Certificate'] = certVal ?? '-';
      updatedRow['CertiNo'] = certiNoVal ?? '-';

      // Legacy/Alias keys
      updatedRow['Id'] = '$detIdVal';
      updatedRow['packetNo'] = pktNoVal ?? '-';
      updatedRow['weight'] = wtStr;
      updatedRow['color'] = colorVal ?? '-';
      updatedRow['purity'] = purityVal ?? '-';
      updatedRow['cut'] = cutVal ?? '-';
      updatedRow['polish'] = polishVal ?? '-';
      updatedRow['symmetry'] = symmetryVal ?? '-';
      updatedRow['florence'] = flouVal ?? '-';
      updatedRow['sellPrice'] = sellPriceStr;
      updatedRow['totalPrice'] = sellAmountStr;
      updatedRow['mm'] = '$lengthStr x $diaStr x $heightStr';
      updatedRow['topsSide'] = topSideVal ?? '-';
      updatedRow['category'] = groupTypeVal ?? '-';
      updatedRow['certificate'] = certVal ?? '-';
      updatedRow['certificateNo'] = certiNoVal ?? '-';
      updatedRow['pairNo'] = '$pairNoVal';

      if (index != null && index >= 0 && index < reportProv.tableData.length) {
        reportProv.updateRow(index, updatedRow);
      } else {
        final existingIndex = reportProv.tableData.indexWhere(
          (e) => '${e['DetID']}' == '$detIdVal' || '${e['Id']}' == '$detIdVal',
        );
        if (existingIndex != -1) {
          reportProv.updateRow(existingIndex, updatedRow);
        } else {
          reportProv.addRow(updatedRow);
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pair record updated successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // ── Display fields (from UserVisibility) ───────────────────────────────────
  List<UserVisibilityModel> _fromDisplayFields = [];
  List<UserVisibilityModel> _toDisplayFields = [];
  String? _selectedRadioCode;

  CounterDisplayDetProvider get _displayProv =>
      context.read<CounterDisplayDetProvider>();

  UserVisibilityProvider get _visProv => context.read<UserVisibilityProvider>();

  // ── Keys that are multi-select ─────────────────────────────────────────────
  static const _multiSelectKeys = {
    'mainCut',
    'kNo',
    'cutNo',
    'fromCrId',
    'toCrId',
    'remarks',
    'deptProcessCode',
    'purityCode',
    'colorCode',
    'tensionCode',
    'shapeCode',
    'typeSecond',
    'factoryCode',
    'divisionCode',
    'employeeCode',
    'fromDept',
    'toDept',
  };

  // ─────────────────────────────────────────────────────────────────────────
  //  API FILTER HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  /// Returns a List<int> for a multi-select field (empty list if nothing selected).
  List<int> _intList(String key) => (_multiSelectValues?[key] ?? [])
      .map((e) => int.tryParse(e))
      .whereType<int>()
      .toList();

  /// Returns a single nullable int for normal (single) dropdown / text fields.
  int? _intVal(String key) => int.tryParse(_formValues[key] ?? '');

  // ─────────────────────────────────────────────────────────────────────────
  //  LOOKUP HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  String _deptNameFor(int? deptCode) {
    if (deptCode == null) return '';
    try {
      return context
              .read<DeptProvider>()
              .list
              .firstWhere((d) => d.deptCode == deptCode)
              .deptName ??
          '';
    } catch (_) {
      return '';
    }
  }

  String _deptGroupNameFor(int? code) {
    if (code == null) return '';
    try {
      return context
              .read<DeptGroupProvider>()
              .list
              .firstWhere((d) => d.deptGroupCode == code)
              .deptGroupName ??
          '';
    } catch (_) {
      return '';
    }
  }

  String _shapeNameFor(int? code) {
    if (code == null) return '';
    try {
      return context
              .read<ShapeProvider>()
              .list
              .firstWhere((s) => s.shapeCode == code)
              .shapeName ??
          '';
    } catch (_) {
      return '';
    }
  }

  String _purityNameFor(int? code) {
    if (code == null) return '';
    try {
      return context
              .read<PurityProvider>()
              .list
              .firstWhere((p) => p.purityCode == code)
              .purityName ??
          '';
    } catch (_) {
      return '';
    }
  }

  String _employeeNameFor(int? code) {
    if (code == null) return '';
    try {
      return context
              .read<EmployeeProvider>()
              .list
              .firstWhere((e) => e.employeeCode == code)
              .employeeName ??
          '';
    } catch (_) {
      return '';
    }
  }

  String _signerNameFor(int? crId) {
    if (crId == null) return '';
    try {
      return context
              .read<CounterProvider>()
              .list
              .firstWhere((c) => c.crId == crId)
              .logInName ??
          '';
    } catch (_) {
      return '';
    }
  }

  String _remarksNameFor(int? code) {
    if (code == null) return '';
    try {
      return context
              .read<RemarksProvider>()
              .list
              .firstWhere((r) => r.remarksCode == code)
              .remarksName ??
          '';
    } catch (_) {
      return '';
    }
  }

  /// Shared logic for building a sorted, validated UserVisibilityModel list.
  List<UserVisibilityModel> _buildVisibilityList({
    required List<dynamic> rawList,
    required String counterType,
  }) {
    return rawList
        .where(
          (r) =>
              r.counterType == counterType &&
              r.userVisibilityCode != null &&
              _visProv.list.any(
                (v) => v.userVisibilityCode == r.userVisibilityCode,
              ),
        )
        .map(
          (r) => _visProv.list.firstWhereOrNull(
            (v) => v.userVisibilityCode == r.userVisibilityCode,
          ),
        )
        .where(
          (v) =>
              v != null &&
              v!.userVisibilityCode != null &&
              (v.userVisibilityName ?? '').isNotEmpty,
        )
        .cast<UserVisibilityModel>()
        .toList()
      ..sort((a, b) => (a.sortID ?? 0).compareTo(b.sortID ?? 0));
  }

  Future<void> _loadToDisplayFields(int crId) async {
    final counter = context.read<CounterProvider>().list.firstWhereOrNull(
      (c) => c.crId == crId,
    );
    if (counter == null || counter.counterMstID == null) return;

    await _displayProv.loadByCounter(counter.counterMstID!);
    if (!mounted) return;

    setState(() {
      _toDisplayFields = _buildVisibilityList(
        rawList: _displayProv.counterList,
        counterType: 'TO',
      );
    });
  }

  Future<void> _loadFromDisplayFields(int crId) async {
    final counter = context.read<CounterProvider>().list.firstWhereOrNull(
      (c) => c.crId == crId,
    );
    if (counter == null || counter.counterMstID == null) return;

    await _displayProv.loadByCounter(counter.counterMstID!);
    if (!mounted) return;

    setState(() {
      _fromDisplayFields = _buildVisibilityList(
        rawList: _displayProv.counterList,
        counterType: 'FROM',
      );
    });
  }

  void _onFromSelected(String crIdStr) {
    final crId = int.tryParse(crIdStr);
    if (crId == null) return;

    try {
      final counter = context.read<CounterProvider>().list.firstWhere(
        (c) => c.crId == crId,
      );
      final deptName = _deptNameFor(counter.deptCode);

      setState(() {
        _fromCrId = crId;
        _fromDeptName = deptName;
        _fromDeptCode = counter.deptCode;
        _toCrId = null;
        _toDeptName = null;
        _formValues['fromCrId'] = crIdStr;
        _formValues['fromDept'] = deptName;
      });

      _erpFormKey.currentState?.updateFieldValue('fromDept', deptName);
      _erpFormKey.currentState?.updateFieldValue('toCrId', '');
      _erpFormKey.currentState?.updateFieldValue('toDept', '');
      _erpFormKey.currentState?.updateFieldValue('deptProcessCode', '');
      _erpFormKey.currentState?.updateFieldValue('deptName', '');

      _loadFromDisplayFields(crId);
    } catch (_) {}
  }

  void _onToSelected(String crIdStr) {
    final crId = int.tryParse(crIdStr);
    if (crId == null) return;

    try {
      final counter = context.read<CounterProvider>().list.firstWhere(
        (c) => c.crId == crId,
      );
      final deptName = _deptNameFor(counter.deptCode);

      setState(() {
        _toCrId = crId;
        _toDeptName = deptName;
        _toDeptCodeVal = counter.deptCode;
        _formValues['toCrId'] = crIdStr;
        _formValues['toDept'] = deptName;
      });

      _erpFormKey.currentState?.updateFieldValue('toDept', deptName);
      _erpFormKey.currentState?.updateFieldValue('deptName', deptName);
      _erpFormKey.currentState?.updateFieldValue('deptProcessCode', '');

      _loadToDisplayFields(crId);
    } catch (_) {}
  }

  @override
  void initState() {
    super.initState();
    _setDefaultFormValues();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.wait([
        context.read<CounterProvider>().load(),
        context.read<CounterManagerDetProvider>().load(),
        context.read<DeptProvider>().load(),
        context.read<DeptGroupProvider>().load(),
        context.read<DeptProcessProvider>().load(),
        context.read<CharniProvider>().load(),
        context.read<TensionsProvider>().load(),
        context.read<CounterDisplayDetProvider>().load(),
        context.read<UserVisibilityProvider>().load(),
        context.read<EmployeeProvider>().loadEmployees(),
        context.read<RemarksProvider>().load(),
        context.read<ShapeProvider>().load(),
        context.read<PurityProvider>().load(),
        context.read<FactoryProvider>().loadFactories(),
        context.read<ColorProvider>().load(),
        context.read<ReportTypeProvider>().load(),
        context.read<TestProvider>().load(),
        context.read<CutProvider>().loadCuts(),
        context.read<RoughProvider>().loadRoughs(),
        context.read<CutCreateProvider>().load(),
        context.read<DivisionProvider>().loadDivisions(),
        context.read<ReportMstProvider>().load(),
      ]);
    });
  }

  List<List<ErpFieldConfig>> _buildFormRows() {
    return [];
  }

  List<List<ErpFieldConfig>> _sanitizeRows(List<List<ErpFieldConfig>> rows) {
    return rows.map((section) {
      return section.whereType<ErpFieldConfig>().map((field) {
        final safeItems = (field.dropdownItems ?? [])
            .whereType<ErpDropdownItem>()
            .where((item) => item.value.isNotEmpty && item.label.isNotEmpty)
            .toList();

        if (safeItems.length == (field.dropdownItems?.length ?? 0)) {
          return field;
        }
        return ErpFieldConfig(
          key: field.key,
          label: field.label,
          type: field.type,
          flex: field.flex,
          readOnly: field.readOnly,
          required: field.required,
          sectionIndex: field.sectionIndex ?? 0,
          sectionTitle: field.sectionTitle,
          isEntryField: field.isEntryField,
          isEntryRequired: field.isEntryRequired,
          showAddButton: field.showAddButton,
          dropdownItems: safeItems,
        );
      }).toList();
    }).toList();
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  REGISTRY KEY HELPER
  // ─────────────────────────────────────────────────────────────────────────

  String _toRegistryKey(String reportName) =>
      reportName.trim().toUpperCase().replaceAll(' ', '_');

  // ─────────────────────────────────────────────────────────────────────────
  //  SEARCH
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _onSearch() async {
    final reportName = _formValues['report'];
    if (reportName == null || reportName.isEmpty) return;
    context.read<ReportProvider>().clear();

    final registryKey = _toRegistryKey(reportName);
    print(registryKey);
    final config = ReportRegistry.of(registryKey);
    if (config == null) return;

    setState(() => _activeReportType = registryKey);

    final prov = context.read<ReportProvider>();
    final colorProv = context.read<ColorProvider>();
    final purityProv = context.read<PurityProvider>();

    final selectedColorCodes = _multiSelectValues?['colorCode'] ?? [];
    final selectedColorNames = <String>[];
    for (final codeStr in selectedColorCodes) {
      final codeInt = int.tryParse(codeStr);
      final match = colorProv.list.firstWhereOrNull((c) => c.colorCode == codeInt);
      if (match?.colorName != null && match!.colorName!.isNotEmpty) {
        selectedColorNames.add(match.colorName!);
      } else {
        selectedColorNames.add(codeStr);
      }
    }

    final selectedPurityCodes = _multiSelectValues?['purityCode'] ?? [];
    final selectedPurityNames = <String>[];
    for (final codeStr in selectedPurityCodes) {
      final codeInt = int.tryParse(codeStr);
      final match = purityProv.list.firstWhereOrNull((p) => p.purityCode == codeInt);
      if (match?.purityName != null && match!.purityName!.isNotEmpty) {
        selectedPurityNames.add(match.purityName!);
      } else {
        selectedPurityNames.add(codeStr);
      }
    }

    final filter = <String, dynamic>{
      // Single-value fields
      "reportType": _intVal('type'),
      "sel": _intVal('sel'),
      "finish": _formValues['finish'],
      "repairing": _formValues['repairing'],
      "shift": _formValues['shift'],
      "lotNoFrom": _intVal('lotNoFrom'),
      "lotNoTo": _intVal('lotNoTo'),
      "pktType": _formValues['pktType'],
      "GroupType": _formValues['groupType'] ?? _formValues['GroupType'],

      // Dimension & Weight fields
      "from_Length": _formValues['lengthFrom'],
      "to_Length": _formValues['lengthTo'],
      "from_Width": _formValues['widthFrom'],
      "to_Width": _formValues['widthTo'],
      "from_PoWt": _formValues['weightFrom'],
      "to_PoWt": _formValues['weightTo'],

      // Color and Purity Names
      "ColorName": selectedColorNames,
      "PurityName": selectedPurityNames,

      // Multi-select fields (KEEP AS LISTS)
      "MainCutNo": _multiSelectValues?['mainCut'] ?? [],
      "KapanNo": _multiSelectValues?['kNo'] ?? [],
      "cutNo": _multiSelectValues?['cutNo'] ?? [],

      "fromManager": _intList('fromCrId'),
      "toManager": _intList('toCrId'),
      "Remarks": _intList('remarks'),
      "deptProcessCode": _intList('deptProcessCode'),
      "purityCode": _intList('purityCode'),
      "colorCode": _intList('colorCode'),
      "tensionCode": _intList('tensionCode'),
      "shapeCode": _intList('shapeCode'),
      "factoryCode": _intList('factoryCode'),
      "divisionCode": _intList('divisionCode'),
      "employeeCode": _intList('employeeCode'),
    };

    // Remove nulls and empty lists
    filter.removeWhere((key, value) {
      if (value == null) return true;
      if (value is String && value.trim().isEmpty) return true;
      if (value is List && value.isEmpty) return true;
      return false;
    });

    // Date / Time
    if (registryKey != 'PACKET_WISE_PLANNING_SUMMARY' &&
        registryKey != 'PACKET_WISE_PLANNING_DETAIL') {
      filter.addAll({
        "fromDate": DateFormat(
          'yyyy-MM-dd',
        ).format(DateFormat('dd/MM/yyyy').parse(_formValues['dateFrom']!)),

        "toDate": DateFormat(
          'yyyy-MM-dd',
        ).format(DateFormat('dd/MM/yyyy').parse(_formValues['dateTo']!)),

        // "fromTime": DateFormat('HH:mm:ss')
        //     .format(DateFormat('hh:mm a').parse(_formValues['timeFrom']!)),
        //
        // "toTime": DateFormat('HH:mm:ss')
        //     .format(DateFormat('hh:mm a').parse(_formValues['timeTo']!)),
      });
    }

    // Special case
    if (registryKey == 'KAPAN_PERFORMANCE') {
      filter['kapanNos'] = _multiSelectValues?['cutNo'] ?? [];
    }

    print('FINAL FILTER');
    print(jsonEncode(filter));

    await prov.loadReport(
      reportTypeCode: registryKey,
      filter: filter,
      theme: _theme,
      context: context,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  RESET
  // ─────────────────────────────────────────────────────────────────────────

  void _resetForm() {
    // ⚠️  Do NOT reassign _erpFormKey — that triggers the
    //     "_elements.contains(element)" assertion during the next rebuild.
    //     Instead, call resetForm() on the existing state and bump
    //     _formResetCount so ErpForm receives a new ValueKey and rebuilds
    //     its internal widget tree cleanly.
    _erpFormKey.currentState?.resetForm();

    _entryVals.clear();
    _multiSelectValues?.clear();
    context.read<ReportProvider>().clear();
    setState(() {
      _editingDetIndex = null;
      _fromCrId = _toCrId = null;
      _fromDeptName = _toDeptName = null;
      _fromDeptCode = _toDeptCodeVal = null;
      _selectedRadioCode = null;
      _selectedTestCode = null;
      _selectedReportTypeCode = null;
      _activeReportType = '';
      _toDisplayFields.clear();
      _fromDisplayFields.clear();
      _formValues.clear();
      _formResetCount++; // ← gives ErpForm a new ValueKey, forces clean rebuild
    });

    _setDefaultFormValues();
  }

  void _setDefaultFormValues() {
    final now = DateTime.now();
    _formValues = {
      'dateFrom': DateFormat('dd/MM/yyyy').format(now),
      'dateTo': DateFormat('dd/MM/yyyy').format(now),
      'timeFrom': DateFormat('hh:mm a').format(now),
      'timeTo': DateFormat('hh:mm a').format(now),
    };
    _multiSelectValues?.clear();
    if (mounted) setState(() {});
    // After reset the ErpForm subtree is recreated (new ValueKey), so wait
    // two frames before requesting focus so the new State is mounted.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 80), () {
        if (mounted) _erpFormKey.currentState?.focusField('type');
      });
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.transparent,
      endDrawer: _buildFilterSidebar(context),
      body: Consumer<ReportProvider>(
        builder: (ctx, prov, _) {
          return Padding(
            padding: const EdgeInsets.all(8),
            child: _buildForm(context, prov),
          );
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context, ReportProvider prov) {
    return ErpForm(
      logo: AppImages.logo,
      key: ValueKey('erp_form_$_formResetCount'),
      title: 'REPORT',
      rows: _buildFormRows(),
      initialValues: _formValues,
      autoStartAdding: true,
      onSearch: _onSearch,
      isShowSaveButton: false,
      isEditMode: false,
      isShowSearch: false,
      isShowAddButton: false,
      filter: () {
        scaffoldKey.currentState?.openEndDrawer();
      },
      onFieldChanged: _handleFieldValueChanged,
      detailBuilder: (ctx) {
        final prov = context.watch<ReportProvider>();
        final registryKey = _toRegistryKey(_activeReportType ?? '');
        final config = ReportRegistry.of(registryKey);

        final screenHeight = MediaQuery.of(context).size.height;
        final isMobile = Responsive.isMobile(context);
        final double subtractHeight = isMobile ? 140.0 : 110.0;
        final dynamicHeight = (screenHeight - subtractHeight).clamp(
          500.0,
          3000.0,
        );

        final noDataWidget = Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.info_outline, size: 60, color: Colors.grey),
                const SizedBox(height: 12),
                const Text(
                  'No Data Found',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                const Text(
                  'No records match the selected filters.\nPlease adjust your filters and try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        );

        if (config == null) {
          return SizedBox(
            height: dynamicHeight,
            width: double.infinity,
            child: noDataWidget,
          );
        }

        // ── PDF branch ───────────────────────────────────────────────────
        if (config.isPdf) {
          if (prov.isLoading) {
            return SizedBox(
              height: dynamicHeight,
              width: double.infinity,
              child: const Center(child: CircularProgressIndicator()),
            );
          }
          if (prov.pdfBytes == null) return const SizedBox.shrink();

          return LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight.isFinite
                    ? constraints.maxHeight
                    : dynamicHeight,
                child: _PdfReportView(
                  filter: _formValues,
                  pdfBytes: prov.pdfBytes!,
                  reportTitle: registryKey,
                ),
              );
            },
          );
        }
        final erpColumns = config.columns.map((c) => c.toErpColumn()).toList();
        final isPairReport = registryKey == 'PAIR_DATA';

        return LayoutBuilder(
          builder: (context, constraints) {
            Widget tableWidget;
            if (prov.isLoading) {
              tableWidget = const Center(child: CircularProgressIndicator());
            } else if (prov.tableData.isEmpty) {
              tableWidget = noDataWidget;
            } else {
              tableWidget = ErpDataTable(
                key: ValueKey(
                  '${_activeReportType}_${prov.tableData.length}_$_pairEditingRowIndex',
                ),
                data: prov.tableData,
                columns: erpColumns,
                showSearch: false,
                defaultGroupBy: config.defaultGroupBy ?? [],
                title: registryKey.isEmpty
                    ? 'REPORT DATA'
                    : registryKey.replaceAll('_', ' '),
                token: '',
                url: '',
                isReportRow: false,
                showFooterTotals: true,
                headerActions: isPairReport
                    ? [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => _fetchAndPrintPairPdf(context),
                                icon: const Icon(Icons.print, size: 18),
                                label: const Text('Print PDF'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent.shade700,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]
                    : [],
                onRowTap: isPairReport
                    ? (row) {
                        final idx = prov.tableData.indexOf(row);
                        if (idx != -1) {
                          _onPairRowDoubleTap(row, idx);
                        } else {
                          final fallbackIdx = prov.tableData.indexWhere(
                            (e) =>
                                e['Id'] == row['Id'] &&
                                e['packetNo'] == row['packetNo'],
                          );
                          if (fallbackIdx != -1) {
                            _onPairRowDoubleTap(row, fallbackIdx);
                          }
                        }
                      }
                    : null,
              );
            }

            if (isPairReport) {
              return SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight.isFinite
                    ? constraints.maxHeight
                    : dynamicHeight,
                child: Column(children: [Expanded(child: tableWidget)]),
              );
            }

            return SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight.isFinite
                  ? constraints.maxHeight
                  : dynamicHeight,
              child: tableWidget,
            );
          },
        );
      },
    );
  }

  Future<void> _fetchAndPrintPairPdf(BuildContext context) async {
    try {
      final dio = Dio();
      final String? token = AppStorage.getString('token');

      final filter = Map<String, dynamic>.from(_entryVals);
      final queryParams = <String, dynamic>{
        'fromDate': filter['fromDate'] ?? filter['FromDate'] ?? '2025-01-01',
        'toDate': filter['toDate'] ?? filter['ToDate'] ?? '2026-07-31',
      };

      if (filter['kNo'] != null || filter['KapanNo'] != null) {
        queryParams['KapanNo'] = filter['kNo'] ?? filter['KapanNo'];
      }
      if (filter['groupType'] != null || filter['GroupType'] != null) {
        queryParams['GroupType'] = filter['groupType'] ?? filter['GroupType'];
      }

      final response = await dio.get(
        '$baseUrl/reports/pair-report',
        queryParameters: queryParams,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/pdf',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final pdfBytes = Uint8List.fromList(List<int>.from(response.data));
        await Printing.layoutPdf(onLayout: (_) async => pdfBytes);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load PDF (${response.statusCode})'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleFieldValueChanged(String key, dynamic value) {
    print('KEY = $key   VALUE = $value');

    setState(() {
      if (_multiSelectKeys.contains(key)) {
        _multiSelectValues ??= {};

        if (value is List<String>) {
          _multiSelectValues![key] = value;
          _formValues[key] = value.join(',');
        } else if (value == null || (value is List && value.isEmpty)) {
          _multiSelectValues![key] = [];
          _formValues[key] = '';
        }
      } else {
        _formValues[key] = value?.toString() ?? '';
      }
    });

    _erpFormKey.currentState?.updateFieldValue(key, _formValues[key] ?? '');

    switch (key) {
      case 'type':
        final testCode = int.tryParse(value.toString());
        final firstReportType = context
            .read<ReportTypeProvider>()
            .list
            .firstWhereOrNull(
              (e) => testCode == null || e.TestCode == testCode,
            );

        final firstReportTypeCode = firstReportType?.reportTypeCode;
        final firstReportTypeCodeStr = firstReportTypeCode?.toString() ?? '';

        setState(() {
          _selectedTestCode = testCode;
          _selectedReportTypeCode = firstReportTypeCode;
          _formValues['sel'] = firstReportTypeCodeStr;
        });

        _erpFormKey.currentState?.updateFieldValue(
          'sel',
          firstReportTypeCodeStr,
        );
        break;

      case 'sel':
        _entryVals[key] = value.toString();
        context.read<ReportProvider>().clear();
        _selectedReportTypeCode = int.tryParse(value.toString());

        final filtered = context
            .read<ReportMstProvider>()
            .list
            .where(
              (e) =>
                  (_selectedTestCode == null ||
                      e.testCode == _selectedTestCode) &&
                  (_selectedReportTypeCode == null ||
                      e.reportTypeCode == _selectedReportTypeCode),
            )
            .toList();

        final firstReportName = filtered.isNotEmpty
            ? filtered.first.reportName ?? ''
            : '';

        setState(() {
          _formValues['report'] = firstReportName;
          _activeReportType = _toRegistryKey(firstReportName);
        });

        _erpFormKey.currentState?.updateFieldValue('report', firstReportName);

        Future.delayed(
          const Duration(milliseconds: 50),
          () => _erpFormKey.currentState?.focusField('report'),
        );
        break;

      case 'report':
        _entryVals[key] = value.toString();
        context.read<ReportProvider>().clear();
        break;

      case 'fromCrId':
        final firstId =
            (_multiSelectValues?['fromCrId'] ?? []).firstOrNull ?? '';
        if (firstId.isNotEmpty) {
          _onFromSelected(firstId);
        } else {
          setState(() {
            _fromCrId = null;
            _fromDeptName = null;
            _fromDeptCode = null;
            _toCrId = null;
            _toDeptName = null;
            _formValues['fromDept'] = '';
            _formValues['toCrId'] = '';
            _formValues['toDept'] = '';
            _formValues['deptProcessCode'] = '';
            _formValues['deptName'] = '';
          });
        }
        break;

      case 'toCrId':
        final firstId = (_multiSelectValues?['toCrId'] ?? []).firstOrNull ?? '';
        if (firstId.isNotEmpty) {
          _onToSelected(firstId);
        } else {
          setState(() {
            _toCrId = null;
            _toDeptName = null;
            _toDeptCodeVal = null;
            _formValues['toDept'] = '';
            _formValues['deptProcessCode'] = '';
            _formValues['deptName'] = '';
          });
        }
        break;

      default:
        _entryVals[key] = value.toString();
        _formValues[key] = value.toString();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  //  RIGHT SIDEBAR FILTER PANEL
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildFilterSidebar(BuildContext context) {
    final theme = Theme.of(context);
    final counterProv = context.read<CounterProvider>();
    final mgDetProv = context.read<CounterManagerDetProvider>();
    final procProv = context.read<DeptProcessProvider>();
    final tensProv = context.read<TensionsProvider>();
    final colorProv = context.read<ColorProvider>();
    final shapeProv = context.read<ShapeProvider>();
    final purityProv = context.read<PurityProvider>();
    final remarksProv = context.read<RemarksProvider>();
    final employeeProv = context.read<EmployeeProvider>();
    final divisionProv = context.read<DivisionProvider>();
    final factoryProv = context.read<FactoryProvider>();
    final cutProv = context.read<CutCreateProvider>();
    final roughProv = context.watch<RoughProvider>();

    final isFromSelected = _fromCrId != null;
    final isToSelected = _toCrId != null;

    final fromItems = counterProv.list
        .where((c) {
          final grp = _deptGroupNameFor(c.deptGroupCode).toUpperCase();
          return grp.contains('CLEAVING') || grp.contains('CLV');
        })
        .map(
          (c) => ErpDropdownItem(
            label: '${c.crName ?? ''}  |  ${_deptNameFor(c.deptCode)}',
            value: c.crId?.toString() ?? '',
          ),
        )
        .toList();

    final toItems = _fromCrId == null
        ? <ErpDropdownItem>[]
        : mgDetProv.list
              .where((m) => m.crId == _fromCrId && m.allowCrId != null)
              .map((m) => m.allowCrId!)
              .toSet()
              .map((allowId) {
                try {
                  final c = counterProv.list.firstWhere(
                    (c) => c.crId == allowId && c.active == true,
                  );
                  if (c.crId == _fromCrId) return null;
                  return ErpDropdownItem(
                    label: '${c.crName ?? ''} | ${_deptNameFor(c.deptCode)}',
                    value: c.crId?.toString() ?? '',
                  );
                } catch (_) {
                  return null;
                }
              })
              .whereType<ErpDropdownItem>()
              .toList();

    final processItems = (_fromCrId == null || _toCrId == null)
        ? <ErpDropdownItem>[]
        : () {
            final issueCodes = mgDetProv.list
                .where((m) => m.crId == _fromCrId && m.deptProcessCode != null)
                .map((m) => m.deptProcessCode!)
                .toSet();

            final recvCodes = mgDetProv.list
                .where(
                  (m) => m.allowCrId == _toCrId && m.deptProcessCode != null,
                )
                .map((m) => m.deptProcessCode!)
                .toSet();

            return issueCodes.intersection(recvCodes).map((code) {
              String label = '$code';
              try {
                label =
                    procProv.list
                        .firstWhere((p) => p.deptProcessCode == code)
                        .deptProcessName ??
                    '$code';
              } catch (_) {}
              return ErpDropdownItem(label: label, value: code.toString());
            }).toList();
          }();

    final tensItems = tensProv.list.where((e) => e.active == true).toList()
      ..sort((a, b) => (a.sortID ?? 0).compareTo(b.sortID ?? 0));
    final tensDropdown = tensItems
        .map(
          (e) => ErpDropdownItem(
            label: e.tensionsName ?? '',
            value: e.tensionsCode?.toString() ?? '',
          ),
        )
        .toList();

    final factoryItems = factoryProv.factories
        .map(
          (e) => ErpDropdownItem(
            label: e.factoryName ?? '',
            value: e.factoryCode?.toString() ?? '',
          ),
        )
        .toList();

    final purityItems = purityProv.list
        .map(
          (e) => ErpDropdownItem(
            label: e.purityName ?? '',
            value: e.purityCode?.toString() ?? '',
          ),
        )
        .toList();

    final colorItems = colorProv.list
        .map(
          (e) => ErpDropdownItem(
            label: e.colorName ?? '',
            value: e.colorCode?.toString() ?? '',
          ),
        )
        .toList();

    final shapeItems = shapeProv.list
        .map(
          (e) => ErpDropdownItem(
            label: e.shapeName ?? '',
            value: e.shapeCode?.toString() ?? '',
          ),
        )
        .toList();

    final empItems = employeeProv.list
        .map(
          (e) => ErpDropdownItem(
            label: e.employeeName ?? '',
            value: e.employeeCode?.toString() ?? '',
          ),
        )
        .toList();

    final divisionItems = divisionProv.divisions
        .map(
          (e) => ErpDropdownItem(
            label: e.divisionName ?? '',
            value: e.divisionCode?.toString() ?? '',
          ),
        )
        .toList();

    final remarksItems = remarksProv.list
        .map(
          (e) => ErpDropdownItem(
            label: e.remarksName ?? '',
            value: e.remarksCode?.toString() ?? '',
          ),
        )
        .toList();

    final cutItems = cutProv.list
        .where((cc) => cc.details.isNotEmpty)
        .map((cc) {
          final spkDet = cc.details.firstWhere(
            (d) => d.cutType == 'SPK',
            orElse: () => cc.details.first,
          );
          return ErpDropdownItem(
            label: spkDet.cutNo ?? '',
            value: spkDet.cutNo ?? '',
          );
        })
        .where((e) => e.value.isNotEmpty)
        .fold<List<ErpDropdownItem>>([], (acc, item) {
          if (!acc.any((x) => x.value == item.value)) acc.add(item);
          return acc;
        });

    final roughItems = roughProv.roughs
        .map(
          (e) => ErpDropdownItem(
            label: e.kapanNo ?? '',
            value: e.kapanNo?.toString() ?? '',
          ),
        )
        .toList();

    final mainCutNoItems = roughProv.roughs
        .map(
          (e) => ErpDropdownItem(
            label: e.mainCutNo ?? '',
            value: e.mainCutNo?.toString() ?? '',
          ),
        )
        .toList();

    final typeProv = context.read<TestProvider>();
    final reportTypeProv = context.read<ReportTypeProvider>();
    final reportsProv = context.watch<ReportMstProvider>();

    final typeItems = typeProv.list
        .map(
          (e) => ErpDropdownItem(
            label: e.testName ?? '',
            value: e.testCode?.toString() ?? '',
          ),
        )
        .toList();

    final reportTypeItems = reportTypeProv.list
        .where(
          (e) => _selectedTestCode == null || e.TestCode == _selectedTestCode,
        )
        .map(
          (e) => ErpDropdownItem(
            label: e.reportTypeName ?? '',
            value: e.reportTypeCode?.toString() ?? '',
          ),
        )
        .toList();

    final reportsItems = reportsProv.list
        .where(
          (e) =>
              (_selectedTestCode == null || e.testCode == _selectedTestCode) &&
              (_selectedReportTypeCode == null ||
                  e.reportTypeCode == _selectedReportTypeCode),
        )
        .map(
          (e) => ErpDropdownItem(
            label: e.reportName ?? '',
            value: e.reportName ?? '',
          ),
        )
        .toList();

    return Drawer(
      width: 500,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header (Dark Navy Theme)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              color: const Color(0xFF1A1F3D),
              child: Row(
                children: [
                  const Icon(
                    Icons.filter_list_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Filter Panel',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    tooltip: 'Close Sidebar',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Body Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ── Section 0: Primary Report Selection ──
                  _buildSidebarSectionHeader(
                    'Report Selection',
                    Icons.description_rounded,
                  ),
                  _buildGridRow(
                    _buildSidebarSingleSelectWithItems(
                      'type',
                      'TYPE',
                      typeItems,
                    ),
                    _buildSidebarSingleSelectWithItems(
                      'sel',
                      'SEL',
                      reportTypeItems,
                    ),
                  ),
                  _buildGridRow(
                    _buildSidebarSingleSelectWithItems(
                      'report',
                      'REPORTS',
                      reportsItems,
                    ),
                    _buildSidebarSingleSelect('finish', 'FINISH', const [
                      'N',
                      'Y',
                    ]),
                  ),

                  // ── Section 1: Date Range ──
                  _buildSidebarSectionHeader(
                    'Date Range',
                    Icons.calendar_today_rounded,
                  ),
                  _buildGridRow(
                    _buildSidebarDateField('dateFrom', 'FROM DATE'),
                    _buildSidebarDateField('dateTo', 'TO DATE'),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _buildDatePresetChip('Today', () => _setPresetDates(0)),
                        _buildDatePresetChip(
                          'Yesterday',
                          () => _setPresetDates(1),
                        ),
                        _buildDatePresetChip(
                          'Last 7 Days',
                          () => _setPresetDates(7),
                        ),
                        _buildDatePresetChip(
                          'This Month',
                          () => _setMonthlyPreset(),
                        ),
                      ],
                    ),
                  ),

                  // ── Section 2: Kapan & Cut ──
                  _buildSidebarSectionHeader(
                    'Kapan & Cut Filters',
                    Icons.content_cut_rounded,
                  ),
                  _buildGridRow(
                    _buildSidebarMultiSelect(
                      context,
                      'mainCut',
                      'MAIN CUT',
                      mainCutNoItems,
                    ),
                    _buildSidebarMultiSelect(context, 'kNo', 'KNO', roughItems),
                  ),
                  _buildGridRow(
                    _buildSidebarMultiSelect(
                      context,
                      'cutNo',
                      'CUT NO',
                      cutItems,
                    ),
                  ),

                  // ── Section 3: Department & Manager Transfer ──
                  _buildSidebarSectionHeader(
                    'Manager & Dept Transfer',
                    Icons.swap_horiz_rounded,
                  ),
                  _buildGridRow(
                    _buildSidebarMultiSelect(
                      context,
                      'fromCrId',
                      'FROM MANAGER',
                      fromItems,
                    ),
                    _buildSidebarDisplayField(
                      'FROM DEPT',
                      _formValues['fromDept'] ?? '',
                    ),
                  ),
                  _buildGridRow(
                    _buildSidebarMultiSelect(
                      context,
                      'toCrId',
                      'TO MANAGER',
                      toItems,
                      enabled: isFromSelected,
                    ),
                    _buildSidebarDisplayField(
                      'TO DEPT',
                      _formValues['toDept'] ?? '',
                    ),
                  ),
                  _buildGridRow(
                    _buildSidebarMultiSelect(
                      context,
                      'deptProcessCode',
                      'PROCESS',
                      processItems,
                      enabled: isToSelected,
                    ),
                    _buildSidebarDisplayField(
                      'DEPT NAME',
                      _formValues['deptName'] ?? '',
                    ),
                  ),

                  // ── Section 4: Organization & Remarks ──
                  _buildSidebarSectionHeader(
                    'Organization & Staff',
                    Icons.business_rounded,
                  ),
                  _buildGridRow(
                    _buildSidebarMultiSelect(
                      context,
                      'factoryCode',
                      'FACTORY',
                      factoryItems,
                    ),
                    _buildSidebarSingleSelect('pktType', 'PKT TYPE', const [
                      'ALL',
                      'SINGLE',
                      'LOOSE',
                    ]),
                  ),
                  _buildGridRow(
                    _buildSidebarTextField('lotNoFrom', 'LOT NO FROM'),
                    _buildSidebarTextField('lotNoTo', 'LOT NO TO'),
                  ),
                  _buildGridRow(
                    _buildSidebarMultiSelect(
                      context,
                      'remarks',
                      'REMARKS',
                      remarksItems,
                    ),
                  ),

                  const SizedBox(height: 6),
                  const Divider(height: 1),
                  const SizedBox(height: 6),

                  // ── Section 5: Advanced Filters (Expandable) ──
                  Theme(
                    data: theme.copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      initiallyExpanded: _isAdvancedFiltersExpanded,
                      onExpansionChanged: (expanded) {
                        setState(() {
                          _isAdvancedFiltersExpanded = expanded;
                        });
                      },
                      tilePadding: EdgeInsets.zero,
                      childrenPadding: const EdgeInsets.only(top: 4, bottom: 10),
                      title: Row(
                        children: [
                          const Icon(
                            Icons.tune_rounded,
                            size: 18,
                            color: Color(0xFF556EE6),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Advanced Filters',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF556EE6),
                            ),
                          ),
                        ],
                      ),
                      children: [
                        _buildGridRow(
                          _buildSidebarMultiSelect(
                            context,
                            'shapeCode',
                            'SHAPE',
                            shapeItems,
                          ),
                          _buildSidebarMultiSelect(
                            context,
                            'colorCode',
                            'COLOR',
                            colorItems,
                          ),
                        ),
                        _buildGridRow(
                          _buildSidebarMultiSelect(
                            context,
                            'purityCode',
                            'PURITY',
                            purityItems,
                          ),
                          _buildSidebarMultiSelect(
                            context,
                            'tensionCode',
                            'TENSION',
                            tensDropdown,
                          ),
                        ),
                        _buildGridRow(
                          _buildSidebarTextField('lengthFrom', 'LENGTH FROM'),
                          _buildSidebarTextField('lengthTo', 'LENGTH TO'),
                        ),
                        _buildGridRow(
                          _buildSidebarTextField('widthFrom', 'WIDTH FROM'),
                          _buildSidebarTextField('widthTo', 'WIDTH TO'),
                        ),
                        _buildGridRow(
                          _buildSidebarTextField('weightFrom', 'WEIGHT FROM'),
                          _buildSidebarTextField('weightTo', 'WEIGHT TO'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // type, division, employee, repairing, shift fields removed
            // Footer Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, -2),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(
                        Icons.cleaning_services_rounded,
                        size: 18,
                        color: Color(0xFF556EE6),
                      ),
                      label: const Text(
                        'Reset All',
                        style: TextStyle(
                          color: Color(0xFF556EE6),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF556EE6)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        _resetForm();
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle_rounded, size: 18),
                      label: const Text('Apply'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF556EE6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _onSearch();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridRow(Widget left, [Widget? right]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: left),
          const SizedBox(width: 10),
          Expanded(child: right ?? const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildSidebarSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 15, color: const Color(0xFF556EE6)),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF556EE6),
            ),
          ),
          const SizedBox(width: 6),
          const Expanded(child: Divider(height: 1)),
        ],
      ),
    );
  }

  Widget _buildSidebarMultiSelect(
    BuildContext context,
    String key,
    String label,
    List<ErpDropdownItem> items, {
    bool enabled = true,
  }) {
    final selectedList = _multiSelectValues?[key] ?? [];
    final displayCount = selectedList.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: enabled ? Colors.grey.shade700 : Colors.grey.shade400,
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: enabled
              ? () {
                  _showMultiSelectDialog(
                    context: context,
                    title: label,
                    items: items,
                    initialSelected: selectedList,
                    onConfirm: (newList) {
                      _handleFieldValueChanged(key, newList);
                    },
                  );
                }
              : null,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            height: 35,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: enabled ? Colors.white : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: enabled ? Colors.grey.shade300 : Colors.grey.shade200,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: displayCount == 0
                      ? Text(
                          'Select $label...',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: enabled
                                ? Colors.grey.shade500
                                : Colors.grey.shade400,
                          ),
                        )
                      : Text(
                          '$displayCount (${selectedList.join(", ")})',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  size: 20,
                  color: enabled ? Colors.grey.shade600 : Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSidebarSingleSelectWithItems(
    String key,
    String label,
    List<ErpDropdownItem> items, {
    bool enabled = true,
  }) {
    final currentVal = _formValues[key] ?? '';
    final validItems = items.where((i) => i.value.isNotEmpty).toList();
    final matchedItem = validItems.firstWhereOrNull(
      (i) => i.value == currentVal,
    );
    final displayLabel = matchedItem?.label ?? currentVal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: enabled ? Colors.grey.shade700 : Colors.grey.shade400,
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: enabled && validItems.isNotEmpty
              ? () {
                  _showSingleSelectDialog(
                    context: context,
                    title: label,
                    items: validItems,
                    initialSelected: currentVal,
                    onConfirm: (selectedVal) {
                      _handleFieldValueChanged(key, selectedVal);
                    },
                  );
                }
              : null,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            height: 35,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: enabled ? Colors.white : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: enabled ? Colors.grey.shade300 : Colors.grey.shade200,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    displayLabel.isEmpty ? 'Select $label...' : displayLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: displayLabel.isEmpty
                          ? FontWeight.normal
                          : FontWeight.w500,
                      color: displayLabel.isEmpty
                          ? (enabled
                                ? Colors.grey.shade500
                                : Colors.grey.shade400)
                          : Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  size: 20,
                  color: enabled ? Colors.grey.shade600 : Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSidebarDateField(String key, String label) {
    final val = _formValues[key] ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () => _pickDate(key),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            height: 35,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 14,
                  color: Color(0xFF556EE6),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    val.isEmpty ? 'Pick Date' : val,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: val.isNotEmpty ? const Color(0xFF556EE6) : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate(String key) async {
    final initialDateStr = _formValues[key];
    DateTime initialDate = DateTime.now();
    if (initialDateStr != null && initialDateStr.isNotEmpty) {
      try {
        initialDate = DateFormat('dd/MM/yyyy').parse(initialDateStr);
      } catch (_) {}
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      final formatted = DateFormat('dd/MM/yyyy').format(picked);
      _handleFieldValueChanged(key, formatted);
    }
  }

  void _setPresetDates(int daysAgo) {
    final now = DateTime.now();
    final fromDate = now.subtract(Duration(days: daysAgo));
    final format = DateFormat('dd/MM/yyyy');
    setState(() {
      _formValues['dateFrom'] = format.format(fromDate);
      _formValues['dateTo'] = format.format(now);
    });
    _handleFieldValueChanged('dateFrom', format.format(fromDate));
    _handleFieldValueChanged('dateTo', format.format(now));
  }

  void _setMonthlyPreset() {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final format = DateFormat('dd/MM/yyyy');
    setState(() {
      _formValues['dateFrom'] = format.format(firstDay);
      _formValues['dateTo'] = format.format(now);
    });
    _handleFieldValueChanged('dateFrom', format.format(firstDay));
    _handleFieldValueChanged('dateTo', format.format(now));
  }

  Widget _buildDatePresetChip(String label, VoidCallback onTap) {
    return ActionChip(
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF556EE6),
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: const Color(0xFF556EE6).withValues(alpha: 0.08),
      side: const BorderSide(
        color: Color(0x40556EE6),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      visualDensity: VisualDensity.compact,
      onPressed: onTap,
    );
  }

  Widget _buildSidebarDisplayField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 35,
          width: double.infinity,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            value.isEmpty ? '-' : value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSidebarSingleSelect(
    String key,
    String label,
    List<String> options,
  ) {
    final currentVal = _formValues[key] ?? options.first;
    final items = options
        .map(
          (opt) => ErpDropdownItem(label: opt, value: opt == 'ALL' ? '' : opt),
        )
        .toList();

    final matchedItem = items.firstWhereOrNull(
      (i) => (currentVal.isEmpty && i.value.isEmpty) || i.value == currentVal,
    );
    final displayLabel =
        matchedItem?.label ?? (currentVal.isEmpty ? options.first : currentVal);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () {
            _showSingleSelectDialog(
              context: context,
              title: label,
              items: items,
              initialSelected: currentVal.isEmpty ? '' : currentVal,
              onConfirm: (selectedVal) {
                _handleFieldValueChanged(key, selectedVal);
              },
            );
          },
          borderRadius: BorderRadius.circular(6),
          child: Container(
            height: 35,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    displayLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  size: 20,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSidebarTextField(String key, String label) {
    final controller = TextEditingController(text: _formValues[key] ?? '');
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 35,
            child: TextField(
              controller: controller,
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onChanged: (val) {
                _handleFieldValueChanged(key, val);
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showSingleSelectDialog({
    required BuildContext context,
    required String title,
    required List<ErpDropdownItem> items,
    required String initialSelected,
    required ValueChanged<String> onConfirm,
  }) async {
    String searchQuery = '';
    int focusedIndex = 0;
    final scrollController = ScrollController();
    final searchFocusNode = FocusNode();

    final initIndex = items.indexWhere((i) => i.value == initialSelected);
    if (initIndex != -1) {
      focusedIndex = initIndex;
    }

    void scrollToFocused(int index) {
      if (!scrollController.hasClients) return;
      const itemExtent = 36.0;
      final viewportDimension = scrollController.position.viewportDimension;
      final maxScroll = scrollController.position.maxScrollExtent;
      final currentScroll = scrollController.offset;

      final itemTop = index * itemExtent;
      final itemBottom = itemTop + itemExtent;

      if (itemTop < currentScroll) {
        final target = itemTop.clamp(0.0, maxScroll);
        scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 60),
          curve: Curves.easeOut,
        );
      } else if (itemBottom > currentScroll + viewportDimension) {
        final target = (itemBottom - viewportDimension).clamp(0.0, maxScroll);
        scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 60),
          curve: Curves.easeOut,
        );
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      searchFocusNode.requestFocus();
      if (initIndex > 0) {
        scrollToFocused(focusedIndex);
      }
    });

    await showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final filteredItems = items.where((item) {
              return item.label.toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  ) ||
                  item.value.toLowerCase().contains(searchQuery.toLowerCase());
            }).toList();

            if (focusedIndex >= filteredItems.length) {
              focusedIndex = (filteredItems.length - 1).clamp(
                0,
                filteredItems.length,
              );
            }

            return AlertDialog(
              titlePadding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Select $title',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              content: SizedBox(
                width: 400,
                height: 400,
                child: Column(
                  children: [
                    Focus(
                      onKeyEvent: (node, event) {
                        if (event is KeyDownEvent) {
                          if (event.logicalKey ==
                              LogicalKeyboardKey.arrowDown) {
                            if (filteredItems.isNotEmpty) {
                              setDialogState(() {
                                focusedIndex = (focusedIndex + 1).clamp(
                                  0,
                                  filteredItems.length - 1,
                                );
                              });
                              scrollToFocused(focusedIndex);
                            }
                            return KeyEventResult.handled;
                          } else if (event.logicalKey ==
                              LogicalKeyboardKey.arrowUp) {
                            if (filteredItems.isNotEmpty) {
                              setDialogState(() {
                                focusedIndex = (focusedIndex - 1).clamp(
                                  0,
                                  filteredItems.length - 1,
                                );
                              });
                              scrollToFocused(focusedIndex);
                            }
                            return KeyEventResult.handled;
                          } else if (event.logicalKey ==
                                  LogicalKeyboardKey.enter ||
                              event.logicalKey ==
                                  LogicalKeyboardKey.numpadEnter) {
                            if (filteredItems.isNotEmpty &&
                                focusedIndex >= 0 &&
                                focusedIndex < filteredItems.length) {
                              final selectedVal =
                                  filteredItems[focusedIndex].value;
                              Navigator.of(ctx).pop();
                              onConfirm(selectedVal);
                            }
                            return KeyEventResult.handled;
                          }
                        }
                        return KeyEventResult.ignored;
                      },
                      child: SizedBox(
                        height: 36,
                        child: TextField(
                          focusNode: searchFocusNode,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: 'Search $title...',
                            prefixIcon: const Icon(Icons.search, size: 20),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onChanged: (val) {
                            setDialogState(() {
                              searchQuery = val;
                              focusedIndex = 0;
                            });
                            if (scrollController.hasClients) {
                              scrollController.jumpTo(0);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Divider(height: 1),
                    Expanded(
                      child: filteredItems.isEmpty
                          ? const Center(
                              child: Text(
                                'No items found',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              itemExtent: 36.0,
                              itemCount: filteredItems.length,
                              itemBuilder: (context, index) {
                                final item = filteredItems[index];
                                final isSelected =
                                    item.value == initialSelected;
                                final isFocused = index == focusedIndex;

                                return InkWell(
                                  onTap: () {
                                    Navigator.of(ctx).pop();
                                    onConfirm(item.value);
                                  },
                                  child: Container(
                                    height: 36.0,
                                    alignment: Alignment.centerLeft,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isFocused
                                          ? const Color(0xFF556EE6).withValues(alpha: 0.14)
                                          : (isSelected
                                                ? const Color(0xFF556EE6).withValues(alpha: 0.06)
                                                : Colors.transparent),
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey.shade200,
                                          width: 0.5,
                                        ),
                                        left: isFocused
                                            ? const BorderSide(
                                                color: Color(0xFF556EE6),
                                                width: 4.0,
                                              )
                                            : BorderSide.none,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.label,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight:
                                                  (isSelected || isFocused)
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                              color: (isSelected || isFocused)
                                                  ? const Color(0xFF556EE6)
                                                  : Colors.black87,
                                            ),
                                          ),
                                        ),
                                        if (isSelected)
                                          const Icon(
                                            Icons.check_circle_rounded,
                                            color: Color(0xFF556EE6),
                                            size: 20,
                                          )
                                        else if (isFocused)
                                          const Icon(
                                            Icons.arrow_forward_rounded,
                                            color: Color(0x99556EE6),
                                            size: 16,
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showMultiSelectDialog({
    required BuildContext context,
    required String title,
    required List<ErpDropdownItem> items,
    required List<String> initialSelected,
    required ValueChanged<List<String>> onConfirm,
  }) async {
    final tempSelected = List<String>.from(initialSelected);
    String searchQuery = '';
    int focusedIndex = 0;
    final scrollController = ScrollController();
    final searchFocusNode = FocusNode();

    void scrollToFocused(int index) {
      if (!scrollController.hasClients) return;
      const itemExtent = 36.0;
      final viewportDimension = scrollController.position.viewportDimension;
      final maxScroll = scrollController.position.maxScrollExtent;
      final currentScroll = scrollController.offset;

      final itemTop = index * itemExtent;
      final itemBottom = itemTop + itemExtent;

      if (itemTop < currentScroll) {
        final target = itemTop.clamp(0.0, maxScroll);
        scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 60),
          curve: Curves.easeOut,
        );
      } else if (itemBottom > currentScroll + viewportDimension) {
        final target = (itemBottom - viewportDimension).clamp(0.0, maxScroll);
        scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 60),
          curve: Curves.easeOut,
        );
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      searchFocusNode.requestFocus();
    });

    await showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final filteredItems = items.where((item) {
              return item.label.toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  ) ||
                  item.value.toLowerCase().contains(searchQuery.toLowerCase());
            }).toList();

            final isAllSelected =
                filteredItems.isNotEmpty &&
                filteredItems.every(
                  (item) => tempSelected.contains(item.value),
                );

            if (focusedIndex >= filteredItems.length) {
              focusedIndex = (filteredItems.length - 1).clamp(
                0,
                filteredItems.length,
              );
            }

            return AlertDialog(
              titlePadding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Select $title',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              content: SizedBox(
                width: 400,
                height: 450,
                child: Column(
                  children: [
                    Focus(
                      onKeyEvent: (node, event) {
                        if (event is KeyDownEvent) {
                          if (event.logicalKey ==
                              LogicalKeyboardKey.arrowDown) {
                            if (filteredItems.isNotEmpty) {
                              setDialogState(() {
                                focusedIndex = (focusedIndex + 1).clamp(
                                  0,
                                  filteredItems.length - 1,
                                );
                              });
                              scrollToFocused(focusedIndex);
                            }
                            return KeyEventResult.handled;
                          } else if (event.logicalKey ==
                              LogicalKeyboardKey.arrowUp) {
                            if (filteredItems.isNotEmpty) {
                              setDialogState(() {
                                focusedIndex = (focusedIndex - 1).clamp(
                                  0,
                                  filteredItems.length - 1,
                                );
                              });
                              scrollToFocused(focusedIndex);
                            }
                            return KeyEventResult.handled;
                          } else if (event.logicalKey ==
                                  LogicalKeyboardKey.enter ||
                              event.logicalKey ==
                                  LogicalKeyboardKey.numpadEnter) {
                            if (filteredItems.isNotEmpty &&
                                focusedIndex >= 0 &&
                                focusedIndex < filteredItems.length) {
                              final itemVal = filteredItems[focusedIndex].value;
                              setDialogState(() {
                                if (tempSelected.contains(itemVal)) {
                                  tempSelected.remove(itemVal);
                                } else {
                                  tempSelected.add(itemVal);
                                }
                              });
                            }
                            return KeyEventResult.handled;
                          }
                        }
                        return KeyEventResult.ignored;
                      },
                      child: SizedBox(
                        height: 36,
                        child: TextField(
                          focusNode: searchFocusNode,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: 'Search $title...',
                            prefixIcon: const Icon(Icons.search, size: 20),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onChanged: (val) {
                            setDialogState(() {
                              searchQuery = val;
                              focusedIndex = 0;
                            });
                            if (scrollController.hasClients) {
                              scrollController.jumpTo(0);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Checkbox(
                          value: isAllSelected,
                          onChanged: (val) {
                            setDialogState(() {
                              if (val == true) {
                                for (var item in filteredItems) {
                                  if (!tempSelected.contains(item.value)) {
                                    tempSelected.add(item.value);
                                  }
                                }
                              } else {
                                for (var item in filteredItems) {
                                  tempSelected.remove(item.value);
                                }
                              }
                            });
                          },
                        ),
                        Text(
                          isAllSelected ? 'Deselect All' : 'Select All',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${tempSelected.length} selected',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: filteredItems.isEmpty
                          ? const Center(
                              child: Text(
                                'No items found',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              itemExtent: 36.0,
                              itemCount: filteredItems.length,
                              itemBuilder: (context, index) {
                                final item = filteredItems[index];
                                final isChecked = tempSelected.contains(
                                  item.value,
                                );
                                final isFocused = index == focusedIndex;

                                return Container(
                                  height: 36.0,
                                  decoration: BoxDecoration(
                                    color: isFocused
                                        ? const Color(0xFF556EE6).withValues(alpha: 0.14)
                                        : Colors.transparent,
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey.shade200,
                                        width: 0.5,
                                      ),
                                      left: isFocused
                                          ? const BorderSide(
                                              color: Color(0xFF556EE6),
                                              width: 4.0,
                                            )
                                          : BorderSide.none,
                                    ),
                                  ),
                                  child: CheckboxListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                                    dense: true,
                                    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                                    activeColor: const Color(0xFF556EE6),
                                    title: Text(
                                      item.label,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    value: isChecked,
                                    onChanged: (checked) {
                                      setDialogState(() {
                                        if (checked == true) {
                                          tempSelected.add(item.value);
                                        } else {
                                          tempSelected.remove(item.value);
                                        }
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    onConfirm(tempSelected);
                  },
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String? get _selectedReportName {
    final selVal = _formValues['sel'];
    if (selVal == null || selVal.isEmpty) return null;
    final code = int.tryParse(selVal);
    final reportsProv = context.read<ReportMstProvider>();
    final matched = reportsProv.list.firstWhereOrNull(
      (e) =>
          (code != null && e.reportTypeCode == code) || e.reportName == selVal,
    );
    return matched?.reportName ?? selVal;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  PDF VIEWER
// ─────────────────────────────────────────────────────────────────────────────

class _PdfReportView extends StatefulWidget {
  final Uint8List pdfBytes;
  final String reportTitle;
  final dynamic filter;

  const _PdfReportView({
    required this.pdfBytes,
    required this.reportTitle,
    this.filter,
  });

  @override
  State<_PdfReportView> createState() => _PdfReportViewState();
}

class _PdfReportViewState extends State<_PdfReportView> {
  late PdfControllerPinch _pdfController;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfControllerPinch(
      document: PdfDocument.openData(widget.pdfBytes),
    );
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  Future<void> _openInNewTab(BuildContext context) async {
    final dio = Dio();
    final String? token = AppStorage.getString('token');
    final config = ReportRegistry.of(widget.reportTitle);
    if (config == null) return;

    final queryParams =
        config.queryBuilder?.call(widget.filter) ?? widget.filter;

    final response = await dio.get(
      '$baseUrl${config.endpoint}',
      queryParameters: queryParams,
      options: Options(
        responseType: ResponseType.bytes,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/pdf',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    final blob = html.Blob([response.data], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.window.open(url, '_blank');
    Future.delayed(
      const Duration(seconds: 10),
      () => html.Url.revokeObjectUrl(url),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : 600.0;

        return SizedBox(
          width: constraints.maxWidth,
          height: height,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Align(
                alignment: AlignmentGeometry.topRight,
                child: ElevatedButton.icon(
                  onPressed: () => _openInNewTab(context),
                  icon: const Icon(Icons.print, size: 18),
                  label: const Text('Open'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PdfViewPinch(
                  controller: _pdfController,
                  scrollDirection: Axis.vertical,
                  builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
                    options: const DefaultBuilderOptions(),
                    errorBuilder: (_, error) =>
                        Center(child: Text('Error loading PDF: $error')),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}