import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:lora_web_view/main.dart';
import 'package:lora_web_view/screens/product_detail_screen.dart';
import 'package:lora_web_view/widgets/pip/pip_container.dart';

class PipUrlWrapper extends StatefulWidget {
  const PipUrlWrapper({super.key, this.child});
  final Widget? child;
  @override
  State<PipUrlWrapper> createState() => _PipUrlWrapperState();

  static void openPlayer(BuildContext context, String url, String showId) {
    context
        .findAncestorStateOfType<_PipUrlWrapperState>()
        ?.openPlayer(url, showId);
  }

  static void minize(BuildContext context) {
    context.findAncestorStateOfType<_PipUrlWrapperState>()?.minimize();
  }

  static void unminize(BuildContext context) {
    context.findAncestorStateOfType<_PipUrlWrapperState>()?.unminimize();
  }
}

class _PipUrlWrapperState extends State<PipUrlWrapper> {
  final GlobalKey webViewKey = GlobalKey();
  final PipController pipController = PipController();
  final InAppWebViewSettings settings = InAppWebViewSettings(
    isInspectable: true,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    iframeAllow: "camera; microphone",
    iframeAllowFullscreen: true,
    allowBackgroundAudioPlaying: false,
  );

  Widget? _bottomSheet;
  String _url = "about:blank";
  String _showId = "";
  InAppWebViewController? _controller;
  bool _isPlayerReady = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    pipController.dispose();
    close();
    super.dispose();
  }

  void openPlayer(String url, String showId) async {
    if (_isPlayerReady && showId != _showId) {
      runJavaScript('window.player.unminimize()');
      runJavaScript('window.player.open("$showId")');
    }
    setState(() {
      _url = url;
      _showId = showId;
    });
    pipController.full();
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
    pipController.close();
  }

  void runJavaScript(String javascript) {
    _controller?.evaluateJavascript(source: javascript);
  }

  void initWebController(InAppWebViewController controller) {
    _controller = controller;
    _controller?.addJavaScriptHandler(
      handlerName: 'LoraChannel',
      callback: (args) {
        final message = args[0] as String;
        Map<String, dynamic> jsonMap = json.decode(message);
        final payload = jsonMap.containsKey('payload')
            ? jsonMap['payload'] as Map<String, dynamic>
            : null;

        switch (jsonMap['eventName'] as String) {
          case 'player.INITIALIZE':
            _isPlayerReady = true;
            runJavaScript('window.player.open("$_showId")');
            break;
          case 'player.READY':
            debugPrint('player.READY');
            break;
          case 'player.SHOW_PRODUCT_VIEW':
            debugPrint(message);
            minimize();
            navigatorKey.currentState?.pushNamed(
              ProductDetailScreen.routeName,
              arguments: ProductDetailScreenArguments(
                sku: payload?['sku'] ?? "null",
                title: payload?['name'] as String,
                description: json.encode(payload),
              ),
            );
            break;
          case 'player.MINIMIZED':
            minimize();
            break;
          case 'player.CLOSE':
            close();
            break;
          case 'player.SHOW_SHARE_VIEW':
            showBottomSheet(
                'Share title', 'Share view Content share view... $message');
            break;
        }
      },
    );
  }

  void showMessage(message) {
    BuildContext context = navigatorKey.currentContext!;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void showBottomSheet(title, String content) {
    BuildContext context = navigatorKey.currentContext!;
    final deviceHeight = MediaQuery.of(context).size.height * 0.7;
    _bottomSheet = Container(
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
                  _bottomSheet = null;
                  setState(() {});
                },
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          Text(content),
        ],
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: _bottomSheet,
      body: PipContainer(
          content: widget.child,
          controller: pipController,
          pipStateBuilder: (_, state) {
            switch (state) {
              case PipState.full:
                return _buildWebView(context);
              case PipState.minimize:
                return Stack(
                  children: [
                    _buildWebView(context),
                    _buildPipActions(context),
                  ],
                );

              default:
                return const SizedBox();
            }
          }),
    );
  }

  Widget _buildPipActions(BuildContext context) {
    return Positioned(
      right: 0,
      top: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              close();
            },
            icon: const Icon(
              Icons.close,
            ),
          ),
          IconButton(
            onPressed: () {
              runJavaScript('window.player.unminimize()');
              pipController.full();
            },
            icon: const Icon(
              Icons.expand,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebView(BuildContext context) {
    return SafeArea(
      child: InAppWebView(
        key: webViewKey,
        initialUrlRequest: URLRequest(url: WebUri(_url)),
        initialSettings: settings,
        onWebViewCreated: (controller) {
          initWebController(controller);
        },
        onEnterFullscreen: (controller) {
          controller.clearFocus();
        },
        onExitFullscreen: (controller) {
          controller.clearFocus();
        },
        onLoadStart: (controller, url) {
          debugPrint('onLoadStart: $url');
        },
        onPermissionRequest: (controller, request) async {
          return PermissionResponse(
            resources: request.resources,
            action: PermissionResponseAction.GRANT,
          );
        },
        onReceivedError: (controller, request, error) {
          debugPrint('onReceivedError: $error');
        },
        onConsoleMessage: (controller, consoleMessage) {
          debugPrint(consoleMessage.message);
        },
      ),
    );
  }
}
