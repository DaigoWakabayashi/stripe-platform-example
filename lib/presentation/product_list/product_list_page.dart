import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stripe_platform_example/presentation/add_product/add_product_page.dart';
import 'package:stripe_platform_example/utils/int_formatter.dart';
import 'package:stripe_platform_example/utils/show_dialog.dart';
import 'package:stripe_platform_example/utils/verification_status.dart';

import 'product_list_model.dart';

class ProductListPage extends StatelessWidget {
  const ProductListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProductListModel>(
      create: (_) => ProductListModel()..fetch(),
      child: Consumer<ProductListModel>(
        builder: (context, model, child) {
          final products = model.products;
          return Scaffold(
            appBar: AppBar(
              title: const Text('商品一覧'),
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                model.fetch();
              },
              child: GridView.count(
                crossAxisCount: 2,
                children: products
                    .map(
                      (product) => Card(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(product.name ?? ''),
                            Text('¥ ${product.price.toSplitCommaString()}'),
                            Text('出品者： ${product.owner?.displayName ?? ''}'),
                            ElevatedButton(
                              onPressed: () {
                                // todo : 購入処理
                              },
                              child: const Text('購入する'),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                // 認証済みの場合は商品を追加できる
                if (model.user?.verificationStatus ==
                    VerificationStatus.verified) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return const AddProductPage();
                      },
                      fullscreenDialog: true,
                    ),
                  );
                } else {
                  await showTextDialog(context, '「アカウント」から本人確認を行ってください');
                }
              },
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }
}
