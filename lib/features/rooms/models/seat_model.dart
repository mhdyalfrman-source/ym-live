import 'package:tom_chat/core/utils/my_math.dart';
import 'package:tom_chat/models/user/user_model.dart';

class SeatModel {
  final int seatNumber;
  final bool isHost;
  final double percentageSize;
  StatePosition? micState;
  StatePosition? seatState;
  UserModel? user;
  String? emoji;
  int score;

  SeatModel({
    required this.seatNumber,
    required this.isHost,
    required this.percentageSize,
    this.micState,
    this.seatState,
    this.user,
    this.emoji,
    this.score = 0,
  });

  factory SeatModel.fromJson(Map<String, dynamic> json) {
    if ((json['state'] ?? -1) < 0) json['state'] = 0;
    return SeatModel(
      seatNumber: MyMath.toInt(json['pos']),
      score: MyMath.toInt(json['score']),
      isHost: json['isHost'] ?? false,
      percentageSize: MyMath.toDouble(json['percentageSize']),
      user: json['user'] != null ? UserModel.fromMap(json["user"]) : null,
      micState: json['mute'] != null
          ? StatePosition.values[MyMath.toInt(json['mute'])]
          : null,
      seatState: json['state'] != null
          ? StatePosition.values[MyMath.toInt(json['state'])]
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'seatNumber': seatNumber,
      'isHost': isHost,
      'percentageSize': percentageSize,
      'user': user?.toMap(),
      'micState': micState?.index,
      'state': seatState?.index,
      'score': score,
    };
  }

  SeatModel copyWith({
    int? seatNumber,
    bool? isHost,
    double? percentageSize,
    UserModel? user,
    StatePosition? micState,
    StatePosition? seatState,
    StatePosition? camState,
  }) {
    return SeatModel(
      seatNumber: seatNumber ?? this.seatNumber,
      isHost: isHost ?? this.isHost,
      percentageSize: percentageSize ?? this.percentageSize,
      user: user ?? this.user,
      micState: micState ?? this.micState,
      seatState: seatState ?? this.seatState,
    );
  }
}

enum StatePosition {
  open(0),
  closed(1),
  locked(2);

  final int value;
  const StatePosition(this.value);
}
