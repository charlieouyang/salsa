class User {
  final String id;
  final String name;
  final String email;
  final String extraData;
  final String userRoleId;
  final DateTime createdAt;
  final DateTime updatedAt;

  User(this.id, this.name, this.email, this.extraData, this.userRoleId, this.createdAt, this.updatedAt);
}
