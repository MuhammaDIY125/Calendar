import 'package:flutter/material.dart';

import 'package:calendar/features/event/domain/entities/event_color.dart';
import 'package:calendar/features/event/presentation/widgets/color_picker.dart';
import 'package:calendar/features/event/presentation/widgets/reminder_picker.dart';
import 'package:calendar/features/event/presentation/widgets/time_picker_field.dart';

/// Данные формы события
class EventFormData {
  final String name;
  final String description;
  final String location;
  final EventColor color;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final int? reminderMinutes;

  const EventFormData({
    required this.name,
    required this.description,
    required this.location,
    required this.color,
    required this.startTime,
    required this.endTime,
    this.reminderMinutes,
  });
}

/// Форма создания/редактирования события.
///
/// [initialData] — предзаполненные данные при редактировании.
/// [submitLabel] — текст кнопки ('Add' или 'Save').
/// [onSubmit] — колбэк с валидными данными формы.
class EventForm extends StatefulWidget {
  final EventFormData? initialData;
  final String submitLabel;
  final ValueChanged<EventFormData> onSubmit;

  const EventForm({
    super.key,
    this.initialData,
    required this.submitLabel,
    required this.onSubmit,
  });

  @override
  State<EventForm> createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _locationCtrl;
  late EventColor _color;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late int? _reminderMinutes;

  @override
  void initState() {
    super.initState();
    final d = widget.initialData;
    _nameCtrl = TextEditingController(text: d?.name ?? '');
    _descCtrl = TextEditingController(text: d?.description ?? '');
    _locationCtrl = TextEditingController(text: d?.location ?? '');
    _color = d?.color ?? EventColor.blue;
    _startTime = d?.startTime ?? const TimeOfDay(hour: 9, minute: 0);
    _endTime = d?.endTime ?? const TimeOfDay(hour: 10, minute: 0);
    _reminderMinutes = d?.reminderMinutes;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    // Проверка: время конца позже времени начала
    final startMinutes = _startTime.hour * 60 + _startTime.minute;
    final endMinutes = _endTime.hour * 60 + _endTime.minute;
    if (endMinutes <= startMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time')),
      );
      return;
    }

    widget.onSubmit(
      EventFormData(
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        color: _color,
        startTime: _startTime,
        endTime: _endTime,
        reminderMinutes: _reminderMinutes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Название
                  TextFormField(
                    controller: _nameCtrl,
                    decoration:
                        const InputDecoration(hintText: 'Event name'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 12),
                  // Описание
                  TextFormField(
                    controller: _descCtrl,
                    maxLines: 5,
                    decoration:
                        const InputDecoration(hintText: 'Event description'),
                  ),
                  const SizedBox(height: 12),
                  // Место
                  TextFormField(
                    controller: _locationCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Event location',
                      suffixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Цвет
                  EventColorPicker(
                    value: _color,
                    onChanged: (c) => setState(() => _color = c),
                  ),
                  const SizedBox(height: 12),
                  // Время начала и конца
                  Row(
                    children: [
                      Expanded(
                        child: TimePickerField(
                          label: 'Start',
                          value: _startTime,
                          onChanged: (t) => setState(() => _startTime = t),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TimePickerField(
                          label: 'End',
                          value: _endTime,
                          onChanged: (t) => setState(() => _endTime = t),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Напоминание
                  ReminderPicker(
                    value: _reminderMinutes,
                    onChanged: (v) => setState(() => _reminderMinutes = v),
                  ),
                ],
              ),
            ),
          ),
          // Кнопка внизу
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              child: Text(widget.submitLabel),
            ),
          ),
        ],
      ),
    );
  }
}
