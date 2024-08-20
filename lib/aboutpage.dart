import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hakkımızda'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildHeroSection(),
            SizedBox(height: 20.0),
            _buildSection(
              title: 'Misyonumuz',
              content:
                  'Sokak hayvanlarının ihtiyaçlarını anlamak ve onların haklarını savunmak, bizim en öncelikli görevlerimizden biridir. Her bir hayvanın özel bir hikayesi ve sevgiye ihtiyacı olduğunu biliyoruz. Bu nedenle, adil, etik ve sevgi dolu bir sahiplendirme süreci sunarak, onların hayatlarına olumlu bir dokunuş yapmayı amaçlıyoruz.',
              color: Colors.orange,
              icon: Icons.pets,
            ),
            SizedBox(height: 20.0),
            _buildSection(
              title: 'Vizyonumuz',
              content:
                  'Gelecekte, her sokak hayvanının bir yuvası olması için çalışıyoruz. Toplumun her bireyini sokak hayvanlarına karşı duyarlı olmaya teşvik ederek, birlikte daha yaşanabilir bir dünya yaratmayı hedefliyoruz. Teknolojiyi kullanarak, hayvanseverleri ve sahiplendirme adaylarını bir araya getiren bir platform oluşturuyoruz.',
              color: Colors.blue,
              icon: Icons.visibility,
            ),
            SizedBox(height: 20.0),
            _buildSection(
              title: 'Neden Biz?',
              content:
                  '- Toplumsal Sorumluluk: Sokak hayvanlarının refahı için toplumu bilinçlendirme ve destek alma konusunda çaba sarf ediyoruz.',
              color: Colors.green,
              icon: Icons.favorite,
            ),
            SizedBox(height: 20.0),
            _buildContactSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 147, 58, 142),
            Color.fromARGB(255, 147, 58, 142),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30.0),
          bottomRight: Radius.circular(30.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15.0,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hoş geldiniz!',
            style: TextStyle(
              fontSize: 32.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 15.0),
          Text(
            'Hayvanları sahiplendirme ve onlara yeni bir yuva bulma misyonuyla yola çıkan uygulamamız, sevgi dolu bir topluluk için köprü görevi görüyor. Amacımız, sokak hayvanlarına destek olmak ve onları sevgi dolu ailelerle buluşturarak hayatlarında olumlu bir değişim yaratmaktır.',
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      {required String title,
      required String content,
      required Color color,
      required IconData icon}) {
    return Container(
      padding: EdgeInsets.all(15.0),
      margin: EdgeInsets.symmetric(horizontal: 15.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 30.0, color: color),
          ),
          SizedBox(width: 15.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                SizedBox(height: 10.0),
                Text(
                  content,
                  style: TextStyle(fontSize: 16.0, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: EdgeInsets.all(15.0),
      margin: EdgeInsets.symmetric(horizontal: 15.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bizimle İletişime Geçin',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 147, 58, 142),
            ),
          ),
          SizedBox(height: 10.0),
          Text(
            'Siz de sokak hayvanlarına destek olmak ve bir hayat kurtarmak istiyorsanız, bize katılın! İhtiyaç duyduğunuz her an bizimle iletişime geçebilirsiniz. Hayvan sevgisini paylaşan herkesi uygulamamıza davet ediyoruz.',
            style: TextStyle(fontSize: 16.0, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    title: 'Hayvan Sahiplendirme Uygulaması',
    home: AboutUsPage(),
  ));
}
