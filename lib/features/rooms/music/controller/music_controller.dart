import 'dart:io';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:tom_chat/core/utils/snakbar_dialog.dart';
import 'package:tom_chat/features/rooms/controllers/room_agora_controller.dart';
import 'package:tom_chat/features/rooms/controllers/room_controller_variables.dart';
import 'package:tom_chat/features/rooms/music/audio_list_bottom_sheet.dart';

mixin MusicController
    on GetxController, RoomControllerVariables, RoomAgoraController {
  RxList<String> playlist = <String>[].obs;
  RxString currentTrack = ''.obs;

  RxDouble volume = 1.0.obs;

  RxBool loop = false.obs;

  Future<void> fetchAllMusics() async {
    playlist.value = List<String>.from(box.read('playlist') ?? []);
    currentTrack.value = box.read('currentTrack') ?? '';
    volume.value = box.read('volume') ?? 1.0;
    loop.value = box.read('loop') ?? false;
  }

  Future<void> addMusic() async {
    Get.bottomSheet(
      AudioPickerBottomSheet(
        onAudioSelected: (File file) async {
          const allowedExtensions = {
            '.mp3',
            '.wav',
            '.flac',
            '.aac',
            '.ogg',
            '.m4a',
          };

          final path = file.path;

          final lowerPath = path.toLowerCase();

          final isValid = allowedExtensions.any(lowerPath.endsWith);
          if (!isValid) return;

          if (!playlist.contains(path)) {
            playlist.add(path);
          }

          playlist.refresh();
          await box.write('playlist', playlist);
        },
      ),
    );
  }

  Future<void> playMusic(String path) async {
    if (!await File(path).exists()) {
      int index = playlist.indexWhere((p) => p == path);
      deleteMusic(index);
      snakbarDialog(title: "هذا الملف لم يعد موجود", durationSecound: 5);
    }
    isSoundOn.value = true;
    engine!.enableAudio();
    playing.value = true;
    showMiniPlayer.value = true;
    if (currentTrack.value == path) {
      if (currentPosition.value.inMilliseconds ==
          totalDuration.value.inMilliseconds) {
        currentPosition.value = Duration.zero;
      }
      await startMusic(
        filePathOrUrl: path,
        loop: loop.value,
        playLocalOnly: false,
        startPosMs: currentPosition.value.inMilliseconds,
      );
      await setVolume(volume.value);
      return;
    }

    currentTrack.value = path;
    box.write('currentTrack', path);

    // agora
    await startMusic(
      filePathOrUrl: path,
      loop: loop.value,
      playLocalOnly: false,
    );
    await setVolume(volume.value);
  }

  Future<void> stopMusicForWver() async {
    await stopMusic();
    playing.value = false;
  }

  Future<void> toggleMusic() async {
    if (playing.value) {
      await stopMusicForWver();
    } else {
      await playMusic(currentTrack.value);
    }
  }

  // ========= NEXT / PREVIOUS =========

  void next() {
    if (playlist.isEmpty) return;

    int index = playlist.indexOf(currentTrack.value);
    if (index == -1 || index == playlist.length - 1) {
      playMusic(playlist.first);
    } else {
      playMusic(playlist[index + 1]);
    }
  }

  void previous() {
    if (playlist.isEmpty) return;

    int index = playlist.indexOf(currentTrack.value);
    if (index <= 0) {
      playMusic(playlist.last);
    } else {
      playMusic(playlist[index - 1]);
    }
  }

  // ========= SETTINGS =========

  Future<void> setVolume(double v) async {
    volume.value = v;
    await setPublishVolume((v * 100).toInt());
    await setPlayoutVolume((v * 100).toInt());
    box.write('volume', v);
  }

  void toggleLoop() {
    loop.value = !loop.value;
    box.write('loop', loop.value);
  }

  deleteMusic(index) {
    stopMusic();
    if (index == -1) return;
    String p = playlist.removeAt(index);
    if (p == currentTrack.value) {
      currentTrack.value = "";
    }
    playlist.refresh();
    GetStorage().write('playlist', playlist);
  }
}
