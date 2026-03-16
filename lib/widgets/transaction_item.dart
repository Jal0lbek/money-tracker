import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../providers/finance_provider.dart';
import '../utils/app_utils.dart';
import '../theme/app_theme.dart';

class TransactionItem extends StatelessWidget {
  final TransactionModel transaction;
  final FinanceProvider finance;
  final bool isDark;
  final bool showDivider;
  final VoidCallback? onDelete;

  const TransactionItem({
    super.key,
    required this.transaction,
    required this.finance,
    required this.isDark,
    this.showDivider = true,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == 'kirim';
    final isTransfer = transaction.type == 'otkazma';
    final color = isTransfer
        ? AppTheme.kartaColor
        : isIncome
            ? AppTheme.primaryGreen
            : const Color(0xFFFF4757);

    final category = transaction.categoryId != null
        ? finance.getCategoryById(transaction.categoryId!)
        : null;

    final account = isIncome
        ? (transaction.accountTo != null ? finance.getAccountById(transaction.accountTo!) : null)
        : (transaction.accountFrom != null ? finance.getAccountById(transaction.accountFrom!) : null);

    final icon = isTransfer
        ? Icons.sync_alt_rounded
        : category != null
            ? AppUtils.getCategoryIcon(category.icon)
            : (isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded);

    final title = isTransfer
        ? (transaction.note ?? 'O\'tkazma')
        : category?.name ?? (isIncome ? 'Kirim' : 'Chiqim');

    final subtitle = transaction.note != null && !isTransfer
        ? transaction.note!
        : account?.name ?? '';

    return Column(
      children: [
        Dismissible(
          key: Key('txn_${transaction.id}'),
          direction: onDelete != null ? DismissDirection.endToStart : DismissDirection.none,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            color: const Color(0xFFFF4757).withOpacity(0.1),
            child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFF4757)),
          ),
          onDismissed: (_) => onDelete?.call(),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            title: Text(
              title,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1A2332),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            subtitle: subtitle.isNotEmpty
                ? Text(
                    subtitle,
                    style: TextStyle(
                      color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                      fontSize: 12,
                    ),
                  )
                : null,
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isIncome ? '+' : isTransfer ? '↔' : '-'} ${AppUtils.formatAmount(transaction.amount)}',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                Text(
                  'so\'m',
                  style: TextStyle(
                    color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 72,
            color: isDark ? const Color(0xFF1A2332) : const Color(0xFFF0F4F8),
          ),
      ],
    );
  }
}
