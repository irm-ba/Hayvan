import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VetVisitAdd extends StatefulWidget {
  const VetVisitAdd({Key? key}) : super(key: key);

  @override
  _VetVisitAddState createState() => _VetVisitAddState();
}

class _VetVisitAddState extends State<VetVisitAdd> {
  DateTime? visitDate;
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Veteriner Ziyareti Ekle"),
        backgroundColor: const Color.fromARGB(255, 210, 141, 212),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Açıklama'),
            ),
            const SizedBox(height: 16),
            Text(
              visitDate != null
                  ? 'Ziyaret Tarihi: ${visitDate!.toLocal()}'
                  : 'Tarihi seçin',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final result = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (result != null) {
                  setState(() {
                    visitDate = result;
                  });
                }
              },
              child: const Text("Tarihi Seç"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 210, 141, 212),
                foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (visitDate != null &&
                    _descriptionController.text.isNotEmpty) {
                  await FirebaseFirestore.instance.collection('vetVisits').add({
                    'description': _descriptionController.text,
                    'visitDate': visitDate,
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text("Kaydet"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 210, 141, 212),
                foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
