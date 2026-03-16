import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppUtils {
  static String formatCurrency(double amount, {String currency = 'UZS'}) {
    if (currency == 'USD') {
      return '\$${NumberFormat('#,###.##').format(amount)}';
    }
    final formatted = NumberFormat('#,###').format(amount.abs());
    return '$formatted so\'m';
  }

  static String formatAmount(double amount) {
    return NumberFormat('#,###').format(amount.abs());
  }

  static String formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final txDate = DateTime(date.year, date.month, date.day);

      if (txDate == today) return 'Bugun';
      if (txDate == yesterday) return 'Kecha';
      return DateFormat('d MMMM, yyyy', 'uz').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  static String todayString() {
    final today = DateTime.now();
    return '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
  }

  static String dateString(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  static String nowString() {
    return DateTime.now().toIso8601String();
  }

  static Color parseColor(String? hex) {
    if (hex == null) return Colors.grey;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.grey;
    }
  }

  static IconData getCategoryIcon(String? icon) {
    switch (icon) {
      case 'gas': return Icons.local_gas_station_rounded;
      case 'food': return Icons.restaurant_rounded;
      case 'service': return Icons.build_rounded;
      case 'home': return Icons.home_rounded;
      case 'transport': return Icons.directions_car_rounded;
      case 'clothes': return Icons.checkroom_rounded;
      case 'health': return Icons.local_hospital_rounded;
      case 'education': return Icons.school_rounded;
      case 'entertainment': return Icons.movie_rounded;
      case 'salary': return Icons.work_rounded;
      case 'trade': return Icons.store_rounded;
      case 'client': return Icons.person_rounded;
      case 'invest': return Icons.trending_up_rounded;
      case 'gift': return Icons.card_giftcard_rounded;
      case 'cash': return Icons.payments_rounded;
      case 'card': return Icons.credit_card_rounded;
      case 'bank': return Icons.account_balance_rounded;
      case 'currency': return Icons.attach_money_rounded;
      default: return Icons.category_rounded;
    }
  }

  static IconData getAccountIcon(String type) {
    switch (type) {
      case 'naqd': return Icons.payments_rounded;
      case 'karta': return Icons.credit_card_rounded;
      case 'bank': return Icons.account_balance_rounded;
      case 'valyuta': return Icons.attach_money_rounded;
      default: return Icons.account_balance_wallet_rounded;
    }
  }

  static String getAccountTypeName(String type) {
    switch (type) {
      case 'naqd': return 'Naqd';
      case 'karta': return 'Karta';
      case 'bank': return 'Bank';
      case 'valyuta': return 'Valyuta';
      default: return type;
    }
  }

  static List<String> getWeekRange() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    return [dateString(weekStart), dateString(weekEnd)];
  }

  static List<String> getMonthRange() {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);
    return [dateString(monthStart), dateString(monthEnd)];
  }
}
