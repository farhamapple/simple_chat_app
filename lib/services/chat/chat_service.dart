import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simple_chat_app/models/user_model.dart';

class ChatService {
  // get Instance of Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  // Get Messages
}
