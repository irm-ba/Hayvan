import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DenemeService {
  static final DenemeService _denemeService = DenemeService._internal();

  factory DenemeService() {
    return _denemeService;
  }

  DenemeService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<QuerySnapshot<Map<String, dynamic>>> getItems() async {
    try {
      var querySnapshot = await _db.collection('Deneme').get();
      return querySnapshot;
    } catch (e) {
      throw Exception('Veri alınamadı: $e');
    }
  }
}

class Example extends StatefulWidget {
  const Example({Key? key}) : super(key: key);

  @override
  State<Example> createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  late Future<QuerySnapshot<Map<String, dynamic>>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = DenemeService().getItems(); // Veri alımı başlatılıyor
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Veritabanı Testi'),
      ),
      body: SafeArea(
        child: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
          future: _dataFuture,
          builder: (context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            if (snapshot.hasError) {
              return Center(
                  child: Text(
                      'Veri alınırken bir hata oluştu: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            final data = snapshot.requireData;

            return ListView.builder(
              itemCount: data.size,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(data.docs[index]['Name']),
                  subtitle: const Text('subtitle'),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Example(),
  ));
}
