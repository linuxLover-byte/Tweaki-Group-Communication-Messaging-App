import 'package:flutter/material.dart';
import 'package:tweaki/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'constant.dart';

// Create a Firestore instance
final _firestore = FirebaseFirestore.instance;
// Create a variable to store the logged-in user
User? loggedInUser;

// Define the ChatScreen class
class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';

  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

// Define the _ChatScreenState class
class _ChatScreenState extends State<ChatScreen> {
  // Create a text controller for the message input field
  final messageTextController = TextEditingController();
  // Create a Firebase Authentication instance
  final _auth = FirebaseAuth.instance;
  // Create a variable to store the message text
  String messageText = '';

  // Initialize the state
  @override
  void initState() {
    super.initState();
    // Get the current user
    getCurrentUser();
  }

  // Get the current user
  void getCurrentUser() async {
    try {
      // Get the current user from Firebase Authentication
      final user = _auth.currentUser;
      if (user != null) {
        // Set the logged-in user
        loggedInUser = user;
      }
    } catch (e) {
      // Print any errors
      print(e);
    }
  }

  // Build the chat screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar with a logout button
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.exit_to_app,
              color: Colors.white,
            ),
            onPressed: () {
              // Sign out the user
              _auth.signOut();
              // Go back to the previous screen
              Navigator.pop(context);
            },
          ),
        ],
        backgroundColor: Colors.lightBlueAccent,
      ),
      // Drawer with the user's email address
      drawer: Drawer(
        backgroundColor: Colors.lightBlueAccent,
        child: Container(
          child: Column(
            children: [
              const SafeArea(
                child: CircleAvatar(
                  backgroundImage: AssetImage("images/sender.jpg"),
                  radius: 60,
                ),
              ),
              const SizedBox(
                  height:
                      10), // Add some space between the avatar and the email
              Text(
                "${loggedInUser?.email ?? 'Unknown'}", // Display the user's email address
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
            ],
          ),
        ),
      ),
      // Background color of the screen
      backgroundColor: Colors.white,
      // Body of the screen
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Display the messages stream
            MessagesStream(),
            // Container for the message input field and send button
            Container(
              margin: const EdgeInsets.all(10.0), // Add margin to all edges
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(10.0), // Add rounded corners
                color: Colors.blue[400],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // Expanded text field for the message input
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        // Update the message text
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration.copyWith(
                        hintStyle: const TextStyle(
                            color: Colors.white), // Change hint color here
                      ),
                      style: const TextStyle(
                          color: Colors.black), // Change text color here
                    ),
                  ),
                  // Send button
                  TextButton(
                    onPressed: () {
                      // Check if the message is not empty
                      if (messageText.isNotEmpty) {
                        // Clear the message input field
                        messageTextController.clear();
                        // Add the message to the Firestore database
                        _firestore.collection('messages').add({
                          'text': messageText,
                          'sender': loggedInUser?.email ?? 'Unknown',
                        }).catchError((error) {
                          // Handle any errors
                          print("Error adding message: $error");
                        });
                      }
                    },
                    child: const Icon(Icons.send_rounded, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Define the MessagesStream class
class MessagesStream extends StatelessWidget {
  const MessagesStream({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      // Stream from the Firestore database
      stream: _firestore.collection('messages').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // Display a circular progress indicator while loading
          return const Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        // Get the list of messages from the snapshot
        final messages = snapshot.data!.docs.reversed;
        List<MessageBubble> messageBubbles = [];
        for (var message in messages) {
          // Get the message data
          final messageData = message.data() as Map<String, dynamic>;
          final messageText = messageData['text'];
          final messageSender = messageData['sender'];
          // Check if the message is from the current user
          final currentUser = loggedInUser?.email ?? '';
          // Create a MessageBubble widget
          final messageBubble = MessageBubble(
            sender: messageSender,
            text: messageText,
            isMe: currentUser == messageSender,
          );
          // Add the message bubble to the list
          messageBubbles.add(messageBubble);
        }
        // Return the list of message bubbles
        return Expanded(
          child: ListView(
            reverse: true,
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            children: messageBubbles,
          ),
        );
      },
    );
  }
}

// Define the MessageBubble class
class MessageBubble extends StatelessWidget {
  const MessageBubble(
      {super.key,
      required this.sender,
      required this.text,
      required this.isMe});
  final String sender;
  final String text;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          // Display the sender's email address
          Text(
            sender,
            style: const TextStyle(
              fontSize: 12.0,
              color: Colors.black,
            ),
          ),
          // Display the message text
          Material(
            borderRadius: isMe
                ? const BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    bottomLeft: Radius.circular(10.0),
                    bottomRight: Radius.circular(10.0),
                  )
                : const BorderRadius.only(
                    bottomLeft: Radius.circular(10.0),
                    bottomRight: Radius.circular(10.0),
                    topRight: Radius.circular(10.0),
                  ),
            elevation: 5.0,
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                text,
                style: TextStyle(
                  color: isMe ? Colors.black : Colors.black,
                  fontSize: 15.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
