import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/widgets/app_image.dart';
import 'package:tom_chat/core/widgets/svga_viewer.dart';
import 'package:tom_chat/features/store/models/store_item_model.dart';
import 'package:tom_chat/models/helpers/image_model.dart';
import 'package:tom_chat/statics_values.dart';

Future<void> showPropDialog(BuildContext context, StoreItemModel item) async {
  await showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                    Colors.black.withValues(alpha: 0.8),
                  ),
                ),
                onPressed: Get.back,
                icon: const Icon(Icons.close),
              ),
            ),
            Expanded(
              child: SvgaViwer(
                withLoading: true,
                networkSvga: item.animation.network ?? "",
              ),
            ),
          ],
        ),
      );
    },
  );
}

Future<void> showEntryEventDialog(
  BuildContext context,
  StoreItemModel item,
) async {
  await showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: Stack(
            children: [
              AppImage(image: item.img, width: 300.w, fit: BoxFit.fitWidth),
              Positioned(
                top: 0,
                left: 0,
                child: IconButton(onPressed: Get.back, icon: Icon(Icons.close)),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> showFramDialog(BuildContext context, StoreItemModel item) async {
  await showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              CrossAxisAlignment.center, // علشان الأيقونة تيجي يمين
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                onPressed: Get.back,
                icon: const Icon(Icons.close),
              ),
            ),
            Stack(
              children: [
                if (StaticValue.userData.avatar?.network != null)
                  Positioned.fill(
                    child: Center(
                      child: CircleAvatar(
                        radius: 70.w,
                        backgroundColor: Colors.transparent,
                        backgroundImage: NetworkImage(
                          StaticValue.userData.avatar!.network!,
                        ),
                      ),
                    ),
                  ),
                Center(
                  child: AppImage(
                    image: ImageModel(network: item.img.network!),
                    width: 200.w,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
