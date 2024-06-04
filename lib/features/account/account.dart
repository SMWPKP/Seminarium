import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:seminarium/model/user_page_models.dart';
import 'package:seminarium/providers/user_provider.dart';
import 'package:seminarium/widgets/profile_widget.dart';

class Account extends ConsumerStatefulWidget {
  const Account({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AccountState();
}

class _AccountState extends ConsumerState<Account> {
  @override
  void initState() {
    super.initState();
    ref.read(userProvider.notifier).loadUser().then((_) {
      final userAcc = ref.read(userProvider);
      print('User data in initState: ${userAcc.name}, ${userAcc.email}');
    });
  }

  @override
  Widget build(BuildContext context) {
    final userAcc = ref.watch(userProvider);

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                ProfileWidget(
                  imagePath: userAcc.imagePath,
                  onClicked: () {
                    GoRouter.of(context).go('/account/edit');
                  },
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildName(userAcc),
                      const SizedBox(height: 8),
                      buildEmail(userAcc),
                      const SizedBox(height: 8),
                      buildPhoneNumber(userAcc),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: buildAbout(userAcc),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildName(UserPage user) => Text(
        user.name,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      );

  Widget buildEmail(UserPage user) => Text(
        user.email,
        style: const TextStyle(color: Colors.grey),
      );

  Widget buildPhoneNumber(UserPage user) => RichText(
        text: TextSpan(
          text: 'Numer telefonu: ',
          style: const TextStyle(color: Colors.grey),
          children: [
            TextSpan(
              text: user.phoneNumber.toString(),
              style: const TextStyle(color: Colors.black),
            ),
          ],
        ),
      );

  Widget buildAbout(UserPage user) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('O mnie',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text(
              user.about,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
          ],
        ),
      );

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
