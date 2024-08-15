import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:pet_adoption/sign_up.dart';

class IntroScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Hides the status bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    return Scaffold(
      body: IntroductionScreen(
        globalBackgroundColor: Color.fromARGB(255, 241, 213, 239),
        scrollPhysics: BouncingScrollPhysics(),
        pages: [
          PageViewModel(
            titleWidget: Text(
              "Felvera Evcil Hayvan Platformu",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            body:
                "Felvera'ya Hoş Geldiniz! Sevgi dolu dostlarımızı keşfedin ve hayatlarına neşe katın..",
            image: Image.asset(
              "assets/images/birinci.png",
              height: 400,
              width: 400,
            ),
          ),
          PageViewModel(
            titleWidget: Text(
              "Felvera Evcil Hayvan Platformu",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            body:
                "Bizim amacımız sevimli dostlarımızın daha güzel bir yaşam sürmesi. bunu hep birlikte başarabiliriz.",
            image: Image.asset(
              "assets/images/ikinci.png",
              height: 400,
              width: 400,
            ),
          ),
          PageViewModel(
            titleWidget: Text(
              "Felvera Evcil Hayvan Platformu",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            body:
                "Sokak hayvanlarına yuva, kayıp dostlara kavuşma, evcil hayvanlara sıcak bir yuva sunmak için hemen başlayın!",
            image: Image.asset(
              "assets/images/resim.png",
              height: 400,
              width: 400,
            ),
          ),
        ],
        onDone: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SignupPage()),
          );
        },
        onSkip: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SignupPage()),
          );
        },
        showBackButton: false,
        skip: Text(
          "Atla",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF6C63FF),
          ),
        ),
        next: Icon(Icons.arrow_forward, color: Color(0xFF6C63FF)),
        done: InkWell(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SignupPage()),
            );
          },
          child: Text(
            "Devam et",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(0xFF6C63FF),
            ),
          ),
        ),
        dotsDecorator: DotsDecorator(
          size: Size.square(10.0),
          activeSize: Size(20.0, 10.0),
          color: Colors.black26,
          activeColor: Color(0xFF6C63FF),
          spacing: EdgeInsets.symmetric(horizontal: 3.0),
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
      ),
    );
  }
}
