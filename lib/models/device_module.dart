class DeviceInfoModule {
  String? deviceUUID;
  String? brand;
  String? deviceName;
  String? platform;
  String? model;
  String? serialNumber;
  String? systemVersion;
  String? productId;
  String? userName;
  String? packageVersion;
  String? buildNumber;
  String? buildID;

  DeviceInfoModule({
    this.deviceUUID,
    this.brand,
    this.deviceName,
    this.platform,
    this.model,
    this.serialNumber,
    this.systemVersion,
    this.productId,
    this.userName,
    this.packageVersion,
    this.buildNumber,
    this.buildID,
  });

  DeviceInfoModule.fromJson(Map<String, dynamic> json)
    : deviceUUID = json["deviceUUID"],
      brand = json["brand"],
      deviceName = json["deviceName"],
      platform = json["platform"],
      model = json["model"],
      serialNumber = json["serialNumber"],
      systemVersion = json["systemVersion"],
      productId = json["productId"],
      userName = json["userName"],
      packageVersion = json["packageVersion"],
      buildNumber = json["buildNumber"],
      buildID = json["buildID"];

  Map<String, String?> toJson() {
    return {
      "deviceUUID": deviceUUID,
      "brand": brand,
      "deviceName": deviceName,
      "platform": platform,
      "model": model,
      "serialNumber": serialNumber,
      "systemVersion": systemVersion,
      "productId": productId,
      "userName": userName,
      "packageVersion": packageVersion,
      "buildNumber": buildNumber,
      "buildID": buildID,
    };
  }

  bool compare(DeviceInfoModule d) {
    if (d.buildID != null && d.buildID == buildID) {
      return true;
    }
    if (d.deviceUUID != null && d.deviceUUID?.trim() == deviceUUID?.trim()) {
      return true;
    }
    return false;
  }
}
