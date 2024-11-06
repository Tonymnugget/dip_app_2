import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderID;
  final String senderEmail;
  final String senderName;
  final String receiverID;
  final String message;
  final Timestamp timestamp;
  final bool isUnread;

  Message({
    required this.senderID,
    required this.senderEmail,
    required this.senderName,
    required this.receiverID,
    required this.message,
    required this.timestamp,
    required this.isUnread, // default when a new message is sent
  });

  // convert to a map
  Map<String, dynamic> toMap() {
    return {
      'senderID': senderID,
      'senderEmail': senderEmail,
      'senderName': senderName,
      'receiverID': receiverID,
      'message': message,
      'timestamp': timestamp,
      'isUnread': isUnread,
    };
  }
}
