class Product {
  String? id;
  String? name;
  int? price;

  Product.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    price = json['price'];
  }
}
