import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CaseSummaryScreen extends StatefulWidget {
  final String firNumber;

  const CaseSummaryScreen({Key? key, required this.firNumber}) : super(key: key);

  @override
  _CaseSummaryScreenState createState() => _CaseSummaryScreenState();
}

class _CaseSummaryScreenState extends State<CaseSummaryScreen> {
  Map<String, dynamic>? caseDetails;

  @override
  void initState() {
    super.initState();
    _fetchCaseDetails();
  }

  Future<void> _fetchCaseDetails() async {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('complaints')
        .where('firNumber', isEqualTo: widget.firNumber)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        caseDetails = querySnapshot.docs.first.data() as Map<String, dynamic>?;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Case Summary',
        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 227, 227, 247),
                          ),
        ),
        backgroundColor: const Color.fromARGB(255, 0, 51, 102), // Dark blue
      ),
      body: caseDetails == null
          ? const Center(child: CircularProgressIndicator())
          : Container(
              color: Colors.white, // Background color
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Heading Section
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          'Case Summary',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 0, 51, 102),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'FIR Number: ${widget.firNumber}',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  // Details Box
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow(
                              Icons.person, 'Complainant Name', caseDetails!['complainantName']),
                          _buildDetailRow(
                              Icons.date_range, 'Date of Report', caseDetails!['dateOfReport']),
                          _buildDetailRow(
                              Icons.description, 'Incident Details', caseDetails!['incidentDetails']),
                          _buildDetailRow(
                              Icons.calendar_today, 'Date of Incident', caseDetails!['dateOfIncident']),
                          _buildDetailRow(
                              Icons.access_time, 'Time of Incident', caseDetails!['timeOfIncident']),
                          _buildDetailRow(Icons.location_on, 'Address', caseDetails!['address']),
                          _buildDetailRow(
                              Icons.phone, 'Phone Number', caseDetails!['phoneNumber']),
                          // Add more fields as necessary
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Helper method to create each detail row
  Widget _buildDetailRow(IconData icon, String fieldName, String fieldValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color.fromARGB(255, 0, 51, 102)), // Icon color
          const SizedBox(width: 8),
          Text(
            '$fieldName: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color.fromARGB(255, 51, 51, 51),
            ),
          ),
          Expanded(
            child: Text(
              fieldValue,
              style: const TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 77, 77, 77),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
