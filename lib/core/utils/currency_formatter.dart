import '../config/app_config.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final Map<String, String> _symbols = {
    for (final c in AppConfig.currencies) c.code: c.symbol,
  };

  static String format(double amount, String currencyCode) {
    final symbol = _symbols[currencyCode] ?? currencyCode;
    final formatted = amount.abs().toStringAsFixed(2);
    final parts = formatted.split('.');
    final intPart = parts[0];
    final decPart = parts[1];
    final buffer = StringBuffer();
    int count = 0;
    for (int i = intPart.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write(',');
      buffer.write(intPart[i]);
      count++;
    }
    final intFormatted = buffer.toString().split('').reversed.join();
    return '${amount < 0 ? '-' : ''}$symbol$intFormatted.$decPart';
  }

  static String formatCompact(double amount, String currencyCode) {
    final symbol = _symbols[currencyCode] ?? currencyCode;
    final abs = amount.abs();
    final prefix = amount < 0 ? '-' : '';
    if (abs >= 1000000) {
      return '$prefix$symbol${(abs / 1000000).toStringAsFixed(1)}M';
    } else if (abs >= 1000) {
      return '$prefix$symbol${(abs / 1000).toStringAsFixed(1)}K';
    }
    return format(amount, currencyCode);
  }

  static String getSymbol(String currencyCode) {
    return _symbols[currencyCode] ?? currencyCode;
  }
}
