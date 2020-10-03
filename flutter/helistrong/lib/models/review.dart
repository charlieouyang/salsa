class Review {
  final String id;
  final String name;
  final String description;
  final double numStars;
  final String purchaseId;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Review(this.id, this.name, this.description, this.numStars, this.purchaseId, this.userId, this.createdAt, this.updatedAt);
}
