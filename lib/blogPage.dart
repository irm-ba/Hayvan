import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BlogPage extends StatelessWidget {
  const BlogPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hayvanlar Hakkında Bilgiler'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('blogs').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Hata oluştu: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Henüz blog gönderisi bulunmamaktadır.'));
          }

          List<QueryDocumentSnapshot> docs = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var doc = docs[index];
              return _buildBlogPost(
                context,
                title: doc['title'],
                date: doc['date'],
                author: doc['author'],
                content: doc['content'],
                imageUrl: doc['imageUrl'],
                category: doc['category'],
                tags: List<String>.from(doc['tags']),
                contentType: doc['contentType'],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBlogPost(
    BuildContext context, {
    required String title,
    required String date,
    required String author,
    required String content,
    required String imageUrl,
    required String category,
    required List<String> tags,
    required String contentType,
  }) {
    return GestureDetector(
      onTap: () => _showPostDetails(
        context,
        title: title,
        date: date,
        author: author,
        content: content,
        category: category,
        tags: tags,
        contentType: contentType,
      ),
      child: Card(
        elevation: 8,
        margin: EdgeInsets.symmetric(vertical: 12.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 147, 58, 142),
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    children: [
                      Icon(Icons.date_range,
                          color: Color.fromARGB(255, 147, 58, 142)),
                      SizedBox(width: 4.0),
                      Text(
                        date,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.0),
                  Row(
                    children: [
                      Icon(Icons.person,
                          color: Color.fromARGB(255, 147, 58, 142)),
                      SizedBox(width: 4.0),
                      Text(
                        author,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Kategori: $category',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    'Etiketler: ${tags.join(', ')}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    'Tür: $contentType',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    content.length > 100
                        ? '${content.substring(0, 100)}...'
                        : content,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPostDetails(
    BuildContext context, {
    required String title,
    required String date,
    required String author,
    required String content,
    required String category,
    required List<String> tags,
    required String contentType,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: Color.fromARGB(255, 147, 58, 142),
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text(
                  'Yayınlanma Tarihi: $date',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  'Yazar: $author',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  'Kategori: $category',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  'Etiketler: ${tags.join(', ')}',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  'Tür: $contentType',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 16.0),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                'Kapat',
                style: TextStyle(
                  color: Color.fromARGB(255, 147, 58, 142),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
