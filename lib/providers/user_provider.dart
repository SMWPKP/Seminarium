import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:seminarium/model/user_page_models.dart';

final userProvider = StateNotifierProvider<UserNotifier, UserPage>((ref) {
  return UserNotifier();
});

class UserNotifier extends StateNotifier<UserPage> {
  UserNotifier()
      : super(UserPage(
            imagePath: '',
            name: '',
            email: FirebaseAuth.instance.currentUser?.email ?? 'uzupełnij dane',
            about: 'uzupełnij dane',
            phoneNumber: 123456789));

  final userCollection = FirebaseFirestore.instance.collection('users');
  final storage = FirebaseStorage.instance;

  Future<void> loadUser() async {
    final userDoc =
        await userCollection.doc(FirebaseAuth.instance.currentUser!.uid).get();

    if (userDoc.exists) {
      state = UserPage.fromFirestore(userDoc.data()!);
    }
  }

  Future<void> saveUser(UserPage user) async {
    await userCollection
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set(user.toFirestore());
    state = user;

    await loadUser();
  }

  final ImagePicker picker = ImagePicker();

  Future<void> uploadImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final ref = storage
          .ref()
          .child('user_images')
          .child('${FirebaseAuth.instance.currentUser!.uid}.png');
      await ref.putFile(File(image.path));

      final url = await ref.getDownloadURL();

      state = state.copyWith(imagePath: url);

      await saveUser(state);
    }
  }
}
