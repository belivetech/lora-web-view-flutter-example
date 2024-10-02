import 'package:flutter/material.dart';
import 'package:lora_web_view/product_detail_screen.dart';
import 'package:lora_web_view/settings.dart' as settings;
import 'package:lora_web_view/webview_screen.dart';

class ShowInputScreen extends StatefulWidget {
  const ShowInputScreen({super.key});

  @override
  State<ShowInputScreen> createState() => _ShowInputScreenState();
}

class _ShowInputScreenState extends State<ShowInputScreen> {
  final TextEditingController _controller =
      TextEditingController(text: settings.defaultShowId);
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
                      // PipWrapper.showUrl(context, enteredText);
                      Navigator.pushNamed(
                        context,
                        WebViewScreen.routeName,
                        arguments: WebViewScreenArguments(
                          settings.webViewUrl,
                          enteredText,
                        ),
                      );
                    }
                  },
                  child: const Text('Open Show'),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const ProductDetailScreen()));
                },
                child: const Text('Open Product'),
              ),
              ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      final deviceHeight =
                          MediaQuery.of(context).size.height * 0.7;
                      return SizedBox(
                        height: deviceHeight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize:
                              MainAxisSize.min, // To make the modal compact
                          children: <Widget>[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'title',
                                  style: const TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 10.0),
                            Text('content'),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: const Text('Show bottom sheet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
