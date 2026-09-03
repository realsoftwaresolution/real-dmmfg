import 'dart:async';
import 'package:diam_mfg/providers/PacketDelete_provider.dart';
import 'package:diam_mfg/providers/PacketEdit_provider.dart';
import 'package:diam_mfg/providers/PairProvider.dart';
import 'package:diam_mfg/providers/ReportProvider.dart';
import 'package:diam_mfg/providers/admin_menu_provider.dart';
import 'package:diam_mfg/providers/article_provider.dart';
import 'package:diam_mfg/providers/auth_provider.dart';
import 'package:diam_mfg/providers/charni_group_provider.dart';
import 'package:diam_mfg/providers/charni_provider.dart';
import 'package:diam_mfg/providers/clv_rate_provider.dart';
import 'package:diam_mfg/providers/color_group_provider.dart';
import 'package:diam_mfg/providers/color_provider.dart';
import 'package:diam_mfg/providers/company_provider.dart';
import 'package:diam_mfg/providers/counter_dept_det_provider.dart';
import 'package:diam_mfg/providers/counter_det_provider.dart';
import 'package:diam_mfg/providers/counter_display_det_provider.dart';
import 'package:diam_mfg/providers/counter_manager_det_provider.dart';
import 'package:diam_mfg/providers/counter_operator_det_provider.dart';
import 'package:diam_mfg/providers/counter_process_provider.dart';
import 'package:diam_mfg/providers/counter_provider.dart';
import 'package:diam_mfg/providers/counter_report_det_provider.dart';
import 'package:diam_mfg/providers/counter_shape_det_provider.dart';
import 'package:diam_mfg/providers/counter_stock_type_det_provider.dart';
import 'package:diam_mfg/providers/counter_type_provider.dart';
import 'package:diam_mfg/providers/cut_create_provider.dart';
import 'package:diam_mfg/providers/cut_provider.dart';
import 'package:diam_mfg/providers/department_rate_provider.dart';
import 'package:diam_mfg/providers/dept_group_provider.dart';
import 'package:diam_mfg/providers/dept_process_provider.dart';
import 'package:diam_mfg/providers/dept_provider.dart';
import 'package:diam_mfg/providers/designation_provider.dart';
import 'package:diam_mfg/providers/division_provider.dart';
import 'package:diam_mfg/providers/employee_dept_det_provider.dart';
import 'package:diam_mfg/providers/employee_manager_det_provider.dart';
import 'package:diam_mfg/providers/employee_provider.dart';
import 'package:diam_mfg/providers/fColor_provider.dart';
import 'package:diam_mfg/providers/factory_issue_entry_provider.dart';
import 'package:diam_mfg/providers/repair_issue_entry_provider.dart';
import 'package:diam_mfg/providers/factory_provider.dart';
import 'package:diam_mfg/providers/factory_rate_provider.dart';
import 'package:diam_mfg/providers/factory_receive_provider.dart';
import 'package:diam_mfg/providers/fluo_provider.dart';
import 'package:diam_mfg/providers/holiday_provider.dart';
import 'package:diam_mfg/providers/intent_provider.dart';
import 'package:diam_mfg/providers/jangad_charni_provider.dart';
import 'package:diam_mfg/providers/certificate_provider.dart';
import 'package:diam_mfg/providers/job_work_issue_entry_provider.dart';
import 'package:diam_mfg/providers/job_work_rec_entry_provider.dart';
import 'package:diam_mfg/providers/main_group_mst_provider.dart';
import 'package:diam_mfg/providers/main_menuMst_provider.dart';
import 'package:diam_mfg/providers/makable_entry_provider.dart';
import 'package:diam_mfg/providers/menu_mst_provider.dart';
import 'package:diam_mfg/providers/over_provider.dart';
import 'package:diam_mfg/providers/packet_provider.dart';
import 'package:diam_mfg/providers/party_provider.dart';
import 'package:diam_mfg/providers/party_type_provider.dart';
import 'package:diam_mfg/providers/pc_provider.dart';
import 'package:diam_mfg/providers/pkt_type_provider.dart';
import 'package:diam_mfg/providers/polish_provider.dart';
import 'package:diam_mfg/providers/production_dashboard_provider.dart';
import 'package:diam_mfg/providers/purity_group_provider.dart';
import 'package:diam_mfg/providers/purity_provider.dart';
import 'package:diam_mfg/providers/purity_rpt_group_provider.dart';
import 'package:diam_mfg/providers/purity_type_provider.dart';
import 'package:diam_mfg/providers/remarks_provider.dart';
import 'package:diam_mfg/providers/repair_receive_provider.dart';
import 'package:diam_mfg/providers/report_mst_provider.dart';
import 'package:diam_mfg/providers/report_type_provider.dart';
import 'package:diam_mfg/providers/rough_assort_provider.dart';
import 'package:diam_mfg/providers/rough_provider.dart';
import 'package:diam_mfg/providers/rough_type_provider.dart';
import 'package:diam_mfg/providers/sell_price_provider.dart';
import 'package:diam_mfg/providers/shape_group_provider.dart';
import 'package:diam_mfg/providers/shape_provider.dart';
import 'package:diam_mfg/providers/spk_dept_iss_provider.dart';
import 'package:diam_mfg/providers/stock_type_provider.dart';
import 'package:diam_mfg/providers/symmetry_provider.dart';
import 'package:diam_mfg/providers/team_provider.dart';
import 'package:diam_mfg/providers/tension_type_provider.dart';
import 'package:diam_mfg/providers/tensions_provider.dart';
import 'package:diam_mfg/providers/test_provider.dart';
import 'package:diam_mfg/providers/trn_laser_received_provider.dart';
import 'package:diam_mfg/providers/trn_planning_received_provider.dart';
import 'package:diam_mfg/providers/trn_process_issue_provider.dart';
import 'package:diam_mfg/providers/trn_process_rec_provider.dart';
import 'package:diam_mfg/providers/user_visibility_provider.dart';
import 'package:diam_mfg/providers/utility_clvdepartment_rate_update_provider.dart';
import 'package:diam_mfg/providers/utility_factory_rate_update_provider.dart';
import 'package:diam_mfg/providers/utility_jobwork_rate_update_provider.dart';
import 'package:diam_mfg/providers/utility_sell_price_list_update_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rs_dashboard/rs_dashboard.dart';
import '../providers/menu_provider.dart';
import 'providers/Ls_party_wt_calc_entry_provider.dart';
import 'providers/Packet_History_provider.dart';
import 'providers/factory_man_group_provider.dart';

