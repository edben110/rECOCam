import 'package:flutter/material.dart';

/// Placeholder page.
/// Result display is integrated in HomePage.
/// Keep for future extensibility.
class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Result here - integrated in Home')),
    );
  }
}
