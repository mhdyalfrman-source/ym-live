import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart' hide Trans;
import 'package:tom_chat/core/utils/swip_page.dart';
import 'package:tom_chat/statics_values.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImageGallery extends StatelessWidget {
  final List<String> images;

  const ImageGallery({super.key, required this.images});
  @override
  Widget build(BuildContext context) {
    return MasonryGridView.builder(
      itemCount: images.length,
      gridDelegate: SliverSimpleGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 250,
      ),
      itemBuilder: (context, index) {
        return ServiceImageItem(
          image: images[index],
          onTap: () {
            openDialog(
              context,
              ImagePreview(images: images, initialIndex: index),
            );
          },
        );
      },
    );
  }
}

class ServiceImageItem extends StatelessWidget {
  const ServiceImageItem({Key? key, required this.image, required this.onTap})
    : super(key: key);

  final String image;

  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: GestureDetector(
          onTap: onTap,
          child: Hero(
            tag: image,
            child: Image(
              image: NetworkImage("${StaticValue.serverPath}${image}"),
            ),
          ),
        ),
      ),
    );
  }
}

class ImagePreview extends StatefulWidget {
  ImagePreview({this.initialIndex = 0, required this.images})
    : pageController = PageController(initialPage: initialIndex);

  final int initialIndex;
  final PageController pageController;
  final List<String> images;

  @override
  State<StatefulWidget> createState() {
    return _ImagePreviewState();
  }
}

class _ImagePreviewState extends State<ImagePreview> {
  late int currentIndex = widget.initialIndex;

  void onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: Colors.black),
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: Stack(
          alignment: Alignment.bottomRight,
          children: <Widget>[
            PhotoViewGallery.builder(
              builder: _buildItem,
              itemCount: widget.images.length,
              backgroundDecoration: const BoxDecoration(color: Colors.black),
              pageController: widget.pageController,
              onPageChanged: onPageChanged,
              allowImplicitScrolling: true,
              scrollDirection: Axis.horizontal,
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                onPressed: Get.back,
                icon: Icon(Icons.close, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PhotoViewGalleryPageOptions _buildItem(BuildContext context, int index) {
    return
    // item.isSvg
    // ? PhotoViewGalleryPageOptions.customChild(
    //     child: Container(
    //       width: 300,
    //       height: 300,
    //       child: Image.asset(
    //         item.resource,
    //         height: 200.0,
    //       ),
    //     ),
    //     childSize: const Size(300, 300),
    //     initialScale: PhotoViewComputedScale.contained,
    //     minScale: PhotoViewComputedScale.contained * (0.5 + index / 10),
    //     maxScale: PhotoViewComputedScale.covered * 4.1,
    //     heroAttributes: PhotoViewHeroAttributes(tag: item.id),
    //   )
    // :
    PhotoViewGalleryPageOptions(
      imageProvider: CachedNetworkImageProvider(widget.images[index]),
      // initialScale: PhotoViewComputedScale.contained,
      minScale: PhotoViewComputedScale.contained * 0.9,
      // maxScale: PhotoViewComputedScale.covered * 4.1,
      heroAttributes: PhotoViewHeroAttributes(tag: widget.images[index]),
      // disableGestures: true
    );
  }
}
