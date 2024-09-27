import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class SectionSuggestionScreen extends StatelessWidget {
  final String complaintDetails;
  final FlutterTts _flutterTts = FlutterTts();

  SectionSuggestionScreen({super.key, required this.complaintDetails});

  List<Map<String, String>> _suggestLegalSections() {
    return [
      {'section': 'IPC 420', 'description': 'Cheating and dishonestly inducing delivery of property'},
      {'section': 'IPC 324', 'description': 'Voluntarily causing hurt by dangerous weapons or means'},
    ];
  }

  Future<void> _speakSection(String section) async {
    await _flutterTts.setLanguage("en-IN");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.speak(section);
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = _suggestLegalSections();

    return Scaffold(
      appBar: AppBar(title: const Text('Suggested Legal Sections')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: suggestions.map((section) {
            return Card(
              child: ListTile(
                title: Text(section['section']!),
                subtitle: Text(section['description']!),
                onTap: () => _speakSection(section['section']!),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
