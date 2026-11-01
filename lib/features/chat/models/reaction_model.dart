class ReactionModel {
  final String emoji;
  final int uid;

  ReactionModel({required this.emoji, required this.uid});

  Map<String, dynamic> toJson() {
    return {'emoji': emoji, 'uid': uid};
  }

  ReactionModel copyWith({String? emoji, int? uid}) {
    return ReactionModel(emoji: emoji ?? this.emoji, uid: uid ?? this.uid);
  }

  factory ReactionModel.fromJson(Map<String, dynamic> json) {
    return ReactionModel(emoji: json['emoji'] ?? '', uid: json['uid'] ?? 0);
  }
}
