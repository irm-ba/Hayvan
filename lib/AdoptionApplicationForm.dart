import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class AdoptionApplicationForm extends StatefulWidget {
  final String petOwnerId;
  final String petId; // Add petId parameter

  AdoptionApplicationForm({
    required this.petOwnerId,
    required this.petId, // Initialize petId
  });

  @override
  _AdoptionApplicationFormState createState() =>
      _AdoptionApplicationFormState();
}

class _AdoptionApplicationFormState extends State<AdoptionApplicationForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _livingConditionsController =
      TextEditingController();
  final TextEditingController _adoptionReasonController =
      TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = Uuid(); // UUID oluşturucu

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sahiplenme Başvurusu',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.purple[800],
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple[900]!, Colors.purple[600]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'İletişim Bilgileri',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[800],
                  ),
                ),
                SizedBox(height: 16),
                _buildTextField(
                  controller: _nameController,
                  labelText: 'Adınız ve Soyadınız',
                  prefixIcon: Icons.person,
                ),
                SizedBox(height: 12),
                _buildTextField(
                  controller: _phoneController,
                  labelText: 'Telefon Numaranız',
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone,
                ),
                SizedBox(height: 12),
                _buildTextField(
                  controller: _emailController,
                  labelText: 'E-posta Adresiniz',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email,
                ),
                SizedBox(height: 12),
                _buildTextField(
                  controller: _addressController,
                  labelText: 'Adresiniz',
                  prefixIcon: Icons.location_on,
                ),
                SizedBox(height: 24),
                Text(
                  'Başvuru Bilgileri',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[800],
                  ),
                ),
                SizedBox(height: 16),
                _buildTextField(
                  controller: _livingConditionsController,
                  labelText: 'Yaşam Koşullarınız',
                  maxLines: 3,
                  prefixIcon: Icons.home,
                ),
                SizedBox(height: 12),
                _buildTextField(
                  controller: _adoptionReasonController,
                  labelText: 'Sahiplenme Nedeni',
                  maxLines: 3,
                  prefixIcon: Icons.notes,
                ),
                SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[700],
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      textStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      elevation: 8,
                    ),
                    child: Text('Gönder'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType? keyboardType,
    int? maxLines,
    IconData? prefixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: Colors.purple[600])
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.purple[800]!, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          labelStyle: TextStyle(color: Colors.purple[700]),
          fillColor: Colors.white,
          filled: true,
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final phone = _phoneController.text;
      final email = _emailController.text;
      final address = _addressController.text;
      final livingConditions = _livingConditionsController.text;
      final adoptionReason = _adoptionReasonController.text;

      try {
        final String applicationId = _uuid.v4();
        final String userId =
            FirebaseAuth.instance.currentUser?.uid ?? _uuid.v4();
        final String petOwnerId = widget.petOwnerId;
        final String petId = widget.petId; // Use petId from widget

        DocumentReference docRef =
            _firestore.collection('adoption_applications').doc(applicationId);

        await docRef.set({
          'applicationId': applicationId,
          'userId': userId,
          'petOwnerId': petOwnerId,
          'petId': petId, // Use petId from widget
          'name': name,
          'phone': phone,
          'email': email,
          'address': address,
          'livingConditions': livingConditions,
          'adoptionReason': adoptionReason,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Başvurunuz gönderildi')),
        );

        _nameController.clear();
        _phoneController.clear();
        _emailController.clear();
        _addressController.clear();
        _livingConditionsController.clear();
        _adoptionReasonController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bir hata oluştu, lütfen tekrar deneyin')),
        );
      }
    }
  }
}
