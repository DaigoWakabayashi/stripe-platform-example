import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'account_model.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AccountModel>(
      create: (_) => AccountModel(),
      child: Consumer<AccountModel>(builder: (context, model, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('アカウント'),
          ),
          body: Column(
            children: [
              Text('アカウント'),
            ],
          ),
        );
      }),
    );
  }
}
