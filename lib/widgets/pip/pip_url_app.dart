import 'package:flutter/material.dart';
import 'package:lora_web_view/widgets/pip/pip_url_wrapper.dart';

class MyPipUrlApp extends StatefulWidget {
  const MyPipUrlApp({
    super.key,
    required this.initialRoute,
    this.routes,
    this.builder,
    this.localizationsDelegates,
    this.navigatorKey,
    this.onGenerateRoute,
  });
  final String initialRoute;
  final Map<String, WidgetBuilder>? routes;
  final TransitionBuilder? builder;
  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;
  final GlobalKey<NavigatorState>? navigatorKey;
  final RouteFactory? onGenerateRoute;
  @override
  State<MyPipUrlApp> createState() => _MyPipUrlAppState();
}

class _MyPipUrlAppState extends State<MyPipUrlApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: widget.initialRoute,
      routes: widget.routes ?? const <String, WidgetBuilder>{},
      navigatorKey: widget.navigatorKey,
      localizationsDelegates: widget.localizationsDelegates,
      onGenerateRoute: widget.onGenerateRoute,
      builder: (context, child) {
        return PipUrlWrapper(
          child:
              widget.builder != null ? widget.builder!(context, child) : child,
        );
      },
    );
  }
}
