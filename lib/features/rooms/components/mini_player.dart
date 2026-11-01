import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tom_chat/core/theme/color.dart';
import 'package:tom_chat/features/rooms/controllers/room_controller.dart';

class MiniPlayer extends StatelessWidget {
  final RoomController c;

  const MiniPlayer({super.key, required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!c.showMiniPlayer.value || c.currentTrack.isEmpty)
        return const SizedBox.shrink();

      return AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: EdgeInsets.symmetric(
          horizontal: c.showFullMiniPlayer.value ? 45 : 10,
          vertical: 14,
        ),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: c.showFullMiniPlayer.value
              ? Colors.black.withOpacity(0.5)
              : null,
          borderRadius: BorderRadius.circular(20),
        ),
        child: c.showFullMiniPlayer.value
            ? _buildExpanded(context)
            : _buildCollapsed(context),
      );
    });
  }

  // ---------------- Mini Mode (Collapsed) ----------------
  Widget _buildCollapsed(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: GestureDetector(
        onTap: () => c.showFullMiniPlayer.value = true,
        child: Container(
          padding: EdgeInsets.all(10).r,
          width: 50.r,
          height: 50.r,
          decoration: BoxDecoration(
            color: Colors.black12,
            shape: BoxShape.circle,
          ),
          child: Image.asset("assets/images/music.png"),
        ),
      ),
    );
    return Row(
      children: [
        // Play / Pause
        Obx(() {
          return IconButton(
            icon: Icon(
              c.playing.value ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 32,
            ),
            onPressed: c.toggleMusic,
          );
        }),

        const SizedBox(width: 8),

        // Track Name
        Expanded(
          child: Text(
            c.currentTrack.value.split('/').last,
            style: const TextStyle(color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // Expand button
        IconButton(
          icon: const Icon(Icons.expand_less, color: Colors.white),
          onPressed: () => c.showFullMiniPlayer.value = true,
        ),
      ],
    );
  }

  // ---------------- Full Mode (Expanded) ----------------
  Widget _buildExpanded(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ---------- Header ----------
        Row(
          children: [
            GestureDetector(
              onTap: () {
                final isPlaying = c.playing.value;

                if (isPlaying) {
                  c.showFullMiniPlayer.value = false;
                } else {
                  c.stopMusic();
                  c.showMiniPlayer.value = false;
                }
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.withOpacity(0.2),
                ),
                child: const Icon(Icons.close, color: Colors.redAccent),
              ),
            ),
            SizedBox(width: 10.w),
            Obx(() {
              if (!c.showFullMiniPlayer.value) {
                return SizedBox();
              }
              return IconButton(
                icon: Icon(
                  Icons.repeat,
                  color: c.loop.value ? AppColors.primaryDark : Colors.white,
                ),
                onPressed: () {
                  c.loop.value = !c.loop.value;
                  // c.player.setLoopMode(
                  //     c.loop.value ? LoopMode.one : LoopMode.off);
                },
              );
            }),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                c.currentTrack.value.split('/').last,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),

        // ---------- Controls ----------
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Next
            IconButton(
              icon: const Icon(Icons.skip_next, color: Colors.white, size: 36),
              onPressed: c.next,
            ),

            // Play / Pause
            Obx(() {
              return IconButton(
                icon: Icon(
                  c.playing.value
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_fill,
                  color: Colors.white,
                  size: 48,
                ),
                onPressed: c.toggleMusic,
              );
            }),

            // Prev
            IconButton(
              icon: const Icon(
                Icons.skip_previous,
                color: Colors.white,
                size: 36,
              ),
              onPressed: c.previous,
            ),
          ],
        ),

        Obx(() {
          return Row(
            children: [
              SizedBox(width: 5.w),
              Text(
                _fmt(c.currentPosition.value),
                style: Theme.of(context).textTheme.labelMedium,
              ),
              Expanded(
                child: Slider(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15).r,
                  value: c.totalDuration.value.inMilliseconds == 0
                      ? 0
                      : (c.currentPosition.value.inMilliseconds /
                                c.totalDuration.value.inMilliseconds)
                            .clamp(0.0, 1.0),
                  onChanged: (v) {
                    c.seek(v);
                  },
                ),
              ),
              Text(
                _fmt(c.totalDuration.value),
                style: Theme.of(context).textTheme.labelMedium,
              ),
              SizedBox(width: 5.w),
            ],
          );
        }),

        // ---------- Progress Bar ----------
        // StreamBuilder<Duration>(
        //   stream: c.durationController.stream,
        //   builder: (context, snapDur) {
        //     final total = snapDur.data ?? Duration.zero;

        //     return StreamBuilder<Duration>(
        //       stream: c.positionController.stream,
        //       builder: (context, snapPos) {
        //         final pos = snapPos.data ?? Duration.zero;

        //         double val = total.inMilliseconds == 0
        //             ? 0.0
        //             : pos.inMilliseconds / total.inMilliseconds;

        //         return Column(
        //           children: [
        //             Slider(
        //               value: val.clamp(0.0, 1.0),
        //               onChanged: (v) {
        //                 if (total.inMilliseconds > 0) {
        //                   c.engine!.setAudioMixingPosition(
        //                     (v * total.inMilliseconds).round(),
        //                   );
        //                 }
        //               },
        //             ),

        //             Row(
        //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //               children: [
        //                 Text(_fmt(pos), style: TextStyle(color: Colors.white70)),
        //                 Text(_fmt(total), style: TextStyle(color: Colors.white70)),
        //               ],
        //             ),
        //           ],
        //         );
        //       },
        //     );
        //   },
        // ),
        SizedBox(height: 10.h),

        // ---------- Volume ----------
        Row(
          children: [
            SizedBox(width: 10.w),
            const Icon(Icons.volume_up, color: Colors.white70),
            Expanded(
              child: Obx(
                () => Slider(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15).r,
                  value: c.volume.value,
                  min: 0,
                  max: 1,
                  onChanged: (v) => c.setVolume(v),
                ),
              ),
            ),
            Obx(
              () => Text(
                "${(c.volume.value * 100).round()}%",
                style: const TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(width: 10.w),
          ],
        ),
      ],
    );
  }

  String _fmt(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final m = two(d.inMinutes.remainder(60));
    final s = two(d.inSeconds.remainder(60));
    return "$m:$s";
  }
}
