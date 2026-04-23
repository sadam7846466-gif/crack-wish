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
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:vlucky_flutter/services/push_notification_service.dart';
import 'package:vlucky_flutter/services/auth_service.dart';
import 'package:vlucky_flutter/services/purchase_service.dart';
import 'package:vlucky_flutter/services/analytics_service.dart';
import 'package:vlucky_flutter/services/cosmic_engine_service.dart';
import 'package:vlucky_flutter/services/cosmic_illusion_service.dart';
import 'package:vlucky_flutter/services/cloud_sync_service.dart';
import 'package:vlucky_flutter/services/referral_service.dart';
import 'package:vlucky_flutter/services/supabase_owl_service.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Güvenlik Kalkanı: Ekranı tüm cihazlarda BİRİNCİL DİKEY moda kilitler.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  await Supabase.initialize(
    url: 'https://zzheonrmioxbiinvomsw.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp6aGVvbnJtaW94YmlpbnZvbXN3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQyMzI3MTAsImV4cCI6MjA4OTgwODcxMH0.ur8u0vCa9x-nRKdKhS_xL6c56jpmXjU9FXa2CCHnaWU',
  );

  // Uygulama başlar başlamaz Davet Linklerini dinlemeye başla
  ReferralService().initialize();

  // Kullanıcı zaten giriş yapmışsa (Google/Apple), sosyal servisleri başlat
  final existingSession = Supabase.instance.client.auth.currentSession;
  if (existingSession != null) {
    await SupabaseOwlService().initialize();
  }

  // Her girişte kendimize gelen davet ödüllerini (Çevrimdışı Ruh Taşları) kontrol edelim
  ReferralService.checkInviterRewards();

  // Elite (Premium) Abonelik + Kurabiye Satın Alma Sistemi
  await PurchaseService().initialize();

  // Firebase ve Bildirim Başlatıcısı
  try {
    await Firebase.initializeApp();
    await PushNotificationService().initialize();
  } catch(e) {
    debugPrint("Firebase başlatılamadı: $e");
  }

  // Akıllı Profilleme ve Uyku Verisine Göre Zamanlanmış Bildirim Sistemi (Cosmic Engine)
  await CosmicEngineService().initialize();

  // Sıfır Maliyetli İllüzyon Motoru (Zero-Cost Magic)
  // Arka planda doğum günü, anksiyete, vb. taramasını yapıp sinsi mektuplar kurar
  CosmicIllusionService().runInvisibleProfiler();

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
  // Uygulama açıldı event'i
  AnalyticsService().logAppOpened();
  
  runApp(MyApp(localeController: localeController));
}

class MyApp extends StatefulWidget {
  final LocaleController localeController;

  const MyApp({super.key, required this.localeController});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Uygulama aşağı kaydırıldığında, minimize edildiğinde veya arka plana atıldığında
    // anında tüm verileri taze olarak Supabase Kasasına yükler!
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      CloudSyncService().pushToCloud();
    }
    
    // Uygulama ekrana geri döndüğünde (Resumed) "last_active_at" süresini güncelle.
    // Bu sayede AI kullanıcının hangi saatlerde aktif olduğunu öğrenir.
    if (state == AppLifecycleState.resumed) {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        Supabase.instance.client.from('profiles').update({
          'last_active_at': DateTime.now().toUtc().toIso8601String()
        }).eq('id', user.id).catchError((_) {}); // Sessizce çalışsın, hatada uygulamayı bozmasın
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.localeController,
      child: Consumer<LocaleController>(
        builder: (context, controller, _) {
          return MaterialApp(
            onGenerateTitle: (context) =>
                AppLocalizations.of(context)!.appTitle,
            debugShowCheckedModeBanner: false,
            scaffoldMessengerKey: scaffoldMessengerKey,
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
            navigatorObservers: [
              if (AnalyticsService().observer != null)
                AnalyticsService().observer!,
            ],
          );
        },
      ),
    );
  }
}
