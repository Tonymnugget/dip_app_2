import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dip_app_2/components/chat_bubble.dart';
import 'package:dip_app_2/components/my_profile_button.dart';
import 'package:dip_app_2/helper/navigator_animation.dart';
import 'package:dip_app_2/screens/matching/user_details.dart';
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
  final ChatService chatService = ChatService();
  final AuthService authService = AuthService();

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
      await chatService.sendMessage(widget.receiverID, _messageController.text);

      // clear text controller after sending
      _messageController.clear();
    }

    // Everytime a message is sent, auto scroll so keyboard does not cover message
    scrollDown();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.inverseSurface,
      appBar: AppBar(
        title: Text(
          widget.receiverName,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Theme.of(context)
              .colorScheme
              .tertiary, // Change the back arrow color to white
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: MyProfileButton(
              profileImageUrl: widget.profileImageUrl,
              onTap: () async {
                // Fetch userData from Firestore
                DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.receiverID)
                    .get();

                if (userSnapshot.exists) {
                  Map<String, dynamic> userData =
                      userSnapshot.data() as Map<String, dynamic>;

                  // Navigate to UserDetailsPage with the userData
                  Navigator.push(
                    context,
                    CustomNavigator.createSlideRoute(
                        UserDetailsPage(userData: userData)),
                  );
                }
              },
            ),
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
    String senderID = authService.getCurrentUser()!.uid;
    return StreamBuilder(
      stream: chatService.getMessage(widget.receiverID, senderID),
      builder: (context, snapshot) {
        // errors
        if (snapshot.hasError) {
          return const Text("Error");
        }

        // loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading...");
        }

        // retrieve this messages
        var messages = snapshot.data!.docs;

        // return list view
        return ListView.builder(
          controller: _scrollController,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            // Get current message data
            var currentMessage = messages[index];
            Map<String, dynamic> currentData =
                currentMessage.data() as Map<String, dynamic>;

            // Get current message date
            Timestamp currentTimestamp =
                currentData['timestamp'] ?? Timestamp.now();
            DateTime currentDateTime = currentTimestamp.toDate();
            String currentDateString =
                DateFormat('yyyy-MM-dd').format(currentDateTime);

            // Initialize variable to hold previous date string
            String previousDateString = '';

            if (index > 0) {
              // Get previous message data
              var previousMessage = messages[index - 1];
              Map<String, dynamic> previousData =
                  previousMessage.data() as Map<String, dynamic>;

              // Get previous message date
              Timestamp previousTimestamp =
                  previousData['timestamp'] ?? Timestamp.now();
              DateTime previousDateTime = previousTimestamp.toDate();
              previousDateString =
                  DateFormat('yyyy-MM-dd').format(previousDateTime);
            }

            // Decide whether to show date header
            bool showDateHeader = false;
            if (index == 0 || currentDateString != previousDateString) {
              showDateHeader = true;
            }

            List<Widget> messageWidgets = [];

            if (showDateHeader) {
              // Add date header
              messageWidgets.add(
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        DateFormat('MMMM dd, yyyy').format(currentDateTime),
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }

            // Add message bubble
            messageWidgets.add(_buildMessageItem(messages[index]));

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: messageWidgets,
            );
          },
        );
      },
    );
  }

  // build message item also show timestamp for each messages
  Widget _buildMessageItem(QueryDocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // is current user
    bool isCurrentUser = data['senderID'] == authService.getCurrentUser()!.uid;

    // align message to the right if sender is the current user, otherwise left
    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    // convert the timestamp to readable format
    Timestamp timestamp = data['timestamp'] ?? Timestamp.now();
    DateTime dateTime = timestamp.toDate();
    bool is24HourFormat = MediaQuery.of(context).alwaysUse24HourFormat;
    String formattedTime = is24HourFormat
        ? DateFormat('HH:mm').format(dateTime)
        : DateFormat('hh:mm a').format(dateTime);

    return Container(
      alignment: alignment,
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          ChatBubble(
            timestamp: formattedTime,
            message: data["message"],
            isCurrentUser: isCurrentUser,
          ),
        ],
      ),
    );
  }

  // build message input
  Widget _buildUserInput() {
    return Container(
      color: Theme.of(context).colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            // textfield should take up most of the space
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Message...",
                    border: InputBorder.none,
                  ),
                  minLines: 1,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  focusNode: myFocusNode,
                  controller: _messageController,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // send button
            GestureDetector(
              onTap: sendMessage,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Color.fromARGB(255, 131, 191, 255),
                    shape: BoxShape.circle),
                child: const Icon(Icons.send, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*

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


*/