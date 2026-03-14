
import 'package:diam_mfg/providers/company_provider.dart';
import 'package:diam_mfg/providers/team_provider.dart';
import 'package:diam_mfg/models/team_model.dart';
import 'package:diam_mfg/utils/app_images.dart';
import 'package:erp_data_table/erp_data_table.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rs_dashboard/rs_dashboard.dart';
import '../utils/delete_dialogue.dart';
import '../utils/msg_dialogue.dart';

class MstTeamEntry extends StatefulWidget {
  const MstTeamEntry({super.key});
  @override
  State<MstTeamEntry> createState() => _MstTeamEntryState();
}

class _MstTeamEntryState extends State<MstTeamEntry> {
  final ErpThemeVariant          _themeVariant = ErpThemeVariant.frost;
  ErpTheme get _theme                          => ErpTheme(_themeVariant);
  final GlobalKey<ErpFormState>  _erpFormKey   = GlobalKey<ErpFormState>();

  Map<String, dynamic>? _selectedRow;
  TeamModel?            _selectedModel;
  bool                  _isEditMode        = false;
  bool                  _showTableOnMobile = false;

  Map<String, String> _formValues = {};

  final String? token = AppStorage.getString('token');

  // ── TABLE COLUMNS ──────────────────────────────────────────────────────────
  List<ErpColumnConfig> get _tableColumns =>  [
    ErpColumnConfig(key: 'teamCode',    label: 'CODE',    width: 80,  required: true),
    ErpColumnConfig(key: 'teamName',    label: 'NAME',    width: 180, required: true),
    ErpColumnConfig(key: 'companyCode', label: 'COMPANY', width: 150),
    ErpColumnConfig(key: 'sortID',      label: 'SORT',    width: 80),
    ErpColumnConfig(key: 'active',      label: 'ACTIVE',  width: 80),
  ];

  // ── FORM ROWS ──────────────────────────────────────────────────────────────
  List<List<ErpFieldConfig>> _formRows(CompanyProvider compProv) {
    final companyItems = compProv.companies
        .map((c) => ErpDropdownItem(
      label: c.companyName ?? '',
      value: c.companyCode?.toString() ?? '',
    ))
        .toList();

    return [
      [
        ErpFieldConfig(
          key: 'teamName', label: 'TEAM NAME',
          type: ErpFieldType.text,
          required: true, flex: 2,
          sectionTitle: 'TEAM MASTER', sectionIndex: 0,
        ),
        ErpFieldConfig(
          key: 'companyCode', label: 'COMPANY',
          type: ErpFieldType.dropdown,
          dropdownItems: companyItems,
          required: true, flex: 2, sectionIndex: 0,
        ),
      ],
      [
        ErpFieldConfig(
          key: 'sortID', label: 'SORT ID',
          type: ErpFieldType.number,
          flex: 1, sectionIndex: 0,
        ),
        ErpFieldConfig(
          key: 'active',
          label: 'ACTIVE',
          type: ErpFieldType.checkbox,
          sectionTitle: 'SETTINGS',
          sectionIndex: 1,
          checkboxDbType: 'BIT',
        ),
        // ErpFieldConfig(
        //   key: 'active', label: 'ACTIVE',
        //   type: ErpFieldType.dropdown,
        //   dropdownItems: const [
        //     ErpDropdownItem(label: 'Yes', value: 'true'),
        //     ErpDropdownItem(label: 'No',  value: 'false'),
        //   ],
        //   flex: 1, sectionIndex: 0,
        // ),
      ],
    ];
  }

