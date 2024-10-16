import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dip_app_2/components/chat_bubble.dart';
import 'package:dip_app_2/components/my_profile_button.dart';
import 'package:dip_app_2/components/my_textfield.dart';
import 'package:dip_app_2/services/auth/auth_service.dart';
import 'package:dip_app_2/services/chat/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  final String receiverEmail;
  final String receiverID;
  final String receiverName;
  final String profileImageUrl;

  const ChatPage(
      {super.key,
      required this.receiverEmail,
      required this.receiverID,
      required this.receiverName,
      required this.profileImageUrl});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // text controller
  final TextEditingController _messageController = TextEditingController();

  // chat & auth services
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  // for textfield focus => if a lot of text, next message send/receive auto scroll
  FocusNode myFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // add listener to focus node
    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        // if we are in focus, cause a delay so that the keyboard has time to show up
        // then the amopunt of remaining space will be calculated,
        // then scroll down
        Future.delayed(
          const Duration(milliseconds: 500),
          () => scrollDown(),
        );
      }
    });

    // wait for listview to be built, then scroll to bottom
    Future.delayed(
      const Duration(milliseconds: 500),
      () => scrollDown(),
    );
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // scroll controller
  final ScrollController _scrollController = ScrollController();
  void scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  // send message
  void sendMessage() async {
    // if there is something inside the textfield
    if (_messageController.text.isNotEmpty) {
      // send the message
      await _chatService.sendMessage(
          widget.receiverID, _messageController.text);

      // clear text controller after sending
      _messageController.clear();
    }

    // Everytime a message is sent, auto scroll so keyboard does not cover message
    scrollDown();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          widget.receiverName,
          style: TextStyle(
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
        actions: [
          MyProfileButton(
            profileImageUrl: widget.profileImageUrl,
            onTap: () {
              print("profile pic tapped");
            },
          )
        ],
      ),
      body: Column(
        children: [
          // display all messages
          Expanded(
            child: _buildMessageList(),
          ),

          // user input
          _buildUserInput(),
        ],
      ),
    );
  }

  // build message list
  Widget _buildMessageList() {
    String senderID = _authService.getCurrentUser()!.uid;
    return StreamBuilder(
      stream: _chatService.getMessage(widget.receiverID, senderID),
      builder: (context, snapshot) {
        // errors
        if (snapshot.hasError) {
          return const Text("Error");
        }

        // loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading...");
        }

        // retrieve this messages and determine the last message
        var messages = snapshot.data!.docs;
        QueryDocumentSnapshot? lastSenderMessage;
        QueryDocumentSnapshot? lastReceiverMessage;

        // Identify the last message sent by the sender and receiver
        for (var message in messages) {
          Map<String, dynamic> data = message.data() as Map<String, dynamic>;
          if (data['senderID'] == senderID) {
            lastSenderMessage = message;
          } else {
            lastReceiverMessage = message;
          }
        }

        // return list view
        return ListView.builder(
          controller: _scrollController,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            var isLastSenderMessage =
                messages[index].id == lastSenderMessage?.id;
            var isLastReceiverMessage =
                messages[index].id == lastReceiverMessage?.id;
            return _buildMessageItem(
                messages[index], isLastSenderMessage, isLastReceiverMessage);
          },
        );
      },
    );
  }

  // build message item
  Widget _buildMessageItem(QueryDocumentSnapshot doc, bool isLastSenderMessage,
      bool isLastReceiverMessage) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // is current user
    bool isCurrentUser = data['senderID'] == _authService.getCurrentUser()!.uid;

    // align message to the right if sender is the current user, otherwise left
    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    // convert the timestamp to readable format
    Timestamp timestamp = data['timestamp'] ?? Timestamp.now();
    DateTime dateTime = timestamp.toDate();
    String formattedTime = DateFormat('hh:mm a').format(dateTime);

    return Container(
      alignment: alignment,
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          ChatBubble(
            message: data["message"],
            isCurrentUser: isCurrentUser,
          ),

          // Display the timestamp only for the last message
          if (isLastSenderMessage || isLastReceiverMessage)
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                formattedTime,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  // build message input
  Widget _buildUserInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 50.0),
      child: Row(
        children: [
          // textfield should take up most of the space
          Expanded(
            child: MyTextField(
                focusNode: myFocusNode,
                hintText: "Type a message",
                obscureText: false,
                controller: _messageController),
          ),

          // send button
          // TODO: change this to frontend design
          Container(
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: sendMessage,
              icon: const Icon(
                Icons.arrow_upward,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
