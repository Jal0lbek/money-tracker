import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import '../providers/theme_provider.dart';
import '../models/account_model.dart';
import '../models/category_model.dart';
import '../database/database_helper.dart';
import '../utils/app_utils.dart';
import '../theme/app_theme.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  bool _exporting = false;
  String? _lastExportPath;
  String _selectedPeriod = 'month';

  final List<Map<String, String>> _periods = [
    {'key': 'today', 'label': 'Bugun'},
    {'key': 'week', 'label': 'Bu hafta'},
    {'key': 'month', 'label': 'Bu oy'},
    {'key': 'all', 'label': 'Hammasi'},
  ];

  Future<Map<String, String>> _getDateRange() async {
    final now = DateTime.now();
    String from, to;
    if (_selectedPeriod == 'today') {
      from = to = AppUtils.dateString(now);
    } else if (_selectedPeriod == 'week') {
      final r = AppUtils.getWeekRange();
      from = r[0]; to = r[1];
    } else if (_selectedPeriod == 'month') {
      final r = AppUtils.getMonthRange();
      from = r[0]; to = r[1];
    } else {
      from = '2020-01-01';
      to = AppUtils.dateString(now);
    }
    return {'from': from, 'to': to};
  }

  Future<void> _exportCSV() async {
    setState(() => _exporting = true);
    try {
      final range = await _getDateRange();
      final transactions = await DatabaseHelper.instance
          .getTransactionsByDateRange(range['from']!, range['to']!);
      final accounts = await DatabaseHelper.instance.getAccounts();
      final categories = await DatabaseHelper.instance.getCategories();

      final buffer = StringBuffer();
      buffer.writeln('Sana,Tur,Summa,Hisob,Kategoriya,Izoh');

      for (final txn in transactions) {
        AccountModel? account;
        try {
          account = txn.type == 'kirim'
              ? accounts.firstWhere((a) => a.id == txn.accountTo)
              : accounts.firstWhere((a) => a.id == txn.accountFrom);
        } catch (_) {}

        CategoryModel? category;
        try {
          if (txn.categoryId != null) {
            category =
                categories.firstWhere((c) => c.id == txn.categoryId);
          }
        } catch (_) {}

        final typeLabel = txn.type == 'kirim'
            ? 'Kirim'
            : txn.type == 'chiqim'
                ? 'Chiqim'
                : 'O\'tkazma';

        buffer.writeln(
          '${txn.date},$typeLabel,${txn.amount.toStringAsFixed(0)},'
          '${account?.name ?? ''},'
          '${category?.name ?? ''},'
          '${txn.note ?? ''}',
        );
      }

      final dir = await getExternalStorageDirectory() ??
          await getApplicationDocumentsDirectory();
      final fileName =
          'money_tracker_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(buffer.toString());

      setState(() {
        _lastExportPath = file.path;
        _exporting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Saqlandi: $fileName'),
          backgroundColor: AppTheme.primaryGreen,
        ));
      }
    } catch (e) {
      setState(() => _exporting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Xato: $e'),
          backgroundColor: const Color(0xFFFF4757),
        ));
      }
    }
  }

  Future<void> _exportTXT() async {
    setState(() => _exporting = true);
    try {
      final range = await _getDateRange();
      final now = DateTime.now();
      final transactions = await DatabaseHelper.instance
          .getTransactionsByDateRange(range['from']!, range['to']!);
      final accounts = await DatabaseHelper.instance.getAccounts();
      final categories = await DatabaseHelper.instance.getCategories();
      final summary = await DatabaseHelper.instance
          .getRangeSummary(range['from']!, range['to']!);

      final buffer = StringBuffer();
      buffer.writeln('=' * 40);
      buffer.writeln('       MONEY TRACKER HISOBOTI');
      buffer.writeln('=' * 40);
      buffer.writeln('Davr: ${range['from']} — ${range['to']}');
      buffer.writeln('Sana: ${AppUtils.dateString(now)}');
      buffer.writeln('-' * 40);
      buffer.writeln(
          'Jami kirim:  ${AppUtils.formatAmount(summary['kirim'] ?? 0)} som');
      buffer.writeln(
          'Jami chiqim: ${AppUtils.formatAmount(summary['chiqim'] ?? 0)} som');
      buffer.writeln(
          'Balans:      ${AppUtils.formatAmount((summary['kirim'] ?? 0) - (summary['chiqim'] ?? 0))} som');
      buffer.writeln('=' * 40);
      buffer.writeln('TRANZAKSIYALAR:');
      buffer.writeln('-' * 40);

      String lastDate = '';
      for (final txn in transactions) {
        if (txn.date != lastDate) {
          buffer.writeln('\n  ${AppUtils.formatDate(txn.date)}');
          lastDate = txn.date;
        }

        AccountModel? account;
        try {
          account = txn.type == 'kirim'
              ? accounts.firstWhere((a) => a.id == txn.accountTo)
              : accounts.firstWhere((a) => a.id == txn.accountFrom);
        } catch (_) {}

        CategoryModel? category;
        try {
          if (txn.categoryId != null) {
            category =
                categories.firstWhere((c) => c.id == txn.categoryId);
          }
        } catch (_) {}

        final sign = txn.type == 'kirim' ? '+' : '-';
        buffer.writeln(
          '  $sign${AppUtils.formatAmount(txn.amount)} som'
          '  [${account?.name ?? '?'}]'
          '  ${category?.name ?? '—'}'
          '${txn.note != null ? '  (${txn.note})' : ''}',
        );
      }

      buffer.writeln('\n${'=' * 40}');
      buffer.writeln('HISOBLAR:');
      for (final acc in accounts) {
        buffer.writeln(
            '  ${acc.name}: ${AppUtils.formatAmount(acc.balance)} ${acc.currency}');
      }
      buffer.writeln('=' * 40);

      final dir = await getExternalStorageDirectory() ??
          await getApplicationDocumentsDirectory();
      final fileName =
          'money_tracker_${DateTime.now().millisecondsSinceEpoch}.txt';
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(buffer.toString());

      setState(() {
        _lastExportPath = file.path;
        _exporting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Saqlandi: $fileName'),
          backgroundColor: AppTheme.primaryGreen,
        ));
      }
    } catch (e) {
      setState(() => _exporting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Xato: $e'),
          backgroundColor: const Color(0xFFFF4757),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final bg = isDark ? const Color(0xFF0A0E1A) : const Color(0xFFF0F4F8);
    final cardBg = isDark ? const Color(0xFF131929) : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0A0E1A) : Colors.white,
        title: const Text('EKSPORT'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Davr tanlang',
                style: TextStyle(
                    color: isDark
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF6B7280),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1)),
            const SizedBox(height: 10),
            Row(
              children: _periods.map((p) {
                final isSelected = _selectedPeriod == p['key'];
                return Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _selectedPeriod = p['key']!),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryGreen.withOpacity(0.15)
                            : cardBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: isSelected
                                ? AppTheme.primaryGreen
                                : Colors.transparent),
                      ),
                      child: Text(p['label']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: isSelected
                                  ? AppTheme.primaryGreen
                                  : (isDark
                                      ? const Color(0xFF6B7280)
                                      : const Color(0xFF9CA3AF)),
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500)),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text('Format tanlang',
                style: TextStyle(
                    color: isDark
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF6B7280),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1)),
            const SizedBox(height: 10),
            _ExportButton(
              icon: Icons.table_chart_rounded,
              title: 'CSV fayl',
              subtitle: 'Excel da ochish mumkin',
              color: const Color(0xFF00B894),
              isDark: isDark,
              loading: _exporting,
              onTap: _exportCSV,
            ),
            const SizedBox(height: 10),
            _ExportButton(
              icon: Icons.description_rounded,
              title: 'TXT fayl',
              subtitle: 'Oddiy matn hisoboti',
              color: AppTheme.kartaColor,
              isDark: isDark,
              loading: _exporting,
              onTap: _exportTXT,
            ),
            if (_lastExportPath != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppTheme.primaryGreen.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: AppTheme.primaryGreen, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Fayl saqlandi',
                              style: TextStyle(
                                  color: AppTheme.primaryGreen,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13)),
                          Text(
                            _lastExportPath!.split('/').last,
                            style: TextStyle(
                                color: isDark
                                    ? const Color(0xFF6B7280)
                                    : const Color(0xFF9CA3AF),
                                fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: Color(0xFF6B7280), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Fayllar telefoningizning xotirasiga saqlanadi. '
                      'CSV faylni Excel yoki Google Sheets da ochish mumkin.',
                      style: TextStyle(
                          color: isDark
                              ? const Color(0xFF6B7280)
                              : const Color(0xFF9CA3AF),
                          fontSize: 12,
                          height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExportButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool isDark;
  final bool loading;
  final VoidCallback onTap;

  const _ExportButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.isDark,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF131929) : Colors.white;
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1A2332),
                          fontWeight: FontWeight.w700,
                          fontSize: 15)),
                  Text(subtitle,
                      style: TextStyle(
                          color: isDark
                              ? const Color(0xFF6B7280)
                              : const Color(0xFF9CA3AF),
                          fontSize: 12)),
                ],
              ),
            ),
            loading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: color, strokeWidth: 2))
                : Icon(Icons.download_rounded, color: color, size: 22),
          ],
        ),
      ),
    );
  }
}
