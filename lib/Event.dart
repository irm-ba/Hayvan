import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_adoption/CreateEvent.dart';
import 'package:pet_adoption/models/event_data.dart'; // Kullanıcı kimliği için

class EventPage extends StatefulWidget {
  const EventPage({Key? key}) : super(key: key);

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gönüllük Etkinlikleri'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateEventPage()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('events').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Hata oluştu: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Henüz etkinlik bulunmamaktadır.'));
          }

          List<QueryDocumentSnapshot> docs = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var doc = docs[index];
              return EventCard(
                eventData: EventData.fromSnapshot(doc),
              );
            },
          );
        },
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final EventData eventData;

  const EventCard({required this.eventData});

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
    return GestureDetector(
      onTap: () => _showEventDetails(context),
      child: Card(
        elevation: 8,
        margin: EdgeInsets.symmetric(vertical: 12.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
              child: eventData.imageUrl != null
                  ? Image.network(
                      eventData.imageUrl!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Placeholder(fallbackHeight: 200),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eventData.title ?? 'Başlık Yok',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 147, 58, 142),
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    children: [
                      Icon(Icons.date_range,
                          color: Color.fromARGB(255, 170, 169, 170)),
                      SizedBox(width: 4.0),
                      Text(
                        eventData.date ?? 'Tarih Yok',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.0),
                  Row(
                    children: [
                      Icon(Icons.people,
                          color: Color.fromARGB(255, 170, 169, 170)),
                      SizedBox(width: 4.0),
                      Text(
                        "${eventData.participants?.length} katılımcı",
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    eventData.description ?? 'Açıklama Yok',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () => joinEvent(context),
                    child: Text('Etkinliğe Katıl'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Color.fromARGB(255, 147, 58, 142),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEventDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          title: Text(
            eventData.title ?? 'Başlık Yok',
            style: TextStyle(
              color: Color.fromARGB(255, 147, 58, 142),
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text(
                  'Etkinlik Tarihi: ${eventData.date ?? 'Tarih Yok'}',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  'Katılımcılar: ${eventData.participants?.length ?? 0}',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  eventData.description ?? 'Açıklama Yok',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                'Kapat',
                style: TextStyle(
                  color: Color.fromARGB(255, 147, 58, 142),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
