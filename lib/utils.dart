import 'package:firebase_auth/firebase_auth.dart';

String getCurrentUserId() {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    return user.uid;
  } else {
    // Kullanıcı giriş yapmamışsa, uygun bir hata mesajı veya yönlendirme yapılabilir
    throw Exception('Kullanıcı oturum açmamış');
  }
}

/// İki kullanıcı ID'sini kullanarak benzersiz bir konuşma ID'si oluşturur.
String generateConversationId(String userId1, String userId2) {
  return userId1.compareTo(userId2) < 0
      ? '$userId1-$userId2'
      : '$userId2-$userId1';
}
