import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:tom_chat/core/utils/device_information.dart';
import 'package:tom_chat/statics_values.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';

// this works with API
getRequest(String url) async {
  try {
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var responsebody = jsonDecode(response.body);
      return responsebody;
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}

postRequest(String url, Map data) async {
  try {
    var response = await http.post(Uri.parse(url), body: data);
    if (response.statusCode == 200) {
      var responsebody = jsonDecode(response.body);
      return responsebody;
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}

Future postRequestWithoutBody(String url) async {
  try {
    var response = await http.post(Uri.parse(url));
    if (response.statusCode == 200) {
      var responsebody = jsonDecode(response.body);
      return responsebody;
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}

requestPermission() async {
  var status = await Permission.camera.status;
  if (!status.isGranted) {
    await Permission.camera.request();
  }

  var status1 = await Permission.photos.status;
  if (!status1.isGranted) {
    await Permission.photos.request();
  }
  // var status1 = await Permission.storage.status;
  // if(!status1.isGranted){
  //   await Permission.storage.request();
  // }

  // var status3 = await Permission.manageExternalStorage.status;
  // if(!status3.isGranted){
  //   await Permission.manageExternalStorage.request();
  // }
}

requestStoragePermission() async {
  // var status1 = await Permission.storage.status;
  // if(!status1.isGranted){
  //   await Permission.storage.request();
  // }

  var status2 = await Permission.manageExternalStorage.status;
  if (!status2.isGranted) {
    await Permission.manageExternalStorage.request();
  }
  var status3 = await Permission.storage.status;
  if (!status3.isGranted) {
    // await Permission.manageExternalStorage.request();
    await Permission.storage.request();
  }
}

requestCameraPermission() async {
  var status = await Permission.camera.status;
  if (!status.isGranted) {
    await Permission.camera.request();
  }
}

checkPermission() async {
  if (Platform.isAndroid || Platform.isIOS) {
    var status = await Permission.camera.status;

    var status1 = await Permission.photos.status;
    // var status1 = await Permission.storage.status;

    // var status2 = await Permission.manageExternalStorage.status;
    return status.isGranted && status1.isGranted; //&& status2.isGranted;
  }
  return true;
}

checkCameraPermission() async {
  var status = await Permission.camera.status;
  return status.isGranted;
}

Future<bool> checkStoragePermission() async {
  if (await DeviceInformationHelper.getAndroidVersion() > 32) {
    return true;
  }
  var status = await Permission.storage.status;
  var status2 = await Permission.manageExternalStorage.status;
  return status.isGranted || status2.isGranted;
}

Future<String> postRequestWithFile(
  String type,
  String id,
  File file, [
  String? lastFileName,
]) async {
  try {
    if (file.path != '' && file.path != lastFileName) {
      var request = http.MultipartRequest(
        "POST",
        Uri.parse("${StaticValue.serverPath}upload_image.php"),
      );

      var length = await file.length();
      var stream = http.ByteStream(file.openRead());
      // String fileName = basename(file.path) + DateFormat("yyyy-MM-ddHH:mm:ss").format(DateTime.now());
      String fileName = "$id${extension(file.path)}";
      var multiPartFile = http.MultipartFile(
        "image",
        stream,
        length,
        filename: fileName,
      );
      request.files.add(multiPartFile);
      request.fields["type"] = type;
      request.fields["last_image"] = lastFileName ?? "";
      var myRequest = await request.send();

      var response = await http.Response.fromStream(myRequest);
      if (myRequest.statusCode == 200 &&
          jsonDecode(response.body)["operator"] != "FAILED") {
        return "$type/$fileName";
      } else {
        return "";
      }
    }
    return "";
  } catch (e) {
    return "";
  }
}

// String _basicAuth = 'Basic ' +
//   base64Encode(utf8.encode(
//       'hamod:mero@ahmed'));

//   Map<String, String> myheaders = {
//         'authorization': _basicAuth
//       };

Map<String, String> myheaders = {
  "Content-Type": "application/json",
  'Authorization':
      "key = AAAAfafGCl4:APA91bGWetA15WLoMMi4cbBfJ90jEJJiJXgHokCqg4MsnBKJMbSoUCJjnQpHS2p0WoVlC3CdMspEm8pXyAd7OwtzEBCuvA8K0lSo53Y2p_ImAaIBJ7zlFLtg-iWcRRZhrx6dmaXZXed2",
};

//  await sendNotification(["e955uzgtRFqbstfbFeh8Zj:APA91bERZijDyTYSG5gvzLr_rm8T8iB24lPWT9XLtHLW1jzN-NnQUnGDByKviQHWv2lDPh20ljY_8kICv6mx90zl2cIIiT4xyun2Yc5p6i_dtS01tGgNggZtiUGVGUmjSGgi1tPdz67h"],

sendNotification(List<String> tokents, String title, String subtitle) async {
  try {
    var response = await http.post(
      Uri.parse("https://fcm.googleapis.com/fcm/send"),
      body: json.encode({
        "registration_ids": [...tokents],
        "notification": {"body": subtitle, "title": title},
      }),
      headers: myheaders,
      encoding: Encoding.getByName("utf-8"),
    );
    if (response.statusCode == 200) {
      var responsebody = jsonDecode(response.body);
      return responsebody;
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}

bool getFromBoolOrInt(value) {
  if (value is int) {
    return value == 1;
  }
  if (value is bool) {
    return value;
  }
  return value == "1" || value == "true";
}

convertBoolToInt(value) {
  if (value is bool) {
    return value ? "1" : "0";
  }
}

getFromDate(value) {
  if (value == null) {
    return null;
  }
  return DateTime.tryParse(value);
}
