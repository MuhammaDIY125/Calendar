import 'package:flutter/material.dart';

// Заглушка — будет заменена в Шаге 12
class EventDetailPage extends StatelessWidget {
  final int eventId;

  const EventDetailPage({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Event Detail')),
    );
  }
}
