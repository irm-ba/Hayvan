import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/pet_data.dart'; // PetData model import

class PetApplicationsPage extends StatefulWidget {
  final PetData pet;

  PetApplicationsPage({required this.pet});

  @override
  _PetApplicationsPageState createState() => _PetApplicationsPageState();
}

class _PetApplicationsPageState extends State<PetApplicationsPage> {
  List<DocumentSnapshot<Map<String, dynamic>>> _applications = [];

  @override
  void initState() {
    super.initState();
    _fetchApplications();
  }

  Future<void> _fetchApplications() async {
    try {
      QuerySnapshot<Map<String, dynamic>> applicationSnapshot =
          await FirebaseFirestore.instance
              .collection('applications')
              .where('petId', isEqualTo: widget.pet.petId)
              .get();

      List<DocumentSnapshot<Map<String, dynamic>>> applications =
          applicationSnapshot.docs;

      setState(() {
        _applications = applications;
      });
    } catch (e) {
      print('Error fetching applications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.pet.name} Applications'),
      ),
      body: _applications.isNotEmpty
          ? ListView.builder(
              itemCount: _applications.length,
              itemBuilder: (context, index) {
                final applicationDoc = _applications[index];
                final applicationData =
                    applicationDoc.data() as Map<String, dynamic>?;

                return ListTile(
                  contentPadding: EdgeInsets.all(8.0),
                  title: Text(applicationData?['applicantName'] ?? 'No Name'),
                  subtitle: Text(applicationData?['status'] ?? 'No Status'),
                  onTap: () {
                    // Navigate to detailed application page if needed
                  },
                );
              },
            )
          : Center(child: Text('No applications available.')),
    );
  }
}
