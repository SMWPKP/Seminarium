import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:seminarium/model/user_page.dart';
import 'package:seminarium/providers/profil_provider.dart';
import 'package:seminarium/widgets/profile_widget.dart';
import 'package:seminarium/widgets/textfield_widget.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  UserPage userAcc = ProfilProvider.myUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              GoRouter.of(context).pop();
            },
            icon: const Icon(Icons.done),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 32),
        physics: BouncingScrollPhysics(),
        children: [
          ProfileWidget(imagePath: userAcc.imagePath,
          isEdit: true,
           onClicked: () async {},
          ),
          const SizedBox(height: 24),
          TextfieldWidget(
            label: 'Email',
            text: userAcc.email,
            onChanged: (email) {},
          ),
          const SizedBox(height: 24),
          TextfieldWidget(
            label: 'Numer telefonu',
            text: userAcc.phoneNumber.toString(),
            onChanged: (phoneNumber) {},
          ),
          const SizedBox(height: 24),
          TextfieldWidget(
            label: 'O mnie',
            text: userAcc.about,
            maxLines: 5,
            onChanged: (about) {},
          ),
        ],
      ),
    );
  }
}
