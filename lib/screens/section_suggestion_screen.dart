import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class SectionSuggestionScreen extends StatefulWidget {
  SectionSuggestionScreen({super.key});

  @override
  _SectionSuggestionScreenState createState() => _SectionSuggestionScreenState();
}

class _SectionSuggestionScreenState extends State<SectionSuggestionScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  final List<Map<String, String>> _sections = [
    {
      'section': '44. Right of private defence against deadly assault when there is risk of harm to innocent person.',
      'description': 'Provides protection against deadly attacks posing risk to innocents.'
    },
    {
      'section': '73. Assault or criminal force to woman with intent to outrage her modesty.',
      'description': 'Covers acts of violence or force aimed at degrading a woman’s dignity.'
    },
    {
      'section': '75. Assault or use of criminal force to woman with intent to disrobe.',
      'description': 'Details punishments for assaults aimed at disrobing a woman.'
    },
    {
      'section': '128. Assault.',
      'description': 'Defines assault and the legal ramifications of such actions.'
    },
    {
      'section': '129. Punishment for assault or criminal force otherwise than on grave provocation.',
      'description': 'Outlines penalties for assault not provoked by grave circumstances.'
    },
    {
      'section': '130. Assault or criminal force to deter public servant from discharge of his duty.',
      'description': 'Covers penalties for obstructing public servants in their duties through force.'
    },
    {
      'section': '131. Assault or criminal force with intent to dishonor person, otherwise than on grave provocation.',
      'description': 'Details legal consequences for assault aimed at dishonoring individuals.'
    },
    {
      'section': '132. Assault or criminal force in attempt to commit theft of property carried by a person.',
      'description': 'Defines penalties for assault during theft attempts involving physical property.'
    },
    {
      'section': '133. Assault or criminal force in attempt wrongfully to confine a person.',
      'description': 'Covers legal implications for using force to wrongfully confine individuals.'
    },
    {
      'section': '134. Assault or criminal force on grave provocation.',
      'description': 'Specifies legal repercussions for assault committed under grave provocation.'
    },
  ];

  List<String> _selectedSections = [];

  Future<void> _speakSection(String section) async {
    await _flutterTts.setLanguage("en-IN");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.speak(section);
  }

  void _toggleSelection(String section) {
    setState(() {
      if (_selectedSections.contains(section)) {
        _selectedSections.remove(section);
      } else {
        _selectedSections.add(section);
      }
    });
  }

  void _submitSelectedSections() {
    // Extract only the section numbers from selected sections
    List<String> selectedSectionNumbers = _selectedSections.map((section) {
      // Get the section number before the first period
      return section.split('.')[0].trim();
    }).toList();

    String selectedSectionsString = selectedSectionNumbers.join(', ');

    // Print the selected section numbers to the console
    print("Selected Sections Numbers: $selectedSectionsString");

    // Optionally navigate back to the complaint input screen
    Navigator.pop(context, selectedSectionsString);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Suggested Legal Sections')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _sections.length,
                itemBuilder: (context, index) {
                  final section = _sections[index];
                  final isSelected = _selectedSections.contains(section['section']);
                  return Card(
                    child: ListTile(
                      title: Text(section['section']!),
                      subtitle: Text(section['description']!),
                      tileColor: isSelected ? Colors.blue.withOpacity(0.3) : null,
                      trailing: isSelected 
                          ? const Icon(Icons.check, color: Colors.green) 
                          : null,
                      onTap: () {
                        _toggleSelection(section['section']!);
                      },
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _submitSelectedSections,
              child: const Text('Submit Selected Sections'),
            ),
          ],
        ),
      ),
    );
  }
}
