class StockPrice {
  final double price; // Harga saat ini
  final double timestamp; // Waktu dalam UNIX timestamp

  StockPrice({
    required this.price,
    required this.timestamp,
  });

  factory StockPrice.fromJson(Map<String, dynamic> json, double timestamp) {
    return StockPrice(
      price: json['c']?.toDouble() ?? 0.0, // Harga penutupan terkini
      timestamp: timestamp,
    );
  }
}