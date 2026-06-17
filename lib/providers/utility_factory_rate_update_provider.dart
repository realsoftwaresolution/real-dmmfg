import 'package:diam_mfg/utils/msg_dialogue.dart';
import 'package:flutter/cupertino.dart';
import 'package:rs_dashboard/rs_dashboard.dart';
import '../models/factory_rate_update_model.dart';

class UtilityFactoryRateUpdateProvider extends BaseProvider {
  List<FactoryRateUpdateModel> recalculationData = [];
  bool showRecalculationButton = false;

  Future<void> clvDeptRateUpdate(
    Map<String, dynamic> formValues,
    BuildContext context,
  ) async {
    await request(
      showLoader: true,
      call: () => api.post('/factoryRec/recalculate', data: formValues),
      onSuccess: (res) async {
        if (res.data['success'] == false) {
          recalculationData.clear();
          showRecalculationButton = false;
          notifyListeners();

          await ErpResultDialog.showError(
            context: context,
            theme: context.erpTheme,
            title: 'Error',
            message: res.data['message'],
          );
        } else {
          recalculationData = (res.data['data'] as List<dynamic>)
              .map(
                (e) => FactoryRateUpdateModel.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList();

          showRecalculationButton = recalculationData.isNotEmpty;

          notifyListeners();

          await ErpResultDialog.showSuccess(
            context: context,
            theme: context.erpTheme,
            title: 'Success',
            message: res.data['message'],
          );
        }
      },
    );
  }

  void hideRecalculation() {
    recalculationData.clear();
    showRecalculationButton = false;
    notifyListeners();
  }
}