  // ── INIT ───────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final compProv = context.read<CompanyProvider>();
      final teamProv = context.read<TeamProvider>();
      compProv.loadCompanies().then((_) {
        teamProv.setCompanies(compProv.companies);
      });
      teamProv.load();
      _setDefaultFormValues();
    });
  }

  void _setDefaultFormValues() {
    _formValues = {'active': 'true', 'sortID': '0'};
    if (mounted) setState(() {});
  }

  // ── ROW TAP ────────────────────────────────────────────────────────────────
  void _onRowTap(Map<String, dynamic> row) {
    final raw = row['_raw'] as TeamModel;
    setState(() {
      _selectedRow   = row;
      _selectedModel = raw;
      _isEditMode    = true;
      _formValues    = {
        'teamName':    raw.teamName    ?? '',
        'companyCode': raw.companyCode?.toString() ?? '',
        'sortID':      raw.sortID?.toString()      ?? '0',
        'active': raw.active == true ? 'true' : 'false',
      };
      if (Responsive.isMobile(context)) _showTableOnMobile = false;
    });
  }

  // ── SAVE ───────────────────────────────────────────────────────────────────
  Future<void> _onSave(Map<String, dynamic> values) async {
    final prov = context.read<TeamProvider>();
    bool success;

    if (_isEditMode && _selectedModel?.teamCode != null) {
      success = await prov.update(_selectedModel!.teamCode!, values);
    } else {
      success = await prov.create(values);
    }

    if (!mounted) return;
    if (success) {
      final wasEdit = _isEditMode;
      _resetForm();
      await ErpResultDialog.showSuccess(
        context: context, theme: _theme,
        title:   wasEdit ? 'Updated' : 'Saved',
        message: wasEdit ? 'Team updated successfully.' : 'Team saved successfully.',
      );
    }
  }

  // ── DELETE ─────────────────────────────────────────────────────────────────
  Future<void> _onDelete() async {
    if (_selectedModel?.teamCode == null) return;
    final confirm = await ErpDeleteDialog.show(
      context: context, theme: _theme,
      title:    'Team',
      itemName: _selectedModel!.teamName ?? '',
    );
    if (confirm != true || !mounted) return;

    final success = await context
        .read<TeamProvider>()
        .delete(_selectedModel!.teamCode!);

    if (success && mounted) {
      final name = _selectedModel?.teamName ?? '';
      _resetForm();
      await ErpResultDialog.showDeleted(
        context: context, theme: _theme,
        itemName: 'Team: $name',
      );
    }
  }

  // ── RESET ──────────────────────────────────────────────────────────────────
  void _resetForm() {
    _erpFormKey.currentState?.resetForm();
    setState(() {
      _selectedRow       = null;
      _selectedModel     = null;
      _isEditMode        = false;
      _showTableOnMobile = false;
      _formValues        = {};
    });
  }

  // ── BUILD ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Consumer<TeamProvider>(
      builder: (ctx, prov, _) => Padding(
        padding: const EdgeInsets.all(8),
        child: Responsive.isMobile(context)
            ? _showTableOnMobile
            ? _buildTable(prov)
            : _buildForm(context)
            : Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: _buildForm(context)),
            const SizedBox(width: 12),
            Expanded(flex: 2, child: _buildTable(prov)),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final compProv = context.watch<CompanyProvider>();

    return ErpForm(
      logo:          AppImages.logo,
      key:           _erpFormKey,
      title:         'TEAM MASTER',
      tabBarBackgroundColor:  const Color(0xfff2f0ef),
      tabBarSelectedColor:    _theme.primaryGradient.first,
      tabBarSelectedTxtColor: Colors.white,
      rows:          _formRows(compProv),
      initialValues: _formValues,
      isEditMode:    _isEditMode,

      onFieldChanged: (key, value) {
        _formValues[key] = value.toString();
      },

      onExit:   () => context.read<TabProvider>().closeCurrentTab(),
      onSave:   _onSave,
      onCancel: _resetForm,
      onDelete: _isEditMode ? _onDelete : null,
      onSearch: () => setState(() => _showTableOnMobile = true),
    );
  }

  Widget _buildTable(TeamProvider prov) {
    return ErpDataTable(
      isReportRow:  false,
      token:        token ?? '',
      url:          'http://50.62.183.116:5000',
      title:        'TEAM LIST',
      columns:      _tableColumns,
      data:         prov.tableData,
      showSearch:   true,
      searchFields: const [
        ErpSearchFieldConfig(key: 'teamName',    label: 'TEAM NAME', width: 180),
        ErpSearchFieldConfig(key: 'companyCode', label: 'COMPANY',   width: 150),
      ],
      selectedRow:  _selectedRow,
      onRowTap:     _onRowTap,
      emptyMessage: prov.isLoaded ? 'No teams found' : 'Loading...',
    );
  }
}