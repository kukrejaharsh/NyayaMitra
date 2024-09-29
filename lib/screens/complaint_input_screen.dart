import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:legal_info_app/screens/section_suggestion_screen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:intl/intl.dart'; // For date formatting
import 'package:cloud_firestore/cloud_firestore.dart';

class ComplaintInputScreen extends StatefulWidget {
  const ComplaintInputScreen({super.key});

  @override
  _ComplaintInputScreenState createState() => _ComplaintInputScreenState();
}

class _ComplaintInputScreenState extends State<ComplaintInputScreen> {
  final TextEditingController _complainantNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _firNumberController = TextEditingController();
  final TextEditingController _fathersHusbandsNameController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();
  final TextEditingController _incidentDetailsController = TextEditingController(); // Incident Details Controller
   final TextEditingController _sectionsAppliedController = TextEditingController(); // Sections Applied Controller

  final FlutterTts _flutterTts = FlutterTts();
  late stt.SpeechToText _speechToText;
  bool _isListening = false;
  String _currentField = '';
  String _selectedGender = 'Male'; // Default selected gender

  DateTime? _dobOfComplainant;
  DateTime? _dateOfIncident;
  TimeOfDay? _timeOfIncident;
  final String _dateOfReport = DateFormat('dd-MM-yyyy').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();
  }

  Future<void> _startListening(String field) async {
    bool available = await _speechToText.initialize();
    if (available) {
      setState(() {
        _isListening = true;
        _currentField = field;
      });
      _speechToText.listen(onResult: (val) {
        setState(() {
          switch (_currentField) {
            case 'name':
              _complainantNameController.text = val.recognizedWords;
              break;
            case 'location':
              _locationController.text = val.recognizedWords;
              break;
            case 'address':
              _addressController.text = val.recognizedWords;
              break;
            case 'phoneNumber':
              _phoneNumberController.text = val.recognizedWords;
              break;
            case 'firNumber':
              _firNumberController.text = val.recognizedWords;
              break;
            case 'fathersHusbandsName':
              _fathersHusbandsNameController.text = val.recognizedWords;
              break;
            case 'occupation':
              _occupationController.text = val.recognizedWords;
              break;
            case 'incidentDetails':
              _incidentDetailsController.text = val.recognizedWords;
              break;
            case 'sectionsApplied':
              _sectionsAppliedController.text = val.recognizedWords; // Added for Sections Applied
              break;
          }
        });
      });
    }
  }

  void _stopListening() {
    setState(() {
      _isListening = false;
    });
    _speechToText.stop();
  }
  

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(), // Only allow up to current date
    );
    if (picked != null && picked != _dobOfComplainant) {
      setState(() {
        _dobOfComplainant = picked;
      });
    }
  }

  Future<void> _selectIncidentDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(), // Only allow up to current date
    );
    if (picked != null && picked != _dateOfIncident) {
      setState(() {
        _dateOfIncident = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _timeOfIncident) {
      setState(() {
        _timeOfIncident = picked;
      });
    }
  }

  

  bool _isValidPhoneNumber(String phoneNumber) {
    final RegExp phoneRegExp = RegExp(r'^\d{10}$');
    return phoneRegExp.hasMatch(phoneNumber);
  }

  void _submitComplaint() {
    if (_complainantNameController.text.isNotEmpty &&
        _dobOfComplainant != null &&
        _dateOfIncident != null &&
        _timeOfIncident != null &&
        _locationController.text.isNotEmpty &&
        _addressController.text.isNotEmpty &&
        _incidentDetailsController.text.isNotEmpty  && // Check Incident Details
        _sectionsAppliedController.text.isNotEmpty && // Check Sections Applied
        _isValidPhoneNumber(_phoneNumberController.text) &&
        _firNumberController.text.isNotEmpty &&
        _fathersHusbandsNameController.text.isNotEmpty &&
        _occupationController.text.isNotEmpty) {

      // Save the complaint details to Firestore
      _saveComplaintToFirestore();

      // Navigate to the next screen after saving
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ComplaintInputScreen()),
      );
      
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter all the mandatory details.')));
    }
  }

  void _saveComplaintToFirestore() async {
    final Map<String, dynamic> complaintData = {
      'complainantName': _complainantNameController.text.trim(),
      'complainantDob': _dobOfComplainant != null 
          ? DateFormat('dd-MM-yyyy').format(_dobOfComplainant!) 
          : 'NA',
      'gender': _selectedGender,  // Save selected gender
      'complaintDetails': 'Date of Incident: ${DateFormat('dd-MM-yyyy').format(_dateOfIncident!)}' +
          '\nTime of Incident: ${_timeOfIncident!.format(context)}' +
          '\nIncident Details: ${_incidentDetailsController.text.trim()}', // Include Incident Details
      'location': _locationController.text.trim(),
      'address': _addressController.text.trim(),
      'phoneNumber': _phoneNumberController.text.trim(),
      'firNumber': _firNumberController.text.trim(),
      'dateOfReport': _dateOfReport,
      'fathersHusbandsName': _fathersHusbandsNameController.text.trim(),
      'occupation': _occupationController.text.trim(),
      'sectionsApplied': _sectionsAppliedController.text.trim(), // Save Sections Applied
    };

    try {
      await FirebaseFirestore.instance.collection('complaints').add(complaintData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complaint successfully saved!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save complaint.')),
      );
    }
  }

  int _calculateAge() {
    if (_dobOfComplainant == null) return 0;
    int age = DateTime.now().year - _dobOfComplainant!.year;
    if (DateTime.now().isBefore(DateTime(_dobOfComplainant!.year, _dobOfComplainant!.month, _dobOfComplainant!.day))) {
      age--;
    }
    return age;
  }

  Future<void> _speakComplaint() async {
    if (_incidentDetailsController.text.isNotEmpty) {
      await _flutterTts.setLanguage("en-IN");
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.speak(_incidentDetailsController.text);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter the incident details first')));
    }
  }
  
    Future<void> _navigateToSectionSuggestion() async {
    final selectedSection = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SectionSuggestionScreen()),
    );
    if (selectedSection != null) {
      setState(() {
        _sectionsAppliedController.text = selectedSection; // Update the text field with selected section
      });
    }
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Enter Complaint Details')),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // FIR Registration Form Title with Underline
            const Text(
              'FIR Registration Form',
              style: TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.bold, 
                decoration: TextDecoration.underline,
              ),
            ),
            const SizedBox(height: 20),
            // Date of Report
            Text(
              'Date of Report: $_dateOfReport',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            // FIR Number Input
            _buildTextField(
              label: 'FIR Number',
              controller: _firNumberController,
              field: 'firNumber',
            ),
            const SizedBox(height: 20),
            // Complainant Details shifted to left
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Complainant Details',
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold, 
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Complainant Name Input
            _buildTextField(
              label: 'Complainant Name',
              controller: _complainantNameController,
              field: 'name',
            ),
            const SizedBox(height: 20),
            // Complainant Date of Birth Input
            _buildDatePicker(
              label: 'Date of Birth',
              selectedDate: _dobOfComplainant,
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 10), // Add space before the age display

            // Display calculated age
            Text(
              'Age: ${_calculateAge()} years old',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20), // Add some spacing after the age display

            // Gender Selection
            const Text(
              'Gender',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: _selectedGender,
              items: <String>['Male', 'Female', 'Other']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedGender = newValue!;
                });
              },
            ),
            const SizedBox(height: 20),
            // Address Input
            _buildTextField(
              label: 'Address',
              controller: _addressController,
              field: 'address',
            ),
            const SizedBox(height: 20),
            // Phone Number Input
            _buildTextField(
              label: 'Phone Number',
              controller: _phoneNumberController,
              field: 'phoneNumber',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            // Father's/Husband's Name Input
            _buildTextField(
              label: 'Father\'s/Husband\'s Name',
              controller: _fathersHusbandsNameController,
              field: 'fathersHusbandsName',
            ),
            const SizedBox(height: 20),
            // Occupation Input
            _buildTextField(
              label: 'Occupation',
              controller: _occupationController,
              field: 'occupation',
            ),
            const SizedBox(height: 20),
            // Complainant Details shifted to left
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Incident Details',
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold, 
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Date of Incident Input
            _buildDatePicker(
              label: 'Date of Incident',
              selectedDate: _dateOfIncident,
              onTap: () => _selectIncidentDate(context),
            ),
            const SizedBox(height: 20),
            // Time of Incident Input
            _buildTimePicker(
              label: 'Time of Incident',
              selectedTime: _timeOfIncident,
              onTap: () => _selectTime(context),
            ),
            const SizedBox(height: 20),
            // Location Input
            _buildTextField(
              label: 'Location Of Incident',
              controller: _locationController,
              field: 'location',
            ),
            const SizedBox(height: 20),
            // Incident Details Input
            _buildTextField(
              label: 'Incident Details',
              controller: _incidentDetailsController,
              field: 'incidentDetails',
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            // Sections Applied Input
            _buildSectionsPicker(
              label: 'Sections Applied',
              selectedSection: _sectionsAppliedController.text,
              onTap: _navigateToSectionSuggestion, // Navigate to section suggestion
            ),
            const SizedBox(height: 20),
            // Speak Complaint Button
            ElevatedButton(
              onPressed: _speakComplaint,
              child: const Text('Speak Complaint'),
            ),
            const SizedBox(height: 20),
            // Submit Complaint Button
            ElevatedButton(
              onPressed: _submitComplaint,
              child: const Text('Submit Complaint'),
            ),
          ],
        ),
      ),
    ),
  );
  }



  Widget _buildTimePicker({
  required String label,
  required TimeOfDay? selectedTime,
  required VoidCallback onTap,
}) {
  return Container(
    padding: const EdgeInsets.all(8.0),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey),
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label: ${selectedTime != null ? selectedTime.format(context) : 'Select Time'}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        ElevatedButton(
          onPressed: onTap,
          child: const Text('Pick Time'),
        ),
      ],
    ),
  );
}

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String field,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            onTap: () {
              _startListening(field);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? selectedDate,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label: ${selectedDate != null ? DateFormat('dd-MM-yyyy').format(selectedDate) : 'Select Date'}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          ElevatedButton(
            onPressed: onTap,
            child: const Text('Pick Date'),
          ),
        ],
      ),
    );
  }
}


Widget _buildSectionsPicker({
  required String label,
  required String? selectedSection,
  required VoidCallback onTap,
}) {
  return Container(
    padding: const EdgeInsets.all(8.0),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey),
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Text widget to display selected sections
        Expanded(
          child: Text(
            '$label: ${selectedSection != null && selectedSection.isNotEmpty ? selectedSection : 'Select Section'}',
            style: const TextStyle(fontWeight: FontWeight.bold),
            maxLines: 3, // Limit to 3 lines
            overflow: TextOverflow.ellipsis, // Handle overflow with ellipsis
            softWrap: true, // Allow text to wrap
          ),
        ),
        const SizedBox(width: 8), // Add some spacing between text and button
        ElevatedButton(
          onPressed: onTap,
          child: const Text('Pick Section'),
        ),
      ],
    ),
  );
}