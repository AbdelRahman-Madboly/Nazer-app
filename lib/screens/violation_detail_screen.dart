import 'package:flutter/material.dart';

class ViolationDetailScreen extends StatelessWidget {
  final String violationId;
  const ViolationDetailScreen({super.key, required this.violationId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Violation Detail')),
      body: Center(
        child: Text(
          'Violation Detail\n$violationId',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
