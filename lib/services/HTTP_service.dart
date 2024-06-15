import 'package:http/http.dart' as http;

class HttpsService {
  static const String _defaultUrl = 'https://orre.store/api/admin';

  static Uri getUri(String url) {
    return Uri.parse(_defaultUrl + url);
  }

  static Future<http.Response> postRequest(String url, String jsonBody) async {
    try {
      print('jsonBody: $jsonBody');
      print('post url: $url');
      final response = await http.post(
        getUri(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonBody,
      );
      print('response: ${response.body}');
      return response;
    } catch (e) {
      // 예외 처리
      print('오류 발생 : $e');
      rethrow; // 예외를 다시 던져서 상위 수준에서 처리하도록 함
    }
  }

  static Future<http.Response> getRequest(String url) async {
    print('get url: ${getUri(url)}');
    final response = await http.get(
      getUri(url),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    return response;
  }
}