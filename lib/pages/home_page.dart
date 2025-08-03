import 'package:flutter/material.dart';
import 'package:simple_chat_app/components/my_drawer.dart';
import 'package:simple_chat_app/components/my_user_tile.dart';
import 'package:simple_chat_app/pages/chat_page.dart';
import 'package:simple_chat_app/services/auth/auth_service.dart';
import 'package:simple_chat_app/services/chat/chat_service.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  // chat & auth Service
  final AuthService _authService = AuthService();
  final ChatService _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: const MyDrawer(),
      body: _buildUserList(),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chatService.getUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No users found.'));
        } else {
          final users = snapshot.data!;
          // return ListView.builder(
          //   itemCount: users.length,
          //   itemBuilder: (context, index) {
          //     final user = users[index];
          //     return ListTile(
          //       title: Text(user.name),
          //       subtitle: Text(user.email),
          //       onTap: () {
          //         // Handle user tap
          //       },
          //     );
          //   },
          // );

          return ListView(
            children: snapshot.data!
                .map<Widget>(
                  (userData) => _buildUserListItem(userData, context),
                )
                .toList(),
          );
        }
      },
    );
  }

  Widget _buildUserListItem(
    Map<String, dynamic> userData,
    BuildContext context,
  ) {
    return MyUserTile(
      text: userData['name'],
      onTap: () {
        // Handle user tap, e.g., navigate to chat page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(receiverEmail: userData['email']),
          ),
        );
      },
    );
  }
}
