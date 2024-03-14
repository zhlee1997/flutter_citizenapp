import 'package:flutter/material.dart';

class TransactionHistoryScreen extends StatelessWidget {
  static const String routeName = "transaction-history-screen";

  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Transaction History"),
      ),
      body: Container(),
    );
  }
}
