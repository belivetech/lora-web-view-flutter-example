import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_in_app_pip/flutter_in_app_pip.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class MyPiPWebView extends StatefulWidget {
  final String url;
  final String showId;
  const MyPiPWebView({
    super.key,
    required this.url,
    required this.showId,
    this.shouldCallMinimize = false,
    required this.onExpanded,
  });
  final bool shouldCallMinimize;
  final VoidCallback onExpanded;
  @override
  State<MyPiPWebView> createState() => _MyWebViewState();
}

class _MyWebViewState extends State<MyPiPWebView> {
  late final WebViewController controller;
  @override
  void initState() {
    super.initState();
    controller = createWebViewController();
    controller.loadRequest(Uri.parse(widget.url));
  }

  @override
  void dispose() {
    controller.loadRequest(Uri.parse('about:blank'));
    super.dispose();
  }

  WebViewController createWebViewController() {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }
    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params)
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..addJavaScriptChannel(
            'LoraChannel',
            onMessageReceived: (JavaScriptMessage message) {
              Map<String, dynamic> jsonMap = json.decode(message.message);
              if (!jsonMap.containsKey('eventName')) return;
              switch (jsonMap['eventName'] as String) {
                case 'player.INITIALIZE':
                  runJavaScript('window.player.open("${widget.showId}")');

                  break;
                case 'player.READY':
                  debugPrint('Player is ready');
                  if (widget.shouldCallMinimize) {
                    runJavaScript('window.player.minimize()');
                  }
                  break;
                case 'player.CLOSE':
                  debugPrint('Player CLOSED');
                  Navigator.pop(context);
                  break;
                case 'player.SHOW_PRODUCT_VIEW':
                  debugPrint('Player SHOW_PRODUCT_VIEW');
                  break;
                case 'player.SHOW_SHARE_VIEW':
                  debugPrint('Player SHOW_SHARE_VIEW');
                  showBottomSheet(context, 'Share view',
                      'Content share view... ${message.message}');

                  break;
                case 'player.MINIMIZED':
                  debugPrint('Player is MINIMIZED');
                  // runJavaScript('window.player.minimize()');

                  break;
                case 'player.UNMINIMIZED':
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   const SnackBar(
                  //     showCloseIcon: true,
                  //     content: Text('Player UNMINIMIZED'),
                  //   ),
                  // );
                  break;
              }
            },
          );

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    return controller;
  }

  Future<void> runJavaScript(String javascript) {
    return controller.runJavaScript(javascript);
  }

  @override
  Widget build(BuildContext context) {
    bool shouldShowAction = widget.shouldCallMinimize;
    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          WebViewWidget(
            key: const ValueKey('webview'),
            controller: controller,
          ),
          if (shouldShowAction)
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

  void showBottomSheet(BuildContext context, title, String content) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        final deviceHeight = MediaQuery.of(context).size.height * 0.7;
        return Material(
          child: SizedBox(
            height: deviceHeight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // To make the modal compact
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      title,
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
                Text(content),
              ],
            ),
          ),
        );
      },
    );
  }
}
