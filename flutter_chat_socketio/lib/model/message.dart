class Message {
  String message;
  String myMessage;

  Message({required this.message, required this.myMessage});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(message: json["message"], myMessage: json["myMessage"]);
  }
}
