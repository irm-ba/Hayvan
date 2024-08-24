import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VaccinationScheduleList extends StatelessWidget {
  const VaccinationScheduleList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Aşı Takvimleri"),
      ),
      body: user == null
          ? const Center(child: Text('Kullanıcı oturumu açık değil.'))
          : StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('vaccinationSchedules')
                  .where('userId',
                      isEqualTo:
                          user.uid) // Sadece kullanıcıya ait verileri çek
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final schedules = snapshot.data!.docs;
                if (schedules.isEmpty) {
                  return const Center(
                      child: Text('Henüz aşı takvimi eklenmedi.'));
                }
                return ListView.builder(
                  itemCount: schedules.length,
                  itemBuilder: (context, index) {
                    final schedule =
                        schedules[index].data() as Map<String, dynamic>;
                    final animalImageUrl = schedule['animalImageUrl'] as String;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: animalImageUrl.isNotEmpty
                            ? CircleAvatar(
                                backgroundImage: NetworkImage(animalImageUrl),
                                radius: 30,
                              )
                            : const CircleAvatar(
                                child: Icon(Icons.pets),
                                radius: 30,
                              ),
                        title: Text(schedule['description'] as String),
                        subtitle: Text(
                          'Başlangıç: ${schedule['start'].toDate()} \nBitiş: ${schedule['end'].toDate()}',
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
