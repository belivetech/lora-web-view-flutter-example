import 'package:flutter/material.dart';
import 'package:lora_web_view/settings.dart';
import 'package:lora_web_view/widgets/pip_container.dart';

import 'my_webview.dart';

class PipWrapper extends StatefulWidget {
  const PipWrapper({super.key, required this.child});
  final Widget? child;
  @override
  State<PipWrapper> createState() => _PipWrapperState();
  static void showUrl(BuildContext context, showId) {
    final _PipWrapperState? state =
        context.findAncestorStateOfType<_PipWrapperState>();
    state?.openWebView(webViewUrl, showId);
  }

  static void minimize(BuildContext context) {
    final _PipWrapperState? state =
        context.findAncestorStateOfType<_PipWrapperState>();
    state?.minimize();
  }

  static void unminimize(BuildContext context) {
    final _PipWrapperState? state =
        context.findAncestorStateOfType<_PipWrapperState>();
    state?.unminimize();
  }

  static void clearPip(BuildContext context) {
    final _PipWrapperState? state =
        context.findAncestorStateOfType<_PipWrapperState>();
    state?.clearPip();
  }
}

class _PipWrapperState extends State<PipWrapper> {
  final PipController pipController = PipController();
  String url = "";
  String showId = "";

  void clearPip() {
    pipController.close();
  }

  void openWebView(String url, String showId) {
    this.url = url;
    this.showId = showId;
    pipController.full();
  }

  void minimize() {
    pipController.minimize();
  }

  void unminimize() {
    pipController.full();
  }

  @override
  void initState() {
    super.initState();
    url = webViewUrl;
    showId = defaultShowId;
  }

  @override
  void dispose() {
    pipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PipContainer(
          content: widget.child ?? const SizedBox(),
          controller: pipController,
          pipStateBuilder: (_, state) {
            switch (state) {
              case PipState.full:
                return _buildWebView(context);
              case PipState.minimize:
                return _buildWebView(context, shouldCallMinimize: true);

              default:
                return const SizedBox();
            }
          }),
    );
  }

  Widget _buildWebView(
    BuildContext context, {
    bool shouldCallMinimize = false,
  }) {
    return SizedBox.expand(
      child: GestureDetector(
        onTap: () {
          pipController.full();
        },
        child: SafeArea(
            child: MyWebView(
          url: url,
          showId: showId,
          shouldCallMinimize: shouldCallMinimize,
          callback: (String action, String message) async {
            debugPrint('action $action - $message');
            await Future.delayed(const Duration(milliseconds: 100));
            // if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
            // showBottomSheet(
            //     context: context,
            //     builder: (_) {
            //       return Column(
            //         children: [
            //           Text(message),
            //         ],
            //       );
            //     });
            // showBottomSheet1(context, action, message);

            // }
          },
        )),
      ),
    );
  }

  void showBottomSheet1(BuildContext context, String title, String content) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        final deviceHeight = MediaQuery.of(context).size.height * 0.7;
        return SizedBox(
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
                ],
              ),
              const SizedBox(height: 10.0),
              Text(content),
            ],
          ),
        );
      },
    );
  }
}
