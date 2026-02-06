import 'package:flutter/material.dart';
import 'storage_service.dart';

class LocaleController extends ChangeNotifier {
  static const supportedLocales = [
    Locale('tr'),
    Locale('en'),
  ];

  Locale? _locale;

  Locale? get locale => _locale;

  Future<void> load() async {
    _locale = await StorageService.getAppLocale() ?? const Locale('tr');
    notifyListeners();
  }

  Future<void> setLocale(Locale? locale) async {
    _locale = locale ?? const Locale('tr');
    await StorageService.setAppLocale(_locale);
    notifyListeners();
  }

  String getLabel({
    required String system,
    required String turkish,
    required String english,
  }) {
    if (_locale?.languageCode == 'tr') return turkish;
    return english;
  }
}
