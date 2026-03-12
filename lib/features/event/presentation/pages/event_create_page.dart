import 'package:flutter/material.dart';

// Заглушка — будет заменена в Шаге 11
class EventCreatePage extends StatelessWidget {
  final DateTime? selectedDate;

  const EventCreatePage({super.key, this.selectedDate});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Create Event')),
    );
  }
}
