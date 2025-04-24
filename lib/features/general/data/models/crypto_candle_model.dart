class CryptoCandle {
  final List<double> closePrices; // Harga penutupan
  final List<double> timestamps; // Waktu dalam UNIX timestamp

  CryptoCandle({
    required this.closePrices,
    required this.timestamps,
  });

  factory CryptoCandle.fromJson(Map<String, dynamic> json) {
    return CryptoCandle(
      closePrices: List<double>.from(json['c'].map((x) => x.toDouble())),
      timestamps: List<double>.from(json['t'].map((x) => x.toDouble())),
    );
  }
}