import 'dart:io';
import 'dart:math';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:go_router/go_router.dart';

import '../../../core/env.dart';
import '../../auth/state/auth_controller.dart';
import '../data/agora_service.dart';

final agoraProvider = Provider((ref) => AgoraService());

class VideoCallScreen extends ConsumerStatefulWidget {
  const VideoCallScreen({super.key});

  @override
  ConsumerState<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends ConsumerState<VideoCallScreen>
    with WidgetsBindingObserver {
  final _channelCtrl = TextEditingController(text: Env.defaultChannelId);
  String? _channelError;

  late int _uid;

  bool _joined = false;
  bool _connecting = false;
  bool _mutedAudio = false;
  bool _mutedVideo = false;
  bool _sharing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _uid = Random().nextInt(1 << 31);
    _ensureEngineReady();
  }

  Future<void> _ensureEngineReady() async {
    await [Permission.camera, Permission.microphone].request();
    await ref.read(agoraProvider).init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _channelCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final agora = ref.read(agoraProvider);
    if (!_joined) return;
    if (state == AppLifecycleState.paused) {
      agora.muteLocalAudio(true);
      agora.muteLocalVideo(true);
    } else if (state == AppLifecycleState.resumed) {
      if (!_mutedAudio) agora.muteLocalAudio(false);
      if (!_mutedVideo) agora.muteLocalVideo(false);
    }
  }


