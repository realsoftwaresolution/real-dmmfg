import 'package:dio/dio.dart';
import 'package:diam_mfg/models/job_work_rec_model.dart';
import 'package:diam_mfg/utils/msg_dialogue.dart';
import 'package:diam_mfg/utils/process_constants.dart';
import 'package:rs_dashboard/rs_dashboard.dart';

class JobWorkRecEntryProvider extends BaseProvider {
  List<JobWorkRecMstModel> _list = [];
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  List<JobWorkRecMstModel> get list => List.unmodifiable(_list);

  // Detail Map cache
  Map<int, List<JobWorkRecDetModel>> detMap = {};

  // ── UPLOAD MEDIA ───────────────────────────────────────────────────────────
  Future<bool> uploadMedia({
    required String bCode,
    required String mediaType,
    required dynamic fileVal,
    dynamic theme,
    dynamic context,
  }) async {
    if (fileVal == null) return true;

    try {
      final List<dynamic> rawList = fileVal is List ? fileVal : [fileVal];
      final List<dynamic> fileList = [];

      void flatten(dynamic input) {
        if (input is List) {
          for (final e in input) {
            flatten(e);
          }
        } else if (input is String) {
          final s = input.trim();
          if (s.startsWith('[') && s.endsWith(']')) {
            final inner = s.substring(1, s.length - 1);
            for (final part in inner.split(',')) {
              if (part.trim().isNotEmpty) flatten(part.trim());
            }
          } else if (s.contains(',')) {
            for (final part in s.split(',')) {
              if (part.trim().isNotEmpty) flatten(part.trim());
            }
          } else if (s.isNotEmpty && s != 'null' && s != '[]') {
            fileList.add(s);
          }
        } else if (input != null) {
          fileList.add(input);
        }
      }
      flatten(rawList);

      final List<MultipartFile> multipartFiles = [];

      for (final item in fileList) {
        if (item == null) continue;
        final mp = await _createMultipartFile(item, mediaType: mediaType);
        if (mp != null) {
          multipartFiles.add(mp);
        }
      }

      if (multipartFiles.isEmpty) {
        return true;
      }

      final formData = FormData();
      formData.fields.add(MapEntry('BCode', bCode.toString()));
      formData.fields.add(MapEntry('MediaType', mediaType));
      for (final mp in multipartFiles) {
        formData.files.add(MapEntry('files', mp));
      }

      final result = await request<bool>(
        call: () => api.post(
          '/media/upload',
          data: formData,
        ),
        onSuccess: (res) {
          final data = res.data;
          if (data is Map && data['success'] == false) {
            if (context != null && theme != null) {
              ErpResultDialog.showError(
                context: context,
                theme: theme,
                message: data['message']?.toString() ?? 'Media upload failed',
              );
            }
            return false;
          }
          return true;
        },
      );

      return result ?? false;
    } catch (e) {
      if (context != null && theme != null) {
        ErpResultDialog.showError(
          context: context,
          theme: theme,
          message: 'Error uploading $mediaType: $e',
        );
      }
      return false;
    }
  }

