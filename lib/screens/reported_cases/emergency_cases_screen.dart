import 'package:flutter/material.dart';

class EmergencyCasesScreen extends StatelessWidget {
  static const String routeName = "emergency-cases-screen";

  const EmergencyCasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Emergency Cases"),
      ),
      body: Container(),
    );
  }
}
