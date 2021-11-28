import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stripe_platform_example/domain/product.dart';

class ProductRepository {
  static final ProductRepository _instance = ProductRepository._internal();
  ProductRepository._internal();
  factory ProductRepository() {
    return _instance;
  }
  final _firestore = FirebaseFirestore.instance;

  // 商品一覧を取得
  Future<List<Product>> fetchProducts() async {
    final snap = await _firestore.collection('products').get();
    return snap.docs.map((e) => Product.fromJson(e.data())).toList();
  }

  // 商品を追加
  Future<void> addProduct(String ownerId, String name, int price) async {
    final newDoc = _firestore.collection('products').doc();
    await newDoc.set({
      'id': newDoc.id,
      'ownerId': ownerId,
      'name': name,
      'price': price,
    });
  }
}
