import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

final authProvider = Provider<AuthService>((ref) => AuthService());

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _firestore.collection('users').doc(_auth.currentUser!.uid).set({
        'uid': _auth.currentUser!.uid,
        'email': email,
      }, SetOptions(merge: true));

      return true;
    } on FirebaseAuthException catch (e) {
      // Handle exceptions
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _firestore.collection('users').doc(_auth.currentUser!.uid).set({
        'uid': _auth.currentUser!.uid,
        'email': email,
      }, SetOptions(merge: true));

      return true;
    } on FirebaseAuthException catch (e) {
      // Handle exceptions
      return false;
    }
  }


  User? get currentUser => _auth.currentUser;
}