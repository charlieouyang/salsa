import 'package:helistrong/models/product.dart';

class Listing {
  final String id;
  final bool active;
  final String name;
  final double price;
  final String updatedAt;
  final String description;
  final String createdAt;
  final double amountAvailable;
  final String productId;
  final String userId;
  final Product product;

  Listing(this.id, this.active, this.name, this.price, this.updatedAt, this.description, this.createdAt, this.amountAvailable, this.productId, this.userId, this.product);
}