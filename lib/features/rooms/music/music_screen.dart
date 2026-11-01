import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/widgets/card_widget.dart';
import 'package:tom_chat/features/page_templete.dart';
import 'package:tom_chat/features/rooms/controllers/room_controller.dart';
import 'package:tom_chat/l10n/l10n.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  final controller = Get.put(RoomController(), permanent: true);
  @override
  void initState() {
    super.initState();
    controller.fetchAllMusics();
  }

  @override
  Widget build(BuildContext context) {
    return PageTemplete(
      title: context.l10n.playlist,
      actions: [
        IconButton(
          icon: Stack(
            children: [
              Icon(Icons.music_note_outlined, color: Colors.black),
              Center(
                child: Icon(Icons.add, size: 10.r, color: Colors.black),
              ),
            ],
          ),
          onPressed: controller.addMusic,
        ),
      ],
      child: Obx(() {
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: controller.playlist.length,
                itemBuilder: (context, index) {
                  final path = controller.playlist[index];
                  final fileName = path.split('/').last;
                  return ListTile(
                    leading: const Icon(Icons.music_note),
                    title: Text(
                      fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => controller.playMusic(path),
                    trailing: PopupMenuButton<int>(
                      onSelected: (int value) {
                        if (value == 0) {
                          controller.playMusic(path);
                        } else if (value == 1) {
                        } else {
                          controller.deleteMusic(index);
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem<int>(
                          value: 0,
                          child: Row(
                            children: [
                              Icon(Icons.play_arrow),
                              SizedBox(width: 8),
                              Text(context.l10n.play),
                            ],
                          ),
                        ),
                        // const PopupMenuItem<int>(
                        //   value: 1,
                        //   child: Row(
                        //     children: [
                        //       Icon(Icons.edit),
                        //       SizedBox(width: 8),
                        //       Text('تعديل الاسم'),
                        //     ],
                        //   ),
                        // ),
                        PopupMenuItem<int>(
                          value: 2,
                          child: Row(
                            children: [
                              Icon(Icons.delete_forever),
                              SizedBox(width: 8),
                              Text(context.l10n.delete),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Obx(() {
              if (controller.currentTrack.value.isEmpty) {
                return SizedBox();
              }
              return CardWidget(
                radius: 0,
                colorIndex: 1,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      const Icon(Icons.music_note_outlined),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          controller.currentTrack.value.split('/').last,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          controller.playing.value
                              ? Icons.pause
                              : Icons.play_arrow,
                        ),
                        onPressed: controller.toggleMusic,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      }),
    );
  }
}