  Future<void> _join() async {
    setState(() => _channelError = null);

    if (_channelCtrl.text.trim().isEmpty) {
      setState(() => _channelError = 'Channel ID is required');
      return;
    }

    final ok = await ensureRtcPermissions(context);
    if (!ok) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera/Microphone permission is required')),
      );
      return;
    }

    final agora = ref.read(agoraProvider);
    try {
      setState(() => _connecting = true);
      await agora.joinChannel(
        channelId: _channelCtrl.text.trim().isEmpty
            ? Env.defaultChannelId
            : _channelCtrl.text.trim(),
        uid: _uid,
      );
      setState(() {
        _joined = true;
        _connecting = false;
      });
    } catch (e) {
      setState(() => _connecting = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Join failed: $e')),
      );
    }
  }

  Future<void> _leave() async {
    final agora = ref.read(agoraProvider);
    await agora.leave();
    if (!mounted) return;
    setState(() {
      _joined = false;
      _connecting = false;
      _mutedAudio = false;
      _mutedVideo = false;
      _sharing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final agora = ref.watch(agoraProvider);
    final scheme = Theme.of(context).colorScheme;

    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
      if (!didPop) {
        await _confirmExit();
      }
    },
    child:Scaffold(
      appBar: AppBar(
        title: const Text('Call'),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        actions: [
          IconButton(
            tooltip: 'Users',
            onPressed: () => context.push('/users'),
            icon: const Icon(Icons.people_alt_outlined),
          ),
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'logout') {
                await ref.read(authControllerProvider.notifier).logout();
                if (!mounted) return;
                context.go('/login');
              }
            },
            itemBuilder: (c) => [
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Logout'),
                ),
              )
            ],
          ),
        ],
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _channelCtrl,
                    decoration: InputDecoration(
                      labelText: 'Meeting / Channel ID',
                      errorText: _channelError,
                      filled: true,
                      fillColor: scheme.surfaceVariant.withOpacity(.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: _joined ? _leave : _join,
                  child: Text(_joined ? 'Leave' : 'Join'),
                ),

              ],
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: !_joined
                      ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.videocam_off, size: 48),
                        SizedBox(height: 8),
                        Text('Disconnected'),
                      ],
                    ),
                  )
                      : (agora.remoteUid != null)
                      ? AgoraVideoView(
                    controller: VideoViewController.remote(
                      rtcEngine: agora.engine,
                      canvas:
                      VideoCanvas(uid: agora.remoteUid!),
                      connection: RtcConnection(
                        channelId: _channelCtrl.text.trim(),
                      ),
                    ),
                  )
                      : AgoraVideoView(
                    controller: VideoViewController(
                      rtcEngine: agora.engine,
                      canvas: const VideoCanvas(uid: 0),
                    ),
                  ),
                ),

                if (_joined && agora.remoteUid != null)
                  Positioned(
                    right: 12,
                    top: 12,
                    width: 120,
                    height: 180,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: Colors.black54,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: AgoraVideoView(
                          controller: VideoViewController(
                            rtcEngine: agora.engine,
                            canvas: const VideoCanvas(uid: 0),
                          ),
                        ),
                      ),
                    ),
                  ),

                // Connecting / waiting
                if (_joined && (_connecting))
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        color: Colors.black26,
                        child: const Center(
                          child: SizedBox(
                            height: 28,
                            width: 28,
                            child: CircularProgressIndicator(strokeWidth: 3),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Bottom controls
          if (_joined)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: scheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(blurRadius: 12, spreadRadius: -4, offset: Offset(0, 6)),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Mic
                        IconButton.filledTonal(
                          tooltip: _mutedAudio ? 'Unmute' : 'Mute',
                          onPressed: () async {
                            _mutedAudio = !_mutedAudio;
                            await ref.read(agoraProvider).muteLocalAudio(_mutedAudio);
                            setState(() {});
                          },
                          icon: Icon(_mutedAudio ? Icons.mic_off : Icons.mic),
                        ),

                        // Camera
                        IconButton.filledTonal(
                          tooltip: _mutedVideo ? 'Enable video' : 'Disable video',
                          onPressed: () async {
                            _mutedVideo = !_mutedVideo;
                            await ref.read(agoraProvider).muteLocalVideo(_mutedVideo);
                            setState(() {});
                          },
                          icon: Icon(_mutedVideo ? Icons.videocam_off : Icons.videocam),
                        ),

                        // Switch camera
                        IconButton.filledTonal(
                          tooltip: 'Switch camera',
                          onPressed: () => ref.read(agoraProvider).switchCamera(),
                          icon: const Icon(Icons.cameraswitch),
                        ),

                        // Screen share (Android)
                        if (Platform.isAndroid)
                          IconButton.filledTonal(
                            tooltip: _sharing ? 'Stop share' : 'Share screen',
                            onPressed: () async {
                              if (_sharing) {
                                await ref.read(agoraProvider).stopScreenShare();
                                _sharing = false;
                              } else {
                                final ok = await ref.read(agoraProvider).startScreenShare();
                                _sharing = ok;
                              }
                              setState(() {});
                            },
                            icon: Icon(_sharing ? Icons.stop_screen_share : Icons.screen_share),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    ));
  }

  Future<void> _confirmExit() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Exit App'),
        content: const Text('Are you sure you want to exit MyTravaly?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Yes, Exit'),
          ),
        ],
      ),
    );

    if (shouldExit == true) {
      if (Platform.isAndroid) {
        exit(0);
      } else {
        Navigator.of(context).maybePop();
      }
    }
  }


  Future<bool> ensureRtcPermissions(BuildContext context) async {
    final cam = await Permission.camera.status;
    final mic = await Permission.microphone.status;

    if (cam.isGranted && mic.isGranted) return true;

    final req = await [
      if (!cam.isGranted) Permission.camera,
      if (!mic.isGranted) Permission.microphone,
    ].request();

    final camOk = (req[Permission.camera] ?? cam).isGranted;
    final micOk = (req[Permission.microphone] ?? mic).isGranted;

    if (camOk && micOk) return true;

    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final permanentlyDenied = (req[Permission.camera]?.isPermanentlyDenied ?? false) ||
            (req[Permission.microphone]?.isPermanentlyDenied ?? false);

        return AlertDialog(
          title: const Text('Permissions needed'),
          content: const Text(
            'Camera and Microphone access are required to start the call.\n\n'
                'Please grant permissions to continue.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            if (permanentlyDenied)
              TextButton(
                onPressed: () async {
                  Navigator.of(ctx).pop(false);
                  await openAppSettings();
                },
                child: const Text('Open Settings'),
              ),
            FilledButton(
              onPressed: () async {
                final retry = await [
                  Permission.camera,
                  Permission.microphone,
                ].request();
                final ok = (retry[Permission.camera]?.isGranted ?? false) &&
                    (retry[Permission.microphone]?.isGranted ?? false);

                Navigator.of(ctx).pop(ok);
              },
              child: const Text('Try Again'),
            ),
          ],
        );
      },
    ) ??
        false;
  }
}
