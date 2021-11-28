import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stripe_platform_example/account/account_model.dart';

class ProductListPage extends StatelessWidget {
  const ProductListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AccountModel>(
      create: (_) => AccountModel(),
      child: Consumer<AccountModel>(builder: (context, model, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('商品一覧'),
          ),
          body: Column(
            children: [
              const Text('商品一覧ページ'),
            ],
          ),
        );
      }),
    );
  }
}
