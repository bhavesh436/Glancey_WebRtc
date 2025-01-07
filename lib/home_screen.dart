
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:uuid/uuid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late io.Socket _socket;
  final String _userId = const Uuid().v4().substring(0, 6);
  final TextEditingController _callIdController = TextEditingController();
  RTCPeerConnection? _peerConnection;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  @override
  void initState() {
    super.initState();
    _initializeRenderers();
    _connectToSocketServer();
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _peerConnection?.close();
    super.dispose();
  }

  Future<void> _initializeRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  void _connectToSocketServer() {
    const serverAddress = 'https://careful-wobbly-pancake.glitch.me';
    _socket = io.io(serverAddress, <String, dynamic>{
      'transports': ['websocket'],
    });

    _socket.onConnect((_) {
      print('Connected to signaling server');
      _socket.emit('register', _userId); // Register the user
    });

    _socket.onError((error) {
      print('Socket error: $error');
    });

    _socket.onConnectError((error) {
      print('Connection error: $error');
    });

    _socket.on('incomingCall', (data) async {
      final from = data['from'];
      final offer = data['offer'];
      bool accept = await _showIncomingCallDialog(from);
      print('Sending answer to: $from');

      if (accept) {
        await _createPeerConnection();
        await _peerConnection?.setRemoteDescription(
          RTCSessionDescription(offer['sdp'], offer['type']),
        );
        final answer = await _peerConnection?.createAnswer();
        if (answer != null) {
          await _peerConnection?.setLocalDescription(answer);
          _socket.emit('answer', {
            'to': from,
            'answer': {
              'sdp': answer.sdp,
              'type': answer.type,
            }
          });
        }
      }
    });

    _socket.on('callAnswered', (data) async {
      final answer = data['answer'];
      if (answer != null) {
        await _peerConnection?.setRemoteDescription(
          RTCSessionDescription(answer['sdp'], answer['type']),
        );
      }
    });

    _socket.on('candidate', (data) async {
      final candidate = data['candidate'];
      if (candidate != null) {
        await _peerConnection?.addCandidate(
          RTCIceCandidate(
            candidate['candidate'],
            candidate['sdpMid'],
            candidate['sdpMLineIndex'],
          ),
        );
      }
    });

    _socket.onDisconnect((_) {
      print('Disconnected from signaling server');
    });
  }

  Future<void> _createPeerConnection() async {
    final config = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ]
    };

    try {
      _peerConnection = await createPeerConnection(config);
    } catch (e) {
      print('Error creating peer connection: $e');
      return;
    }

    _peerConnection?.onIceCandidate = (candidate) {
      if (_callIdController.text.isNotEmpty) {
        _socket.emit('candidate', {
          'to': _callIdController.text,
          'candidate': candidate.toMap(),
        });
      }
    };

    _peerConnection?.onTrack = (event) {
      print('Received track: ${event.track.kind}');

      if (event.track.kind == 'video') {
        setState(() {
          if (event.streams.isNotEmpty) {
            _remoteRenderer.srcObject = event.streams[0];
            print('Remote stream received');
          } else {
            print('No streams available');
          }
        });
      }
    };


    try {
      final mediaStream = await navigator.mediaDevices.getUserMedia({'video': true, 'audio': true});
      mediaStream.getTracks().forEach((track) {
        _peerConnection?.addTrack(track, mediaStream);
      });
      _localRenderer.srcObject = mediaStream;
    } catch (e) {
      print('Error getting media stream: $e');
    }
  }

  Future<bool> _showIncomingCallDialog(String from) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Incoming Call from $from'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Reject'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Accept'),
          ),
        ],
      ),
    ) ??
        false;
  }

  void _makeCall() async {
    if (_callIdController.text.isEmpty) return;

    await _createPeerConnection();
    final offer = await _peerConnection?.createOffer();
    if (offer != null) {
      await _peerConnection?.setLocalDescription(offer);
      _socket.emit('call', {
        'to': _callIdController.text,
        'offer': {
          'sdp': offer.sdp,
          'type': offer.type,
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('P2P Video Call'),
      ),
      body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text('Your ID: $_userId'),
          const SizedBox(height: 16),
          TextField(
            controller: _callIdController,
            decoration: const InputDecoration(
              labelText: 'Enter Call ID',
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _makeCall,
            child: const Text('Make Call'),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                Expanded(child: RTCVideoView(_localRenderer)),
                Expanded(child: RTCVideoView(_remoteRenderer)),
              ],
            ),
          ),
        ],
      ),
              ),
    );
  }
}
