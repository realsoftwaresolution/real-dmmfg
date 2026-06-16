import 'package:diam_mfg/screens/PacketDeleteScreen.dart';
import 'package:diam_mfg/screens/PacketEditScreen.dart';
import 'package:diam_mfg/screens/PacketHistoryScreen.dart' show PacketHistoryScreen;
import 'package:diam_mfg/screens/PairScreen.dart';
import 'package:diam_mfg/screens/Report_screen.dart';
import 'package:diam_mfg/screens/admin_menu_create.dart';
import 'package:diam_mfg/screens/mst_firm_FColor.dart';
import 'package:diam_mfg/screens/mst_firm_clv_rate.dart';
import 'package:diam_mfg/screens/mst_firm_color.dart';
import 'package:diam_mfg/screens/mst_firm_department_rate.dart';
import 'package:diam_mfg/screens/mst_firm_dept_group.dart';
import 'package:diam_mfg/screens/mst_firm_dept_process.dart';
import 'package:diam_mfg/screens/mst_firm_article.dart';
import 'package:diam_mfg/screens/mst_firm_charni.dart';
import 'package:diam_mfg/screens/mst_firm_company.dart';
import 'package:diam_mfg/screens/mst_firm_divison.dart';
import 'package:diam_mfg/screens/mst_firm_employee.dart';
import 'package:diam_mfg/screens/mst_firm_factory.dart';
import 'package:diam_mfg/screens/mst_firm_factory_man_group.dart';
import 'package:diam_mfg/screens/mst_firm_factory_rate.dart';
import 'package:diam_mfg/screens/mst_firm_fluo.dart';
import 'package:diam_mfg/screens/mst_firm_intent.dart';
import 'package:diam_mfg/screens/mst_firm_jangad_charni.dart';
import 'package:diam_mfg/screens/mst_firm_certificate.dart';
import 'package:diam_mfg/screens/mst_firm_ls_party_wt_calc_entry.dart';
import 'package:diam_mfg/screens/mst_firm_over.dart';
import 'package:diam_mfg/screens/mst_firm_party.dart';
import 'package:diam_mfg/screens/mst_firm_polish.dart';
import 'package:diam_mfg/screens/mst_firm_purity.dart';
import 'package:diam_mfg/screens/mst_firm_purity_group.dart';
import 'package:diam_mfg/screens/mst_firm_purity_rpt_group.dart';
import 'package:diam_mfg/screens/mst_firm_rough_type.dart';
import 'package:diam_mfg/screens/mst_firm_holiday.dart';
import 'package:diam_mfg/screens/mst_firm_pc.dart';
import 'package:diam_mfg/screens/mst_firm_remarks.dart';
import 'package:diam_mfg/screens/mst_firm_sell_price.dart';
import 'package:diam_mfg/screens/mst_firm_shape_group.dart';
import 'package:diam_mfg/screens/mst_firm_symmetry.dart';
import 'package:diam_mfg/screens/mst_firm_team.dart';
import 'package:diam_mfg/screens/mst_firm_tensions.dart';
import 'package:diam_mfg/screens/trn_cut_create.dart';
import 'package:diam_mfg/screens/trn_factory_issue.dart';
import 'package:diam_mfg/screens/trn_jobwork_issue.dart';
import 'package:diam_mfg/screens/trn_jobwork_rec.dart';
import 'package:diam_mfg/screens/trn_laser_received.dart';
import 'package:diam_mfg/screens/trn_makable_entry.dart';
import 'package:diam_mfg/screens/trn_packet_create.dart';
import 'package:diam_mfg/screens/trn_planning_received.dart';
import 'package:diam_mfg/screens/trn_process_issue.dart';
import 'package:diam_mfg/screens/trn_rough_assort.dart';
import 'package:diam_mfg/screens/trn_rough_entry.dart';
import 'package:diam_mfg/screens/trn_spk_dept_iss.dart';
import 'package:rs_dashboard/rs_dashboard.dart';
import '../screens/dashboard_screen.dart';
import '../screens/mst_firm_dept.dart';
import '../screens/mst_firm_cut.dart';
import '../screens/mst_firm_shape.dart';
import '../screens/trn_factory_receive.dart';
import '../screens/user_master.dart';



