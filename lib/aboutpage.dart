import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hakkımızda'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Hoş geldiniz!',
              style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple),
            ),
            SizedBox(height: 10.0),
            Text(
              'Hayvanları sahiplendirme ve onlara yeni bir yuva bulma misyonuyla yola çıkan uygulamamız, sevgi dolu bir topluluk için köprü görevi görüyor. Amacımız, sokak hayvanlarına destek olmak ve onları sevgi dolu ailelerle buluşturarak hayatlarında olumlu bir değişim yaratmaktır.',
              style: TextStyle(fontSize: 16.0, color: Colors.black),
            ),
            SizedBox(height: 20.0),
            Text(
              'Misyonumuz',
              style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple),
            ),
            SizedBox(height: 10.0),
            Text(
              'Sokak hayvanlarının ihtiyaçlarını anlamak ve onların haklarını savunmak, bizim en öncelikli görevlerimizden biridir. Her bir hayvanın özel bir hikayesi ve sevgiye ihtiyacı olduğunu biliyoruz. Bu nedenle, adil, etik ve sevgi dolu bir sahiplendirme süreci sunarak, onların hayatlarına olumlu bir dokunuş yapmayı amaçlıyoruz.',
              style: TextStyle(fontSize: 16.0, color: Colors.black),
            ),
            SizedBox(height: 20.0),
            Text(
              'Vizyonumuz',
              style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple),
            ),
            SizedBox(height: 10.0),
            Text(
              'Gelecekte, her sokak hayvanının bir yuvası olması için çalışıyoruz. Toplumun her bireyini sokak hayvanlarına karşı duyarlı olmaya teşvik ederek, birlikte daha yaşanabilir bir dünya yaratmayı hedefliyoruz. Teknolojiyi kullanarak, hayvanseverleri ve sahiplendirme adaylarını bir araya getiren bir platform oluşturuyoruz.',
              style: TextStyle(fontSize: 16.0, color: Colors.black),
            ),
            SizedBox(height: 20.0),
            Text(
              'Neden Biz?',
              style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple),
            ),
            SizedBox(height: 10.0),
            Text(
              '- Toplumsal Sorumluluk: Sokak hayvanlarının refahı için toplumu bilinçlendirme ve destek alma konusunda çaba sarf ediyoruz.',
              style: TextStyle(fontSize: 16.0, color: Colors.black),
            ),
            SizedBox(height: 20.0),
            Text(
              'Bizimle İletişime Geçin',
              style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple),
            ),
            SizedBox(height: 10.0),
            Text(
              'Siz de sokak hayvanlarına destek olmak ve bir hayat kurtarmak istiyorsanız, bize katılın! İhtiyaç duyduğunuz her an bizimle iletişime geçebilirsiniz. Hayvan sevgisini paylaşan herkesi uygulamamıza davet ediyoruz.',
              style: TextStyle(fontSize: 16.0, color: Colors.black),
            ),
          ],
        ),
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
