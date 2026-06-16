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

  final String? token = AppStorage.getString("token");

  // Table columns matching SellPriceModel.toTableRow() keys.
  List<ErpColumnConfig> get _tableColumns => [
    ErpColumnConfig(
      key: 'sellCode',
      label: 'SELL CODE',
      width: 160,
      align: ColumnAlign.center,
    ),
    ErpColumnConfig(
      key: 'articalName',
      label: 'ARTICLE',
      width: 150,
      align: ColumnAlign.center,
    ),
    ErpColumnConfig(
      key: 'shapeName',
      label: 'SHAPE',
      width: 150,
      align: ColumnAlign.center,
    ),
    ErpColumnConfig(
      key: 'length',
      label: 'LENGTH',
      width: 150,
      align: ColumnAlign.center,
    ),
    ErpColumnConfig(
      key: 'width',
      label: 'DIAM',
      width: 130,
      align: ColumnAlign.center,
    ),
    ErpColumnConfig(
      key: 'height',
      label: 'HEIGHT',
      width: 150,
      align: ColumnAlign.center,
    ),
    ErpColumnConfig(
      key: 'rate',
      label: 'RATE',
      width: 130,
      align: ColumnAlign.center,
    ),
    ErpColumnConfig(
      key: 'companyName',
      label: 'COMPANY',
      width: 160,
      align: ColumnAlign.center,
    ),
    ErpColumnConfig(
      key: 'colors',
      label: 'COLOR',
      width: 200,
      align: ColumnAlign.center,
    ),
    ErpColumnConfig(
      key: 'purities',
      label: 'PURITY',
      width: 200,
      align: ColumnAlign.center,
    ),
    ErpColumnConfig(
      key: 'sortID',
      label: 'SORT ID',
      width: 150,
      align: ColumnAlign.center,
    ),
    ErpColumnConfig(
      key: 'active',
      label: 'ACTIVE',
      width: 150,
      align: ColumnAlign.center,
    ),
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
        ErpFieldConfig(
          key: 'colorCode',
          label: 'COLOR',
          type: ErpFieldType.multiselectDropdown,
          dropdownItems: colorProv.list
              .where((e) => e.active == true)
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
          type: ErpFieldType.multiselectDropdown,
          dropdownItems: purityProv.list
              .where((e) => e.active == true)
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
          key: 'rate',
          label: 'RATE',
          type: ErpFieldType.amount,
          sectionIndex: 0,
        ),
      ],
      [
        ErpFieldConfig(
          key: 'length',
          label: 'LENGTH',
          type: ErpFieldType.number,
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
          key: 'code',
          label: 'CODE',
          type: ErpFieldType.text,
          sectionIndex: 1,
          flex: 1,
        ),
        ErpFieldConfig(
          key: 'sortID',
          label: 'SORT ID',
          type: ErpFieldType.number,
          sectionIndex: 1,
        ),
      ],
      [
        ErpFieldConfig(
            key: 'active',
            label: 'ACTIVE',
            type: ErpFieldType.checkbox,
            checkboxDbType: 'BIT',
            sectionIndex: 2,
            initialBoolValue: true,
            width: 160
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
    });
  }

  void _onRowTap(Map<String, dynamic> row) {
    final raw = row['_raw'] as SellPriceModel;

    setState(() {
      _selectedRow = row;
      _isEditMode = true;

      _formValues = {
        'code': raw.sellCode ?? '',
        'articleCode': raw.articalCode?.toString() ?? '',
        'shapeCode': raw.shapeCode?.toString() ?? '',
        'rate': raw.rate?.toString() ?? '',
        'length': raw.length?.toString() ?? '',
        'diam': raw.width?.toString() ?? '',
        'height': raw.height?.toString() ?? '',
        'sortID': raw.sortID?.toString() ?? '',
        'active': raw.active == true ? 'true' : 'false',
        'colorCode': raw.colorCodes.join(','),
        'purityCode': raw.purityCodes.join(','),
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

    final articleLetter =
    (article.articalName?.isNotEmpty ?? false)
        ? article.articalName![0].toUpperCase()
        : '';

    final shapeLetter =
    (shape.shapeName?.isNotEmpty ?? false)
        ? shape.shapeName![0].toUpperCase()
        : '';

    final length =
        double.tryParse(_formValues['length'] ?? '') ?? 0;

    final width =
        double.tryParse(_formValues['diam'] ?? '') ?? 0;

    final lengthPart = (length * 10).round().toString().padLeft(3, '0');

    final widthPart = (width * 10).round().toString().padLeft(2, '0');

    final code =
        '$articleLetter$shapeLetter$lengthPart$widthPart';

    _formValues['code'] = code;

    _erpFormKey.currentState?.updateFieldValue(
      'code',
      code,
    );
  }

  Future<void> _onSave(Map<String, dynamic> values) async {
    final provider = context.read<SellPriceProvider>();

    final payload = {
      "SellCode": values['code']?.toString() ?? '',

      "ArticalCode":
      int.tryParse(values['articleCode']?.toString() ?? '') ?? 0,

      "ShapeCode": int.tryParse(values['shapeCode']?.toString() ?? '') ?? 0,

      "Length": double.tryParse(values['length']?.toString() ?? '') ?? 0,

      "Width": double.tryParse(values['diam']?.toString() ?? '') ?? 0,

      "Height": double.tryParse(values['height']?.toString() ?? '') ?? 0,

      "Rate": double.tryParse(values['rate']?.toString() ?? '') ?? 0,

      "CompanyCode": context.read<CompanyProvider>().selectedCompanyCode ?? 0,

      "SortID": int.tryParse(values['sortID']?.toString() ?? '') ?? 0,

      "Active":
      values['active'] == 'true' ||
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
    };

    bool success = false;

    if (_isEditMode && _selectedRow != null) {
      final raw = _selectedRow!['_raw'] as SellPriceModel;

      success = await provider.updateSellPrice(
        raw.sellPriceListMstID!,
        payload,
      );
    } else {
      success = await provider.createSellPrice(payload);
    }

    if (!mounted) return;

    if (success) {
      _resetForm();

      await ErpResultDialog.showSuccess(
        context: context,
        theme: context.erpTheme,
        title: _isEditMode ? 'Updated' : 'Saved',
        message: _isEditMode
            ? 'Sell Price updated successfully.'
            : 'Sell Price saved successfully.',
      );
    } else {
      await ErpResultDialog.showError(
        context: context,
        theme: context.erpTheme,
        title: 'Error',
        message: _isEditMode
            ? 'Failed to update Sell Price.'
            : 'Failed to save Sell Price.',
      );
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

    final success = await context
        .read<SellPriceProvider>()
        .deleteSellPrice(raw.sellPriceListMstID!);

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
    });
    _erpFormKey.currentState?.resetForm();
    _formValues['active'] = 'true';
    _erpFormKey.currentState?.updateFieldValue('active', 'true');
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
                ),
              ),
              const SizedBox(width: 12),
              Expanded(flex: 2, child: buildErpDataTable(provider)),
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

    if ([
      'articleCode',
      'shapeCode',
      'length',
      'diam',
    ].contains(key)) {
      _generateCode();
    }

    // Auto-advance focus through the form in entry order.
    if (key == 'articleCode') {
      Future.delayed(const Duration(milliseconds: 50), () {
        _erpFormKey.currentState?.focusField('shapeCode');
      });
    }

    if (key == 'shapeCode') {
      Future.delayed(const Duration(milliseconds: 50), () {
        _erpFormKey.currentState?.focusField('colorCode');
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