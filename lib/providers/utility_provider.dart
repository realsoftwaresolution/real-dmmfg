import 'package:diam_mfg/models/verify_state_request_model.dart';
import 'package:rs_dashboard/rs_dashboard.dart';

class UtilityProvider extends BaseProvider {
  Future<bool> verifyState({
    required VerifyStateRequestModel model,
  }) async {
    final result = await request<bool>(
      call: () => api.post(
        '/utility/verify-state',
        data: model.toJson(),
      ),
      onSuccess: (res) {
        return res.data == true;
      },
    );

    return result ?? false;
  }
}