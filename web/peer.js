const peer = new Peer({
  host: 'peerjs.com', // Using the free PeerJS server
  secure: true,
  port: 443,
  path: '/myapp', // Optional path
});

peer.on('open', (id) => {
  console.log('My peer ID is: ' + id);
});

peer.on('call', (call) => {
  call.answer(window.localStream); // Answer the call with local stream
  call.on('stream', (remoteStream) => {
    const remoteVideo = document.querySelector('#remote-video');
    remoteVideo.srcObject = remoteStream;
  });
});

// Initiate a call
function callPeer(peerId) {
  const call = peer.call(peerId, window.localStream);
  call.on('stream', (remoteStream) => {
    const remoteVideo = document.querySelector('#remote-video');
    remoteVideo.srcObject = remoteStream;
  });
}
