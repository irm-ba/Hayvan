import 'package:flutter/material.dart';
import 'package:pet_adoption/AdoptionApplicationsPage.dart';
import 'package:pet_adoption/account.dart';
import 'package:pet_adoption/healtbutton.dart';
import 'package:pet_adoption/product_add_page.dart';
import 'package:pet_adoption/screens/home.dart';
import 'package:pet_adoption/screens/home_page.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  @override
  _CustomBottomNavigationBarState createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  int _currentIndex = 2; // Başlangıçtaki seçili ikon

  @override
  Widget build(BuildContext context) {
    List<IconData> icons = [
      Icons.home,
      Icons.notifications,
      Icons.add, // Ortadaki artı ikonu
      Icons.person_outline,
      Icons.list
    ];

    return BottomNavigationBar(
      currentIndex: _currentIndex,
      items: icons.asMap().entries.map((entry) {
        int index = entry.key;
        IconData icon = entry.value;
        return BottomNavigationBarItem(
          icon: index == 2 ? _addButton() : _animatedIcon(icon, index),
          label: "",
        );
      }).toList(),
      showSelectedLabels: false,
      showUnselectedLabels: false,
      backgroundColor: Colors.white,
      selectedItemColor: Colors.purple,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
        _onItemTapped(index, context);
      },
      type: BottomNavigationBarType.fixed,
    );
  }

  Widget _animatedIcon(IconData icon, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _currentIndex == index
            ? Colors.purple.withOpacity(0.2)
            : Colors.transparent,
      ),
      child: Center(
        child: Icon(
          icon,
          color: _currentIndex == index ? Colors.purple : Colors.grey,
          size: _currentIndex == index ? 30 : 24,
        ),
      ),
    );
  }

  Widget _addButton() {
    return GestureDetector(
      onTap: () {
        // Artı butonuna tıklama işlemi
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
        );
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.deepPurple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: 36,
          ),
        ),
      ),
    );
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
        break;
      case 2:
        // Artı butonuna tıklama işlemi zaten _addButton() içinde yapılmakta
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AccountPage()),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AdoptionApplicationsPage()),
        );
        break;
    }
  }
}
