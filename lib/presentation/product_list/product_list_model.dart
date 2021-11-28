import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stripe_platform_example/domain/product.dart';

class ProductListModel extends ChangeNotifier {
  List<Product> products = [];
  bool isLoading = false;

  Future<void> fetch() async {
    _startLoading();
    // 商品一覧を取得
    final snap = await FirebaseFirestore.instance.collection('products').get();
    products = snap.docs.map((e) => Product.fromJson(e.data())).toList();
    _endLoading();
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
