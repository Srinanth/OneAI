import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SecureTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;

  const SecureTextField({
    super.key, 
    required this.controller, 
    required this.labelText
  });

  @override
  State<SecureTextField> createState() => _SecureTextFieldState();
}

class _SecureTextFieldState extends State<SecureTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscure,
      decoration: InputDecoration(
        labelText: widget.labelText,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off, size: 20),
              onPressed: () => setState(() => _obscure = !_obscure),
              tooltip: _obscure ? 'Show Key' : 'Hide Key',
            ),
            IconButton(
              icon: const Icon(Icons.copy, size: 18),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: widget.controller.text));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Key copied to clipboard"), duration: Duration(seconds: 1)),
                );
              },
              tooltip: 'Copy Key',
            ),
          ],
        ),
      ),
    );
  }
}