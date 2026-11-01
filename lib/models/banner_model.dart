class BannerModel {
  final int id;
  final int type;
  final String img;
  final String url;
  final String? expiredTime;

  BannerModel({
    required this.id,
    required this.type,
    required this.img,
    required this.url,
    this.expiredTime,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] ?? 0,
      type: json['type'] ?? 0,
      img: json['img'] ?? '',
      url: json['url'] ?? '',
      expiredTime: json['expired_time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'img': img,
      'url': url,
      'expired_time': expiredTime,
    };
  }

  static List<BannerModel> fromList(List<dynamic> list) {
    return list.map((e) => BannerModel.fromJson(e)).toList();
  }
}
