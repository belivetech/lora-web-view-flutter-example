import 'package:flutter/material.dart';
import 'package:flutter_in_app_pip/flutter_in_app_pip.dart';
import 'package:lora_web_view/screens/webview_screen.dart';

class MyPiPWebView extends StatefulWidget {
  final String url;
  final String showId;
  final VoidCallback onExpanded;

  const MyPiPWebView({
    super.key,
    required this.url,
    required this.showId,
    required this.onExpanded,
  });

  @override
  State<MyPiPWebView> createState() => _MyWebViewState();
}

class _MyWebViewState extends State<MyPiPWebView> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          WebViewScreen(
            url: widget.url,
            showId: widget.showId,
            isMinimized: true,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  PictureInPicture.stopPiP();
                },
                icon: const Icon(Icons.close),
              ),
              Builder(builder: (context) {
                return IconButton(
                  onPressed: () async {
                    widget.onExpanded();
                  },
                  icon: const Icon(Icons.expand),
                );
              })
            ],
          ),
        ],
      ),
    );
  }
}
