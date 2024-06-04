import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:seminarium/model/user_page_models.dart';
import 'package:seminarium/providers/user_provider.dart';
import 'package:seminarium/widgets/profile_widget.dart';
import 'package:seminarium/widgets/textfield_widget.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  late UserPage userAcc;
  final ImagePicker picker = ImagePicker();
  final FirebaseStorage storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    userAcc = ref.read(userProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              ref.read(userProvider.notifier).saveUser(userAcc);
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
          ProfileWidget(
            imagePath: userAcc.imagePath,
            isEdit: true,
            onClicked: () async {
              await ref.read(userProvider.notifier).uploadImage();
            },
          ),
          const SizedBox(height: 24),
          TextfieldWidget(
            label: 'Email',
            text: userAcc.email,
            onChanged: (email) {
              userAcc = userAcc.copyWith(email: email);
              ref.read(userProvider.notifier).state = userAcc;
            },
          ),
          const SizedBox(height: 24),
          TextfieldWidget(
            label: 'Numer telefonu',
            text: userAcc.phoneNumber.toString(),
            onChanged: (phoneNumber) {
              userAcc = userAcc.copyWith(phoneNumber: int.parse(phoneNumber));
              ref.read(userProvider.notifier).state = userAcc;
            },
          ),
          const SizedBox(height: 24),
          TextfieldWidget(
            label: 'O mnie',
            text: userAcc.about,
            maxLines: 5,
            onChanged: (about) {
              userAcc = userAcc.copyWith(about: about);
              ref.read(userProvider.notifier).state = userAcc;
            },
          ),
        ],
      ),
    );
  }
}
