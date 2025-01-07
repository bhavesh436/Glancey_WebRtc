import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  IO.Socket? socket;

  // Initialize the socket connection
  void initSocket(String callerId) {
    // Connect to the server
    socket = IO.io('https://your-server-url', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'query': {'callerId': callerId},  // Send the callerId as query parameter
    });

    // Connect to the socket
    socket!.connect();

    // Listen for incoming events (newCall, callAnswered, IceCandidate)
    socket!.on('newCall', (data) {
      // Handle new call data here
      print('Received new call from ${data['callerId']}');
    });

    socket!.on('callAnswered', (data) {
      // Handle call answered
      print('Call answered by ${data['callee']}');
    });

    socket!.on('IceCandidate', (data) {
      // Handle ice candidate
      print('Received IceCandidate from ${data['sender']}');
    });
  }

  // Emit makeCall event to the server
  void makeCall(String calleeId, String sdpOffer) {
    socket!.emit('makeCall', {
      'calleeId': calleeId,
      'sdpOffer': sdpOffer,
    });
  }

  // Emit answerCall event to the server
  void answerCall(String callerId, String sdpAnswer) {
    socket!.emit('answerCall', {
      'callerId': callerId,
      'sdpAnswer': sdpAnswer,
    });
  }

  // Emit IceCandidate event to the server
  void sendIceCandidate(String calleeId, String iceCandidate) {
    socket!.emit('IceCandidate', {
      'calleeId': calleeId,
      'iceCandidate': iceCandidate,
    });
  }

  // Disconnect the socket
  void disconnect() {
    socket!.disconnect();
  }
}
