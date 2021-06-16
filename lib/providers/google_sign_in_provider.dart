import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInProvider extends ChangeNotifier {
  final googleSignIn = GoogleSignIn();
  bool _isSigningIn;
  String uid;
  String displayName;
  String email;

  GoogleSignInProvider() {
    _isSigningIn = false;
  }

  bool get isSigningIn => _isSigningIn;

  set isSigningIn(bool isSigningIn) {
    _isSigningIn = isSigningIn;
    notifyListeners();
  }

  Future login() async {
    isSigningIn = true;

    final user = await googleSignIn.signIn();
    if (user == null) {
      isSigningIn = false;
      return;
    } else {
      final googleAuth = await user.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      uid = FirebaseAuth.instance.currentUser.uid;
      displayName = FirebaseAuth.instance.currentUser.displayName;
      email = FirebaseAuth.instance.currentUser.email;
      await storeToFirestore(FirebaseAuth.instance.currentUser);
      isSigningIn = false;
      notifyListeners();
    }
  }

  Future<void> storeToFirestore(User user) async {
    var snapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (!snapshot.exists) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'email': user.email,
        'name': user.displayName,
        'imageUrl': user.photoURL,
        'groupId': [],
      });
    }

  }

  void logout() async {
    await googleSignIn.disconnect();
    FirebaseAuth.instance.signOut();
  }

  // String get uid{
  //   return _uid;
  // }
  // set uid(String uId){
  //   _uid = uId;
  // }
}
