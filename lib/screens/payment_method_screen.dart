import 'package:flutter/material.dart';

class PaymentMethodScreen extends StatelessWidget {
  final String violationId;
  const PaymentMethodScreen({super.key, required this.violationId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Method')),
      body: Center(
        child: Text(
          'Payment Method\n$violationId',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
