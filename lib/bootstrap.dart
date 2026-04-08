import 'dart:async';
import 'package:diam_mfg/providers/admin_menu_provider.dart';
import 'package:diam_mfg/providers/article_provider.dart';
import 'package:diam_mfg/providers/auth_provider.dart';
import 'package:diam_mfg/providers/charni_group_provider.dart';
import 'package:diam_mfg/providers/charni_provider.dart';
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
import 'package:diam_mfg/providers/dept_group_provider.dart';
import 'package:diam_mfg/providers/dept_process_provider.dart';
import 'package:diam_mfg/providers/dept_provider.dart';
import 'package:diam_mfg/providers/designation_provider.dart';
import 'package:diam_mfg/providers/division_provider.dart';
import 'package:diam_mfg/providers/employee_dept_det_provider.dart';
import 'package:diam_mfg/providers/employee_manager_det_provider.dart';
import 'package:diam_mfg/providers/employee_provider.dart';
import 'package:diam_mfg/providers/factory_provider.dart';
import 'package:diam_mfg/providers/fluo_provider.dart';
import 'package:diam_mfg/providers/holiday_provider.dart';
import 'package:diam_mfg/providers/jangad_charni_provider.dart';
import 'package:diam_mfg/providers/main_group_mst_provider.dart';
import 'package:diam_mfg/providers/main_menuMst_provider.dart';
import 'package:diam_mfg/providers/menu_mst_provider.dart';
import 'package:diam_mfg/providers/packet_provider.dart';
import 'package:diam_mfg/providers/party_provider.dart';
import 'package:diam_mfg/providers/party_type_provider.dart';
import 'package:diam_mfg/providers/pc_provider.dart';
import 'package:diam_mfg/providers/pkt_type_provider.dart';
import 'package:diam_mfg/providers/purity_group_provider.dart';
import 'package:diam_mfg/providers/purity_provider.dart';
import 'package:diam_mfg/providers/purity_rpt_group_provider.dart';
import 'package:diam_mfg/providers/purity_type_provider.dart';
import 'package:diam_mfg/providers/remarks_provider.dart';
import 'package:diam_mfg/providers/report_mst_provider.dart';
import 'package:diam_mfg/providers/report_type_provider.dart';
import 'package:diam_mfg/providers/rough_assort_provider.dart';
import 'package:diam_mfg/providers/rough_provider.dart';
import 'package:diam_mfg/providers/rough_type_provider.dart';
import 'package:diam_mfg/providers/shape_group_provider.dart';
import 'package:diam_mfg/providers/shape_provider.dart';
import 'package:diam_mfg/providers/spk_dept_iss_provider.dart';
import 'package:diam_mfg/providers/stock_type_provider.dart';
import 'package:diam_mfg/providers/team_provider.dart';
import 'package:diam_mfg/providers/tension_type_provider.dart';
import 'package:diam_mfg/providers/tensions_provider.dart';
import 'package:diam_mfg/providers/test_provider.dart';
import 'package:diam_mfg/providers/trn_laser_received_provider.dart';
import 'package:diam_mfg/providers/trn_planning_received_provider.dart';
import 'package:diam_mfg/providers/user_visibility_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rs_dashboard/rs_dashboard.dart';
import '../providers/menu_provider.dart';
import 'providers/factory_man_group_provider.dart';
String baseUrl='http://50.62.183.116:5000';