String baseUrl = 'http://50.62.183.116:5000/api';
// String baseUrl = 'https://movers-reliance-vpn-remembered.trycloudflare.com/api';
//CU-7,5/6/2026,17:12,0.096,0.049,ROUND,G,MACKABLE,klhkhkhjkkh,,L:3.10,W:2.07,1.31,96.01,firoz,S.OVAL

//CU-7,5/6/2026,17:12,0.096,0.049,S.OVAL,G,VVS2,omjewR-1.50,,L:3.10,W:2.07,1.31,96.01,firoz,S.OVAL

Future<void> bootstrap({required FutureOr<Widget> Function() fn}) async {
  return runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await AppStorage.init();
      RSApiConfig.init(url: baseUrl);
      ApiClient.reset(); // ✅ force re-create BEFORE any provider touches it
      await RSAuthSession.restore();
      final app = await fn();

      runApp(
        MultiProvider(
          providers: [
            // FIXED: Changed from .value() to create() to prevent memory leaks
            ChangeNotifierProvider<MenuProvider>(create: (_) => MenuProvider()),
            ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
            ChangeNotifierProvider<CompanyProvider>(
              create: (_) => CompanyProvider(),
            ),
            ChangeNotifierProvider<PartyProvider>(
              create: (_) => PartyProvider(),
            ),
            ChangeNotifierProvider<FactoryProvider>(
              create: (_) => FactoryProvider(),
            ),
            ChangeNotifierProvider<FactoryManGroupProvider>(
              create: (_) => FactoryManGroupProvider(),
            ),
            ChangeNotifierProvider<DivisionProvider>(
              create: (_) => DivisionProvider(),
            ),
            ChangeNotifierProvider<CutProvider>(create: (_) => CutProvider()),
            ChangeNotifierProvider<RoughTypeProvider>(
              create: (_) => RoughTypeProvider(),
            ),
            ChangeNotifierProvider<JangadCharaniProvider>(
              create: (_) => JangadCharaniProvider(),
            ),
            ChangeNotifierProvider<CharniProvider>(
              create: (_) => CharniProvider(),
            ),
            ChangeNotifierProvider<ArticleProvider>(
              create: (_) => ArticleProvider(),
            ),
            ChangeNotifierProvider<PurityGroupProvider>(
              create: (_) => PurityGroupProvider(),
            ),
            ChangeNotifierProvider<PurityProvider>(
              create: (_) => PurityProvider(),
            ),
            ChangeNotifierProvider<ColorProvider>(
              create: (_) => ColorProvider(),
            ),
            ChangeNotifierProvider<ShapeGroupProvider>(
              create: (_) => ShapeGroupProvider(),
            ),
            ChangeNotifierProvider<ShapeProvider>(
              create: (_) => ShapeProvider(),
            ),
            ChangeNotifierProvider<DeptGroupProvider>(
              create: (_) => DeptGroupProvider(),
            ),
            ChangeNotifierProvider<DeptProvider>(create: (_) => DeptProvider()),
            ChangeNotifierProvider<DeptProcessProvider>(
              create: (_) => DeptProcessProvider(),
            ),
            ChangeNotifierProvider<TensionsProvider>(
              create: (_) => TensionsProvider(),
            ),
            ChangeNotifierProvider<RemarksProvider>(
              create: (_) => RemarksProvider(),
            ),
            ChangeNotifierProvider<FluoProvider>(create: (_) => FluoProvider()),
            ChangeNotifierProvider<HolidayProvider>(
              create: (_) => HolidayProvider(),
            ),
            ChangeNotifierProvider<PurityRptGroupProvider>(
              create: (_) => PurityRptGroupProvider(),
            ),
            ChangeNotifierProvider<PcProvider>(create: (_) => PcProvider()),
            ChangeNotifierProvider<ColorGroupProvider>(
              create: (_) => ColorGroupProvider(),
            ),
            ChangeNotifierProvider<TensionTypeProvider>(
              create: (_) => TensionTypeProvider(),
            ),
            ChangeNotifierProvider<CharniGroupProvider>(
              create: (_) => CharniGroupProvider(),
            ),
            ChangeNotifierProvider<PurityTypeProvider>(
              create: (_) => PurityTypeProvider(),
            ),
            ChangeNotifierProvider<RoughProvider>(
              create: (_) => RoughProvider(),
            ),
            ChangeNotifierProvider<StockTypeProvider>(
              create: (_) => StockTypeProvider(),
            ),
            ChangeNotifierProvider<TabProvider>(create: (_) => TabProvider()),
            ChangeNotifierProvider<RoughAssortProvider>(
              create: (_) => RoughAssortProvider(),
            ),
            ChangeNotifierProvider<CutCreateProvider>(
              create: (_) => CutCreateProvider(),
            ),
            ChangeNotifierProvider<PacketProvider>(
              create: (_) => PacketProvider(),
            ),
            ChangeNotifierProvider<PktTypeProvider>(
              create: (_) => PktTypeProvider(),
            ),
            ChangeNotifierProvider<TeamProvider>(create: (_) => TeamProvider()),
            ChangeNotifierProvider<CounterDeptDetProvider>(
              create: (_) => CounterDeptDetProvider(),
            ),
            ChangeNotifierProvider<CounterProvider>(
              create: (_) => CounterProvider(),
            ),
            ChangeNotifierProvider<CounterManagerDetProvider>(
              create: (_) => CounterManagerDetProvider(),
            ),
            ChangeNotifierProvider<CounterOperatorDetProvider>(
              create: (_) => CounterOperatorDetProvider(),
            ),
            ChangeNotifierProvider<CounterProcessProvider>(
              create: (_) => CounterProcessProvider(),
            ),
            ChangeNotifierProvider<CounterReportDetProvider>(
              create: (_) => CounterReportDetProvider(),
            ),
            ChangeNotifierProvider<CounterShapeDetProvider>(
              create: (_) => CounterShapeDetProvider(),
            ),
            ChangeNotifierProvider<CounterStockTypeDetProvider>(
              create: (_) => CounterStockTypeDetProvider(),
            ),
            ChangeNotifierProvider<CounterTypeProvider>(
              create: (_) => CounterTypeProvider(),
            ),
            ChangeNotifierProvider<MainGroupMstProvider>(
              create: (_) => MainGroupMstProvider(),
            ),
            ChangeNotifierProvider<MainMenuMstProvider>(
              create: (_) => MainMenuMstProvider(),
            ),
            ChangeNotifierProvider<MenuMstProvider>(
              create: (_) => MenuMstProvider(),
            ),
            ChangeNotifierProvider<ReportTypeProvider>(
              create: (_) => ReportTypeProvider(),
            ),
            ChangeNotifierProvider<ReportMstProvider>(
              create: (_) => ReportMstProvider(),
            ),
            ChangeNotifierProvider<UserVisibilityProvider>(
              create: (_) => UserVisibilityProvider(),
            ),
            ChangeNotifierProvider<TestProvider>(create: (_) => TestProvider()),
            ChangeNotifierProvider<CounterDisplayDetProvider>(
              create: (_) => CounterDisplayDetProvider(),
            ),
            ChangeNotifierProvider<CounterDetProvider>(
              create: (_) => CounterDetProvider(),
            ),
            ChangeNotifierProvider<PartyTypeProvider>(
              create: (_) => PartyTypeProvider(),
            ),
            ChangeNotifierProvider<SpkDeptIssProvider>(
              create: (_) => SpkDeptIssProvider(),
            ),
            ChangeNotifierProvider<TrnPlanningReceivedProvider>(
              create: (_) => TrnPlanningReceivedProvider(),
            ),
            ChangeNotifierProvider<TrnLaserReceivedProvider>(
              create: (_) => TrnLaserReceivedProvider(),
            ),
            ChangeNotifierProvider<EmployeeProvider>(
              create: (_) => EmployeeProvider(),
            ),
            ChangeNotifierProvider<DesignationProvider>(
              create: (_) => DesignationProvider(),
            ),
            ChangeNotifierProvider<EmployeeDeptDetProvider>(
              create: (_) => EmployeeDeptDetProvider(),
            ),
            ChangeNotifierProvider<EmployeeManagerDetProvider>(
              create: (_) => EmployeeManagerDetProvider(),
            ),
            ChangeNotifierProvider<AdminMenuProvider>(
              create: (_) => AdminMenuProvider(),
            ),
            ChangeNotifierProvider<MakableEntryProvider>(
              create: (_) => MakableEntryProvider(),
            ),
            ChangeNotifierProvider<FactoryIssueEntryProvider>(
              create: (_) => FactoryIssueEntryProvider(),
            ),
            ChangeNotifierProvider<RepairIssueEntryProvider>(
              create: (_) => RepairIssueEntryProvider(),
            ),
            ChangeNotifierProvider<RepairReceivedEntryProvider>(
              create: (_) => RepairReceivedEntryProvider(),
            ),
            ChangeNotifierProvider<FactoryReceivedEntryProvider>(
              create: (_) => FactoryReceivedEntryProvider(),
            ),
            ChangeNotifierProvider<ReportProvider>(
              create: (_) => ReportProvider(),
            ),
            ChangeNotifierProvider<PairProvider>(create: (_) => PairProvider()),
            ChangeNotifierProvider<PacketHistoryProvider>(
              create: (_) => PacketHistoryProvider(),
            ),
            ChangeNotifierProvider<PacketDeleteProvider>(
              create: (_) => PacketDeleteProvider(),
            ),
            ChangeNotifierProvider<PacketEditProvider>(
              create: (_) => PacketEditProvider(),
            ),
            ChangeNotifierProvider<PolishProvider>(
              create: (_) => PolishProvider(),
            ),
            ChangeNotifierProvider<SymmetryProvider>(
              create: (_) => SymmetryProvider(),
            ),
            ChangeNotifierProvider<ProcessIssueEntryProvider>(
              create: (_) => ProcessIssueEntryProvider(),
            ),
            ChangeNotifierProvider<MstLsPartyWtCalcEntryProvider>(
              create: (_) => MstLsPartyWtCalcEntryProvider(),
            ),
            ChangeNotifierProvider<ClvRateProvider>(
              create: (_) => ClvRateProvider(),
            ),
            ChangeNotifierProvider<LabProvider>(create: (_) => LabProvider()),
            ChangeNotifierProvider<DepartmentRateProvider>(
              create: (_) => DepartmentRateProvider(),
            ),
            ChangeNotifierProvider<FactoryRateProvider>(
              create: (_) => FactoryRateProvider(),
            ),
            ChangeNotifierProvider<IntentProvider>(
              create: (_) => IntentProvider(),
            ),
            ChangeNotifierProvider<OverProvider>(create: (_) => OverProvider()),
            ChangeNotifierProvider<FColorProvider>(
              create: (_) => FColorProvider(),
            ),
            ChangeNotifierProvider<JobWorkIssueEntryProvider>(
              create: (_) => JobWorkIssueEntryProvider(),
            ),
            ChangeNotifierProvider<JobWorkRecEntryProvider>(
              create: (_) => JobWorkRecEntryProvider(),
            ),
            ChangeNotifierProvider<SellPriceProvider>(
              create: (_) => SellPriceProvider(),
            ),
            ChangeNotifierProvider<UtilityClvDepartmentRateUpdateProvider>(
              create: (_) => UtilityClvDepartmentRateUpdateProvider(),
            ),
            ChangeNotifierProvider<UtilityFactoryRateUpdateProvider>(
              create: (_) => UtilityFactoryRateUpdateProvider(),
            ),
            ChangeNotifierProvider<UtilityJobWorkRateUpdateProvider>(
              create: (_) => UtilityJobWorkRateUpdateProvider(),
            ),
            ChangeNotifierProvider<UtilitySellPriceListUpdateProvider>(
              create: (_) => UtilitySellPriceListUpdateProvider(),
            ),
            ChangeNotifierProvider<ProductionDashboardProvider>(
              create: (_) => ProductionDashboardProvider(),
            ),ChangeNotifierProvider<ProcessRecEntryProvider>(
              create: (_) => ProcessRecEntryProvider(),
            ),
          ],
          child: app,
        ),
      );
    },
    (error, stack) {
      debugPrintStack(stackTrace: stack);
    },
  );
}