  Future<MultipartFile?> _createMultipartFile(dynamic fileObj, {String? mediaType}) async {
    if (fileObj == null) return null;
    try {
      if (fileObj is MultipartFile) {
        return fileObj;
      }

      dynamic bytes;
      dynamic name;
      dynamic path;

      if (fileObj is Map) {
        bytes = fileObj['bytes'] ?? fileObj['data'];
        name = fileObj['name'] ?? fileObj['filename'] ?? fileObj['fileName'];
        path = fileObj['path'] ?? fileObj['filePath'];
        if (bytes == null && fileObj['file'] != null) {
          return await _createMultipartFile(fileObj['file'], mediaType: mediaType);
        }
      } else {
        // 1. Try bytes property (PlatformFile, custom file object)
        try {
          bytes = (fileObj as dynamic).bytes;
        } catch (_) {}

        // 2. Try readAsBytes() method (XFile, etc.)
        if (bytes == null) {
          try {
            bytes = await (fileObj as dynamic).readAsBytes();
          } catch (_) {}
        }

        // Try getting filename & path
        try {
          name = (fileObj as dynamic).name ?? (fileObj as dynamic).filename;
        } catch (_) {}

        try {
          path = (fileObj as dynamic).path;
        } catch (_) {}
      }

      if (path == null && fileObj is String) {
        path = fileObj;
      }

      String defaultExt = '.png';
      if (mediaType != null) {
        final mt = mediaType.toUpperCase();
        if (mt.contains('VIDEO')) {
          defaultExt = '.mp4';
        } else if (mt.contains('CERTIFICATE') || mt.contains('IMAGE')) {
          defaultExt = '.png';
        }
      }

      String getValidFilename(dynamic originalName, String fallbackPrefix) {
        final strName = (originalName ?? '').toString().trim();
        if (strName.isNotEmpty && strName.contains('.')) {
          final ext = strName.split('.').last.toLowerCase();
          if (ext == 'pdf' || ext == 'jpg' || ext == 'jpeg' || ext == 'png' || ext == 'webp' || ext == 'mp4' || ext == 'avi' || ext == 'mov') {
            return strName;
          }
          return '$strName$defaultExt';
        }
        final base = strName.isNotEmpty ? strName : '${fallbackPrefix}_${DateTime.now().millisecondsSinceEpoch}';
        return '$base$defaultExt';
      }

      if (bytes != null && bytes is List<int>) {
        final fileName = getValidFilename(name, 'file');
        return MultipartFile.fromBytes(bytes, filename: fileName);
      }

      if (path != null && path.toString().isNotEmpty) {
        final strPath = path.toString().trim();
        if (strPath.startsWith('blob:') || strPath.startsWith('http')) {
          try {
            final response = await Dio().get<List<int>>(
              strPath,
              options: Options(responseType: ResponseType.bytes),
            );
            if (response.data != null && response.data!.isNotEmpty) {
              final fileName = getValidFilename(name, 'file');
              return MultipartFile.fromBytes(response.data!, filename: fileName);
            }
          } catch (e) {
            print('Error fetching blob data from $strPath: $e');
          }
        } else {
          final fileName = getValidFilename(name ?? strPath.split('/').last.split('\\').last, 'file');
          return await MultipartFile.fromFile(strPath, filename: fileName);
        }
      }
    } catch (e) {
      print('Error creating MultipartFile: $e');
    }
    return null;
  }

  // ── LOAD DETAILS ───────────────────────────────────────────────────────────
  Future<List<JobWorkRecDetModel>> loadDetails(int mstID) async {
    final result = await request<List<JobWorkRecDetModel>>(
      call: () => api.get('/jobWorkRec/$mstID'),
      onSuccess: (res) {
        final json = res.data as Map<String, dynamic>;
        final data = json['data']['details'] as List;

        return data
            .map(
              (e) => JobWorkRecDetModel.fromJson(e as Map<String, dynamic>),
        )
            .toList();
      },
    );

    final dets = result ?? [];
    detMap[mstID] = dets;
    notifyListeners();

    return dets;
  }

  // ── LOAD SUMMARY REPORT ────────────────────────────────────────────────────
  Future<JobWorkRecSummaryModel?> loadSummaryReport(int mstID) async {
    final result = await request<JobWorkRecSummaryModel>(
      call: () => api.get('/jobWorkRec/$mstID?isSummary=true'),
      onSuccess: (res) {
        final json = res.data as Map<String, dynamic>;
        return JobWorkRecSummaryModel.fromJson(json);
      },
    );
    return result;
  }

  // ── LOAD ALL ───────────────────────────────────────────────────────────────
  Future<void> load() async {
    final result = await request<List<JobWorkRecMstModel>>(
      call: () => api.get('/jobWorkRec'),
      onSuccess: (res) {
        final list = res.data['data'] as List;
        return list
            .map(
              (e) => JobWorkRecMstModel.fromJson(e as Map<String, dynamic>),
        )
            .toList();
      },
    );
    if (result != null) {
      _list = result;
      _isLoaded = true;
      notifyListeners();
    }
  }

  // ── FETCH BY BCODE ─────────────────────────────────────────────────────────
  Future<List<JobWorkRecDetModel>> fetchByBCode({
    required String bCode,
    required  partyMst,
    required  deptProcessCode,
  }) async {
    final result = await request<List<JobWorkRecDetModel>>(
      showLoader: false,
      call: () => api.get('/jobWorkRec/scan-bcode/$partyMst/$bCode'),
      onSuccess: (res) {
        final data = res.data['data'];
        final list = data is List ? data : [data];
        return list
            .map(
              (e) => JobWorkRecDetModel.fromJson(e as Map<String, dynamic>),
        )
            .toList();
      },
    );
    return result ?? [];
  }

