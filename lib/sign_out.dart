import 'package:flutter/material.dart';
import 'package:pet_adoption/firebase/auth.dart'; // Auth sınıfının bulunduğu dosya
import 'login.dart'; // Giriş sayfası için import

class SettingsPage extends StatelessWidget {
  final Auth _auth = Auth();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ayarlar"),
      ),
      body: ListView(
        children: [
          Divider(),
          ListTile(
            leading: Icon(Icons.logout_rounded,
                color: Color.fromARGB(255, 147, 58, 142)),
            title: Text('Çıkış yap'),
            onTap: () async {
              try {
                await _auth.signOut();
                // Çıkış yaptıktan sonra kullanıcıyı giriş ekranına yönlendirin
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              } catch (e) {
                // Hata durumunda kullanıcıya bilgi verin
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Çıkış yapılamadı: $e')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
