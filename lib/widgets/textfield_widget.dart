import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TextfieldWidget extends ConsumerStatefulWidget {
  final int maxLines;
  final String label;
  final String text;
  final int? changeNumber;
  final ValueChanged<String> onChanged;
  const TextfieldWidget(
      {this.maxLines = 1,
      required this.label,
      required this.text,
      this.changeNumber,
      required this.onChanged,
      super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TextfieldWidgetState();
}

class _TextfieldWidgetState extends ConsumerState<TextfieldWidget> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();

    controller = TextEditingController(text: widget.text);
    controller.addListener(() {
      widget.onChanged(controller.text);
    });
  }

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            keyboardType: widget.label == 'Numer telefonu'
                ? TextInputType.phone
                : TextInputType.text,
            inputFormatters: widget.label == 'Numer telefonu'
                ? [FilteringTextInputFormatter.digitsOnly]
                : [],
            maxLines: widget.maxLines,
          ),
        ],
      );
}
