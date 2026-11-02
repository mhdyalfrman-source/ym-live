import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:tom_chat/controllers/general_controller.dart';
import 'package:tom_chat/core/utils/my_math.dart';
import 'package:tom_chat/core/utils/snakbar_dialog.dart';
import 'package:tom_chat/core/utils/wait_message.dart';
import 'package:tom_chat/features/settings/setting_screen.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/statics_values.dart';

class CallServerAPI {
  static final String com = 'http://104.207.90.135/yaumi/public/';
  static final String apiKey = "no09-adbz-pat0-ndbe";

  static Future<Map<String, dynamic>> post(
    String service,
    Map<String, dynamic> data, {
    int secounds = 20,
    int messageTime = 20,
    bool withSnakbar = false,
    String Function(String)? errorText,
    File? file,
    bool withMessage = true,
    bool returnAllResponse = false,
    String fileFieldName = 'file',
    String responseField = 'data',
    Function(double)? onProgress,
  }) async {
    if (file != null) {
      secounds = 1200;
    }
    if (withMessage) {
      waitMessage(messageTime);
    }
    http.Response response;

    try {
      // Ensure token exists before request
      // String token = "DPjgpCz8fZUrz4tF2BLdXrJqJ7yFnreJSxIpuYPOwiAZN04iaq";
      // String userID = "1";
      String token = StaticValue.userData.userToken ?? "";
      String? userID = StaticValue.userData.userId.toString();
      String? deviceID = StaticValue.userData.deviceId;
      String platform = Platform.isAndroid ? "android" : "ios";
      if (deviceID == null || deviceID.isEmpty) {
        deviceID = await getDeviceId();
      }
      Uri uri = Uri.parse("${com}api/$service");

      if (file == null) {
        response = await http
            .post(
              uri,
              headers: {
                "API-KEY": apiKey,
                "Auth-Token": token,
                // "Content-Type": "application/json",
              },
              body: jsonEncode({
                ...data.map((k, v) => MapEntry(k, v.toString())),
                "lang": StaticValue.language,
                "uid": userID,
                "device_id": deviceID,
                "platform": platform,
              }),
            )
            .timeout(Duration(seconds: secounds));
      } else {
        if (!await file.exists()) {
          throw Exception('File not found: ${file.path}');
        }
        final fileLength = await file.length();

        final request = http.MultipartRequest('POST', uri);

        request.headers.addAll({"API-KEY": apiKey, "Auth-Token": token});

        data.forEach((k, v) {
          if (v != null) request.fields[k] = v.toString();
        });
        request.fields['language'] = StaticValue.language;
        request.fields['uid'] = userID.toString();
        request.fields['device_id'] = deviceID.toString();
        request.fields['platform'] = platform;

        int uploaded = 0;
        int lastEmitMs = 0;
        Stream<List<int>> progressStream = file.openRead().transform(
          StreamTransformer.fromHandlers(
            handleData: (chunk, sink) {
              uploaded += chunk.length;
              final now = DateTime.now().millisecondsSinceEpoch;
              final p = fileLength > 0 ? uploaded / fileLength : 0.0;
              if (onProgress != null &&
                  (now - lastEmitMs > 200 ||
                      p >= 0.999 ||
                      uploaded == fileLength)) {
                lastEmitMs = now;
                onProgress(p.clamp(0.0, 1.0));
              }
              sink.add(chunk);
            },
          ),
        );

        final multipartFile = http.MultipartFile(
          fileFieldName,
          http.ByteStream(progressStream),
          fileLength,
          filename: file.path.split('/').last,
        );
        request.files.add(multipartFile);

        // أرسل الطلب مع مهلة
        final streamedResponse = await request.send().timeout(
          Duration(seconds: secounds),
        );

        // اجمع الاستجابة
        response = await http.Response.fromStream(streamedResponse);

        // ضمن 100% لو ما انطلقت بالثروتل
        if (onProgress != null) onProgress(1.0);
      }
      print("response ${response.body}");
      GeneralController controller = Get.find();
      if (withMessage && controller.currentDialog == "WAIT") {
        Get.back();
        controller.currentDialog = "";
      }
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final code = int.tryParse(body["code"].toString());
        if (code == 200) {
          if (body[responseField] is Map<String, dynamic>) {
            Map<String, dynamic> result = returnAllResponse
                ? body
                : body[responseField];
            if (result.containsKey("coins")) {
              StaticValue.coins.value = MyMath.toInt(
                result["coins"],
                defaultVal: StaticValue.coins.value,
              );
            }
            if (result.containsKey("diamond")) {
              StaticValue.diamond.value = MyMath.toInt(
                result["diamond"],
                defaultVal: StaticValue.diamond.value,
              );
            }
            return result;
          } else if (body[responseField] == null) {
            return {};
          } else {
            String errorMessage = '';
            if (body['msg'] != null) {
              if (body['msg'] is List) {
                errorMessage += (body['msg'] as List)
                    .map((e) => e.toString())
                    .join(',');
              } else if (body['msg'] is String) {
                errorMessage += body['msg'] as String;
              }
            }
            if (withSnakbar) {
              snakbarDialog(
                title:
                    errorText?.call(errorMessage) ??
                    (errorMessage.isEmpty
                        ? 'Unexpected data format'
                        : errorMessage),
                durationSecound: 5,
              );
            }
          }
        } else if (code == 201) {
          return body;
        } else if (code == 310) {
          await logout();
          snakbarDialog(
            title: Get.context!.l10n.thisAccountUnderBannded,
            durationSecound: 10,
          );
        } else {
          String errorMessage = '';
          if (body['msg'] != null) {
            if (body['msg'] is List) {
              errorMessage += (body['msg'] as List)
                  .map((e) => e.toString())
                  .join(',');
            } else if (body['msg'] is String) {
              errorMessage += body['msg'] as String;
            }
          }
          if (withSnakbar) {
            snakbarDialog(
              title: errorText?.call(errorMessage) ?? errorMessage,
              durationSecound: 5,
            );
          }
        }
      } else {}
    } catch (e) {
      // GeneralController controller = Get.find();
      // if(withMessage && controller.currentDialog == "WAIT"){
      //   Get.back();
      // }
    }

    return {};
  }

  static Future<bool> put(
    String uri,
    File file, {
    String type = "image/png",
  }) async {
    try {
      var request = http.Request('PUT', Uri.parse(uri.replaceAll(r'\', '')))
        ..headers.addAll({'Content-Type': type, 'x-amz-acl': 'public-read'})
        ..bodyBytes = await file.readAsBytes();
      var response = await request.send();
      if (response.statusCode == 200) {
        return true;
      } else {}
    } catch (e) {}
    return false;
  }
}
