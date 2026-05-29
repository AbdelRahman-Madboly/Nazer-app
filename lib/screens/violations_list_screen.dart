import 'package:flutter/material.dart';

class ViolationsListScreen extends StatelessWidget {
  const ViolationsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Violations')),
      body: const Center(
        child: Text(
          'Violations\n(Coming Soon)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
