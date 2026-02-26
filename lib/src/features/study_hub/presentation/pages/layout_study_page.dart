import 'package:flutter/material.dart';

class LayoutStudyPage extends StatelessWidget {
  const LayoutStudyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Layouts Study')),
      body: const Center(child: Text('Study content')),
    );
  }
}
