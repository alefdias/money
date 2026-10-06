import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  static String format(double value) {
    return _formatter.format(value);
  }

  static String formatCompact(double value) {
    if (value.abs() >= 1000) {
      final formatted = (value / 1000).toStringAsFixed(1).replaceAll('.', ',');
      return 'R\$ ${formatted}k';
    }
    return format(value);
  }

  static double parse(String text) {
    final cleaned = text.replaceAll('R\$', '').replaceAll('.', '').replaceAll(',', '.').trim();
    return double.tryParse(cleaned) ?? 0.0;
  }
}