  // ── CREATE ─────────────────────────────────────────────────────────────────
  Future<JobWorkRecMstModel?> create(Map<String, dynamic> payload) async {
    final result = await request<JobWorkRecMstModel>(
      call: () => api.post(
        '/jobWorkRec',
        data: payload, // ✅ Direct payload matching API structure
      ),
      onSuccess: (res) => _parseMstResponse(res.data),
    );

    if (result != null) {
      final existingIdx = _list.indexWhere(
            (e) => e.jobWorkRecMstID == result.jobWorkRecMstID,
      );
      if (existingIdx >= 0) {
        _list[existingIdx] = result;
      } else {
        _list.insert(0, result);
      }
      notifyListeners();
      return result;
    }
    return null;
  }

// ── UPDATE ────────────────────────────────────────────────────────────────
  Future<bool> update(Map<String, dynamic> values, theme,
      context,) async {
    final result = await request<JobWorkRecMstModel>(
      call: () => api.put('/jobWorkRec/update', data: values),
      onSuccess: (res) {
        final data = res.data;
        if (data['success'] == false) {
          ErpResultDialog.showError(
            context: context,
            theme: theme,
            message: data['message'],
          );
          return data;
        }
        return _parseMstResponse(data);
      },
    );
    if (result != null) {
      notifyListeners();
      return true;
    }
    return false;
  }
  // ── DELETE ROW ─────────────────────────────────────────────────────────────
  Future<bool> deleteRow(
      int mstID,
      int detID,
      int bCode, {
        required dynamic theme,
        required dynamic context,
      }) async {
    final result = await request<bool>(
      call: () => api.delete(
        '/jobWorkRec/$mstID/$detID/$bCode',
        data: {
          'expectedProcess': ProcessConstants.jobWorkRec,
        },
      ),
      onSuccess: (res) {
        final data = res.data;
        if (data['success'] == false) {
          ErpResultDialog.showError(
            context: context,
            theme: theme,
            message: data['message'],
          );
          return false;
        }
        return true;
      },
    );

    if (result == true) {
      detMap.remove(mstID);
      notifyListeners();
      return true;
    }
    return false;
  }

  // ── DELETE MASTER ──────────────────────────────────────────────────────────
  Future<bool> delete(
      int mstID, {
        required dynamic theme,
        required dynamic context,
        bCodeArray
      }) async {
    final result = await request<bool>(
      call: () => api.delete(
        '/jobWorkRec/all/$mstID',
        data: {
          'expectedProcess': ProcessConstants.jobWorkRec,
          'bCodeArray': bCodeArray,
        },
      ),
      onSuccess: (res) {
        final data = res.data;
        if (data['success'] == false) {
          ErpResultDialog.showError(
            context: context,
            theme: theme,
            message: data['message'],
          );
          return false;
        }
        return true;
      },
    );

    if (result == true) {
      _list.removeWhere((e) => e.jobWorkRecMstID == mstID);
      detMap.remove(mstID);
      notifyListeners();
      return true;
    }
    return false;
  }

  // ── PARSE RESPONSE ─────────────────────────────────────────────────────────
  JobWorkRecMstModel _parseMstResponse(dynamic data) {
    if (data is Map) {
      Map<String, dynamic> mstJson;
      if (data.containsKey('mst')) {
        mstJson = Map<String, dynamic>.from(data['mst'] as Map);
        final rawDet = data['details'] as List? ?? [];

        // Calculate totals from details
        mstJson['TotalPc'] = rawDet.fold<int>(
          0,
              (s, d) => s + ((d['Pc'] ?? 0) as num).toInt(),
        );
        mstJson['TotalWt'] = rawDet.fold<double>(
          0.0,
              (s, d) => s + ((d['Wt'] ?? 0) as num).toDouble(),
        );
        mstJson['TotalPairNo'] = rawDet.fold<int>(
          0,
              (s, d) => s + ((d['PairNo'] ?? 0) as num).toInt(),
        );
      } else if (data.containsKey('data')) {
        final d = data['data'];
        if (d is Map) {
          mstJson = Map<String, dynamic>.from(d);
        } else {
          mstJson = Map<String, dynamic>.from(data);
        }
      } else {
        mstJson = Map<String, dynamic>.from(data);
      }
      return JobWorkRecMstModel.fromJson(mstJson);
    }
    throw Exception('Unexpected response format');
  }
}