import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'PROFILE',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
      ),
      body: const Center(
        child: Text('Member Settings & Subscriptions (Placeholder)',
          style: TextStyle(fontFamily: 'Inter'),
        ),
      ),
    );
  }
}
