// ignore_for_file: public_member_api_docs, sort_constructors_first
class Menu {
  String? title;
  final int id;
  int? mainId;
  String? privileges;
  String? svgImage;
  // U update   S show    I insert    D delete    P print
  List<Menu> children;
  int index;

  Menu({
    this.title,
    this.mainId,
    required this.id,
    this.privileges,
    required this.index,
    this.svgImage,
    required this.children,
  });

  Menu copyWith({Menu? menu}) {
    return Menu(
      title: menu?.title ?? title,
      id: menu?.id ?? id,
      mainId: menu?.mainId ?? mainId,
      privileges: menu?.privileges ?? privileges,
      svgImage: menu?.svgImage ?? svgImage,
      children: menu?.children ?? children,
      index: menu?.index ?? index,
    );
  }
}
