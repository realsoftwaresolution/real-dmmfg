import 'dart:typed_data';
import 'package:diam_mfg/bootstrap.dart';
import 'package:universal_html/html.dart' as html;

import 'package:dio/dio.dart';

Future<void> openPdf({
  required List<dynamic> bCodeArray,
  required String token,
  required String apiName,
}) async {

  try {

    final dio = Dio();

    final response = await dio.post(

      '${baseUrl}/${apiName}/generate-bcode',

      data: {
        "bcodes": bCodeArray,
      },

      options: Options(

        responseType: ResponseType.bytes,

        headers: {

          'Content-Type': 'application/json',

          'Accept': 'application/pdf',

          'Authorization': 'Bearer $token',
        },
      ),
    );

    final Uint8List pdfBytes = Uint8List.fromList(
      List<int>.from(response.data),
    );

    final blob = html.Blob(
      [pdfBytes],
      'application/pdf',
    );

    final url = html.Url.createObjectUrlFromBlob(
      blob,
    );

    html.window.open(
      url,
      '_blank',
    );

    Future.delayed(
      const Duration(seconds: 10),
          () {
        html.Url.revokeObjectUrl(url);
      },
    );

  } catch (e) {

    print('PDF Error: $e');
  }
}