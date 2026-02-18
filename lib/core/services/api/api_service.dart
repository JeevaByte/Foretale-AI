import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<dynamic> post({required String url,required Map<String, dynamic> payload}) async {
    final body = jsonEncode(payload);

    final response = await http.post(
      Uri.parse(url), 
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      }, 
      body: body);
      
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("API Error: ${response.statusCode}, ${response.body}");
    }
  }
}
