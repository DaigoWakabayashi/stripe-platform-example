import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:stripe_platform_example/repository/stripe_repository.dart';
import 'package:stripe_platform_example/repository/user_repository.dart';

class SignInModel extends ChangeNotifier {
  final userRepo = UserRepository();
  final stripeRepo = StripeRepository();

  Future<void> signIn() async {
    // Google ログイン
    final credential = await _signInWithGoogle();

    // user ドキュメントがあるか確認
    final userId = credential.user?.uid;
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    // user ドキュメントがない場合は作成
    if (!doc.exists) {
      /// Stripe の customer（お金を払う側のアカウント）を作成
      final customerId =
          await stripeRepo.createCustomer(credential.user?.email ?? '');

      /// Stripe の connectAccount (お金を受け取る側のアカウント）を作成
      final accountId =
          await stripeRepo.createConnectAccount(credential.user?.email ?? '');

      // user ドキュメントを作成
      await userRepo.createUser(
        credential.user,
        customerId,
        accountId,
      );
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
