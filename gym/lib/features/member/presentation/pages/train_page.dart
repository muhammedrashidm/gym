import 'package:flutter/material.dart';

class TrainPage extends StatelessWidget {
  const TrainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'TRAIN',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
      ),
      body: const Center(
        child: Text('Active Workout & AI Instructor (Placeholder)',
          style: TextStyle(fontFamily: 'Inter'),
        ),
      ),
    );
  }
}
