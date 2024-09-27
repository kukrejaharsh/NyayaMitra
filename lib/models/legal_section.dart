import 'package:http/http.dart' as http;

Future<void> fetchLegalSections(String complaintText) async {
  final response = await http.post(
    Uri.parse('http://your-backend-url/predict-section'),
    body: {'text': complaintText},
  );
  
  if (response.statusCode == 200) {
    print('Response: ${response.body}');
  } else {
    throw Exception('Failed to load predictions');
  }
}
