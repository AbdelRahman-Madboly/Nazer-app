import 'package:flutter/material.dart';

class PaymentFormScreen extends StatelessWidget {
  final String violationId;
  final String method;
  const PaymentFormScreen({super.key, required this.violationId, required this.method});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Form')),
      body: Center(
        child: Text(
          'Payment Form\nMethod: $method\nID: $violationId',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
