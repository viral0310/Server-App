import 'dart:async';
import 'dart:convert';
import 'dart:io';

class UdpClient {
  static final int broadcastPort = 3000;
  RawDatagramSocket? udpSocket;
  StreamController<List<String>> _messageController = StreamController<List<String>>.broadcast();
  Stream<List<String>> get messageStream => _messageController.stream;

  List<String> messages = [];

  UdpClient() {
    init();
  }

  void init() async {
    udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, broadcastPort);
    udpSocket!.listen((RawSocketEvent e) {
      if (e == RawSocketEvent.read) {
        Datagram? dg = udpSocket!.receive();
        if (dg != null) {
          String message = utf8.decode(dg.data).trim();
          String formattedMessage = '${dg.address.address}: ${dg.port} - $message';
          messages.insert(0, formattedMessage); // Insert at the beginning for reverse display
          _messageController.add(messages.toList()); // Broadcast updated list
        }
      }
    });
  }

  Future<void> sendMessage() async {
    String message = 'start';
    udpSocket!.broadcastEnabled = true;
    udpSocket!.send(message.codeUnits, InternetAddress('255.255.255.255'), broadcastPort);
    print('Sent: $message');
  }

  void close() {
    _messageController.close();
    udpSocket?.close();
  }
}
