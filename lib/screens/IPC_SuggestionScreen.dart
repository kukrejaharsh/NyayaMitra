import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class IPCSuggestionScreen extends StatefulWidget {
  const IPCSuggestionScreen({super.key});

  @override
  _IPCSuggestionScreenState createState() => _IPCSuggestionScreenState();
}

class _IPCSuggestionScreenState extends State<IPCSuggestionScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  final List<Map<String, String>> _sections = [
    {
      'section': 'IPC_350',
      'description': 'Whoever intentionally uses force to any person, without that person’s consent, in order to commit any offence, or intending by the use of such force to cause, or knowing it to be likely that by the use of such force he will cause injury, fear or annoyance to the person to whom the force is used, is said to use criminal force to that other.'
    },
    {
      'section': 'IPC_351',
      'description': 'Whoever makes any gesture, or any preparation intending or knowing it to be likely that such gesture or preparation will cause any person present to apprehend that he who makes that gesture or preparation is about to use criminal force to that person, is said to commit an assault.'
    },
    {
      'section': 'IPC_503',
      'description': 'Whoever threatens another with any injury to his person, reputation or property, or to the person or reputation of any one in whom that person is interested, with intent to cause alarm to that person, or to cause that person to do any act which he is not legally bound to do, or to omit to do any act which that person is legally entitled to do, as the means of avoiding the execution of such threat, commits criminal intimidation.'
    },
  ];

  final List<String> _selectedIPCSections = [];

  Future<void> _speakSection(String section) async {
    await _flutterTts.setLanguage("en-IN");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.speak(section);
  }

  void _toggleSelection(String section) {
    setState(() {
      if (_selectedIPCSections.contains(section)) {
        _selectedIPCSections.remove(section);
      } else {
        _selectedIPCSections.add(section);
      }
    });
  }

  void _submitSelectedSections() {
    // Extract only the section numbers from selected sections
    List<String> selectedIPCSectionNumbers = _selectedIPCSections.map((section) {
      // Get the section number (e.g., IPC_350) from the section string
      return section.split('.')[0].trim();
    }).toList();

    String selectedIPCSectionsString = selectedIPCSectionNumbers.join(', ');

    // Print the selected section numbers to the console
    print("Selected IPC Sections Numbers: $selectedIPCSectionsString");

    // Optionally navigate back to the complaint input screen
    Navigator.pop(context, selectedIPCSectionsString);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Suggested IPC Sections',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 227, 227, 247),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 0, 51, 102),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _sections.length,
                itemBuilder: (context, index) {
                  final section = _sections[index];
                  final isSelected = _selectedIPCSections.contains(section['section']);
                  return Card(
                    child: ListTile(
                      title: Text(
                        section['section']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
            const SizedBox(height: 16), // Add spacing before button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Background color
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20), // Increase padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // Rounded corners
                ),
                elevation: 5, // Add elevation
              ),
              onPressed: _submitSelectedSections,
              icon: const Icon(Icons.check), // Add icon to button
              label: const Text(
                'Submit Selected Sections',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white, // Text color
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
