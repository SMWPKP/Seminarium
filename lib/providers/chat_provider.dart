import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:seminarium/model/message_models.dart';

final chatProvider = ChangeNotifierProvider<ChatProvider>((ref) => ChatProvider(ref));

class ChatProvider extends ChangeNotifier {
  final ChangeNotifierProviderRef read;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  ChatProvider(this.read);

  void goToChat(BuildContext context, String userId, String userEmail) {
    GoRouter.of(context).go('/messages/chat/$userId/$userEmail',);
  }

  Future<void> sendMessage(String receiverId, String message) async {
   final String currentUserId = _firebaseAuth.currentUser!.uid;
   final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
   final Timestamp timestamp = Timestamp.now();


  Message newMessage = Message(
    senderId: currentUserId,
    senderEmail: currentUserEmail,
    receiverId: receiverId,
    message: message,
    timestamp: timestamp,
  );

  List<String> ids = [  currentUserId, receiverId ];
  ids.sort();
  String chatRoomId = ids.join("_");

_firestore.collection('chat_rooms').doc(chatRoomId).collection('messages').add(newMessage.toMap());
  }

  Future<void> sendMessageIfNotEmpty(String receiverUserID, String text, TextEditingController messageController) async {
    if (text.isNotEmpty) {
      await sendMessage(receiverUserID, text);
      messageController.clear();
    }
  }

Stream<QuerySnapshot> getMessages(String userId, String otherUserId){
  List<String> ids = [  userId, otherUserId ];
  ids.sort();
  String chatRoomId = ids.join("_");

  return _firestore.collection('chat_rooms').doc(chatRoomId).collection('messages').orderBy('timestamp', descending: false).snapshots();
}
}

