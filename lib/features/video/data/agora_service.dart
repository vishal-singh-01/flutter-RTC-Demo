import 'dart:io';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

import '../../../core/env.dart';

class AgoraService {
  RtcEngine? _engine;
  bool _initialized = false;
  int? remoteUid;

  RtcEngine get engine {
    final e = _engine;
    if (e == null) throw AgoraRtcException(message:  'Engine not initialized', code: -1);
    return e;
  }

  bool get isInitialized => _initialized;

  Future<void> init() async {
    if (_initialized) return;

    if (Env.agoraAppId.isEmpty) {
      throw AgoraRtcException(message:
        'Missing Agora App ID. Set Env.agoraAppId from Agora Console.',
        code: -1
      );
    }

    _engine = createAgoraRtcEngine();

    await _engine!.initialize(RtcEngineContext(appId: Env.agoraAppId));
    await _engine!.enableVideo();
    await _engine!.setChannelProfile(ChannelProfileType.channelProfileCommunication);

    _engine!.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) {},
      onUserJoined: (RtcConnection connection, int ruid, int elapsed) {
        print("remoteUid $ruid");
        remoteUid = ruid;
      },
      onUserOffline: (RtcConnection connection, int ruid, UserOfflineReasonType reason) {
        if (remoteUid == ruid) remoteUid = null;
      },
    ));

    _initialized = true;
  }

  Future<void> joinChannel({
    required String channelId,
    String? token,
    required int uid,
    bool startWithPreview = true,
  }) async {
    if (!_initialized) {
      await init();
    }

    final effectiveToken = token ?? Env.agoraTempToken;

    final options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileCommunication,
      publishCameraTrack: true,
      publishMicrophoneTrack: true,
      autoSubscribeAudio: true,
      autoSubscribeVideo: true,
    );

    if (startWithPreview) {
      await _engine!.startPreview();
    }

    await _engine!.joinChannel(
      token: effectiveToken,
      channelId: channelId,
      uid: uid,
      options: options,
    );
  }

  Future<void> leave() async {
    await _engine?.leaveChannel();
    remoteUid = null;
  }

  Future<void> dispose() async {
    await _engine?.release();
    _engine = null;
    _initialized = false;
  }

  Future<void> switchCamera() async => engine.switchCamera();
  Future<void> muteLocalAudio(bool mute) async => engine.muteLocalAudioStream(mute);
  Future<void> muteLocalVideo(bool mute) async {
    await engine.muteLocalVideoStream(mute);
    if (mute) {
      await engine.stopPreview();
    } else {
      await engine.startPreview();
    }
  }

  Future<bool> startScreenShare() async {
    if (!Platform.isAndroid) return false;
    const params = ScreenCaptureParameters2(
      captureAudio: true,
      audioParams: ScreenAudioParameters(sampleRate: 32000, channels: 2, captureSignalVolume: 100),
      videoParams: ScreenVideoParameters(
        dimensions: VideoDimensions(width: 1280, height: 720),
        frameRate: 15,
        bitrate: 0,
      ),
    );
    await engine.startScreenCapture( params);
    await engine.updateChannelMediaOptions(const ChannelMediaOptions(publishScreenTrack: true));
    return true;
  }

  Future<void> stopScreenShare() async {
    await engine.updateChannelMediaOptions(const ChannelMediaOptions(publishScreenTrack: false));
    await engine.stopScreenCapture();
  }
}
