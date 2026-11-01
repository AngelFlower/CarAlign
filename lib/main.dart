import 'package:flutter/material.dart';

import 'app/app.dart';
import 'i18n/strings.g.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocaleSettings.useDeviceLocale();
  runApp(TranslationProvider(child: const CarAlignApp()));
}
