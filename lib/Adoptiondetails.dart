import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApplicationDetailPage extends StatelessWidget {
  final String applicationId;

  ApplicationDetailPage({required this.applicationId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Başvuru Detayı',
          style: TextStyle(color: Colors.white), // Başlık rengi beyaz
        ),
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
            child: ListView(
              children: [
                // Başvuru Bilgileri Kartı
                InfoCard(
                  title: 'Başvuru Bilgileri',
                  icon: Icons.pets,
                  content: [
                    InfoRow(
                        label: 'Yaşam Koşulları:',
                        value: application['livingConditions']),
                    InfoRow(
                        label: 'Sahiplenme Nedeni:',
                        value: application['adoptionReason']),
                  ],
                ),

                SizedBox(height: 20),

                // Başvuru Durumu Kartı
                InfoCard(
                  title: 'Başvuru Durumu',
                  icon: Icons.pending,
                  content: [
                    InfoRow(label: 'Durum:', value: application['status']),
                  ],
                ),

                SizedBox(height: 20),

                // Başvuruyu Yapan Kullanıcı Bilgileri Kartı
                InfoCard(
                  title: 'Başvuruyu Yapan Kullanıcı Bilgileri',
                  icon: Icons.person,
                  content: [
                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(application['userId'])
                          .get(),
                      builder: (context, userSnapshot) {
                        if (userSnapshot.hasError) {
                          return Center(
                              child: Text(
                                  'Bir hata oluştu: ${userSnapshot.error}'));
                        }

                        if (userSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (!userSnapshot.hasData ||
                            !userSnapshot.data!.exists) {
                          return Center(
                              child: Text('Kullanıcı bilgileri bulunamadı.'));
                        }

                        var user =
                            userSnapshot.data!.data() as Map<String, dynamic>;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InfoRow(
                                label: 'Kullanıcı Adı:',
                                value:
                                    '${user['firstName']} ${user['lastName']}'),
                            InfoRow(label: 'E-posta:', value: user['email']),
                            InfoRow(
                                label: 'Telefon:', value: user['phoneNumber']),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
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
              value ?? 'Beklemede',
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
