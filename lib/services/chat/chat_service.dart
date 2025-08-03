import 'package:cloud_firestore/cloud_firestore.dart';

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
  Stream<List<Map<String, dynamic>>> getUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();

        return user;
      }).toList();
    });
  }

  // Send Message

  // Get Messages
}
