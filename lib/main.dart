import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lora_web_view/screens/product_detail_screen.dart';
import 'package:lora_web_view/screens/show_input_screen.dart';
import 'package:lora_web_view/screens/webview_screen.dart';

import 'widgets/pip/pip_app.dart';

Future main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MainApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const ShowInputScreen(),
      },
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
      ],
      builder: (context, child) {
        return MyPipUrlApp(
          child: child,
        );
      },
      navigatorKey: navigatorKey,
      onGenerateRoute: (settings) {
        if (settings.name == WebViewScreen.routeName) {
          final args = settings.arguments as WebViewScreenArguments;
          return MaterialPageRoute(
            builder: (context) {
              return RepaintBoundary(
                key: const ValueKey('webview'),
                child: WebViewScreen(
                  url: args.url,
                  showId: args.showId,
                ),
              );
            },
          );
        } else if (settings.name == ProductDetailScreen.routeName) {
          final args = settings.arguments as ProductDetailScreenArguments;
          return MaterialPageRoute(
            builder: (context) {
              return ProductDetailScreen(
                sku: args.sku,
                title: args.title,
                description: args.description,
              );
            },
          );
        }
        assert(false, 'Need to implement ${settings.name}');
        return null;
      },
    );
  }
}
