import 'package:flutter/material.dart';

class HouseFormResult {
  final String location;
  HouseFormResult(this.location);
}

Future<HouseFormResult?> showHouseFormDialog(BuildContext context, {String? initialLocation}) {
  final controller = TextEditingController(text: initialLocation ?? '');
  return showDialog<HouseFormResult>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(initialLocation == null ? 'Add house' : 'Edit house'),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Location'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (controller.text.trim().isEmpty) return;
            Navigator.pop(ctx, HouseFormResult(controller.text.trim()));
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}
