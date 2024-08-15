import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContactPage extends StatefulWidget {
  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _subjectController = TextEditingController();
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
        'mesaj': metin,
        'isActive': true, // isActive değerini true olarak kaydediyoruz
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
    String mail = 'irembaysal1@outlook.com'; // Sabit mail adresi
    String metin = _bodyController.text;

    if (metin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lütfen mesaj alanını doldurun")),
      );
      return;
    }

    // Firestore'a veri kaydet
    _saveToFirestore(mail, metin);

    // E-posta gönder
    sendEmail(mail, metin);

    // Alanları temizle
    _subjectController.clear();
    _bodyController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bize Ulaşın'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _subjectController,
              decoration: InputDecoration(
                labelText: 'Konu',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _bodyController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Mesajınız',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _handleSubmit,
              child: Text('Gönder'),
            ),
          ],
        ),
      ),
    );
  }
}
