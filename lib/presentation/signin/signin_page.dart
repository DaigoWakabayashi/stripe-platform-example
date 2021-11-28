import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:provider/provider.dart';

import 'signin_model.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SignInModel>(
      create: (_) => SignInModel(),
      child: Consumer<SignInModel>(builder: (context, model, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('ログイン')),
          body: Center(
            child: SizedBox(
              height: 64,
              child: SignInButton(
                Buttons.Google,
                onPressed: () async {
                  await model.signIn();
                },
              ),
            ),
          ),
        );
      }),
    );
  }
}
