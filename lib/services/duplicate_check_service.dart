import 'package:diam_mfg/utils/msg_dialogue.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../bootstrap.dart';
import 'package:rs_dashboard/rs_dashboard.dart';


Future<bool> checkDuplicateRecord({
  required String formName,
  required Map<dynamic, dynamic> fields,
  required BuildContext context,
  required ErpTheme theme,
   bool isComposite = false,
}) async {

  return await DuplicateCheckService.checkExists(
    context: context,
    theme: theme,
    formName: formName,
    fields: fields,
    isComposite: isComposite,
  );
}


class DuplicateCheckService {

  static Future<bool> checkExists({
    required BuildContext context,
    required ErpTheme theme,
    required String formName,
    required Map<dynamic, dynamic> fields,
    bool isComposite = false,
  }) async {
    try {
      final dio = Dio();

      dynamic token = AppStorage.getString("token");

      final response = await dio.post(
        '$baseUrl/utility/check-exists',
        data: {
          "formName": formName,
          "fields": fields,
          if(isComposite)
          "isComposite": isComposite,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      final data = response.data;

      /// ✅ DUPLICATE FOUND
      if (data['exists'] == true) {
        await ErpResultDialog.showError(
          context: context,
          theme: theme,
          title: 'Duplicate Found',
          message: '${data['message'] ?? 'Record already exists' } ${fields.keys}' ,
        );
        return true;
      }
      return false;
    } on DioException catch (e) {
      String msg = 'Something went wrong';
      if (e.response != null) {
        msg =
            e.response?.data?['message'] ??
                e.response?.statusMessage ??
                msg;
      }
      await ErpResultDialog.showError(
        context: context,
        theme: theme,
        title: 'API Error',
        message: msg,
      );
      return true;
    } catch (e) {
      await ErpResultDialog.showError(
        context: context,
        theme: theme,
        title: 'Error',
        message: e.toString(),
      );
      return true;
    }
  }
}