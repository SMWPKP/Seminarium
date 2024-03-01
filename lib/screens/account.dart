import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Account extends StatelessWidget {
  const Account({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Wyloguj',
            onPressed: () async {
              try {
                await _signOut();
                if(FirebaseAuth.instance.currentUser == null){
                  GoRouter.of(context).go('/login');
                }
              } catch (e) {
                print(e);
              }
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('To jest ekran konta'),
      ),
    );
  }
}

Future<void> _signOut() async {
  await FirebaseAuth.instance.signOut();
}


