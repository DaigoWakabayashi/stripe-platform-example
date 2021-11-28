import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:stripe_platform_example/presentation/add_product/add_product_model.dart';

class AddProductPage extends StatelessWidget {
  const AddProductPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AddProductModel>(
      create: (_) => AddProductModel()..fetch(),
      child: Consumer<AddProductModel>(
        builder: (context, model, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('出品'),
            ),
            body: Column(
              children: [
                TextField(
                  controller: model.productNameController,
                  decoration: const InputDecoration(
                    labelText: '商品名',
                  ),
                ),
                TextField(
                  controller: model.priceController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: '価格',
                  ),
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      await model.addProduct();
                      Navigator.of(context).pop();
                    },
                    child: const Text('出品する'),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
