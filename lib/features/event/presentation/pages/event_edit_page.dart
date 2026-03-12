import 'package:flutter/material.dart';

// Заглушка — будет заменена в Шаге 13
class EventEditPage extends StatelessWidget {
  final int eventId;

  const EventEditPage({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Edit Event')),
    );
  }
}
