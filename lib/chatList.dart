import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_adoption/chatPage.dart';

class ChatListPage extends StatefulWidget {
  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> _getUserInfo(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        final firstName = userData['firstName'] ?? 'Bilinmeyen';
        final lastName = userData['lastName'] ?? 'Kullanıcı';
        final fullName = '$firstName $lastName';
        return {
          'name': fullName,
          'profileImageUrl': userData['profileImageUrl'],
        };
      } else {
        return {
          'name': 'Bilinmeyen Kullanıcı',
          'profileImageUrl': null,
        };
      }
    } catch (e) {
      print('Error fetching user info: $e');
      return {
        'name': 'Bilinmeyen Kullanıcı',
        'profileImageUrl': null,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _auth.currentUser?.uid;

    if (currentUserId == null) {
      return Scaffold(
        body: Center(child: Text('Kullanıcı giriş yapmamış.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Sohbetler'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('chats')
            .where('participants', arrayContains: currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final chats = snapshot.data!.docs;

          if (chats.isEmpty) {
            return Center(child: Text('Henüz sohbet yok.'));
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index].data() as Map<String, dynamic>;
              final conversationId = chats[index].id;
              final lastMessage = chat['lastMessage'] ?? 'Mesaj bulunmuyor';
              final receiverId = (chat['participants'] as List<dynamic>)
                  .firstWhere((id) => id != currentUserId);

              return FutureBuilder<Map<String, dynamic>>(
                future: _getUserInfo(receiverId),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return ListTile(
                      title: Text('Yükleniyor...'),
                    );
                  }

                  final user = userSnapshot.data!;
                  final receiverName = user['name'] ?? 'Bilinmeyen Kullanıcı';
                  final receiverProfileImageUrl = user['profileImageUrl'];

                  return Card(
                    margin:
                        EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                    elevation: 5.0,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: receiverProfileImageUrl != null
                            ? NetworkImage(receiverProfileImageUrl)
                            : AssetImage('assets/default_profile_image.png')
                                as ImageProvider,
                      ),
                      title: Text(
                        receiverName,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        lastMessage,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(
                              conversationId: conversationId,
                              receiverId: receiverId,
                              receiverName: receiverName,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
