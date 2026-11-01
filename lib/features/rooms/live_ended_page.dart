import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/widgets/profile_avatar.dart';
import 'package:tom_chat/features/profile/components/user_name_widget.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/models/user/user_model.dart';

class LiveEndedPage extends StatefulWidget {
  final UserModel user;
  const LiveEndedPage({super.key, required this.user});

  @override
  State<LiveEndedPage> createState() => _LiveEndedPageState();
}

class _LiveEndedPageState extends State<LiveEndedPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: (widget.user.avatar?.network ?? "") == ""
                ? AssetImage("assets/images/bg.png")
                : CachedNetworkImageProvider(widget.user.avatar?.network ?? ''),
            fit: BoxFit.cover,
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: Get.back,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black87,
                    ),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ),
                const Spacer(),
                Text(
                  context.l10n.thisLiveEnded,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                ProfileAvatar(
                  radius: 100.r,
                  user: widget.user,
                  openProfileType: OpenProfileType.full,
                ),
                const SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15).r,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10).r,
                  ),
                  child: UserNameWidget(
                    user: widget.user,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Spacer(),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Colors.grey.shade100,
                                thickness: 1,
                              ),
                            ),
                            // Padding(
                            //   padding: const EdgeInsets.symmetric(horizontal: 8),
                            //   child: Text(
                            //     "Suggested Lives",
                            //     style: theme.textTheme.headlineMedium?.copyWith(
                            //       color: Colors.grey.shade100,
                            //     ),
                            //   ),
                            // ),
                            // Expanded(
                            //   child: Divider(
                            //     color: Colors.grey.shade100,
                            //     thickness: 1,
                            //   ),
                            // ),
                          ],
                        ),
                        // const SizedBox(height: 16),
                        // Obx(() {
                        //   return StreamGrid(
                        //     onStreamTap:widget.onMoveToNewLive,
                        //     streams: controller.forYouStreams.take(4).toList(),
                        //   );
                        // }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
