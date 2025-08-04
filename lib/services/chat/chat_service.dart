import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_chat_app/models/message_model.dart';
import 'package:simple_chat_app/models/user_model.dart';

class ChatService {
  // get Instance of Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // get User Stream
  /*
  List<Map<String, dynamic>> = [
  {
    'uid': 'user1',
    'name': 'User One',
    'email': 'one@example.com',
    'createdAt': Timestamp.now()
  },
  {
    'uid': 'user2',
    'name': 'User Two',
    'email': 'two@example.com',
    'createdAt': Timestamp.now()
  },
    
  ];

  */
  Stream<List<UserModel>> getUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return UserModel.fromMap(data);
      }).toList();
    });
  }

  // Send Message
  Future<void> sendMessage(String receiverId, String message) async {
    final prefs = await SharedPreferences.getInstance();
    // get Current  User Info
    final String currentUser = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp currentTime = Timestamp.now();
    final String currentUserName = prefs.getString('name') ?? 'Unknown';

    // Create Message Data
    MessageModel newMessage = MessageModel(
      senderId: currentUser,
      senderEmail: currentUserEmail,
      senderName: currentUserName,
      receiverId: receiverId,
      message: message,
      timestamp: currentTime,
    );

    // Construct chat Room ID for the Two Users ( sorted to ensure uniquieness  )
    List<String> userIds = [currentUser, receiverId];
    userIds.sort();
    String chatRoomId = userIds.join('_');

    // add new Message to Databaaase
    await _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());
  }

  // Get Messages
  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    // construct a chatroom ID for the two users
    List<String> userIds = [userId, otherUserId];
    userIds.sort();
    String chatRoomId = userIds.join('_');

    return _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}
