import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VaccinationScheduleList extends StatelessWidget {
  const VaccinationScheduleList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Aşı Takvimleri"),
        backgroundColor: const Color.fromARGB(255, 210, 141, 212),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('vaccinationSchedules')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final schedules = snapshot.data!.docs;
          return ListView.builder(
            itemCount: schedules.length,
            itemBuilder: (context, index) {
              final schedule = schedules[index];
              return ListTile(
                title: Text(schedule['description']),
                subtitle: Text(
                    'Başlangıç: ${schedule['start'].toDate()} \nBitiş: ${schedule['end'].toDate()}'),
              );
            },
          );
        },
      ),
    );
  }
}
