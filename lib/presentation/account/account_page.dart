import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stripe_platform_example/utils/verification_status.dart';

import 'account_model.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AccountModel>(
      create: (_) => AccountModel()..init(),
      child: Consumer<AccountModel>(builder: (context, model, child) {
        final user = model.user;
        return Scaffold(
          appBar: AppBar(
            title: const Text('アカウント'),
          ),
          body: Center(
            child: Column(
              children: [
                const Icon(
                  Icons.person_rounded,
                  size: 64,
                ),
                Text(user?.displayName ?? ''),
                Text('認証ステータス : ${user?.verificationStatus?.toEnumString}'),
                ElevatedButton(
                  onPressed: () async {
                    await model.signOut();
                  },
                  child: const Text('ログアウト'),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
