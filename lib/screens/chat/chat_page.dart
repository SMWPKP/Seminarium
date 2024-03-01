import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seminarium/providers/chat_provider.dart';
import 'package:seminarium/widgets/chat_bubble.dart';

class ChatPage extends ConsumerWidget {
  final String chatId;
  final String receiverUserEmail;
  final String receiverUserID;
  final bool hideNavigationBar;
 
  ChatPage({required this.receiverUserEmail, required this.receiverUserID, required this.chatId, required this.hideNavigationBar});

  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatProviderValue = ref.watch(chatProvider.notifier);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      //appBar
      appBar: AppBar(
        title: Text(receiverUserEmail),
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // Dodaj przycisk powrotu
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          CircleAvatar(
            backgroundImage: NetworkImage('https://warsawdog.com/wp-content/uploads/2021/10/akita.jpg'), // Zastąp URL prawdziwym URL awatara
          ),
        ],
      ),
      //background
      body: Column(
        children: <Widget>[
          Expanded(
            child: _buildMessageList(chatProviderValue),          
          ),
          _buildMessageInput(chatProviderValue),
          const SizedBox(height: 25,),
        ],
      ),
    );
  }

Widget _buildMessageInput(ChatProvider chatProviderValue){
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal:25),
    child: Row(
      children: [
        Expanded(child: TextField(
          controller: _messageController,
          decoration: const InputDecoration(
            hintText: 'Type a message',
          ),
          obscureText: false,
        )),
        IconButton(onPressed: () => chatProviderValue.sendMessageIfNotEmpty(receiverUserID, _messageController.text, _messageController), icon: const Icon(Icons.send)), //scecond _messageController clear text
      ],
    ),
  );
}

Widget _buildMessageItem(DocumentSnapshot document){
  Map<String, dynamic> data = document.data() as Map<String, dynamic>;

  var alignment = data['senderId'] == _firebaseAuth.currentUser!.uid ? Alignment.centerRight : Alignment.centerLeft;
  
  return Container(
    alignment: alignment,
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: (data['senderId'] == _firebaseAuth.currentUser!.uid) ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisAlignment: (data['senderId'] == _firebaseAuth.currentUser!.uid) ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Text(data['senderEmail']),
          const SizedBox(height: 5,),
          ChatBubble(message: data['message'])
        ],
      ),
    )
  );
}

Widget _buildMessageList(ChatProvider chatProvider){
  return StreamBuilder(stream: chatProvider.getMessages(receiverUserID, _firebaseAuth.currentUser!.uid),
  builder: (context, snapshot){
    if(snapshot.hasError){
      return Text('Error' + snapshot.error.toString());
    }

    if(snapshot.connectionState == ConnectionState.waiting){
      return const Text('Loading chat...');
    }

    return ListView(children: snapshot.data!.docs.map((document) => _buildMessageItem(document)).toList(),);
  }
  );
}

}
