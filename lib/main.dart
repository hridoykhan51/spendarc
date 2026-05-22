import 'package:flutter/material.dart';
import 'package:finance_app/core/constants/app_strings.dart';
import 'package:finance_app/core/theme/app_theme.dart';
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
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SpendArcPage(),
    );
  }
}
