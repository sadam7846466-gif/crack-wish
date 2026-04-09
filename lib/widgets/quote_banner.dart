import 'package:flutter/material.dart';
import 'package:vlucky_flutter/l10n/app_localizations.dart';
import '../data/daily_quotes.dart';

class QuoteBanner extends StatelessWidget {
  const QuoteBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final int daysSinceEpoch = DateTime.now().millisecondsSinceEpoch ~/ 86400000;
    final int quoteIndex = daysSinceEpoch % DailyQuotes.pool.length;
    final String activeQuote = DailyQuotes.pool[quoteIndex][l10n.localeName == 'tr' ? 'tr' : 'en']!;

    // Pudra Pembesi / Uçuk Gül (Soft Powder Pink) - Rengi ve şeffaflığı iyice yumuşatılmış ton
    const Color tintColor = Color(0xFFF8BBD0);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        // Hafif renk tonlu cam efekti (Tinted Glassmorphism)
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tintColor.withOpacity(0.15), // Işıltı iyice kısıldı
            tintColor.withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: tintColor.withOpacity(0.15), // Çerçeve daha belirsiz yapıldı
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: tintColor.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: tintColor.withOpacity(0.15)),
            ),
            child: Icon(
              Icons.format_quote_rounded,
              color: Colors.white.withOpacity(0.9), // Daha saf beyaza yakın tutuldu
              size: 18,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activeQuote,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.quoteOfDaySource,
                  style: TextStyle(
                    color: tintColor.withOpacity(0.8), // Göz yormayan alt metin rengi
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

