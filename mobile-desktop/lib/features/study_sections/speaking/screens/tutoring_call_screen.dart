import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/tutoring_provider.dart';
import '../../../../data/services/profile_api.dart';

class TutoringCallScreen extends StatefulWidget {
  final int teacherId;

  const TutoringCallScreen({Key? key, required this.teacherId}) : super(key: key);

  @override
  State<TutoringCallScreen> createState() => _TutoringCallScreenState();
}

class _TutoringCallScreenState extends State<TutoringCallScreen> {
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  int? _myId;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
    
    final profile = await ProfileApi.getProfile();
    if (profile != null) {
      setState(() => _myId = profile['id']);
    }

    await _requestPermissions();
    await _createPeerConnection();
    
    final tutoringProvider = Provider.of<TutoringProvider>(context, listen: false);
    tutoringProvider.resetMatch(); // Clear the "Match Found" state
    
    // Listen for signaling messages from the teacher
    tutoringProvider.resetRtcStream(); // Optional: clears buffer
    final rtcSubscription = tutoringProvider.rtcStream.listen((data) {
      _handleSignalingMessage(data);
    });
  }

  Future<void> _requestPermissions() async {
    await [Permission.camera, Permission.microphone].request();
  }

  Future<void> _createPeerConnection() async {
    Map<String, dynamic> configuration = {
      "iceServers": [
        {"urls": "stun:stun.l.google.com:19302"},
      ]
    };

    _peerConnection = await createPeerConnection(configuration);

    _peerConnection?.onIceCandidate = (candidate) {
      _sendSignalingMessage({
        'type': 'ice-candidate',
        'data': {
          'candidate': candidate.candidate,
          'sdpMid': candidate.sdpMid,
          'sdpMLineIndex': candidate.sdpMLineIndex,
        },
        'fromUser': _myId.toString(),
        'toUser': widget.teacherId.toString(),
      });
    };

    _peerConnection?.onTrack = (RTCTrackEvent event) {
      if (event.streams.isNotEmpty) {
        _remoteRenderer.srcObject = event.streams[0];
      }
    };

    // Get Local Stream
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {
        'facingMode': 'user',
      }
    };

    _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    _localRenderer.srcObject = _localStream;

    _localStream?.getTracks().forEach((track) {
      _peerConnection?.addTrack(track, _localStream!);
    });
  }

  void _handleSignalingMessage(Map<String, dynamic> message) async {
    final type = message['type'];
    final data = message['data'];

    if (type == 'offer') {
      await _peerConnection?.setRemoteDescription(
        RTCSessionDescription(data['sdp'], data['type']),
      );
      
      final answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);

      _sendSignalingMessage({
        'type': 'answer',
        'data': {
          'sdp': answer.sdp,
          'type': answer.type,
        },
        'fromUser': _myId.toString(),
        'toUser': widget.teacherId.toString(),
      });
    } else if (type == 'ice-candidate') {
      _peerConnection?.addCandidate(
        RTCIceCandidate(data['candidate'], data['sdpMid'], data['sdpMLineIndex']),
      );
    }
  }

  void _sendSignalingMessage(Map<String, dynamic> message) {
    Provider.of<TutoringProvider>(context, listen: false).sendRtcSignal(message);
  }

  void _endCall() {
    _localStream?.getTracks().forEach((track) => track.stop());
    _peerConnection?.close();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _localStream?.dispose();
    _peerConnection?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Remote Video (Full Screen)
          _remoteRenderer.srcObject != null
              ? RTCVideoView(_remoteRenderer, objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover)
              : const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.blueAccent),
                      SizedBox(height: 16),
                      Text('Đang kết nối với giáo viên...', style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),

          // Local Video (Small Overlay)
          Positioned(
            right: 20,
            top: 60,
            child: Container(
              width: 120,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24, width: 2),
                boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 10)],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: RTCVideoView(_localRenderer, mirror: true, objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover),
              ),
            ),
          ),

          // Control Bar
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionButton(Icons.mic, Colors.white24, () {}),
                const SizedBox(width: 24),
                _buildActionButton(Icons.call_end, Colors.redAccent, _endCall, size: 32),
                const SizedBox(width: 24),
                _buildActionButton(Icons.videocam, Colors.white24, () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap, {double size = 24}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: size),
      ),
    );
  }
}