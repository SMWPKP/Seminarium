import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:seminarium/model/user_page.dart';
import 'package:seminarium/providers/profil_provider.dart';
import 'package:seminarium/widgets/profile_widget.dart';

class Account extends ConsumerStatefulWidget {
  const Account({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AccountState();
}

class _AccountState extends ConsumerState<Account> {
  @override
  Widget build(BuildContext context) {
    final userAcc = ProfilProvider.myUser;

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
                  if (FirebaseAuth.instance.currentUser == null) {
                    GoRouter.of(context).go('/login');
                  }
                } catch (e) {
                  print(e);
                }
              },
            ),
          ],
        ),
        body: ListView(
          physics: BouncingScrollPhysics(),
          children: [
            ProfileWidget(
              imagePath: userAcc.imagePath,
              onClicked: () {
                GoRouter.of(context).go('/account/edit');
              },
            ),
            const SizedBox(height: 24),
            buildName(userAcc),
            const SizedBox(height: 48),
            buildAbout(userAcc),
          ],
        ));
  }

  Widget buildName(UserPage user) => Column(
        children: [
          Text(
            user.name,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 4),
          RichText(
              text: TextSpan(
                  text: 'Numer telefonu: ',
                  style: TextStyle(color: Colors.grey),
                  children: <TextSpan>[
                TextSpan(
                  text: user.phoneNumber.toString(),
                  style: TextStyle(color: Colors.black),
                ),
              ]))
        ],
      );

  Widget buildAbout(UserPage user) => Container(
        padding: EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('O mnie',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text(
              user.about,
              style: TextStyle(fontSize: 16, height: 1.4),
            ),
          ],
        ),
      );

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
