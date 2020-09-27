import 'package:helistrong/models/review.dart';

class Product {
  final String id;
  final bool active;
  final String name;
  final String updatedAt;
  final String description;
  final String createdAt;
  final double avgNumStars;
  final List<String> imageUrls;
  final String userId;
  final List<Review> reviews;

  Product(this.id, this.active, this.name, this.updatedAt, this.description, this.createdAt, this.avgNumStars, this.imageUrls, this.userId, this.reviews);
}
