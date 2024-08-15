import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VaccinationScheduleAdd extends StatefulWidget {
  const VaccinationScheduleAdd({Key? key}) : super(key: key);

  @override
  _VaccinationScheduleAddState createState() => _VaccinationScheduleAddState();
}

class _VaccinationScheduleAddState extends State<VaccinationScheduleAdd> {
  DateTime? start;
  DateTime? end;
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Aşı Takvimi Ekle"),
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
              start != null && end != null
                  ? 'Başlangıç: ${start!.toLocal()} \nBitiş: ${end!.toLocal()}'
                  : 'Tarihleri seçin',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final result = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (result != null) {
                  setState(() {
                    start = result.start;
                    end = result.end;
                  });
                }
              },
              child: const Text("Tarihleri Seç"),
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
                if (start != null &&
                    end != null &&
                    _descriptionController.text.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('vaccinationSchedules')
                      .add({
                    'description': _descriptionController.text,
                    'start': start,
                    'end': end,
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
