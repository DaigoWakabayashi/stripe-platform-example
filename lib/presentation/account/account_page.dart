import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stripe_platform_example/presentation/edit_card/edit_card_page.dart';
import 'package:stripe_platform_example/presentation/identification/identification_page.dart';
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
                Text('本人確認 : ${user?.status?.toEnumString}'),
                Text('被決済 : ${user?.chargesEnabled}'),
                const Divider(),
                ListTile(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return const EditCardPage();
                        },
                      ),
                    );
                  },
                  title: const Text('クレジットカードの追加'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                ),
                const Divider(),
                ListTile(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return const IdentificationPage();
                        },
                      ),
                    );
                  },
                  title: const Text('本人確認'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                ),
                const Divider(),
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
