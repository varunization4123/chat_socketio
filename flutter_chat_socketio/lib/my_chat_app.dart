import 'package:flutter/material.dart';
import 'package:flutter_chat_socketio/controller/chat_controller.dart';
import 'package:flutter_chat_socketio/model/message.dart';
import 'package:get/get.dart';
import 'utils/colors.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class MyChatApp extends StatefulWidget {
  const MyChatApp({Key? key}) : super(key: key);

  @override
  State<MyChatApp> createState() => _MyChatAppState();
}

class _MyChatAppState extends State<MyChatApp> {
  TextEditingController messageController = TextEditingController();
  late IO.Socket socket;
  ChatController chatController = ChatController();

  @override
  void initState() {
    socket = IO.io(
      'http://localhost:4000',
      IO.OptionBuilder()
          .setTransports(['websocket']) // for Flutter or Dart VM
          .disableAutoConnect() // disable auto-connection
          .build(),
    );
    socket.connect();
    setUpSocketListner();
    super.initState();
  }

  void sendMessage(String text) {
    var messageJson = {"message": text, "myMessage": socket.id};
    socket.emit('message', messageJson);
    chatController.chatMessages.add(Message.fromJson(messageJson));
  }

  void setUpSocketListner() {
    socket.on('message-received', (data) {
      print(data);
      chatController.chatMessages.add(Message.fromJson(data));
    });
    socket.on('connected-user', (data) {
      print(data);
      chatController.connectedUser.value = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: purple,
      ),
      body: Container(
        color: black,
        child: Column(
          children: [
            Expanded(
                child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Obx(
                () => Text(
                  'Connected Users : ${chatController.connectedUser}',
                  style: const TextStyle(color: white, fontSize: 16),
                ),
              ),
            )),
            Expanded(
              flex: 9,
              child: Obx(
                () => ListView.builder(
                    itemCount: chatController.chatMessages.length,
                    itemBuilder: ((context, index) {
                      var currentItem = chatController.chatMessages[index];
                      return MessageItem(
                        message: currentItem.message,
                        myMessage: currentItem.myMessage == socket.id,
                      );
                    })),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: TextField(
                cursorColor: white,
                style: const TextStyle(color: white, fontSize: 24),
                controller: messageController,
                decoration: InputDecoration(
                    focusColor: white,
                    enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: white,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: white,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(10)),
                    suffixIcon: Container(
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: purple,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        color: white,
                        onPressed: () {
                          sendMessage(messageController.text);
                          messageController.clear();
                        },
                        icon: const Icon(Icons.send),
                      ),
                    )),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class MessageItem extends StatelessWidget {
  const MessageItem({Key? key, required this.myMessage, required this.message})
      : super(key: key);
  final bool myMessage;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: myMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: myMessage ? purple : white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              message,
              style: TextStyle(fontSize: 18, color: myMessage ? white : purple),
            ),
            const SizedBox(
              width: 3,
            ),
            Text(
              '1:10 AM',
              style: TextStyle(fontSize: 12, color: myMessage ? white : purple),
            ),
          ],
        ),
      ),
    );
  }
}
