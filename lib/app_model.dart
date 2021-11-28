import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as auth;

import 'domain/user_state.dart';

class AppModel {
  final _userStateStreamController = StreamController<UserState>();
  Stream<UserState> get userState => _userStateStreamController.stream;

  UserState _state = UserState.noLogin;

  AppModel() {
    _init();
  }

  Future _init() async {
    // ログイン状態の変化を監視し、変更があればUserStateをstreamで通知する
    auth.FirebaseAuth.instance.authStateChanges().listen((firebaseUser) async {
      UserState state = UserState.noLogin;
      if (firebaseUser != null) {
        state = UserState.member;
      }

      // 前回と同じ通知はしない
      if (_state == state) {
        return;
      }
      _state = state;
      _userStateStreamController.sink.add(_state);
    });
  }
}