Future<void> bootstrap({
  required FutureOr<Widget> Function() fn,
}) async {
  return runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await AppStorage.init();
    //
    // /// API Base URL
    RSApiConfig.init(url: "http://50.62.183.116:5000/api");
    await RSAuthSession.restore();

    final menuProvider = MenuProvider();

    await menuProvider.loadMenus();

    final app = await fn();

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<MenuProvider>.value(value: menuProvider),
          ChangeNotifierProvider<AuthProvider>.value(value: AuthProvider()),
          ChangeNotifierProvider<CompanyProvider>.value(value: CompanyProvider()),
          ChangeNotifierProvider<PartyProvider>.value(value: PartyProvider()),
          ChangeNotifierProvider<FactoryProvider>.value(value: FactoryProvider()),
          ChangeNotifierProvider<FactoryManGroupProvider>.value(value: FactoryManGroupProvider()),
          ChangeNotifierProvider<DivisionProvider>.value(value: DivisionProvider()),
          ChangeNotifierProvider<CutProvider>.value(value: CutProvider()),
          ChangeNotifierProvider<RoughTypeProvider>.value(value: RoughTypeProvider()),
          ChangeNotifierProvider<JangadCharaniProvider>.value(value: JangadCharaniProvider()),
          ChangeNotifierProvider<CharniProvider>.value(value: CharniProvider()),
          ChangeNotifierProvider<ArticleProvider>.value(value: ArticleProvider()),
          ChangeNotifierProvider<PurityGroupProvider>.value(value: PurityGroupProvider()),
          ChangeNotifierProvider<PurityProvider>.value(value: PurityProvider()),
          ChangeNotifierProvider<ColorProvider>.value(value: ColorProvider()),
          ChangeNotifierProvider<ShapeGroupProvider>.value(value: ShapeGroupProvider()),
          ChangeNotifierProvider<ShapeProvider>.value(value: ShapeProvider()),
          ChangeNotifierProvider<DeptGroupProvider>.value(value: DeptGroupProvider()),
          ChangeNotifierProvider<DeptProvider>.value(value: DeptProvider()),
          ChangeNotifierProvider<DeptProcessProvider>.value(value: DeptProcessProvider()),
          ChangeNotifierProvider<TensionsProvider>.value(value: TensionsProvider()),
          ChangeNotifierProvider<RemarksProvider>.value(value: RemarksProvider()),
          ChangeNotifierProvider<FluoProvider>.value(value: FluoProvider()),
          ChangeNotifierProvider<HolidayProvider>.value(value: HolidayProvider()),
          ChangeNotifierProvider<PurityRptGroupProvider>.value(value: PurityRptGroupProvider()),
          ChangeNotifierProvider<PcProvider>.value(value: PcProvider()),
          ChangeNotifierProvider<ColorGroupProvider>.value(value: ColorGroupProvider()),
          ChangeNotifierProvider<TensionTypeProvider>.value(value: TensionTypeProvider()),
          ChangeNotifierProvider<CharniGroupProvider>.value(value: CharniGroupProvider()),
          ChangeNotifierProvider<PurityTypeProvider>.value(value: PurityTypeProvider()),
          ChangeNotifierProvider<RoughProvider>.value(value: RoughProvider()),
          ChangeNotifierProvider<StockTypeProvider>.value(value: StockTypeProvider()),
          ChangeNotifierProvider<TabProvider>.value(value: TabProvider()),
          ChangeNotifierProvider<RoughAssortProvider>.value(value: RoughAssortProvider()),
          ChangeNotifierProvider<CutCreateProvider>.value(value: CutCreateProvider()),
          ChangeNotifierProvider<PacketProvider>.value(value: PacketProvider()),
          ChangeNotifierProvider<PktTypeProvider>.value(value: PktTypeProvider()),
          ChangeNotifierProvider<TeamProvider>.value(value: TeamProvider()),
          ChangeNotifierProvider<CounterDeptDetProvider>.value(value: CounterDeptDetProvider()),
          ChangeNotifierProvider<CounterProvider>.value(value: CounterProvider()),
          ChangeNotifierProvider<CounterManagerDetProvider>.value(value: CounterManagerDetProvider()),
          ChangeNotifierProvider<CounterOperatorDetProvider>.value(value: CounterOperatorDetProvider()),
          ChangeNotifierProvider<CounterProcessProvider>.value(value: CounterProcessProvider()),
          ChangeNotifierProvider<CounterReportDetProvider>.value(value: CounterReportDetProvider()),
          ChangeNotifierProvider<CounterShapeDetProvider>.value(value: CounterShapeDetProvider()),
          ChangeNotifierProvider<CounterStockTypeDetProvider>.value(value: CounterStockTypeDetProvider()),
          ChangeNotifierProvider<CounterTypeProvider>.value(value: CounterTypeProvider()),
          ChangeNotifierProvider<MainGroupMstProvider>.value(value: MainGroupMstProvider()),
          ChangeNotifierProvider<MainMenuMstProvider>.value(value: MainMenuMstProvider()),
          ChangeNotifierProvider<MenuMstProvider>.value(value: MenuMstProvider()),
          ChangeNotifierProvider<ReportTypeProvider>.value(value: ReportTypeProvider()),
          ChangeNotifierProvider<ReportMstProvider>.value(value: ReportMstProvider()),
          ChangeNotifierProvider<UserVisibilityProvider>.value(value: UserVisibilityProvider()),
          ChangeNotifierProvider<TestProvider>.value(value: TestProvider()),
          ChangeNotifierProvider<CounterDisplayDetProvider>.value(value: CounterDisplayDetProvider()),
          ChangeNotifierProvider<CounterDetProvider>.value(value: CounterDetProvider()),
          ChangeNotifierProvider<PartyTypeProvider>.value(value: PartyTypeProvider()),
          ChangeNotifierProvider<SpkDeptIssProvider>.value(value: SpkDeptIssProvider()),
          ChangeNotifierProvider<TrnPlanningReceivedProvider>.value(value: TrnPlanningReceivedProvider()),
          ChangeNotifierProvider<TrnLaserReceivedProvider>.value(value: TrnLaserReceivedProvider()),
          ChangeNotifierProvider<EmployeeProvider>.value(value: EmployeeProvider()),
          ChangeNotifierProvider<DesignationProvider>.value(value: DesignationProvider()),
          ChangeNotifierProvider<EmployeeDeptDetProvider>.value(value: EmployeeDeptDetProvider()),
          ChangeNotifierProvider<EmployeeManagerDetProvider>.value(value: EmployeeManagerDetProvider()),
          ChangeNotifierProvider<AdminMenuProvider>.value(value: AdminMenuProvider()),



        ],
        child: app,
      ),
    );
  }, (error, stack) {
    debugPrint("GLOBAL ERROR: $error");
    debugPrintStack(stackTrace: stack);
  });
}
