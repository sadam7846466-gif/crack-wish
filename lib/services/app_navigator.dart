import 'package:flutter/foundation.dart';

/// Recovery tamamlandığında bento grid'i anında yenilemek için global sinyal.
/// Her değişiklikte değer artırılır, BentoGrid ValueListenableBuilder ile dinler.
final ValueNotifier<int> readingReadyNotifier = ValueNotifier<int>(0);
