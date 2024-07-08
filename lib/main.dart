import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'udp_client.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final UdpClient udpClient = UdpClient();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UDP Client App',
      home: Scaffold(
        appBar: AppBar(
          title: Text('UDP Client App'),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              flex: 3,
              child: StreamBuilder<List<String>>(
                stream: udpClient.messageStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  List<String>? messages = snapshot.data;
                  if (messages == null || messages.isEmpty) {
                    return Center(child: Text('No messages yet'));
                  }
                  return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(messages[index]),
                      );
                    },
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await udpClient.sendMessage();
              },
              child: Text('Start Broadcasting'),
            ),
          ],
        ),
      ),
    );
  }
}
