import 'package:flutter/material.dart';
import 'package:lora_web_view/settings.dart';
import 'package:lora_web_view/widgets/pip_container.dart';
import 'package:lora_web_view/widgets/pip_wrapper.dart';

class PipApp extends StatefulWidget {
  const PipApp({
    Key? key,
    this.navigatorKey,
    this.scaffoldMessengerKey,
    this.home,
    Map<String, WidgetBuilder> this.routes = const <String, WidgetBuilder>{},
    this.initialRoute,
    this.onGenerateRoute,
    this.onGenerateInitialRoutes,
    this.onUnknownRoute,
    List<NavigatorObserver> this.navigatorObservers =
        const <NavigatorObserver>[],
    this.builder,
    this.title = '',
    this.onGenerateTitle,
    this.color,
    this.theme,
    this.darkTheme,
    this.highContrastTheme,
    this.highContrastDarkTheme,
    this.themeMode = ThemeMode.system,
    this.themeAnimationDuration = kThemeAnimationDuration,
    this.themeAnimationCurve = Curves.linear,
    this.locale,
    this.localizationsDelegates,
    this.localeListResolutionCallback,
    this.localeResolutionCallback,
    this.supportedLocales = const <Locale>[Locale('en', 'US')],
    this.debugShowMaterialGrid = false,
    this.showPerformanceOverlay = false,
    this.checkerboardRasterCacheImages = false,
    this.checkerboardOffscreenLayers = false,
    this.showSemanticsDebugger = false,
    this.debugShowCheckedModeBanner = true,
    this.shortcuts,
    this.actions,
    this.restorationScopeId,
    this.scrollBehavior,
    @Deprecated(
      'Remove this parameter as it is now ignored. '
      'MaterialApp never introduces its own MediaQuery; the View widget takes care of that. '
      'This feature was deprecated after v3.7.0-29.0.pre.',
    )
    this.useInheritedMediaQuery = false,
    this.onNavigationNotification,
    this.themeAnimationStyle,
  })  : routeInformationProvider = null,
        routeInformationParser = null,
        routerDelegate = null,
        backButtonDispatcher = null,
        routerConfig = null,
        super();

  // from MaterialApp
  final Map<String, WidgetBuilder>? routes;
  final String? initialRoute;
  final RouteFactory? onGenerateRoute;

  /// {@macro flutter.widgets.widgetsApp.navigatorKey}
  final GlobalKey<NavigatorState>? navigatorKey;

  /// A key to use when building the [ScaffoldMessenger].
  ///
  /// If a [scaffoldMessengerKey] is specified, the [ScaffoldMessenger] can be
  /// directly manipulated without first obtaining it from a [BuildContext] via
  /// [ScaffoldMessenger.of]: from the [scaffoldMessengerKey], use the
  /// [GlobalKey.currentState] getter.
  final GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;

  /// {@macro flutter.widgets.widgetsApp.home}
  final Widget? home;

  /// The application's top-level routing table.
  ///
  /// When a named route is pushed with [Navigator.pushNamed], the route name is
  /// looked up in this map. If the name is present, the associated
  /// [widgets.WidgetBuilder] is used to construct a [MaterialPageRoute] that
  /// performs an appropriate transition, including [Hero] animations, to the
  /// new route.
  ///
  /// {@macro flutter.widgets.widgetsApp.routes}

  /// {@macro flutter.widgets.widgetsApp.onGenerateInitialRoutes}
  final InitialRouteListFactory? onGenerateInitialRoutes;

  /// {@macro flutter.widgets.widgetsApp.onUnknownRoute}
  final RouteFactory? onUnknownRoute;

  /// {@macro flutter.widgets.widgetsApp.onNavigationNotification}
  final NotificationListenerCallback<NavigationNotification>?
      onNavigationNotification;

  /// {@macro flutter.widgets.widgetsApp.navigatorObservers}
  final List<NavigatorObserver>? navigatorObservers;

  /// {@macro flutter.widgets.widgetsApp.routeInformationProvider}
  final RouteInformationProvider? routeInformationProvider;

