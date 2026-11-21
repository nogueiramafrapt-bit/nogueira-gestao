import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NogueiraGestaoApp());
}

class NogueiraGestaoApp extends StatelessWidget {
  const NogueiraGestaoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nogueira Gestão',
      debugShowCheckedModeBanner: false,
      locale: const Locale('pt', 'PT'),
      supportedLocales: const [Locale('pt', 'PT')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFAD1457)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFFF8FA),
      ),
      home: const NogueiraHomePage(),
    );
  }
}
