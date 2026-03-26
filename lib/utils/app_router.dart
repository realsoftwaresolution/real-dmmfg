import 'package:diam_mfg/screens/mst_firm_color.dart';
import 'package:diam_mfg/screens/mst_firm_dept_group.dart';
import 'package:diam_mfg/screens/mst_firm_dept_process.dart';
import 'package:diam_mfg/screens/mst_firm_article.dart';
import 'package:diam_mfg/screens/mst_firm_charni.dart';
import 'package:diam_mfg/screens/mst_firm_company.dart';
import 'package:diam_mfg/screens/mst_firm_divison.dart';
import 'package:diam_mfg/screens/mst_firm_employee.dart';
import 'package:diam_mfg/screens/mst_firm_factory.dart';
import 'package:diam_mfg/screens/mst_firm_factory_man_group.dart';
import 'package:diam_mfg/screens/mst_firm_fluo.dart';
import 'package:diam_mfg/screens/mst_firm_jangad_charni.dart';
import 'package:diam_mfg/screens/mst_firm_party.dart';
import 'package:diam_mfg/screens/mst_firm_purity.dart';
import 'package:diam_mfg/screens/mst_firm_purity_group.dart';
import 'package:diam_mfg/screens/mst_firm_purity_rpt_group.dart';
import 'package:diam_mfg/screens/mst_firm_rough_type.dart';
import 'package:diam_mfg/screens/mst_firm_holiday.dart';
import 'package:diam_mfg/screens/mst_firm_pc.dart';
import 'package:diam_mfg/screens/mst_firm_remarks.dart';
import 'package:diam_mfg/screens/mst_firm_shape_group.dart';
import 'package:diam_mfg/screens/mst_firm_team.dart';
import 'package:diam_mfg/screens/mst_firm_tensions.dart';
import 'package:diam_mfg/screens/trn_cut_create.dart';
import 'package:diam_mfg/screens/trn_packet_create.dart';
import 'package:diam_mfg/screens/trn_rough_assort.dart';
import 'package:diam_mfg/screens/trn_rough_entry.dart';
import 'package:diam_mfg/screens/trn_spk_dept_iss.dart';
import 'package:rs_dashboard/rs_dashboard.dart';

import '../screens/dashboard_screen.dart';
import '../screens/mst_firm_dept.dart';
import '../screens/mst_firm_cut.dart';
import '../screens/mst_firm_shape.dart';
import '../screens/user_master.dart';



class AppRouter {
  static final String intial='/1';
  static final RSDashboardRouter router = RSDashboardRouter({

    '/1': (context) => const DashboardScreen(),

    '/2.1': (context) => const MstFirmCompany(),
    '/2.2': (context) => const MstFirmParty(),
    '/2.3': (context) => const MstFirmFactory(),
    '/2.4': (context) => const MstFactoryManGroup(),
    '/2.5': (context) => const MstDivision(),
    '/2.6': (context) => const MstCut(),
    '/2.7': (context) => const MstRoughType(),
    '/2.8': (context) => const MstJangadCharni(),
    '/2.9': (context) => const MstCharni(),
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
    '/3.1': (context) => const TrnRoughEntry(),
    '/3.2': (context) => const TrnRoughAssortEntry(),
    '/3.3': (context) => const TrnCutCreateEntry(),
    '/3.4': (context) => const TrnPacketCreateEntry(),
    '/3.5': (context) => const TrnSpkDeptIssEntry(),

  });


}
