import 'package:intl/intl.dart';

class AppFormatters {
  AppFormatters._();

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: '₹ ',
    decimalDigits: 2,
  );

  static final NumberFormat _shortCurrencyFormat = NumberFormat.currency(
    symbol: '₹',
    decimalDigits: 2,
  );

  static final DateFormat _displayDateFormat = DateFormat('EEE, dd MMM yyyy');
  static final DateFormat _shortDateFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _storageFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _groupDateFormat = DateFormat('MMM dd, yyyy');

  /// Format amount with ₹ symbol (e.g., ₹ 1,234.56)
  static String formatCurrency(double amount) {
    return _currencyFormat.format(amount);
  }

  /// Format amount short (e.g., ₹1,234.56)
  static String formatCurrencyShort(double amount) {
    return _shortCurrencyFormat.format(amount);
  }

  /// Format amount with sign (e.g., +₹ 850.00 or -₹ 85.00)
  static String formatWithSign(double amount, bool isIncome) {
    final prefix = isIncome ? '+' : '-';
    return '$prefix${_shortCurrencyFormat.format(amount.abs())}';
  }

  /// Format date for display (e.g., Tue, 22 Feb 2026)
  static String formatDisplayDate(DateTime date) {
    return _displayDateFormat.format(date);
  }

  /// Format date short (e.g., 22 Feb 2026)
  static String formatShortDate(DateTime date) {
    return _shortDateFormat.format(date);
  }

  /// Format date for SQLite storage (e.g., 2026-02-22)
  static String formatStorageDate(DateTime date) {
    return _storageFormat.format(date);
  }

  /// Parse a stored date string back to DateTime
  static DateTime? parseStorageDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      return null;
    }
  }

  /// Format date for grouping headers (e.g., "Today", "Yesterday", "Jan 30, 2022")
  static String formatGroupHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return _groupDateFormat.format(date);
    }
  }

  /// Parse amount from string, returns null if invalid
  static double? parseAmount(String value) {
    final cleaned = value.trim().replaceAll(',', '');
    return double.tryParse(cleaned);
  }
}
