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
        title: const Text('Case Summary'),
      ),
      body: caseDetails == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 0, 51, 102), // Dark blue color
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
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow('Complainant Name', caseDetails!['complainantName']),
                        _buildDetailRow('Date of Report', caseDetails!['dateOfReport']),
                        _buildDetailRow('Incident Details', caseDetails!['incidentDetails']),
                        _buildDetailRow('Date of Incident', caseDetails!['dateOfIncident']),
                        _buildDetailRow('Time of Incident', caseDetails!['timeOfIncident']),
                        _buildDetailRow('Address', caseDetails!['address']),
                        _buildDetailRow('Phone Number', caseDetails!['phoneNumber']),
                        // Add more fields as necessary
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Helper method to create each detail row
  Widget _buildDetailRow(String fieldName, String fieldValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$fieldName: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color.fromARGB(255, 51, 51, 51), // Dark gray color for field name
            ),
          ),
          Expanded(
            child: Text(
              fieldValue,
              style: const TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 77, 77, 77), // Slightly lighter gray for value
              ),
            ),
          ),
        ],
      ),
    );
  }
}
