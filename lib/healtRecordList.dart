import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HealthRecord {
  final String petId;
  final Timestamp date;
  final String description;
  final String treatment;
  final String veterinarianName;
  final String healthStatus;

  HealthRecord({
    required this.petId,
    required this.date,
    required this.description,
    required this.treatment,
    required this.veterinarianName,
    required this.healthStatus,
  });

  factory HealthRecord.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HealthRecord(
      petId: data['petId'],
      date: data['date'],
      description: data['description'],
      treatment: data['treatment'],
      veterinarianName: data['veterinarianName'],
      healthStatus: data['healthStatus'],
    );
  }
}

class HealthRecordList extends StatelessWidget {
  const HealthRecordList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sağlık Kayıtları"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('healthRecords').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Bir hata oluştu: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final records = snapshot.data!.docs
              .map((doc) => HealthRecord.fromDocument(doc))
              .toList();

          if (records.isEmpty) {
            return const Center(child: Text('Kayıt bulunamadı.'));
          }

          return ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              return ListTile(
                title: Text(record.description),
                subtitle: Text(record.treatment),
                trailing: Text(record.date.toDate().toString()),
              );
            },
          );
        },
      ),
    );
  }
}
