import 'package:diam_mfg/models/verify_state_request_model.dart';
import 'package:diam_mfg/providers/utility_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<bool> verifyBCodeState({
  required BuildContext context,
  required List<int> bCodeArray,
  required int expectedMstId,
  required String expectedProcess,
}) async {
  final model = VerifyStateRequestModel(
    bCodeArray: bCodeArray,
    expectedMstId: expectedMstId,
    expectedProcess: expectedProcess,
  );

  final success = await context
      .read<UtilityProvider>()
      .verifyState(model: model);

  return success;
}