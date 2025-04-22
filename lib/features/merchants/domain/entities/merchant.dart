class Merchant {
  final int id;
  final String name;
  final String? createdAt;

  Merchant({
    required this.id,
    required this.name,
    this.createdAt,
  });
}