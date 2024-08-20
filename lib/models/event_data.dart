import 'package:cloud_firestore/cloud_firestore.dart';

class EventData {
  final String id;
  final String? title;
  final String? description;
  final String? date;
  final String? imageUrl;
  final List<String>? participants;

  EventData({
    required this.id,
    this.title,
    this.description,
    this.date,
    this.imageUrl,
    this.participants,
  });

  factory EventData.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Verilerin tipini kontrol edin ve gerekirse dönüştürün
    final participantsData = data['participants'];
    List<String> participantsList = [];
    if (participantsData is List) {
      participantsList = participantsData.map((e) => e.toString()).toList();
    }

    return EventData(
      id: doc.id,
      title: data['title'] as String?,
      description: data['description'] as String?,
      date: data['date'] as String?,
      imageUrl: data['imageUrl'] as String?,
      participants: participantsList,
    );
  }
}