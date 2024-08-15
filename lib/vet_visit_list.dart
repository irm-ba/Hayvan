import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VetVisitList extends StatelessWidget {
  const VetVisitList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Veteriner Ziyaretleri"),
        backgroundColor: const Color.fromARGB(255, 210, 141, 212),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('vetVisits').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final visits = snapshot.data!.docs;
          return ListView.builder(
            itemCount: visits.length,
            itemBuilder: (context, index) {
              final visit = visits[index];
              return ListTile(
                title: Text(visit['description']),
                subtitle:
                    Text('Ziyaret Tarihi: ${visit['visitDate'].toDate()}'),
              );
            },
          );
        },
      ),
    );
  }
}
