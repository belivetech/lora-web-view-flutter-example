import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lora_web_view/main.dart';
import 'package:lora_web_view/screens/product_detail_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import 'pip_container.dart';

class MyPipUrlApp extends StatefulWidget {
  const MyPipUrlApp({super.key, required this.child});
  final Widget? child;
  @override
  State<MyPipUrlApp> createState() => _MyPipUrlAppState();

  static void openPlayer(BuildContext context, String url, String showId) {
    context
        .findAncestorStateOfType<_MyPipUrlAppState>()
        ?.openPlayer(url, showId);
  }

  static void minize(BuildContext context) {
    context.findAncestorStateOfType<_MyPipUrlAppState>()?.minimize();
  }

  static void unminize(BuildContext context) {
    context.findAncestorStateOfType<_MyPipUrlAppState>()?.unminimize();
  }
}

class _MyPipUrlAppState extends State<MyPipUrlApp> {
  final PipController pipController = PipController();
  late final WebViewController _controller;
  String _url = "";
  String _showId = "";
  @override
  void initState() {
    super.initState();
    initWebController();
  }

  @override
  void dispose() {
    pipController.dispose();
    close();
    super.dispose();
  }

  void openPlayer(String url, String showId) {
    _url = url;
    _showId = showId;
    _controller.loadRequest(Uri.parse(_url));
    pipController.full();
    //  runJavaScript('window.player.minimize()');
  }

  void minimize() {
    runJavaScript('window.player.minimize()');
    pipController.minimize();
  }

  void unminimize() {
    runJavaScript('window.player.unminimize()');
    pipController.full();
  }

  void close() {
    _controller.loadRequest(Uri.parse("about:blank"));
    pipController.close();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: pipController.isPipShowing,
      child: Scaffold(
        body: PipContainer(
            content: widget.child ?? const SizedBox(),
            controller: pipController,
            pipStateBuilder: (_, state) {
              switch (state) {
                case PipState.full:
                  return _buildWebView(context);
                case PipState.minimize:
                  return Stack(
                    children: [
                      _buildWebView(context),
                      Positioned(
                        right: 0,
                        top: 16,
                        child: IconButton(
                          onPressed: () {
                            runJavaScript('window.player.unminimize()');
                            pipController.full();
                          },
                          icon: const Icon(
                            Icons.expand,
                          ),
                        ),
                      ),
                    ],
                  );

                default:
                  return const SizedBox();
              }
            }),
      ),
    );
  }

  void initWebController() {
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
        WebViewController.fromPlatformCreationParams(params);
    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(),
      )
      ..addJavaScriptChannel(
        'LoraChannel',
        onMessageReceived: (JavaScriptMessage message) async {
          Map<String, dynamic> jsonMap = json.decode(message.message);
          final payload = jsonMap.containsKey('payload')
              ? jsonMap['payload'] as Map<String, dynamic>
              : null;

          switch (jsonMap['eventName'] as String) {
            case 'player.INITIALIZE':
              runJavaScript('window.player.open("$_showId")');
              break;
            case 'player.SHOW_PRODUCT_VIEW':
              debugPrint(message.message);
              minimize();
              // await Future.delayed(const Duration(milliseconds: 200));
              navigatorKey.currentState?.push(
                MaterialPageRoute(
                    builder: (_) =>
                        ProductDetailScreen(sku: 'sku', title: 'title')),
              );

              break;
            case 'player.MINIMIZED':
              minimize();
              break;
            case 'player.CLOSE':
              close();
              break;
          }
        },
      );
    _controller = controller;
  }

  Widget _buildWebView(BuildContext context) {
    return SafeArea(child: WebViewWidget(controller: _controller));
  }

  Future<void> runJavaScript(String javascript) {
    return _controller.runJavaScript(javascript);
  }
}
