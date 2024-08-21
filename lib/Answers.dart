import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AnswersPage extends StatefulWidget {
  final String questionId;
  final Map<String, dynamic> questionData;

  AnswersPage({required this.questionId, required this.questionData});

  @override
  _AnswersPageState createState() => _AnswersPageState();
}

class _AnswersPageState extends State<AnswersPage> {
  final TextEditingController _answerController = TextEditingController();
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String userName = user?.displayName ?? 'Anonim';
    String userPhotoUrl = user?.photoURL ?? ''; // Profil resmi URL'si

    return Scaffold(
      appBar: AppBar(
        title: Text('Yanıtlar'),
      ),
      body: Column(
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: EdgeInsets.all(16.0),
            child: ListTile(
              title: Text(widget.questionData['question'] ?? 'Soru bulunamadı'),
              subtitle: Text(
                "Soran: ${widget.questionData['userName'] ?? 'Anonim'}",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('forumQuestions')
                  .doc(widget.questionId)
                  .collection('answers')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                      child: Text('Bir hata oluştu: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('Henüz yanıt bulunmuyor.'));
                }

                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    String answerUserId = data['userId'] ?? '';

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(answerUserId)
                          .get(),
                      builder: (context, userSnapshot) {
                        if (userSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (userSnapshot.hasError) {
                          return Center(
                              child: Text(
                                  'Bir hata oluştu: ${userSnapshot.error}'));
                        }

                        var userData =
                            userSnapshot.data?.data() as Map<String, dynamic>?;

                        return Card(
                          elevation: 4,
                          margin:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: userData?['profileImageUrl'] !=
                                      null
                                  ? NetworkImage(userData!['profileImageUrl'])
                                  : AssetImage('assets/default_avatar.png')
                                      as ImageProvider,
                              backgroundColor:
                                  Color.fromARGB(255, 147, 58, 142),
                              child: userData?['profileImageUrl'] == null
                                  ? Icon(Icons.person, color: Colors.white)
                                  : null,
                            ),
                            title: Text(data['answer'] ?? 'Yanıt bulunamadı'),
                            subtitle: Text(
                              "Yanıtlayan: ${userData?['firstName'] ?? 'Anonim'} ${userData?['lastName'] ?? ''}",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _answerController,
                    decoration: InputDecoration(
                      hintText: 'Cevabınızı yazın...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    maxLines: null,
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitAnswer,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Gönder'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitAnswer() async {
    if (_answerController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Yanıt boş bırakılamaz.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('forumQuestions')
            .doc(widget.questionId)
            .collection('answers')
            .add({
          'userId': user.uid,
          'userName': user.displayName ?? 'Anonim',
          'userPhotoUrl': user.photoURL ?? '', // Kullanıcı profil resmi URL'si
          'answer': _answerController.text,
          'timestamp': Timestamp.now(),
        });

        _answerController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Yanıtınız gönderildi!')),
        );
      } catch (e) {
        print("Yanıt gönderme hatası: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bir hata oluştu, lütfen tekrar deneyin.')),
        );
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen giriş yapın.')),
      );
    }
  }
}
