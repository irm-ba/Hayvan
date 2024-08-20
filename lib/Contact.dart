import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContactPage extends StatefulWidget {
  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  String? selectedSubject;
  final _bodyController = TextEditingController();

  Future<void> sendEmail(String mail, String metin) async {
    String senderEmail = 'irembaysal1@outlook.com';
    String senderPassword = '3irem4.3Baysal7';
    String emailSubject = "irem mail doğrulama";
    String emailBody =
        "Merhaba,\n Uygulamaya gönderdiğiniz metin: \n\n" + metin;

    final smtpServer = SmtpServer(
      'smtp.office365.com',
      port: 587,
      username: senderEmail,
      password: senderPassword,
      ignoreBadCertificate: true,
      ssl: false,
      allowInsecure: true,
    );

    final message = Message()
      ..from = Address(senderEmail, 'Felvera')
      ..recipients.add(mail)
      ..subject = emailSubject
      ..text = emailBody;

    try {
      final sendReport = await send(message, smtpServer);
      print('Mesaj gönderildi: ' + sendReport.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("E-posta başarıyla gönderildi")),
      );
    } catch (e) {
      print('Mesaj gönderilemedi.');
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("E-posta gönderilemedi: $e")),
      );
    }
  }

  void _saveToFirestore(String mail, String metin) async {
    try {
      await FirebaseFirestore.instance.collection('contact').add({
        'mail': mail,
        'konu': selectedSubject,
        'mesaj': metin,
        'isActive': true,
        'timestamp': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Veri başarıyla kaydedildi")),
      );
    } catch (e) {
      print('Veri kaydedilemedi.');
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Veri kaydedilemedi")),
      );
    }
  }

  void _handleSubmit() {
    String mail = 'irembaysal1@outlook.com';
    String metin = _bodyController.text;

    if (selectedSubject == null || metin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lütfen tüm alanları doldurun")),
      );
      return;
    }

    _saveToFirestore(mail, metin);
    sendEmail(mail, metin);
    _bodyController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bize Ulaşın'),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background shapes
          Positioned.fill(
            child: CustomPaint(
              painter: BackgroundPainter(),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bizimle İletişime Geçin',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 147, 58, 142),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Geri bildiriminiz bizim için önemli. Aşağıdaki formu doldurarak bize öneri, şikayet veya dileklerinizi iletebilirsiniz.',
                  style: TextStyle(
                    fontSize: 16,
                    color:
                        Colors.black87, // Darker color for better readability
                  ),
                ),
                SizedBox(height: 30),
                Material(
                  elevation: 6,
                  shadowColor: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: DropdownButtonFormField<String>(
                      value: selectedSubject,
                      hint: Text('Konu Seçin'),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedSubject = newValue;
                        });
                      },
                      items: [
                        'Öneri',
                        'Şikayet',
                        'Dilek',
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.topic,
                            color: Color.fromARGB(255, 147, 58, 142)),
                        labelText: 'Konu',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Material(
                  elevation: 6,
                  shadowColor: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: TextField(
                      controller: _bodyController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.message,
                            color: Color.fromARGB(255, 147, 58, 142)),
                        labelText: 'Mesajınız',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: Color.fromARGB(255, 147, 58, 142),
                    ),
                    child: Text(
                      'Gönder',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color.fromARGB(255, 239, 229, 245) // Lighter background color
      ..style = PaintingStyle.fill;

    // Draw large circles
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.3),
      150,
      paint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.7),
      150,
      paint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.8),
      120,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
