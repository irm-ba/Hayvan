import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth

class AnswersPage extends StatefulWidget {
  final String questionId;
  final Map<String, dynamic> questionData;

  AnswersPage({required this.questionId, required this.questionData});

  @override
  _AnswersPageState createState() => _AnswersPageState();
}

class _AnswersPageState extends State<AnswersPage> {
  final TextEditingController _answerController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yanıtlar'),
        backgroundColor: Color(0xFFC478D1),
      ),
      body: Column(
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: EdgeInsets.all(16.0),
            child: ListTile(
              title: Text(widget.questionData['question'] ?? 'No question'),
              subtitle: Text(
                "Posted by: ${widget.questionData['userName'] ?? 'Anonymous'}",
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
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Color(0xFFC478D1),
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(data['answer'] ?? 'No answer'),
                        subtitle: Text(
                          "Answered by: ${data['userName'] ?? 'Anonymous'}",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
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
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Color(0xFFC478D1)),
                  onPressed: _submitAnswer,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitAnswer() async {
    if (_answerController.text.isEmpty) return;

    User? user = FirebaseAuth.instance.currentUser; // Use FirebaseAuth to get the current user
    if (user != null) {
      await FirebaseFirestore.instance.collection('forumQuestions')
          .doc(widget.questionId)
          .collection('answers')
          .add({
        'userId': user.uid,
        'userName': user.displayName ?? 'Anonymous',
        'answer': _answerController.text,
        'timestamp': Timestamp.now(),
      });

      _answerController.clear();
    }
  }
}
