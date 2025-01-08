import 'package:ailibrarian/pages/aichat.dart';
import 'package:ailibrarian/pages/bookstack.dart';
import 'package:ailibrarian/pages/profile.dart';
import 'package:ailibrarian/pages/settings.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _selectedPage = 0;

  final List<Widget> _pages = [
    Bookstack(),
    ChatbotApp(),
    ProfilePage(),
    SettingsPage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedPage],
      bottomNavigationBar: Container(
        color: Color(0xFF2c302e),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: GNav(
              backgroundColor: Color(0xFF2c302e),
              color: Color(0xFF9AE19D),
              activeColor: Color(0xFF9AE19D),
              tabBackgroundColor: Color(0xFF474A48),
              padding: const EdgeInsets.all(16),
              gap: 10,
              onTabChange: (value) {
                setState(() {
                  _selectedPage = value;
                });
              },
              tabs: const [
                GButton(
                  icon: Icons.shelves,
                  text: 'Bookstack',
                ),
                GButton(
                  icon: Icons.chat,
                  text: 'Wednesday AI',
                ),
                GButton(
                  icon: Icons.person,
                  text: 'Profile',
                ),
                // GButton(
                //   icon: Icons.settings,
                //   text: 'Settings',
                // ),
              ]),
        ),
      ),
    );
  }
}
