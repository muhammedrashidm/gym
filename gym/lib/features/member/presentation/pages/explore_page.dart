import 'package:flutter/material.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9), // surface from Stitch
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'EXPLORE',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w900,
            color: Colors.black,
            letterSpacing: -0.5,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 24.0),
            child: CircleAvatar(
              backgroundColor: Color(0xFFE2E2E2),
              child: Icon(Icons.person, color: Colors.black),
            ),
          )
        ],
      ),
      body: const Center(
        child: Text('Find Nearby Gyms (Placeholder)',
          style: TextStyle(fontFamily: 'Inter'),
        ),
      ),
    );
  }
}
