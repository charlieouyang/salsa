import 'package:helistrong/models/product.dart';
import 'package:helistrong/models/user.dart';

class Listing {
  final String id;
  final bool active;
  final String name;
  final double price;
  final DateTime updatedAt;
  final String description;
  final DateTime createdAt;
  final double amountAvailable;
  final String productId;
  final User user;
  final Product product;

  Listing(this.id, this.active, this.name, this.price, this.updatedAt, this.description, this.createdAt, this.amountAvailable, this.productId, this.user, this.product);
}