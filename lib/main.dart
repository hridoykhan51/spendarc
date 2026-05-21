import 'package:flutter/material.dart';
import 'package:finance_app/features/transactions/presentation/pages/spend_arc_page.dart';
import 'package:finance_app/injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const SpendArcApp());
}

class SpendArcApp extends StatelessWidget {
  const SpendArcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpendArc',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff2563eb),
          secondary: const Color(0xff14b8a6),
          tertiary: const Color(0xfff59e0b),
        ),
        scaffoldBackgroundColor: const Color(0xfffbfbf8),
        useMaterial3: true,
      ),
      home: const SpendArcPage(),
    );
  }
}
