import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminApplication extends StatefulWidget {
  final String applicationId;

  const AdminApplication({required this.applicationId, Key? key})
      : super(key: key);

  @override
  State<AdminApplication> createState() => _AdminApplicationState();
}

class _AdminApplicationState extends State<AdminApplication> {
  Map<String, dynamic>? _applicationData;
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _petData;

  @override
  void initState() {
    super.initState();
    _fetchApplicationDetails();
  }

  Future<void> _fetchApplicationDetails() async {
    try {
      DocumentSnapshot applicationDoc = await FirebaseFirestore.instance
          .collection('adoption_applications')
          .doc(widget.applicationId)
          .get();

      setState(() {
        _applicationData = applicationDoc.data() as Map<String, dynamic>?;
      });

      if (_applicationData != null) {
        String userId = _applicationData!['userId'];
        String petId = _applicationData!['petId'];

        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        DocumentSnapshot petDoc =
            await FirebaseFirestore.instance.collection('pet').doc(petId).get();

        setState(() {
          _userData = userDoc.data() as Map<String, dynamic>?;
          _petData = petDoc.data() as Map<String, dynamic>?;
        });
      }
    } catch (e) {
      print('Başvuru detayları alınırken bir hata oluştu: $e');
    }
  }

  Future<void> _updateApplicationStatus(String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('adoption_applications')
          .doc(widget.applicationId)
          .update({
        'status': status,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      setState(() {
        _applicationData?['status'] = status; // Durumu güncelle
      });
    } catch (e) {
      print('Başvuru durumu güncellenirken bir hata oluştu: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Başvuru Detayları'),
        backgroundColor: Colors.purple[800],
      ),
      body: _applicationData == null || _userData == null || _petData == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildApplicationDetails(),
                  SizedBox(height: 20),
                  _buildActionButtons(),
                ],
              ),
            ),
    );
  }

  Widget _buildApplicationDetails() {
    String status = _applicationData?['status'] ?? 'Bekleniyor';
    Color statusColor = status == 'Onaylandı'
        ? Colors.green
        : status == 'Reddedildi'
            ? Colors.red
            : Colors.orange;

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Başvuran: ${_userData!['firstName']}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Hayvan: ${_petData!['name']}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Neden: ${_applicationData!['adoptionReason']}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Durum: $status',
              style: TextStyle(
                fontSize: 16,
                color: statusColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () => _updateApplicationStatus('Onaylandı'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          child: Text('Onayla'),
        ),
        ElevatedButton(
          onPressed: () => _updateApplicationStatus('Reddedildi'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          child: Text('Reddet'),
        ),
      ],
    );
  }
}
