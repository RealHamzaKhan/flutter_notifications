import 'package:flutter/material.dart';

class MessageScreen extends StatelessWidget {
  final String? name;
  const MessageScreen({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name!),
      ),
    );
  }
}