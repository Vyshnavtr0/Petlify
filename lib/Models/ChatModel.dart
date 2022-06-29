class ChatModel {
  String? id;
  String? chat;
  bool? sender;
  bool? seen;
  bool? reply;
  String? type;
  String? reply_msg;
  bool? reply_to;

  ChatModel({this.chat, this.id, this.sender, this.seen, this.type});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chat': chat,
      'sender': sender,
      'seen': seen,
      'type': type,
      'reply': reply,
      'reply_msg': reply_msg,
      'reply_to': reply_to
    };
  }
}
