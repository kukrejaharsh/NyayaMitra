import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
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
        _incidentDetailsController.text.isNotEmpty && // Check Incident Details
        _isValidPhoneNumber(_phoneNumberController.text) &&
        _firNumberController.text.isNotEmpty &&
        _fathersHusbandsNameController.text.isNotEmpty &&
        _occupationController.text.isNotEmpty) {

      // Save the complaint details to Firestore
      _saveComplaintToFirestore();


      // Navigate to the next screen after saving
      // Add your navigation logic here if needed
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
                    color: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Complainant Name
              _buildTextField(
                label: 'Complainant Name',
                controller: _complainantNameController,
                field: 'name',
              ),
              const SizedBox(height: 10),
              // Date of Birth
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => _selectDate(context),
                    child: const Text('Select DOB'),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    _dobOfComplainant != null
                        ? 'Selected DOB: ${DateFormat('dd-MM-yyyy').format(_dobOfComplainant!)}'
                        : 'No DOB selected',
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Age Display
              Text(
                'Age: ${_calculateAge()}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              // Gender Dropdown
              Row(
                children: [
                  const Text('Gender: ', style: TextStyle(fontSize: 16)),
                  DropdownButton<String>(
                    value: _selectedGender,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedGender = newValue!;
                      });
                    },
                    items: <String>['Male', 'Female', 'Others']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Address
              _buildTextField(
                label: 'Address',
                controller: _addressController,
                field: 'address',
              ),
              const SizedBox(height: 10),
              // Father's/Husband's Name
              _buildTextField(
                label: 'Father\'s/Husband\'s Name',
                controller: _fathersHusbandsNameController,
                field: 'fathersHusbandsName',
              ),
              const SizedBox(height: 10),
              // Occupation
              _buildTextField(
                label: 'Occupation',
                controller: _occupationController,
                field: 'occupation',
              ),
              const SizedBox(height: 20),
              // Incident Details shifted to left
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Incident Details',
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Incident Date
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => _selectIncidentDate(context),
                    child: const Text('Date of Incident'),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    _dateOfIncident != null
                        ? ': ${DateFormat('dd-MM-yyyy').format(_dateOfIncident!)}'
                        : 'No Date selected',
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Incident Time
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => _selectTime(context),
                    child: const Text('Time of Incident'),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    _timeOfIncident != null
                        ? ': ${_timeOfIncident!.format(context)}'
                        : 'No Time selected',
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Location
              _buildTextField(
                label: 'Location',
                controller: _locationController,
                field: 'location',
              ),
              const SizedBox(height: 10),
              // Phone Number
              _buildTextField(
                label: 'Phone Number',
                controller: _phoneNumberController,
                field: 'phoneNumber',
              ),
              const SizedBox(height: 10),
              // Incident Details TextField
              _buildTextField(
                label: 'Incident Details',
                controller: _incidentDetailsController,
                field: 'incidentDetails',
                maxLines: 5,
              ),
              const SizedBox(height: 10),
              // Speak Complaint Button
              ElevatedButton(
                onPressed: _speakComplaint,
                child: const Text('Speak Complaint'),
              ),
              const SizedBox(height: 20),
              // Submit Button
              ElevatedButton(
                onPressed: _submitComplaint,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

   Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String field,
    bool highlight = false,
    bool enabled = true,
    int? maxLines,
    int? minLines,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: highlight ? Colors.blue : Colors.grey), // Highlight if needed
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        maxLines: maxLines,
        minLines: minLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
          onPressed: () {
            _isListening ? _stopListening() : _startListening(field);
          },
        ),
      ),
      ),
    );
  }
}

