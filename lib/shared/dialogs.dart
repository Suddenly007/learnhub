import 'package:flutter/material.dart';

Future<String?> promptText(BuildContext context, String title,
    {String label = ''}) {
  final c = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: c,
        autofocus: true,
        decoration: InputDecoration(labelText: label),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () => Navigator.pop(context, c.text.trim()),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
