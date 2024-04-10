import 'package:flutter/material.dart';
import 'package:lora_web_view/show_input_screen.dart';
import 'package:lora_web_view/webview_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const ShowInputScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == WebViewScreen.routeName) {
          final args = settings.arguments as WebViewScreenArguments;

          return MaterialPageRoute(
            builder: (context) {
              return WebViewScreen(
                url: args.url,
                showId: args.showId,
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
