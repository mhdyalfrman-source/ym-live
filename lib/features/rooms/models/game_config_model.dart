// class GameConfigModel {
//   final String? appChannel;
//   final String? appId;
//   final String? userId;
//   final String? code;
//   final String? roomId;
//   final String? gameMode;
//   final String? language;
//   final SceneConfigModel? gameConfig;
//   final String? gsp;

//   GameConfigModel({
//     this.appChannel,
//     this.appId,
//     this.userId,
//     this.code,
//     this.roomId,
//     this.gameMode,
//     this.language,
//     this.gameConfig,
//     this.gsp,
//   });

//   factory GameConfigModel.fromJson(Map<String, dynamic> json) {
//     return GameConfigModel(
//       appChannel: json['appchannel']?.toString() ?? '',
//       appId: json['appid']?.toString() ?? '',
//       userId: json['userId']?.toString() ?? '',
//       code: json['code']?.toString() ?? '',
//       roomId: json['roomId']?.toString() ?? '',
//       gameMode: json['gameMode']?.toString() ?? '',
//       language: json['language']?.toString() ?? '',
//       gameConfig: json['gameConfig'] != null
//           ? SceneConfigModel.fromJson(json['gameConfig'])
//           : null,
//       gsp: json['gsp']?.toString() ?? '',
//     );
//   }
// }

// class SceneConfigModel {
//   final String? sceneMode;
//   final String? currencyIcon;

//   SceneConfigModel({
//     this.sceneMode,
//     this.currencyIcon,
//   });

//   factory SceneConfigModel.fromJson(Map<String, dynamic> json) {
//     return SceneConfigModel(
//       sceneMode: json['sceneMode']?.toString() ?? '',
//       currencyIcon: json['currencyIcon']?.toString() ?? '',
//     );
//   }
// }

class GameConfigModel {
  final String? token;
  final String? appId;
  final String? appKey;
  final String? roomNum;

  GameConfigModel({this.token, this.appId, this.appKey, this.roomNum});

  factory GameConfigModel.fromJson(Map<String, dynamic> json) {
    return GameConfigModel(
      token: json['token']?.toString() ?? '',
      appId: json['app_id']?.toString() ?? '',
      appKey: json['app_key']?.toString() ?? '',
      roomNum: json['room_num']?.toString() ?? '',
    );
  }
}
