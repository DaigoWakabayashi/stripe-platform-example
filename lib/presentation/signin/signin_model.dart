import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignInModel extends ChangeNotifier {
  Future<void> signIn() async {
    // Google ログイン
    final credential = await _signInWithGoogle();

    // user ドキュメントがあるか確認
    final userId = credential.user?.uid;
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    // user ドキュメントがない場合は作成する
    if (!doc.exists) {
      // todo : Stripe Customer の作成

      // user ドキュメントを作成
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'id': userId,
        'displayName': credential.user?.displayName,
        'email': credential.user?.email,
      });
    }
  }

  Future<UserCredential> _signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
}