class AppRouter {
  static final String intial='/1';
  static final RSDashboardRouter router = RSDashboardRouter({
    '/1': (context) => const DashboardScreen(),
    '/2.01': (context) => const MstFirmCompany(),
    '/2.02': (context) => const MstFirmParty(),
    '/2.03': (context) => const MstFirmFactory(),
    '/2.04': (context) => const MstFactoryManGroup(),
    '/2.05': (context) => const MstDivision(),
    '/2.06': (context) => const MstCut(),
    '/2.07': (context) => const MstRoughType(),
    '/2.08': (context) => const MstJangadCharni(),
    '/2.09': (context) => const MstCharni(),
    '/2.10': (context) => const MstArticle(),
    '/2.11': (context) => const MstPurityGroup(),
    '/2.12': (context) => const MstPurity(),
    '/2.13': (context) => const MstColor(),
    '/2.14': (context) => const MstShapeGroup(),
    '/2.15': (context) => const MstShape(),
    '/2.16': (context) => const MstDeptGroup(),
    '/2.17': (context) => const MstDept(),
    '/2.18': (context) => const MstDeptProcess(),
    '/2.19': (context) => const MstTensions(),
    '/2.20': (context) => const MstRemarks(),
    '/2.21': (context) => const MstFluo(),
    '/2.22': (context) => const MstHoliday(),
    '/2.23': (context) => const MstPurityRptGroup(),
    '/2.24': (context) => const MstPc(),
    '/2.25': (context) => const MstTeamEntry(),
    '/2.26': (context) => const MstCounter(),
    '/2.27': (context) => const MstEmployee(),
    '/2.28': (context) => const MstPolish(),
    '/2.29': (context) => const MstSymmetry(),
    '/2.30': (context) => const MstLsPartyWtCalcEntry(),
    '/2.31': (context) => const MstClvRate(),
    '/2.32': (context) => const MstLab(),
    '/2.33': (context) => const MstFactoryRate(),
    '/2.34': (context) => const MstDepartmentRate(),
    '/2.35': (context) => const MstIntent(),
    '/2.36': (context) => const MstOver(),
    '/2.37': (context) => const MstFColor(),
    '/2.38': (context) => const MstSellPrice(),
    '/3.01': (context) => const TrnRoughEntry(),
    '/3.02': (context) => const TrnRoughAssortEntry(),
    '/3.03': (context) => const TrnCutCreateEntry(),
    '/3.04': (context) => const TrnPacketCreateEntry(),
    '/3.05': (context) => const TrnSpkDeptIssEntry(),
    '/3.06': (context) => const TrnPlanningReceivedEntry(),
    '/3.07': (context) => const TrnLaserReceivedEntry(),
    '/3.08': (context) => const TrnMakableEntry(),
    '/3.09': (context) => const TrnFactoryIssueEntry(),
    '/3.10': (context) => const FactoryReceiveEntry(),
    '/3.11': (context) => const TrnProcessIssueEntry(),
    '/3.12': (context) => const TrnProcessIssueEntry(),
    '/3.13': (context) => const TrnJobWorkIssueEntry(),
    '/3.14': (context) => const TrnJobWorkRecEntry(),
    '/4': (context) => const AdminMenuCreateScreen(),
    '/4.01': (context) => const ReportScreen(),
    '/5.01': (context) => const PairScreen(),
    '/5.02': (context) => const PacketHistoryScreen(),
    '/5.03': (context) => const PacketDeleteScreen(),
    '/5.04': (context) => const PacketEditScreen(),
  });
}
