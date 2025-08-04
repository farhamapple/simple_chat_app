import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:simple_chat_app/components/my_textfield.dart';
import 'package:simple_chat_app/models/message_model.dart';
import 'package:simple_chat_app/pages/chat_bubble.dart';
import 'package:simple_chat_app/services/auth/auth_service.dart';
import 'package:simple_chat_app/services/chat/chat_service.dart';

class ChatPage extends StatefulWidget {
  final String receiverEmail;
  final String receiverName;
  final String receiverId;

  ChatPage({
    super.key,
    required this.receiverEmail,
    required this.receiverName,
    required this.receiverId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // Text Controller
  final TextEditingController _messageController = TextEditingController();

  // Chat & Auth Services
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  // For TextField Focus
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // Add Listener to Focus Node
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        // Do something when the TextField gains focus
        Future.delayed(const Duration(milliseconds: 500), () => scrollDown());
      } else {
        // Do something when the TextField loses focus
      }
    });

    // Wait a Bit For ListView to Be Built, Then Scroll to Down
    Future.delayed(const Duration(milliseconds: 500), () {
      scrollDown();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // Scroll Down Function
  final ScrollController _scrollController = ScrollController();
  void scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  // Send Message Function
  void _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      // Send Message using Chat Service
      await _chatService.sendMessage(
        widget.receiverId,
        _messageController.text,
      );

      // Clear the message input field
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.receiverName}'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: MyTextField(
                    hintText: "Type a Message",
                    obscureText: false,
                    controller: _messageController,
                    focusNode: _focusNode,
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                  ),
                  margin: const EdgeInsets.only(right: 10.0),
                  child: IconButton(
                    icon: Icon(Icons.send),
                    onPressed: _sendMessage,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build Message List
  Widget _buildMessageList() {
    String senderId = _authService.getCurrentUser()?.uid ?? '';
    if (senderId == widget.receiverId) {
      return Center(child: Text('You cannot chat with yourself.'));
    }
    return StreamBuilder(
      stream: _chatService.getMessages(widget.receiverId, senderId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          // final messages = snapshot.data!;

          return ListView(
            controller: _scrollController,
            children: snapshot.data!.docs
                .map((doc) => _buildMessageItem(doc))
                .toList(),
          );
        }
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    final messageData = MessageModel.fromMap(
      doc.data() as Map<String, dynamic>,
    );

    // Is Current User's Message?
    bool isCurrentUserMessage =
        messageData.senderId == _authService.getCurrentUser()?.uid;

    // Align Message to the right if it's from the current user
    var aligment = isCurrentUserMessage
        ? Alignment.centerRight
        : Alignment.centerLeft;

    return Container(
      alignment: aligment,
      child: Column(
        crossAxisAlignment: isCurrentUserMessage
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          ChatBubble(
            message: messageData.message,
            isCurrentUser: isCurrentUserMessage,
          ),
        ],
      ),
    );
  }
}
