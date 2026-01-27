import 'package:flutter/material.dart';

class RenameDialog extends StatefulWidget {
  final String currentTitle;
  const RenameDialog({super.key, required this.currentTitle});

  @override
  State<RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<RenameDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentTitle);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rename Conversation'),
      content: TextField(controller: _controller, autofocus: true, decoration: const InputDecoration(hintText: 'New Title')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(context, _controller.text), child: const Text('Rename')),
      ],
    );
  }
}