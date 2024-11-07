import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dip_app_2/components/chat_bubble.dart';
import 'package:dip_app_2/components/my_profile_button.dart';
import 'package:dip_app_2/helper/navigator_animation.dart';
import 'package:dip_app_2/screens/matching/user_details.dart';
import 'package:dip_app_2/services/auth/auth_service.dart';
import 'package:dip_app_2/services/chat/chat_service.dart';
import 'package:dip_app_2/services/database/firestore_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  final String receiverEmail;
  final String receiverID;
  final String receiverName;
  final String? profileImageUrl;

  const ChatPage(
      {super.key,
      required this.receiverEmail,
      required this.receiverID,
      required this.receiverName,
      required this.profileImageUrl});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

// to UserDetailsPage
void _navigateToUserDetails(
    BuildContext context, Map<String, dynamic> userData) {
  Navigator.push(
    context,
    CustomNavigator.createSlideRoute(UserDetailsPage(userData: userData)),
  ).then((shouldRefresh) {
    if (shouldRefresh == true) {
      Navigator.pop(context,
          true); // Pass the flag back to FriendsPage or FriendFinderPage
    }
  });
}

class _ChatPageState extends State<ChatPage> {
  // text controller
  final TextEditingController _messageController = TextEditingController();

  // chat & auth services
  final ChatService chatService = ChatService();
  final AuthService authService = AuthService();
  final FirestoreService firestoreService = FirestoreService();

  // for textfield focus => if a lot of text, next message send/receive auto scroll
  FocusNode myFocusNode = FocusNode();

  // helper function for requesting permission
  void setupPushNotifications() async {
    // get instance of FirebaseMessaging
    final fcm = FirebaseMessaging.instance;

    // called first, ask the user for permission to receive and handle push notifications
    // returns a future can be fine tune to which type to receive
    await fcm.requestPermission();

    // yields the address of the device on which the app is running
    // necessary to target specific devices for notifcaitons
    final token = await fcm.getToken();

    if (token != null) {
      final currentUserId = authService.getCurrentUser()!.uid;

      // save the token in firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .update({'fcmToken': token});
    }
  }

  @override
  void initState() {
    super.initState();

    setupPushNotifications();

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

  void sendMessage() async {
    // Fetch the sender's name
    final senderName = await firestoreService.getCurrentUserName();

    if (_messageController.text.isNotEmpty) {
      try {
        // Check if senderName is not null
        if (senderName.isNotEmpty) {
          await chatService.sendMessage(
            widget.receiverID,
            _messageController.text,
            senderName,
          );
          _messageController
              .clear(); // Clear the message controller after successful send
        } else {
          print('Error: senderName is null or empty');
        }
      } catch (e) {
        print('Error sending message: $e');
      }

      scrollDown(); // Auto-scroll to keep latest message in view
    }
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
              profileImageUrl:
                  widget.profileImageUrl == null ? '' : widget.profileImageUrl!,
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
                  _navigateToUserDetails(context, userData);
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
                  color: Theme.of(context).colorScheme.secondaryFixed,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Message...",
                    hintStyle: TextStyle(
                        color: Theme.of(context).colorScheme.secondaryFixedDim),
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
