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
          _buildQuestionCard(),
          Expanded(
            child: _buildAnswersList(),
          ),
          _buildAnswerInputSection(),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    return Container(
      padding: EdgeInsets.all(20.0),
      margin: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.questionData['question'] ?? 'Soru bulunamadı',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 147, 58, 142), // Main theme color
            ),
          ),
          SizedBox(height: 10.0),
          Text(
            "Soran: ${widget.questionData['userName'] ?? 'Anonim'}",
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswersList() {
    return StreamBuilder<QuerySnapshot>(
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
          return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
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
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (userSnapshot.hasError) {
                  return Center(
                      child: Text('Bir hata oluştu: ${userSnapshot.error}'));
                }

                var userData =
                    userSnapshot.data?.data() as Map<String, dynamic>?;

                return _buildAnswerCard(data, userData);
              },
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildAnswerCard(
      Map<String, dynamic> data, Map<String, dynamic>? userData) {
    return Container(
      padding: EdgeInsets.all(15.0),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: userData?['profileImageUrl'] != null
              ? NetworkImage(userData!['profileImageUrl'])
              : AssetImage('assets/default_avatar.png') as ImageProvider,
          backgroundColor: Color.fromARGB(255, 147, 58, 142),
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
  }

  Widget _buildAnswerInputSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      color: Color.fromARGB(255, 147, 58, 142),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _answerController,
              decoration: InputDecoration(
                hintText: 'Cevabınızı yazın...',
                hintStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
              ),
              maxLines: null,
              style: TextStyle(color: Colors.white),
            ),
          ),
          SizedBox(width: 8),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submitAnswer,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Color.fromARGB(255, 147, 58, 142),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isSubmitting
                ? CircularProgressIndicator(
                    color: Color.fromARGB(255, 147, 58, 142))
                : Text('Gönder'),
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
          'userPhotoUrl': user.photoURL ?? '',
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
    }
  }
}

void main() {
  runApp(MaterialApp(
    title: 'Forum Yanıtları',
    home: AnswersPage(
      questionId: 'exampleQuestionId',
      questionData: {'question': 'Bu bir örnek sorudur', 'userName': 'Irem'},
    ),
  ));
}
