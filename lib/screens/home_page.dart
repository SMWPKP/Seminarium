import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({required this.label, required this.detailsPath, super.key});

  final String label;

  final String detailsPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: const Center(
        child: Text('Home Page'),
      ),
    );
  }
}