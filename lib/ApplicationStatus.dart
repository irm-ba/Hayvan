import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApplicationStatusPage extends StatelessWidget {
  final String applicationId;

  ApplicationStatusPage({required this.applicationId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Başvuru Durumu'),
        backgroundColor: Colors.purple[800],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('adoption_applications')
            .doc(applicationId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Başvuru bulunamadı.'));
          }

          var application = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Başvuru Durumu Kartı
                InfoCard(
                  title: 'Başvuru Durumu',
                  icon: Icons.assignment_turned_in,
                  content: [
                    InfoRow(label: 'Durum:', value: application['status']),
                    InfoRow(
                        label: 'Son Güncelleme:',
                        value:
                            application['lastUpdated']?.toDate().toString() ??
                                'Bilinmiyor'),
                    SizedBox(height: 20),
                    if (application['status'] == 'Beklemede') ...[
                      ElevatedButton(
                        onPressed: () {
                          _updateStatus(context, applicationId, 'Onaylandı');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Onayla'),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          _updateStatus(context, applicationId, 'Reddedildi');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Reddet'),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _updateStatus(
      BuildContext context, String applicationId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('adoption_applications')
          .doc(applicationId)
          .update({
        'status': newStatus,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Başvuru durumu güncellendi: $newStatus')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Güncelleme sırasında bir hata oluştu: $e')),
      );
    }
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> content;

  InfoCard({required this.title, required this.icon, required this.content});

  @override
  Widget build(BuildContext context) {
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
            Row(
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: Colors.purple[800],
                ),
                SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            ...content,
          ],
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String? value;

  InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.purple[700],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value ?? 'Bilinmiyor',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
