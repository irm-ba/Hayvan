import 'package:flutter/material.dart';
import 'package:pet_adoption/chatPage.dart';
import 'package:pet_adoption/models/lost_animal_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LostAnimalDetailsScreen extends StatefulWidget {
  final LostAnimalData lostAnimal;

  const LostAnimalDetailsScreen({Key? key, required this.lostAnimal})
      : super(key: key);

  @override
  _LostAnimalDetailsScreenState createState() =>
      _LostAnimalDetailsScreenState();
}

class _LostAnimalDetailsScreenState extends State<LostAnimalDetailsScreen> {
  String? currentUserName;
  String? receiverName;
  String? receiverEmail;
  String? receiverPhone;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId != null) {
      // Fetch the current user's information
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();
      setState(() {
        final userData = userDoc.data() as Map<String, dynamic>;
        currentUserName =
            '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'
                .trim();
      });
    }

    // Fetch the receiver's information
    DocumentSnapshot receiverDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.lostAnimal.userId)
        .get();
    setState(() {
      final receiverData = receiverDoc.data() as Map<String, dynamic>;
      receiverName =
          '${receiverData['firstName'] ?? ''} ${receiverData['lastName'] ?? ''}'
              .trim();
      receiverEmail = receiverData['email'] ?? 'E-posta bilgisi mevcut değil';
      receiverPhone =
          receiverData['phoneNumber'] ?? 'Telefon numarası mevcut değil';
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the current user ID from Firebase Auth
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.lostAnimal.name,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.purple[800],
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.purple[800]),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildImageSection(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildInfoCard(
                    title: 'Açıklama',
                    content: widget.lostAnimal.description,
                    icon: Icons.description,
                    iconColor: Color(0xFFC478D1), // Ana renk
                  ),
                  SizedBox(height: 16),
                  buildInfoCard(
                    title: 'Yaş',
                    content: '${widget.lostAnimal.age} yaşında',
                    icon: Icons.calendar_today,
                    iconColor: Colors.orange[800]!,
                  ),
                  SizedBox(height: 16),
                  buildInfoCard(
                    title: 'Cinsiyet',
                    content: widget.lostAnimal.isGenderMale ? 'Erkek' : 'Dişi',
                    icon: Icons.pets,
                    iconColor: Colors.blue[800]!,
                  ),
                  SizedBox(height: 16),
                  buildInfoCard(
                    title: 'Konum',
                    content: widget.lostAnimal.location,
                    icon: Icons.location_on,
                    iconColor: Colors.red[800]!,
                  ),
                  SizedBox(height: 16),
                  buildContactInfo(context, currentUserId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildImageSection() {
    return Container(
      width: double.infinity,
      height: 450,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
            widget.lostAnimal.imageUrls.isNotEmpty
                ? widget.lostAnimal.imageUrls[0]
                : '',
          ),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black.withOpacity(0.5), Colors.transparent],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
          child: Text(
            widget.lostAnimal.name,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInfoCard({
    required String title,
    required String content,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.all(16),
          leading: CircleAvatar(
            backgroundColor: iconColor.withOpacity(0.2),
            child: Icon(icon, color: iconColor),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.purple[800],
            ),
          ),
          subtitle: Text(
            content,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildContactInfo(BuildContext context, String? currentUserId) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'İletişim Bilgileri',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.purple[800],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'E-posta: ${receiverEmail ?? 'Bilgi mevcut değil'}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 16),
          // Kodun mevcut haline ek olarak değiştirilecek kısım
          ElevatedButton(
            onPressed: () async {
              if (currentUserId != null &&
                  currentUserName != null &&
                  receiverName != null) {
                final conversationId =
                    'unique-conversation-id-${currentUserId}-${widget.lostAnimal.userId}';

                // Sohbetin daha önce var olup olmadığını kontrol edin
                DocumentReference chatDocRef = FirebaseFirestore.instance
                    .collection('chats')
                    .doc(conversationId);

                DocumentSnapshot chatSnapshot = await chatDocRef.get();

                if (!chatSnapshot.exists) {
                  // Eğer sohbet yoksa yeni bir sohbet oluşturun
                  await chatDocRef.set({
                    'participants': [currentUserId, widget.lostAnimal.userId],
                    'lastMessage': '',
                    'timestamp': FieldValue.serverTimestamp(),
                  });
                }

                // ChatPage'e yönlendirin
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(
                      conversationId: conversationId,
                      receiverId: widget.lostAnimal.userId,
                      receiverName: receiverName!,
                      senderName: currentUserName!,
                    ),
                  ),
                );
              } else {
                // Kullanıcı bilgileri mevcut değilse bir uyarı göster
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Mesaj gönderebilmek için oturum açmış olmalısınız.'),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFC478D1), // Ana renk (mor tonları)
              foregroundColor: Colors.white, // Yazı rengi beyaz
              padding: EdgeInsets.symmetric(
                  vertical: 16.0, horizontal: 24.0), // Düğme içi boşluklar
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // Köşe yuvarlama
              ),
              textStyle: TextStyle(
                fontSize: 16, // Yazı boyutu
                fontWeight: FontWeight.bold, // Yazı kalınlığı
              ),
            ),
            child: Text('Mesaj Gönder'),
          )
        ],
      ),
    );
  }
}
