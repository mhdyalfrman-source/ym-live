import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:tom_chat/core/utils/open_camera_gallery.dart';

class ChooseImage extends StatelessWidget {
  final String? title;
  final String? aboveTitle;
  final Color? color;
  final double height;
  final IconData icon;
  final File file;
  final Function(String) onChanged;
  final Function()? onCancel;
  const ChooseImage({
    super.key,
    this.title,
    required this.file,
    required this.onChanged,
    required this.onCancel,
    required this.height,
    this.aboveTitle,
    this.icon = HugeIcons.strokeRoundedImageAdd01,
    this.color,
  });

  static final List<IconData> icons = [
    Icons.storage_outlined,
    if (!Platform.isWindows) Icons.camera_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (aboveTitle != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20).r,
            child: Text(
              aboveTitle!,
              style: Theme.of(context).textTheme.displaySmall!,
            ),
          ),
          SizedBox(height: 10.h),
        ],
        InkWell(
          onTap: () async {
            String path = await openGallery();
            onChanged(path);
          },
          child: Container(
            // width: double.infinity,
            height: height,
            padding: file.path == ''
                ? EdgeInsets.all(10).r
                : EdgeInsets.all(5).r,
            decoration: BoxDecoration(
              color: color ?? Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(30).r,
            ),
            child: (file.path == '')
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (title != null)
                        Text(
                          title!,
                          style: Theme.of(context).textTheme.displaySmall!
                              .copyWith(color: Colors.white),
                        ),
                      const SizedBox(width: 5),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Color(0x4DFFFFFF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(icon, color: Colors.white, size: 40.r),
                        ),
                      ),
                    ],
                  )
                : SizedBox(
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30).h,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.file(
                              file,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.network(
                                  file.path,
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                          ),
                          IconButton(
                            onPressed: onCancel,
                            icon: Icon(Icons.close),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
