import 'package:flutter/material.dart';
import 'package:stripe_platform_example/domain/user.dart';
import 'package:stripe_platform_example/repository/product_repository.dart';
import 'package:stripe_platform_example/repository/user_repository.dart';

class AddProductModel extends ChangeNotifier {
  User? user;
  bool isLoading = false;
  TextEditingController productNameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  final userRepo = UserRepository();
  final productRepo = ProductRepository();

  Future<void> fetch() async {
    _startLoading();
    user = await userRepo.fetch();
    _endLoading();
  }

  // 商品の追加
  Future<void> addProduct() async {
    await productRepo.addProduct(
      user?.id ?? '',
      productNameController.text,
      int.parse(priceController.text),
    );
  }

  void _startLoading() {
    isLoading = true;
    notifyListeners();
  }

  void _endLoading() {
    isLoading = false;
    notifyListeners();
  }
}
