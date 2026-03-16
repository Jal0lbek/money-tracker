import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';
import '../providers/theme_provider.dart';
import '../models/transaction_model.dart';
import '../utils/app_utils.dart';
import '../theme/app_theme.dart';
import '../widgets/transaction_item.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _filter = 'all'; // all, kirim, chiqim, otkazma

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final bg = isDark ? const Color(0xFF0A0E1A) : const Color(0xFFF0F4F8);
    final finance = context.watch<FinanceProvider>();

    final filtered = _filter == 'all'
        ? finance.transactions
        : finance.transactions.where((t) => t.type == _filter).toList();

    // Group by date
    final Map<String, List<TransactionModel>> grouped = {};
    for (final txn in filtered) {
      grouped.putIfAbsent(txn.date, () => []).add(txn);
    }
    final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0A0E1A) : Colors.white,
        title: const Text('TARIX'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Filter tabs
          Container(
            color: isDark ? const Color(0xFF0A0E1A) : Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                _FilterChip(label: 'Barchasi', value: 'all', current: _filter, onTap: (v) => setState(() => _filter = v), isDark: isDark),
                const SizedBox(width: 8),
                _FilterChip(label: 'Kirim', value: 'kirim', current: _filter, onTap: (v) => setState(() => _filter = v), isDark: isDark, color: AppTheme.primaryGreen),
                const SizedBox(width: 8),
                _FilterChip(label: 'Chiqim', value: 'chiqim', current: _filter, onTap: (v) => setState(() => _filter = v), isDark: isDark, color: const Color(0xFFFF4757)),
                const SizedBox(width: 8),
                _FilterChip(label: 'O\'tkazma', value: 'otkazma', current: _filter, onTap: (v) => setState(() => _filter = v), isDark: isDark, color: AppTheme.kartaColor),
              ],
            ),
          ),

          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.history_rounded, size: 64, color: isDark ? const Color(0xFF2D3748) : const Color(0xFFE2E8F0)),
                        const SizedBox(height: 16),
                        Text(
                          'Tranzaksiyalar topilmadi',
                          style: TextStyle(color: isDark ? const Color(0xFF4A5568) : const Color(0xFF9CA3AF)),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: sortedDates.length,
                    itemBuilder: (context, i) {
                      final date = sortedDates[i];
                      final txns = grouped[date]!;
                      final cardBg = isDark ? const Color(0xFF131929) : Colors.white;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Text(
                                  AppUtils.formatDate(date),
                                  style: TextStyle(
                                    color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(child: Divider(color: isDark ? const Color(0xFF1A2332) : const Color(0xFFE5E7EB))),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
                            child: Column(
                              children: txns.asMap().entries.map((e) {
                                return TransactionItem(
                                  transaction: e.value,
                                  finance: finance,
                                  isDark: isDark,
                                  showDivider: e.key < txns.length - 1,
                                  onDelete: () async {
                                    if (e.value.id != null) {
                                      final confirmed = await _confirmDelete(context);
                                      if (confirmed == true) {
                                        await finance.deleteTransaction(e.value.id!);
                                      }
                                    }
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('O\'chirish'),
        content: const Text('Bu tranzaksiyani o\'chirishni xohlaysizmi?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Yo\'q')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ha', style: TextStyle(color: Color(0xFFFF4757))),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String value;
  final String current;
  final Function(String) onTap;
  final bool isDark;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.value,
    required this.current,
    required this.onTap,
    required this.isDark,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = current == value;
    final c = color ?? AppTheme.primaryGreen;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? c.withOpacity(0.15) : (isDark ? const Color(0xFF1A2332) : const Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? c : Colors.transparent, width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? c : (isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF)),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
