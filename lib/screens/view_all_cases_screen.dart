import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'case_summary_screen.dart'; // Create this screen separately

class ViewAllCasesScreen extends StatefulWidget {
  const ViewAllCasesScreen({Key? key}) : super(key: key);

  @override
  _ViewAllCasesScreenState createState() => _ViewAllCasesScreenState();
}

class _ViewAllCasesScreenState extends State<ViewAllCasesScreen> {
  String searchQuery = '';
  List<DocumentSnapshot> complaintList = [];
  List<DocumentSnapshot> originalComplaintList = []; // Store the original list

  @override
  void initState() {
    super.initState();
    _fetchLatestComplaints();
  }

  // Fetch latest complaints (limit 10) based on the date they were added
  Future<void> _fetchLatestComplaints() async {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('complaints')
        .orderBy('dateOfReport', descending: true) // Order by date
        .limit(10)
        .get();

    setState(() {
      complaintList = querySnapshot.docs;
      originalComplaintList = List.from(complaintList); // Save the original list
    });
  }

  // Search for complaints by FIR number or complainant name
  Future<void> _searchComplaints() async {
    if (searchQuery.isEmpty) {
      setState(() {
        complaintList = List.from(originalComplaintList); // Reset to original list
      });
      return;
    }

    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('complaints')
        .where('firNumber', isEqualTo: searchQuery)
        .get();

    if (querySnapshot.docs.isEmpty) {
      // If no result from FIR number, try searching by complainant name
      final QuerySnapshot nameQuerySnapshot = await FirebaseFirestore.instance
          .collection('complaints')
          .where('complainantName', isEqualTo: searchQuery)
          .get();

      setState(() {
        complaintList = nameQuerySnapshot.docs.isNotEmpty
            ? nameQuerySnapshot.docs
            : []; // Update to an empty list if no results found
      });
    } else {
      setState(() {
        complaintList = querySnapshot.docs;
      });
    }
  }

  // Navigate to case summary
  void _navigateToCaseSummary(String firNumber) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CaseSummaryScreen(firNumber: firNumber),
      ),
    );
  }

  // Build each complaint card
  Widget _buildComplaintCard(DocumentSnapshot document) {
    final Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    // Convert all fields to strings
    final String firNumber = data['firNumber'].toString();
    final String complainantName = data['complainantName'].toString();

    // Get dateOfReport string and parse it
    final String dateOfReportString = data['dateOfReport'] as String;
    final DateTime dateOfReport = DateFormat('dd-MM-yyyy').parse(dateOfReportString);
    final String formattedDate = DateFormat('yMMMd').format(dateOfReport);

    final String incidentDetails = data['incidentDetails'].toString();

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => _navigateToCaseSummary(firNumber),
              child: Row(
                children: [
                  const Text(
                    'FIR Number: ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    firNumber,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text(
                  'Complainant Name: ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Expanded(
                  child: Text(
                    complainantName,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text(
                  'Date of Report: ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  formattedDate,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Incident Details: ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Expanded(
                  child: Text(
                    incidentDetails,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View All Cases',
        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 227, 227, 247),
                          ),
        ),
        backgroundColor: const Color.fromARGB(255, 0, 51, 102),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(
                    color: Colors.blue,
                    width: 1.5,
                  ),
                ),
                hintText: 'Search by FIR Number or Name...',
                hintStyle: const TextStyle(color: Color.fromARGB(255, 94, 92, 92)),
                suffixIcon: const Icon(Icons.search, color: Color.fromARGB(255, 36, 36, 36)),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              onSubmitted: (value) {
                _searchComplaints(); // Trigger search on submission
              },
            ),
          ),
          // Complaint List
          Expanded(
            child: complaintList.isEmpty
                ? const Center(child: Text('No complaints found.'))
                : ListView.builder(
                    itemCount: complaintList.length + 1, // Additional count for the button
                    itemBuilder: (context, index) {
                      if (index < complaintList.length) {
                        return _buildComplaintCard(complaintList[index]);
                      } else {
                        // Display the "Show All Complaints" button
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                              ),
                              onPressed: () {
                                // Fetch all complaints when button is pressed
                                _fetchLatestComplaints(); // Fetch latest complaints
                                setState(() {
                                  complaintList = originalComplaintList; // Update list to show all complaints
                                });
                              },
                              child: const Text(
                                'Show All Complaints',
                                style: TextStyle(fontSize: 16, 
                                fontWeight: FontWeight.bold,
                                color: Colors.white,),
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
