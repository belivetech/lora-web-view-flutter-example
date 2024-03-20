import 'package:flutter/material.dart';
import 'package:lora_web_view/webview_screen.dart';

class ShowInputScreen extends StatefulWidget {
  const ShowInputScreen({super.key});

  @override
  State<ShowInputScreen> createState() => _ShowInputScreenState();
}

class _ShowInputScreenState extends State<ShowInputScreen> {
  final TextEditingController _controller =
      TextEditingController(text: 'b5ed4b45-9d2f-4f92-aabd-992fb189c0ff');
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter show ID',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Show ID is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      String enteredText = _controller.text;
                      Navigator.pushNamed(
                        context,
                        WebViewScreen.routeName,
                        arguments: WebViewScreenArguments(
                          'https://sdk-docs.belive.technology/lora-webview-embed/index.html',
                          enteredText,
                        ),
                      );
                    }
                  },
                  child: const Text('Open Show'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
