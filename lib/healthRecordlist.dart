import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Import for date formatting

class HealthRecordList extends StatelessWidget {
  const HealthRecordList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sağlık Kayıtları"),
        elevation: 0,
      ),
      body: user == null
          ? const Center(
              child: Text('Kullanıcı giriş yapmamış',
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
            )
          : StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('healthRecords')
                  .where('userId', isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final records = snapshot.data!.docs;
                if (records.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Kayıt bulunamadı.',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.grey[600]),
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    final description = record['description'] as String? ?? '';
                    final imageUrl = record['imageUrl'] as String? ?? '';
                    final petId = record['petId'] as String? ?? '';

                    // Check if visitDate is a Timestamp or String
                    final visitDateField = record['date'];
                    DateTime visitDate;
                    if (visitDateField is Timestamp) {
                      visitDate = visitDateField.toDate();
                    } else if (visitDateField is String) {
                      try {
                        visitDate = DateTime.parse(visitDateField);
                      } catch (e) {
                        visitDate =
                            DateTime.now(); // Default to now if parsing fails
                      }
                    } else {
                      visitDate =
                          DateTime.now(); // Default to now if unknown type
                    }

                    // Format date to "August 24, 2024 at 3:00:00 AM UTC+3"
                    final formattedDate =
                        DateFormat('MMMM d, yyyy \'at\' h:mm:ss a')
                            .format(visitDate.toLocal());

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: imageUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  imageUrl,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child:
                                    Icon(Icons.pets, color: Colors.grey[600]),
                              ),
                        title: Text(
                          description,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                        ),
                        subtitle: Text(
                          'Ziyaret Tarihi: $formattedDate\nHayvan ID: $petId',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[700],
                                    fontSize: 14,
                                  ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
