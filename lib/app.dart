import 'package:flutter/material.dart';
import 'package:stripe_platform_example/app_model.dart';
import 'package:stripe_platform_example/domain/user_state.dart';
import 'package:stripe_platform_example/presentation/signup/signup_page.dart';

import 'presentation/home/home_page.dart';

class App extends StatelessWidget {
  App({Key? key}) : super(key: key);

  final model = AppModel();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StripePlatFormSample',
      theme: ThemeData(primarySwatch: Colors.red),
      home: StreamBuilder(
        stream: model.userState,
        initialData: UserState.waiting,
        builder: (context, AsyncSnapshot<UserState> snapshot) {
          final UserState? state =
              snapshot.connectionState == ConnectionState.waiting
                  ? UserState.waiting
                  : snapshot.data;
          return _convertPage(state);
        },
      ),
    );
  }

  /// UserState => page
  StatelessWidget _convertPage(UserState? state) {
    switch (state) {
      // todo : Splash 画面を表示
      // case UserState.waiting:
      //   return CircularProgressIndicator();

      case UserState.noLogin:
        return SignUpPage();

      case UserState.member: // サロンメンバー
        return HomePage();

      default: // 不明
        return SignUpPage();
    }
  }
}
