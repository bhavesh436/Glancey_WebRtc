import 'package:flutter/material.dart';
import 'socket_service.dart'; // Import the SocketService class

class CallScreen extends StatefulWidget {
  final String userId;

  CallScreen({required this.userId});

  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  late SocketService _socketService;

  @override
  void initState() {
    super.initState();
    _socketService = SocketService();
    _socketService.initSocket(widget.userId); // Initialize socket with user ID
  }

  @override
  void dispose() {
    _socketService.disconnect(); // Disconnect socket on screen disposal
    super.dispose();
  }

  // Example call method
  void _makeCall(String calleeId, String sdpOffer) {
    _socketService.makeCall(calleeId, sdpOffer);
  }

  // Example answer call method
  void _answerCall(String callerId, String sdpAnswer) {
    _socketService.answerCall(callerId, sdpAnswer);
  }

  // Example send Ice Candidate method
  void _sendIceCandidate(String calleeId, String iceCandidate) {
    _socketService.sendIceCandidate(calleeId, iceCandidate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Call Screen'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                // Example: Initiate a call
                _makeCall('calleeId', 'sdpOfferHere');
              },
              child: Text('Make Call'),
            ),
            ElevatedButton(
              onPressed: () {
                // Example: Answer a call
                _answerCall('callerId', 'sdpAnswerHere');
              },
              child: Text('Answer Call'),
            ),
            ElevatedButton(
              onPressed: () {
                // Example: Send Ice Candidate
                _sendIceCandidate('calleeId', 'iceCandidateHere');
              },
              child: Text('Send Ice Candidate'),
            ),
          ],
        ),
      ),
    );
  }
}
