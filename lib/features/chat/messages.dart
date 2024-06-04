import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seminarium/providers/chat_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Messages extends ConsumerWidget {
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatProviderValue = ref.watch(chatProvider.notifier);
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Users'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();

           return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot user = snapshot.data!.docs[index];

if(currentUser != null && currentUser.email != user['email']) {
              return ListTile(
  title: Text(user['email']), 
  onTap: () {
    chatProviderValue.goToChat(context, user.id, user['email']);
  },
);
} else {
  return SizedBox.shrink();
}
            }
          );
        },
      ),
    );
  }
}