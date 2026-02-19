import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vlucky_flutter/l10n/app_localizations.dart';
import 'constants/theme.dart';
import 'screens/splash_screen.dart';
import 'services/locale_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();
  final localeController = LocaleController();
  await localeController.load();
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
