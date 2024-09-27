import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CaseSummaryScreen extends StatelessWidget {
  const CaseSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Cases Summary')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('cases').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              return Card(
                child: ListTile(
                  title: Text(doc['caseTitle']),
                  subtitle: Text(doc['details']),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
