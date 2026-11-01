// ignore_for_file: public_member_api_docs, sort_constructors_first
class ImageModel {
  final String? type;
  final String? txt;
  final String? bgColor;
  final String? asset;
  final String? network;
  final String? frame;
  final double? opacity;

  ImageModel({
    this.type,
    this.txt,
    this.bgColor,
    this.asset,
    this.network,
    this.frame,
    this.opacity,
  });

  factory ImageModel.fromMap(json) {
    if (json == null) {
      return ImageModel();
    }
    if (json is String) {
      return ImageModel(network: json, type: "network");
    }
    if (json is List) {
      return ImageModel();
    }
    return ImageModel(
      type: json['type'],
      txt: json['txt'],
      bgColor: json['bgColor'],
      asset: json['asset'],
      network: json['network'],
      frame: json['frame'],
      opacity: (json['opacity'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'txt': txt,
      'bgColor': bgColor,
      'asset': asset,
      'network': network,
      'frame': frame,
      'opacity': opacity,
    };
  }

  static List<ImageModel> fromList(List<dynamic> list) {
    return list.map((e) => ImageModel.fromMap(e)).toList();
  }

  ImageModel copyWith({
    String? type,
    String? txt,
    String? bgColor,
    String? asset,
    String? network,
    String? frame,
    double? opacity,
  }) {
    return ImageModel(
      type: type ?? this.type,
      txt: txt ?? this.txt,
      bgColor: bgColor ?? this.bgColor,
      asset: asset ?? this.asset,
      network: network ?? this.network,
      frame: frame ?? this.frame,
      opacity: opacity ?? this.opacity,
    );
  }
}
