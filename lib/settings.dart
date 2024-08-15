import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Bildirim Ayarları'),
            onTap: () {
              // Bildirim Ayarları sayfasına git
            },
          ),
          ListTile(
            leading: Icon(Icons.lock),
            title: Text('Gizlilik Ayarları'),
            onTap: () {
              // Gizlilik Ayarları sayfasına git
            },
          ),
          ListTile(
            leading: Icon(Icons.color_lens),
            title: Text('Tema Ayarları'),
            onTap: () {
              // Tema Ayarları sayfasına git
            },
          ),
          ListTile(
            leading: Icon(Icons.language),
            title: Text('Dil Ayarları'),
            onTap: () {
              // Dil Ayarları sayfasına git
            },
          ),
          ListTile(
            leading: Icon(Icons.account_circle),
            title: Text('Hesap Ayarları'),
            onTap: () {
              // Hesap Ayarları sayfasına git
            },
          ),
          ListTile(
            leading: Icon(Icons.help),
            title: Text('Yardım ve Destek'),
            onTap: () {
              // Yardım ve Destek sayfasına git
            },
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('Hakkında'),
            onTap: () {
              // Hakkında sayfasına git
            },
          ),
        ],
      ),
    );
  }
}
