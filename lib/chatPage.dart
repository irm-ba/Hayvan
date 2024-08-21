import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatPage extends StatefulWidget {
  final String conversationId;
  final String receiverId;
  final String receiverName;

  const ChatPage({
    required this.conversationId,
    required this.receiverId,
    required this.receiverName,
    Key? key,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _receiverProfileImageUrl;

  @override
  void initState() {
    super.initState();
    _fetchReceiverProfileImage();
  }

  void _fetchReceiverProfileImage() async {
    try {
      final userDoc =
          await _firestore.collection('users').doc(widget.receiverId).get();
      if (userDoc.exists) {
        setState(() {
          _receiverProfileImageUrl = userDoc.data()?['profileImageUrl'];
        });
      }
    } catch (e) {
      print('Profil resmi alınamadı: $e');
    }
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final currentUserId = _auth.currentUser?.uid;

    if (currentUserId == null) return;

    final messageText = _messageController.text;

    // Mesajı sohbete ekleyin
    await _firestore
        .collection('chats')
        .doc(widget.conversationId)
        .collection('messages')
        .add({
      'text': messageText,
      'senderId': currentUserId,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Sohbet listesindeki son mesajı güncelleyin
    await _firestore.collection('chats').doc(widget.conversationId).update({
      'lastMessage': messageText,
      'lastMessageTimestamp': FieldValue.serverTimestamp(),
    });

    _messageController.clear();
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _sendMessage();
    });

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: _receiverProfileImageUrl != null
                  ? NetworkImage(_receiverProfileImageUrl!)
                  : AssetImage('assets/default_profile_image.png')
                      as ImageProvider,
            ),
            SizedBox(width: 8),
            Text(widget.receiverName),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/images/paw_print_background.png'), // Arka plan resmi
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
                Colors.white.withOpacity(0.6), BlendMode.dstATop),
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -100,
              left: -100,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromARGB(255, 200, 200, 200).withOpacity(0.3),
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromARGB(255, 200, 200, 200).withOpacity(0.3),
                ),
              ),
            ),
            Column(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('chats')
                        .doc(widget.conversationId)
                        .collection('messages')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      final messages = snapshot.data!.docs;

                      return ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message =
                              messages[index].data() as Map<String, dynamic>;
                          final isMe =
                              message['senderId'] == _auth.currentUser?.uid;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: isMe
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                if (!isMe)
                                  CircleAvatar(
                                    backgroundImage: _receiverProfileImageUrl !=
                                            null
                                        ? NetworkImage(
                                            _receiverProfileImageUrl!)
                                        : AssetImage(
                                                'assets/default_profile_image.png')
                                            as ImageProvider,
                                  ),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Container(
                                    padding: EdgeInsets.all(12),
                                    margin: EdgeInsets.only(
                                        left: isMe ? 0 : 8,
                                        right: isMe ? 8 : 0),
                                    decoration: BoxDecoration(
                                      color: isMe
                                          ? Color.fromARGB(255, 147, 58, 142)
                                          : Colors.grey[200],
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        topRight: Radius.circular(12),
                                        bottomLeft:
                                            Radius.circular(isMe ? 12 : 0),
                                        bottomRight:
                                            Radius.circular(isMe ? 0 : 12),
                                      ),
                                    ),
                                    child: Text(
                                      message['text'],
                                      style: TextStyle(
                                        color: isMe
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
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
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Mesajınızı yazın...',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 16),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _sendMessage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 147, 58, 142),
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(12),
                        ),
                        child: Icon(Icons.send, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
