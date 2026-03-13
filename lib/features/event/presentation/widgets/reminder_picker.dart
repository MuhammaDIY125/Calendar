import 'package:flutter/material.dart';

/// Предустановленные варианты напоминания (в минутах).
/// null = без напоминания.
const _presets = [
  (null, 'No reminder'),
  (5, '5 minutes before'),
  (15, '15 minutes before'),
  (30, '30 minutes before'),
  (60, '1 hour before'),
  (1440, '1 day before'),
];

/// Дропдаун выбора напоминания с поддержкой произвольного значения.
class ReminderPicker extends StatefulWidget {
  final int? value;
  final ValueChanged<int?> onChanged;

  const ReminderPicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<ReminderPicker> createState() => _ReminderPickerState();
}

class _ReminderPickerState extends State<ReminderPicker> {
  static const _customKey = -1;
  late int? _selected;
  bool _isCustom = false;
  final _customController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final isPreset = _presets.any((p) => p.$1 == widget.value);
    _isCustom = widget.value != null && !isPreset;
    _selected = _isCustom ? _customKey : widget.value;
    if (_isCustom) {
      _customController.text = '${widget.value}';
    }
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<int?>(
          initialValue: _selected,
          decoration: const InputDecoration(),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          items: [
            ..._presets.map(
              (p) => DropdownMenuItem(
                value: p.$1,
                child: Text(p.$2),
              ),
            ),
            const DropdownMenuItem(
              value: _customKey,
              child: Text('Custom'),
            ),
          ],
          onChanged: (val) {
            setState(() {
              _selected = val;
              _isCustom = val == _customKey;
            });
            if (!_isCustom) widget.onChanged(val);
          },
        ),
        if (_isCustom) ...[
          const SizedBox(height: 8),
          TextField(
            controller: _customController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'Minutes before event',
            ),
            onChanged: (v) {
              final minutes = int.tryParse(v);
              widget.onChanged(minutes);
            },
          ),
        ],
      ],
    );
  }
}
