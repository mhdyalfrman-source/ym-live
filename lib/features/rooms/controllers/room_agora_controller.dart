import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:tom_chat/features/rooms/controllers/room_controller_variables.dart';

mixin RoomAgoraController on GetxController implements RoomControllerVariables {
  RtcEngine? engine;

  final RxString channelName = ''.obs;

  final RxBool isCallActive = false.obs;
  final RxBool isAgoraInitialized = false.obs;
  final RxBool isAgoraJoinRunning = false.obs;

  final RxDouble audioVolume = 50.0.obs;

  // Group call users management
  final RxList<int> remoteUsers = <int>[].obs;
  final RxMap<int, bool> remoteAudioStates = <int, bool>{}.obs;
  final RxMap<int, double> remoteUserVolumes = <int, double>{}.obs;
  final Map<int, double> _prev = {};

  // Network and quality monitoring
  final RxInt networkQuality = 0.obs;
  final RxString networkType = 'Unknown'.obs;
  final RxBool isNetworkGood = true.obs;

  /// Initialize Agora RTC Engine
  Future<void> initializeAgoraConfiguration(String appId) async {
    if (isAgoraInitialized.value) return;

    try {
      await _releaseExistingEngine();

      final trimmedAppId = appId.trim();
      engine = createAgoraRtcEngine();
      await engine!.initialize(
        RtcEngineContext(
          appId: trimmedAppId,
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        ),
      );

      await _setupEventHandlers();
      await _configureEngine();

      isAgoraInitialized.value = true;
    } on AgoraRtcException catch (e) {
      isAgoraInitialized.value = false;
      _handleError(_getInitializationError(e));
    } catch (e) {
      isAgoraInitialized.value = false;
      _handleError(_getInitializationError(e));
    }
  }

  /// Release existing engine if any
  Future<void> _releaseExistingEngine() async {
    if (engine != null) {
      await engine!.release();
      engine = null;
      isAgoraInitialized.value = false;
    }
  }

  /// Setup Agora event handlers
  Future<void> _setupEventHandlers() async {
    engine!.unregisterEventHandler(handlers);
    engine!.registerEventHandler(handlers);
  }

  RtcEngineEventHandler get handlers {
    return RtcEngineEventHandler(
      onJoinChannelSuccess: _onJoinChannelSuccess,
      onLeaveChannel: _onLeaveChannel,
      onUserJoined: _onUserJoined,
      onUserOffline: _onUserOffline,
      onAudioVolumeIndication: _onAudioVolumeIndication,
      onRemoteAudioStateChanged: _onRemoteAudioStateChanged,
      onNetworkQuality: _onNetworkQuality,
      onRtcStats: _onRtcStats,
      onError: _onError,
    );
  }

  /// Configure engine settings for group calls
  Future<void> _configureEngine() async {
    await engine!.enableAudio();
  }

  /// Generic method to start a group call
  Future<void> joinToCall({
    required String appId,
    required String channelId,
    required String callToken,
    required int rid,
    int? uid,
    required bool enableMic,
  }) async {
    final trimmedAppId = appId.trim();
    final trimmedToken = callToken.trim();
    final trimmedChannel = channelId.trim();
    final joinUid = uid ?? 0;

    if (isAgoraJoinRunning.value) {
      return;
    }
    if (isCallActive.value) {
      return;
    }
    if (trimmedAppId.isEmpty) {
      _handleError('Agora join skipped: empty App ID.');
      return;
    }
    if (trimmedChannel.isEmpty) {
      _handleError('Agora join skipped: empty channel ID.');
      return;
    }
    if (trimmedToken.isEmpty) {
      _handleError('Agora join skipped: empty RTC token.');
      return;
    }

    if (!isAgoraInitialized.value) {
      await initializeAgoraConfiguration(trimmedAppId);
    }
    if (!isAgoraInitialized.value) {
      return;
    }

    try {
      final hasPermissions = await _requestPermissions(false);
      if (!hasPermissions) {
        throw Exception('Required permissions not granted');
      }

      await _setupCall(rid, trimmedChannel, trimmedToken, joinUid, enableMic);
    } on AgoraRtcException catch (e) {
      _handleError('Agora join failed: code=${e.code}, message=${e.message}');
    } catch (e) {
      _handleError(
        'Failed to start call: $e rid=$rid, channelId=$trimmedChannel, uid=$joinUid',
      );
    }
  }

  /// Setup call configuration and join channel
  Future<void> _setupCall(
    int rid,
    String channelId,
    String callToken,
    int uid,
    bool enableMic,
  ) async {
    if (isCallActive.value) {
      await endCall();
    }

    isAgoraJoinRunning.value = true;
    channelName.value = channelId;

    final isBroadcaster = enableMic;

    try {
      await engine!.joinChannel(
        token: callToken,
        channelId: channelId,
        uid: uid,
        options: ChannelMediaOptions(
          clientRoleType: isBroadcaster
              ? ClientRoleType.clientRoleBroadcaster
              : ClientRoleType.clientRoleAudience,
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
          publishMicrophoneTrack: enableMic,
          autoSubscribeAudio: true,
        ),
      );
      await engine!.enableAudioVolumeIndication(
        interval: 200,
        smooth: 3,
        reportVad: true,
      );
      isCallActive.value = true;
    } finally {
      isAgoraJoinRunning.value = false;
    }
  }

  /// End the current call
  Future<void> endCall() async {
    try {
      if (engine != null && isCallActive.value) {
        await engine!.leaveChannel();
        await Future.delayed(const Duration(milliseconds: 100));
      }
      _resetCallState();
    } catch (e) {
      _handleError('Error ending call: $e');
    }
  }

  /// Stop audio streams
  // Future<void> stopAudioStreams() async {
  //   await engine!.muteLocalAudioStream(true);
  //   await engine!.enableLocalAudio(false);
  //   await engine!.updateChannelMediaOptions(ChannelMediaOptions(
  //     publishMicrophoneTrack: false,
  //   ));
  // }

  // Future<void> startAudioStreams() async {
  //   await engine!.muteLocalAudioStream(false);
  //   await engine!.enableLocalAudio(true);
  //   await engine!.updateChannelMediaOptions(ChannelMediaOptions(
  //     publishMicrophoneTrack: true,
  //   ));
  // }

  // Future<void> toggleVideoStreams({bool? publishCameraTrack,bool? publishMicTrack}) async {
  //   if(publishCameraTrack != null){
  //     await engine!.muteLocalVideoStream(!publishCameraTrack);
  //     await engine!.enableLocalVideo(publishCameraTrack);
  //   }
  //   if(publishMicTrack != null){
  //     await engine!.muteLocalAudioStream(!publishMicTrack);
  //     await engine!.enableLocalAudio(publishMicTrack);
  //   }
  //   await engine!.updateChannelMediaOptions(ChannelMediaOptions(
  //     publishCameraTrack: publishCameraTrack,
  //     publishMicrophoneTrack: publishMicTrack,
  //   ));
  // }

  /// Toggle audio mute/unmute and handle role switching
  Future<void> toggleUserRole({
    required bool isBroadcaster,
    bool? withPublishCamera,
    bool? withPublishMic,
  }) async {
    if (!isCallActive.value) return;

    try {
      // isAudioMuted.value = withPublishMic ?? isAudioMuted.value;
      // isVideoEnabled.value = withPublishCamera ?? isVideoEnabled.value;

      if (isBroadcaster) {
        await switchToBroadcaster(
          withPublishCamera: withPublishCamera,
          withPublishMic: withPublishMic,
        );
      } else {
        await switchToAudience(
          withPublishCamera: withPublishCamera,
          withPublishMic: withPublishMic,
        );
      }

      // await engine!.muteLocalAudioStream(isAudioMuted.value);
    } catch (e) {
      _handleError('Failed to toggle audio mute: $e');
    }
  }

  /// Switch to broadcaster role
  Future<void> switchToBroadcaster({
    bool? withPublishCamera,
    bool? withPublishMic,
    bool? publishMixedAudioTrack,
  }) async {
    await engine!.updateChannelMediaOptions(
      ChannelMediaOptions(
        publishMicrophoneTrack: withPublishMic ?? true,
        publishCameraTrack: withPublishCamera,
        publishMixedAudioTrack: publishMixedAudioTrack,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
    );
    await engine!.enableAudioVolumeIndication(
      interval: 200,
      smooth: 3,
      reportVad: true,
    );
  }

  /// Switch to audience role
  Future<void> switchToAudience({
    bool? withPublishCamera,
    bool? withPublishMic,
    bool? publishMixedAudioTrack,
  }) async {
    await engine!.updateChannelMediaOptions(
      ChannelMediaOptions(
        publishMicrophoneTrack: withPublishMic ?? false,
        publishCameraTrack: withPublishCamera,
        publishMixedAudioTrack: publishMixedAudioTrack,
        clientRoleType: ClientRoleType.clientRoleAudience,
      ),
    );
  }

  Rx<Duration> totalDuration = Duration.zero.obs;
  Rx<Duration> currentPosition = Duration.zero.obs;
  Timer? _timer;

  /// Start playing a music file and publish it to remote users.
  ///
  /// [filePathOrUrl]:
  ///  - if it starts with "asset:" the asset after ":" will be copied to temp and used.
  ///  - if it's a local absolute path use it directly.
  ///  - if it's an http/https URL you can pass it (platform dependent).
  ///
  /// [loop]: true => infinite loop, false => play once.
  /// [playLocalOnly]: true => only local playback (remote users don't hear),
  ///                  false => both local & remote hear the music.
  Future<void> startMusic({
    required String filePathOrUrl,
    bool loop = false,
    bool playLocalOnly = false,
    int startPosMs = 0,
  }) async {
    String playPath = filePathOrUrl;
    final bool loopback = playLocalOnly;
    final int cycle = loop ? -1 : 1;
    await engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    engine!.startAudioMixing(
      filePath: playPath,
      loopback: loopback,
      cycle: cycle,
      startPos: startPosMs,
    );
    final audio = AudioPlayer();
    await audio.setFilePath(filePathOrUrl);

    // اجلب مدة الملف
    final info = audio.duration;
    if (info != null) {
      totalDuration.value = info;
    }

    // شغل المؤقت لجلب position كل 200ms
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) async {
      int pos = await engine!.getAudioMixingCurrentPosition();
      currentPosition.value = Duration(milliseconds: pos);
      if (currentPosition.value >= totalDuration.value && !loop) {
        playing.value = false;
        t.cancel();
      }
    });
  }

  Future<void> resumeMusic() async {
    await engine!.resumeAudioMixing();
  }

  Future<void> stopMusic() async {
    _timer?.cancel();
    await engine!.stopAudioMixing();
  }

  void seek(double value) {
    if (totalDuration.value.inMilliseconds > 0) {
      final ms = (value * totalDuration.value.inMilliseconds).round();
      currentPosition.value = Duration(milliseconds: ms);
      engine!.setAudioMixingPosition(ms);
    }
  }

  /// Ajust volumes: publishVolume affects what remote users hear,
  /// playoutVolume affects local playback heard by this client.
  Future<void> setPublishVolume(int volume /* 0..100 */) async {
    // adjustAudioMixingPublishVolume adjusts what remote users hear
    await engine!.adjustAudioMixingPublishVolume(volume);
  }

  Future<void> setPlayoutVolume(int volume /* 0..100 */) async {
    // adjustAudioMixingPlayoutVolume adjusts local playback volume
    await engine!.adjustAudioMixingPlayoutVolume(volume);
  }

  // Event Handlers
  void _onJoinChannelSuccess(RtcConnection connection, int elapsed) {
    isCallActive.value = true;
  }

  void _onLeaveChannel(RtcConnection connection, RtcStats stats) {
    _resetCallState();
  }

  void _onUserJoined(RtcConnection connection, int remoteUid, int elapsed) {
    _addRemoteUser(remoteUid);
  }

  void _onUserOffline(
    RtcConnection connection,
    int remoteUid,
    UserOfflineReasonType reason,
  ) {
    _removeRemoteUser(remoteUid);
  }

  void _onAudioVolumeIndication(
    RtcConnection connection,
    List<AudioVolumeInfo> speakers,
    int speakerNumber,
    int totalVolume,
  ) {
    if (speakers.isEmpty) {
      // تقدر تعطي خريطة فارغة لبدء ال decay
      updateVolumes({});
      return;
    }

    final Map<int, double> incoming = {};
    for (var s in speakers) {
      final uid = s.uid ?? 0;
      final vol = (s.volume ?? 0).toDouble();
      // optional: تجاهل الضجيج
      if (vol > 2) incoming[uid] = vol;
    }

    updateVolumes(incoming);
  }

  void updateVolumes(Map<int, double> incoming) {
    // incoming already contains uid -> rawVolume (0..100)
    incoming.forEach((uid, rawVol) {
      final prev = _prev[uid] ?? 0.0;
      // simple exponential smoothing alpha
      const alpha = 0.45;
      final smoothed = prev * (1 - alpha) + rawVol * alpha;
      _prev[uid] = smoothed;
      if ((remoteUserVolumes[uid] ?? -1) != smoothed.roundToDouble()) {
        remoteUserVolumes[uid] = smoothed;
      }
    });

    // remove uids not present in incoming (they become zero over time)
    final incomingUids = incoming.keys.toSet();
    final toZero = _prev.keys.where((k) => !incomingUids.contains(k)).toList();
    for (final uid in toZero) {
      // decay gradually to zero
      final decayed = (_prev[uid] ?? 0) * 0.6;
      if (decayed < 1.0) {
        _prev.remove(uid);
        remoteUserVolumes.remove(uid);
      } else {
        _prev[uid] = decayed;
        remoteUserVolumes[uid] = decayed;
      }
    }
  }

  void _onRemoteAudioStateChanged(
    RtcConnection connection,
    int remoteUid,
    RemoteAudioState state,
    RemoteAudioStateReason reason,
    int elapsed,
  ) {
    remoteAudioStates[remoteUid] =
        state == RemoteAudioState.remoteAudioStateStarting ||
        state == RemoteAudioState.remoteAudioStateDecoding;
  }

  void _onNetworkQuality(
    RtcConnection connection,
    int localUid,
    QualityType txQuality,
    QualityType rxQuality,
  ) {
    networkQuality.value = rxQuality.index;
    isNetworkGood.value = rxQuality.index <= 2;
  }

  // // enable extension
  // Future<void> enableExtension(
  //     String provider, String extension, bool enable) async {
  //   // await engine!.enableExtension(
  //   //   provider: provider,
  //   //   extension: extension,
  //   //   enable: enable,
  //   // );
  // }

  void _onRtcStats(RtcConnection connection, RtcStats stats) {
    // Handle call statistics if needed
  }

  void _onError(ErrorCodeType err, String msg) {
    _handleError('Call error: $err');
  }

  String _getInitializationError(dynamic e) {
    final errorStr = e.toString();
    if (errorStr.contains('Invalid App ID')) {
      return 'Invalid Agora App ID. Please verify your App ID configuration.';
    } else if (errorStr.contains('network')) {
      return 'Network error during Agora initialization. Please check your connection.';
    } else {
      return 'Failed to initialize Agora engine: $errorStr';
    }
  }

  Future<bool> _requestPermissions(bool needVideo) async {
    final permissions = <Permission>[Permission.microphone];
    if (needVideo) permissions.add(Permission.camera);

    final statuses = await permissions.request();

    for (final permission in permissions) {
      if (statuses[permission] != PermissionStatus.granted) {
        _showPermissionDialog(permission);
        return false;
      }
    }
    return true;
  }

  void _showPermissionDialog(Permission permission) {
    final permissionName = permission == Permission.microphone
        ? 'Microphone'
        : 'Camera';

    Get.dialog(
      AlertDialog(
        title: Text('$permissionName Permission Required'),
        content: Text('$permissionName permission is required to make calls.'),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        ],
      ),
    );
  }

  void _addRemoteUser(int uid) {
    if (!remoteUsers.contains(uid)) {
      remoteUsers.add(uid);
      remoteAudioStates[uid] = true;
      remoteUserVolumes[uid] = 0.0;
    }
  }

  void _removeRemoteUser(int uid) {
    remoteUsers.remove(uid);
    remoteAudioStates.remove(uid);
    remoteUserVolumes.remove(uid);
  }

  void _resetCallState() {
    isCallActive.value = false;
    isAgoraJoinRunning.value = false;
    channelName.value = '';
    remoteUsers.clear();
    remoteAudioStates.clear();
    remoteUserVolumes.clear();
  }

  String _tokenPrefix(String token) {
    if (token.isEmpty) return '';
    return token.length <= 8 ? token : token.substring(0, 8);
  }

  void _handleError(String message) {}

  @override
  void onClose() async {
    if (engine != null) {
      try {
        await engine!.muteLocalAudioStream(true);
        await engine!.enableLocalAudio(false);
        await engine!.leaveChannel();
        await engine!.release();
      } catch (e) {
        // Silent cleanup failure
      }
    }

    super.onClose();
  }
}
