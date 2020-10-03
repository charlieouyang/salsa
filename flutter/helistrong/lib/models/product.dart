import 'package:helistrong/models/review.dart';
import 'package:helistrong/models/user.dart';

class Product {
  final String id;
  final bool active;
  final String name;
  final DateTime updatedAt;
  final String description;
  final DateTime createdAt;
  final double avgNumStars;
  final List<String> imageUrls;
  final User user;
  final List<Review> reviews;

  Product(this.id, this.active, this.name, this.updatedAt, this.description, this.createdAt, this.avgNumStars, this.imageUrls, this.user, this.reviews);
}
