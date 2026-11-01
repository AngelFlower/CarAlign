import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../i18n/strings.g.dart';
import '../presentation/pages/home/home_page.dart';
import 'app_scope.dart';
import 'theme.dart';

class CarAlignApp extends StatefulWidget {
  const CarAlignApp({super.key});

  @override
  State<CarAlignApp> createState() => _CarAlignAppState();
}

class _CarAlignAppState extends State<CarAlignApp> {
  final _messenger = GlobalKey<ScaffoldMessengerState>();
  late final AppDependencies _dependencies = AppDependencies(onMessage: _showMessage);

  void _showMessage(String message) {
    _messenger.currentState?.showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 12), showCloseIcon: true),
    );
  }

  @override
  void dispose() {
    _dependencies.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      dependencies: _dependencies,
      child: MaterialApp(
        scaffoldMessengerKey: _messenger,
        title: t.appName,
        locale: TranslationProvider.of(context).flutterLocale,
        supportedLocales: AppLocaleUtils.supportedLocales,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        themeMode: ThemeMode.system,
        theme: buildTheme(Brightness.light),
        darkTheme: buildTheme(Brightness.dark),
        home: const HomePage(),
      ),
    );
  }
}
