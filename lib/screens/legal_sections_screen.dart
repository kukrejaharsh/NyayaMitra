import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/data_table_widget.dart'; // Import the DataTableWidget

class LegalSectionsScreen extends StatelessWidget {
  const LegalSectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Legal Sections'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('legalSections').snapshots(),
        builder: (context, snapshot) {
          // Check for connection issues or loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Prepare data for the DataTableWidget
          final legalSections = snapshot.data?.docs.map((doc) {
            return {
              'Section': doc['title'] as String? ?? 'Unknown',
              'Description': doc['description'] as String? ?? 'No description available',
            };
          }).toList() ?? [];

          // Define the columns for the DataTable
          const columns = ['Section', 'Description'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: DataTableWidget(
              data: legalSections,
              columns: columns,
            ),
          );
        },
      ),
    );
  }
}
