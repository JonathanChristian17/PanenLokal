import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/market_price.dart';

class MarketService {
  static const String baseUrl = "http://localhost:8000/api"; 

  Future<List<MarketPrice>> getMarketPrices() async {
    final response = await http.get(Uri.parse("$baseUrl/market-prices"));

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((e) => MarketPrice.fromJson(e)).toList();
    } else {
      throw Exception("Gagal memuat data harga pasar");
    }
  }
}