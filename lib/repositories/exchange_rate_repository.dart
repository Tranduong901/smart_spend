import 'dart:convert';

import 'package:http/http.dart' as http;

class ExchangeRateException implements Exception {
  ExchangeRateException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ExchangeRateRepository {
  ExchangeRateRepository({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  Future<double> getUsdToVndRate() async {
    final uri = Uri.parse('https://open.er-api.com/v6/latest/USD');

    try {
      final response = await _httpClient.get(uri);
      if (response.statusCode != 200) {
        throw ExchangeRateException(
            'Không lấy được tỷ giá mới nhất từ máy chủ.');
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw ExchangeRateException('Dữ liệu tỷ giá không hợp lệ.');
      }

      final rates = decoded['rates'];
      if (rates is! Map<String, dynamic>) {
        throw ExchangeRateException('Không tìm thấy dữ liệu tỷ giá.');
      }

      final vndRate = rates['VND'];
      if (vndRate is num) {
        return vndRate.toDouble();
      }

      throw ExchangeRateException('Không tìm thấy tỷ giá USD/VND.');
    } on ExchangeRateException {
      rethrow;
    } catch (_) {
      throw ExchangeRateException(
        'Không thể kết nối mạng để lấy tỷ giá. Vui lòng thử lại.',
      );
    }
  }
}
