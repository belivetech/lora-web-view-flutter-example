import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_in_app_pip/flutter_in_app_pip.dart';
import 'package:lora_web_view/main.dart';
import 'package:lora_web_view/widgets/my_pip_webview.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class WebViewScreenArguments {
  final String url;
  final String showId;

  WebViewScreenArguments(this.url, this.showId);
}

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({
    super.key,
    required this.url,
    required this.showId,
    this.isLoadFromAssets = false,
  });

  static const routeName = '/show';

  final String url;
  final String showId;
  final bool isLoadFromAssets;

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
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
                  break;
                case 'player.CLOSE':
                  debugPrint('Player CLOSED');
                  Navigator.pop(context);
                  break;
                case 'player.SHOW_PRODUCT_VIEW':
                  debugPrint('Player SHOW_PRODUCT_VIEW');
                  showBottomSheet('Product detail',
                      'Product detail view... ${message.message}');
                  break;
                case 'player.SHOW_SHARE_VIEW':
                  debugPrint('Player SHOW_SHARE_VIEW');
                  showBottomSheet(
                      'Share view', 'Content share view... ${message.message}');
                  break;
                case 'player.MINIMIZED':
                  debugPrint('Player is MINIMIZED');
                  activePip(context);
                  break;
                case 'player.UNMINIMIZED':
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      showCloseIcon: true,
                      content: Text('Player UNMINIMIZED'),
                    ),
                  );
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

  Future activePip(BuildContext context) async {
    PictureInPicture.updatePiPParams(
        pipParams: const PiPParams(
      pipWindowHeight: 250,
      pipWindowWidth: 150,
    ));
    PictureInPicture.startPiP(
      pipWidget: Builder(builder: (context) {
        return PiPWidget(
          onPiPClose: () {},
          child: MyPiPWebView(
            url: widget.url,
            showId: widget.showId,
            shouldCallMinimize: true,
            onExpanded: () {
              navigatorKey.currentState?.pushNamed(
                WebViewScreen.routeName,
                arguments: WebViewScreenArguments(
                  widget.url,
                  widget.showId,
                ),
              );
              // Navigator.of(context)
              //     .pushNamed('product_detail');
              PictureInPicture.stopPiP();
            },
          ),
        );
      }),
    );
    Navigator.pop(context);
  }

  void showBottomSheet(String title, String content) {
    final deviceHeight = MediaQuery.of(context).size.height * 0.7;
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: deviceHeight,
          padding: const EdgeInsets.all(20.0),
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
              TextButton(
                  onPressed: () async {
                    await activePip(context);
                    if (context.mounted) {
                      Navigator.of(context)
                          .pushReplacementNamed('product_detail');
                    }
                  },
                  child: const Text('Open Product detail')),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              WebViewWidget(
                controller: controller,
              ),
              Positioned(
                top: 8,
                left: 8,
                child: IconButton(
                  color: Colors.white,
                  icon: const Icon(
                    Icons.arrow_back,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
