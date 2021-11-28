import 'package:stripe_platform_example/domain/user.dart';

class Product {
  String? id;
  String? ownerId;
  String? name;
  int? price;

  User? owner;

  Product.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    ownerId = json['ownerId'];
    name = json['name'];
    price = json['price'];
  }
}
