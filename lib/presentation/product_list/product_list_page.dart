import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stripe_platform_example/presentation/product_list/product_list_model.dart';
import 'package:stripe_platform_example/utils/int_formatter.dart';

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
            body: GridView.count(
              crossAxisCount: 2,
              children: products
                  .map(
                    (product) => Card(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(product.name ?? ''),
                          Text('¥' + product.price.toSplitCommaString()),
                          ElevatedButton(
                            onPressed: () {},
                            child: const Text('購入する'),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          );
        },
      ),
    );
  }
}
