import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HealthRecord {
  final String petId;
  final String userId; // Kullanıcı UID'si
  final Timestamp date;
  final String description;
  final String treatment;
  final String veterinarianName;
  final String healthStatus;

  HealthRecord({
    required this.petId,
    required this.userId, // Yeni parametre
    required this.date,
    required this.description,
    required this.treatment,
    required this.veterinarianName,
    required this.healthStatus,
  });

  Map<String, dynamic> toMap() {
    return {
      'petId': petId,
      'userId': userId, // Firebase'e kaydedilecek
      'date': date,
      'description': description,
      'treatment': treatment,
      'veterinarianName': veterinarianName,
      'healthStatus': healthStatus,
    };
  }
}

class HealthRecordAdd extends StatefulWidget {
  const HealthRecordAdd({Key? key, required this.petId}) : super(key: key);

  final String petId;

  @override
  State<HealthRecordAdd> createState() => _HealthRecordAddState();
}

class _HealthRecordAddState extends State<HealthRecordAdd> {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController treatmentController = TextEditingController();
  final TextEditingController veterinarianNameController =
  TextEditingController();
  final TextEditingController healthStatusController = TextEditingController();

  void _submitForm() async {
    // Firebase Authentication üzerinden giriş yapan kullanıcının UID'sini alın
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lütfen giriş yapın.'),
        ),
      );
      return;
    }

    if (dateController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        treatmentController.text.isEmpty ||
        veterinarianNameController.text.isEmpty ||
        healthStatusController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lütfen tüm alanları doldurun.'),
        ),
      );
      return;
    }

    final healthRecord = HealthRecord(
      petId: widget.petId,
      userId: user.uid, // Kullanıcı UID'si
      date: Timestamp.fromDate(DateTime.parse(dateController.text)),
      description: descriptionController.text,
      treatment: treatmentController.text,
      veterinarianName: veterinarianNameController.text,
      healthStatus: healthStatusController.text,
    );

    try {
      // Firestore'a yeni sağlık kaydını ekle
      await FirebaseFirestore.instance
          .collection('healthRecords')
          .add(healthRecord.toMap());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sağlık kaydı başarıyla eklendi!'),
        ),
      );

      // Formu sıfırlamak için gerekli kontrolleri ekleyebilirsiniz (isteğe bağlı)
      dateController.clear();
      descriptionController.clear();
      treatmentController.clear();
      veterinarianNameController.clear();
      healthStatusController.clear();
    } catch (e) {
      print('Firebase veri eklerken hata oluştu: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sağlık kaydı eklenirken bir hata oluştu.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sağlık Kaydı Ekle"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Tarih",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 10),
              TextField(
                controller: dateController,
                decoration: InputDecoration(
                  hintText: "YYYY-MM-DD",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Açıklama",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  hintText: "Açıklama",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Tedavi",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 10),
              TextField(
                controller: treatmentController,
                decoration: InputDecoration(
                  hintText: "Tedavi",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Veterinerin Adı",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 10),
              TextField(
                controller: veterinarianNameController,
                decoration: InputDecoration(
                  hintText: "Veterinerin Adı",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Sağlık Durumu",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 10),
              TextField(
                controller: healthStatusController,
                decoration: InputDecoration(
                  hintText: "Sağlık Durumu",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text("Ekle",),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Color.fromARGB(255, 255, 255, 255),
                  backgroundColor: Color.fromARGB(255, 147, 58, 142),
              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Sağlık kayıtlarını yalnızca giriş yapan kullanıcıya göre getiren fonksiyon
Stream<QuerySnapshot> getUserHealthRecords() {
  final user = FirebaseAuth.instance.currentUser;
  return FirebaseFirestore.instance
      .collection('healthRecords')
      .where('userId', isEqualTo: user!.uid)
      .snapshots();
}
