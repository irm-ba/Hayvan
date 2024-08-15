import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HealthRecord {
  final String petId;
  final Timestamp date;
  final String description;
  final String treatment;
  final String veterinarianName;
  final String healthStatus;

  HealthRecord({
    required this.petId,
    required this.date,
    required this.description,
    required this.treatment,
    required this.veterinarianName,
    required this.healthStatus,
  });

  Map<String, dynamic> toMap() {
    return {
      'petId': petId,
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

  Future<void> _selectDate() async {
    // Tarih seçici penceresini aç
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Başlangıç tarihi olarak bugünü ayarla
      firstDate: DateTime(2000), // En erken tarih olarak yıl 2000'i ayarla
      lastDate: DateTime(2101), // En geç tarih olarak yıl 2101'i ayarla
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.purple, // Ana renk olarak moru ayarla
            colorScheme: ColorScheme.light(
                primary: Colors.purple), // İkincil renk olarak moru ayarla
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    // Seçilen tarihi kontrol et ve formu güncelle
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        dateController.text = DateFormat('dd-MM-yyyy')
            .format(picked); // Tarihi 'gg-aa-yyyy' formatında ayarla
      });
    }
  }

  void _submitForm() async {
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

    try {
      final date = DateFormat('dd-MM-yyyy').parse(dateController.text);

      final healthRecord = HealthRecord(
        petId: widget.petId,
        date: Timestamp.fromDate(date),
        description: descriptionController.text,
        treatment: treatmentController.text,
        veterinarianName: veterinarianNameController.text,
        healthStatus: healthStatusController.text,
      );

      await FirebaseFirestore.instance
          .collection('healthRecords')
          .add(healthRecord.toMap());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sağlık kaydı başarıyla eklendi!'),
        ),
      );

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
              GestureDetector(
                onTap: _selectDate,
                child: AbsorbPointer(
                  child: TextField(
                    controller: dateController,
                    decoration: InputDecoration(
                      hintText: "GG-AA-YYYY", // Türkçe format: GG-AA-YYYY
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
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
                child: Text("Ekle"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
