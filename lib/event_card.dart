import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/models/event_data.dart';

class EventCard extends StatelessWidget {
  final EventData eventData;

  const EventCard({required this.eventData});

  // Kullanıcıyı etkinliğe katılmak için listeye ekleme fonksiyonu
  Future<void> joinEvent(BuildContext context) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final eventDoc =
          FirebaseFirestore.instance.collection('events').doc(eventData.id);

      // Katılımcı listesine UID ekle
      await eventDoc.update({
        'participants': FieldValue.arrayUnion([userId])
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Etkinliğe katıldınız!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Katılmak için giriş yapmalısınız.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Etkinlik resmi
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            child: eventData.imageUrl != null
                ? Image.network(eventData.imageUrl!, fit: BoxFit.cover)
                : Placeholder(fallbackHeight: 200),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eventData.title ?? 'Başlık Yok',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(eventData.date ?? 'Tarih Yok',
                    style: TextStyle(color: Colors.grey)),
                SizedBox(height: 10),
                Text(eventData.description ?? 'Açıklama Yok'),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.people, color: Colors.grey),
                    SizedBox(width: 5),
                    Text(
                      "${eventData.participants?.length ?? 0} katılımcı",
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => joinEvent(context),
                  child: Text('Etkinliğe Katıl'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
