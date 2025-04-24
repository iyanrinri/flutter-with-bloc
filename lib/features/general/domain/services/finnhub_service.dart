import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:yukngantri/features/general/data/models/crypto_candle_model.dart';
import 'package:yukngantri/features/general/data/models/stock_price_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FinnhubService {
  static final String _apiKey = dotenv.env['FINNHUB_API_KEY'] ?? '';
  static const String _baseUrl = 'https://finnhub.io/api/v1';

  Future<CryptoCandle> fetchCryptoCandle({
    required String symbol,
    required String resolution, // 1, 5, 15, 30, 60, D, W, M
    required int from, // UNIX timestamp
    required int to, // UNIX timestamp
  }) async {
    final url = Uri.parse(
      '$_baseUrl/crypto/candle?symbol=$symbol&resolution=$resolution&from=$from&to=$to&token=$_apiKey',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['s'] == 'no_data') {
        throw Exception('No data available for the selected period');
      }
      return CryptoCandle.fromJson(data);
    } else {
      throw Exception('Failed to load crypto data');
    }
  }

  Future<StockPrice> fetchCryptoQuote(String symbol) async {
    final url = Uri.parse('$_baseUrl/quote?symbol=$symbol&token=$_apiKey');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return StockPrice.fromJson(
        data,
        DateTime.now().millisecondsSinceEpoch / 1000,
      );
    } else {
      throw Exception('Failed to load crypto quote');
    }
  }
}