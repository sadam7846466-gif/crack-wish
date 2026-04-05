import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vlucky_flutter/l10n/app_localizations.dart';
import 'constants/theme.dart';
import 'screens/splash_screen.dart';
import 'services/locale_controller.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://zzheonrmioxbiinvomsw.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp6aGVvbnJtaW94YmlpbnZvbXN3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQyMzI3MTAsImV4cCI6MjA4OTgwODcxMH0.ur8u0vCa9x-nRKdKhS_xL6c56jpmXjU9FXa2CCHnaWU',
  );
  await LiquidGlassWidgets.initialize();
  final localeController = LocaleController();
  await localeController.load();
  // Günlük giriş kaydı — takvimde ateş ikonu için
  StorageService.recordAppOpenToday();
  
  // ── TEST: Eski günlere henüz toplanmamış yeni ateşler koyalım ──
  final now = DateTime.now();
  for (int i = 5; i <= 9; i++) { // 5 ile 9 gün öncesi
    final d = now.subtract(Duration(days: i));
    final key = "${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
    final prefs = await SharedPreferences.getInstance();
    final days = prefs.getStringList('app_open_days') ?? [];
    if (!days.contains(key)) {
      days.add(key);
      await prefs.setStringList('app_open_days', days);
    }
  }
  // ── TEST SONU ──
  
  runApp(MyApp(localeController: localeController));
}

class MyApp extends StatelessWidget {
  final LocaleController localeController;

  const MyApp({super.key, required this.localeController});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: localeController,
      child: Consumer<LocaleController>(
        builder: (context, controller, _) {
          return MaterialApp(
            onGenerateTitle: (context) =>
                AppLocalizations.of(context)!.appTitle,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            home: const SplashScreen(),
            locale: controller.locale,
            supportedLocales: LocaleController.supportedLocales,
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
          );
        },
      ),
    );
  }
}
