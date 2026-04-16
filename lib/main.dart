import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vlucky_flutter/l10n/app_localizations.dart';
import 'constants/theme.dart';
import 'screens/splash_screen.dart';
import 'services/locale_controller.dart';
import 'services/ad_service.dart';
import 'services/storage_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:vlucky_flutter/services/push_notification_service.dart';
import 'package:vlucky_flutter/services/auth_service.dart';
import 'package:vlucky_flutter/services/revenuecat_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://zzheonrmioxbiinvomsw.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp6aGVvbnJtaW94YmlpbnZvbXN3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQyMzI3MTAsImV4cCI6MjA4OTgwODcxMH0.ur8u0vCa9x-nRKdKhS_xL6c56jpmXjU9FXa2CCHnaWU',
  );

  // Kullanıcı Oturum İşlemleri (Bulut Veritabanı için Gizli ID Alımı)
  await AuthService().signInAnonymously();

  // Elite (Premium) Abonelik Kasası Başlatıcısı
  await RevenueCatService().initialize();

  // Firebase ve Bildirim Başlatıcısı
  try {
    await Firebase.initializeApp();
    await PushNotificationService().initialize();
  } catch(e) {
    debugPrint("Firebase başlatılamadı: $e");
  }

  if (kDebugMode) {
    await StorageService.forceResetDailyLimits(); // Geliştirici modu: Limitsiz test edebilmek için R ile sıfırla
  }
  
  await MobileAds.instance.initialize();
  // Uygulama açılır açılmaz ilk reklamı arka planda yükle (kullanıcı beklemesim):
  AdService().loadRewardedAd();
  await LiquidGlassWidgets.initialize();
  final localeController = LocaleController();
  await localeController.load();
  // Günlük giriş kaydı — takvimde ateş ikonu için
  StorageService.recordAppOpenToday();
  
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