  /// {@macro flutter.widgets.widgetsApp.routeInformationParser}
  final RouteInformationParser<Object>? routeInformationParser;

  /// {@macro flutter.widgets.widgetsApp.routerDelegate}
  final RouterDelegate<Object>? routerDelegate;

  final BackButtonDispatcher? backButtonDispatcher;

  final RouterConfig<Object>? routerConfig;

  final TransitionBuilder? builder;

  final String title;

  final GenerateAppTitle? onGenerateTitle;

  final ThemeData? theme;

  final ThemeData? darkTheme;

  final ThemeData? highContrastTheme;

  final ThemeData? highContrastDarkTheme;

  final ThemeMode? themeMode;

  final Duration themeAnimationDuration;

  final Curve themeAnimationCurve;

  final Color? color;

  final Locale? locale;

  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;

  final LocaleListResolutionCallback? localeListResolutionCallback;

  final LocaleResolutionCallback? localeResolutionCallback;

  final Iterable<Locale> supportedLocales;

  final bool showPerformanceOverlay;

  final bool checkerboardRasterCacheImages;

  final bool checkerboardOffscreenLayers;

  final bool showSemanticsDebugger;

  final bool debugShowCheckedModeBanner;

  final Map<ShortcutActivator, Intent>? shortcuts;

  final Map<Type, Action<Intent>>? actions;

  final String? restorationScopeId;

  final ScrollBehavior? scrollBehavior;

  final bool debugShowMaterialGrid;

  final bool useInheritedMediaQuery;
  final AnimationStyle? themeAnimationStyle;

  @override
  State<PipApp> createState() => _PipAppState();
}

class _PipAppState extends State<PipApp> {
  final PipController pipController = PipController();
  Widget? pip;
  String url = "";
  String showId = "";
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
    return MaterialApp(
      actions: widget.actions,
      initialRoute: widget.initialRoute,
      routes: widget.routes ?? const <String, WidgetBuilder>{},
      onGenerateRoute: widget.onGenerateRoute,
      checkerboardOffscreenLayers: widget.checkerboardOffscreenLayers,
      checkerboardRasterCacheImages: widget.checkerboardRasterCacheImages,
      color: widget.color,
      darkTheme: widget.darkTheme,
      debugShowCheckedModeBanner: widget.debugShowCheckedModeBanner,
      debugShowMaterialGrid: widget.debugShowMaterialGrid,
      highContrastDarkTheme: widget.highContrastDarkTheme,
      highContrastTheme: widget.highContrastTheme,
      home: widget.home,
      themeAnimationCurve: widget.themeAnimationCurve,
      themeAnimationDuration: widget.themeAnimationDuration,
      locale: widget.locale,
      localeListResolutionCallback: widget.localeListResolutionCallback,
      localeResolutionCallback: widget.localeResolutionCallback,
      localizationsDelegates: widget.localizationsDelegates,
      navigatorKey: widget.navigatorKey,
      navigatorObservers:
          widget.navigatorObservers ?? const <NavigatorObserver>[],
      onGenerateInitialRoutes: widget.onGenerateInitialRoutes,
      onGenerateTitle: widget.onGenerateTitle,
      onUnknownRoute: widget.onUnknownRoute,
      restorationScopeId: widget.restorationScopeId,
      scaffoldMessengerKey: widget.scaffoldMessengerKey,
      scrollBehavior: widget.scrollBehavior,
      shortcuts: widget.shortcuts,
      showPerformanceOverlay: widget.showPerformanceOverlay,
      showSemanticsDebugger: widget.showSemanticsDebugger,
      supportedLocales: widget.supportedLocales,
      theme: widget.theme,
      themeMode: widget.themeMode,
      title: widget.title,
      onNavigationNotification: widget.onNavigationNotification,
      themeAnimationStyle: widget.themeAnimationStyle,
      builder: (context, child) {
        return Scaffold(
          body: PipWrapper(
            child: child,
          ),
        );
      },
    );
  }
}
