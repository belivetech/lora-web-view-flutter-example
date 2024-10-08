import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lora_web_view/main.dart';
import 'package:lora_web_view/screens/product_detail_screen.dart';
import 'package:lora_web_view/widgets/pip/pip_container.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

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
  final PipController pipController = PipController();
  late final WebViewController _controller;
  Widget? _bottomSheet;
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
    _controller.loadRequest(Uri.parse(
        'https://debug.ivsdemos.com/?url=https://fcc3ddae59ed.us-west-2.playback.live-video.net/api/video/v1/us-west-2.893648527354.channel.DmumNckWFTqz.m3u8&p=vjs&d=&l='));
    pipController.full();
  }

  void minimize() {
    //runJavaScript('window.player.minimize()');
    pipController.minimize();
  }

  void unminimize() {
    //runJavaScript('window.player.unminimize()');
    pipController.full();
  }

  void close() {
    _controller.loadRequest(Uri.parse("about:blank"));
    pipController.close();
  }

  Future<void> runJavaScript(String javascript) {
    return _controller.runJavaScript(javascript);
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
        NavigationDelegate(
          onPageFinished: (String _) {
            minimize();
          },
        ),
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
            case 'player.READY':
              debugPrint('player.READY');
              break;
            case 'player.SHOW_PRODUCT_VIEW':
              debugPrint(message.message);
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
              showBottomSheet('Share title',
                  'Share view Content share view... ${message.message}');
              break;
          }
        },
      );
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    _controller = controller;
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
                    Positioned(
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
                              //runJavaScript('window.player.unminimize()');
                              pipController.full();
                            },
                            icon: const Icon(
                              Icons.expand,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );

              default:
                return const SizedBox();
            }
          }),
    );
  }

  Widget _buildWebView(BuildContext context) {
    return SafeArea(
      child: WebViewWidget(
        controller: _controller,
      ),
    );
  }
}
