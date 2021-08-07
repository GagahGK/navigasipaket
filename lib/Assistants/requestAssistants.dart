import 'dart:convert';

import 'package:http/http.dart' as http;

class RequestAssistant {
  static Future<dynamic> getRequest(Uri url) async {
    http.Response response = await http.get(url);

    try {
      if (response.statusCode == 200) {
        String jsondata = response.body;
        var decodeData = jsonDecode(jsondata);
        return decodeData;
      } else {
        return "request failed";
      }
    } catch (exp) {
      return "error detected, failed.";
    }
  }
}
