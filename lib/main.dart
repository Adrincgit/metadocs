import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:metadocs/helpers/scroll_behavior.dart';
import 'package:metadocs/internationalization/internationalization.dart';
import 'package:metadocs/router/router.dart';
import 'package:metadocs/theme/theme.dart';
import 'package:provider/provider.dart';

import 'package:metadocs/providers/providers.dart';
import 'package:metadocs/helpers/globals.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setPathUrlStrategy();

  // Initialize globals (SharedPreferences)
  await initGlobals();
  AppTheme.initPrefs(prefs);

  GoRouter.optionURLReflectsImperativeAPIs = true;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VisualStateProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  final Locale _locale = const Locale('es');

  @override
  Widget build(BuildContext context) {
    // El themeMode se maneja desde VisualStateProvider para que el toggle
    // del header actualice MaterialApp reactivamente.
    final themeMode = context.select<VisualStateProvider, ThemeMode>(
      (p) => p.themeMode,
    );
    return Portal(
      child: MaterialApp.router(
        title: 'MetaDocs — AI Document Intelligence Demo',
        debugShowCheckedModeBanner: false,
        locale: _locale,
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('es'), Locale('en', 'US')],
        theme: AppTheme.materialLight(),
        darkTheme: AppTheme.materialDark(),
        themeMode: themeMode,
        routerConfig: router,
        scrollBehavior: MyCustomScrollBehavior(),
      ),
    );
  }
}
