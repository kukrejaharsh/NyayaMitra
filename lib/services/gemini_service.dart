import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  // Your backend URL that proxies requests to the Gemini API
  static const String _baseUrl = "https://nyaya-gemini-backend.vercel.app/api/askGemini";

  /// Asks the Gemini model a question and returns the text response.
  /// Throws an [Exception] if the network call fails or returns an error.
  static Future<String> askGemini(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"prompt": prompt}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Standard Gemini response parsing
        final text = data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"];
        
        if (text != null) {
          return text;
        } else {
          // Throw an exception if the expected text is not in the response
          throw Exception("Failed to parse Gemini response.");
        }
      } else {
        // Throw an exception for non-200 HTTP status codes
        throw Exception("Error from server: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      // Re-throw the exception to be handled by the UI layer
      throw Exception("Failed to connect to Gemini service: $e");
    }
  }
}
