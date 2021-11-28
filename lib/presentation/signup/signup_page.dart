import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stripe_platform_example/presentation/signup/signup_model.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SignUpModel>(
      create: (_) => SignUpModel(),
      child: Consumer<SignUpModel>(builder: (context, model, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('新規登録'),
          ),
          body: Column(
            children: [
              TextField(
                controller: model.displayNameController,
                decoration: const InputDecoration(
                  hintText: 'ユーザー名',
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  await model.signUp();
                },
                child: const Text('登録'),
              ),
            ],
          ),
        );
      }),
    );
  }
}
