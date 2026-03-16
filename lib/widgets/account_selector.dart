import 'package:flutter/material.dart';
import '../models/account_model.dart';
import '../utils/app_utils.dart';
import '../theme/app_theme.dart';

class AccountSelector extends StatelessWidget {
  final List<AccountModel> accounts;
  final AccountModel? selected;
  final Function(AccountModel) onSelected;
  final bool isDark;

  const AccountSelector({
    super.key,
    required this.accounts,
    required this.selected,
    required this.onSelected,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final accountColors = {
      'naqd': AppTheme.naqdColor,
      'karta': AppTheme.kartaColor,
      'bank': AppTheme.bankColor,
      'valyuta': AppTheme.valyutaColor,
    };

    return Row(
      children: accounts.map((acc) {
        final isSelected = selected?.id == acc.id;
        final color = accountColors[acc.type] ?? AppTheme.primaryGreen;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelected(acc),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withOpacity(0.18)
                    : (isDark ? const Color(0xFF1A2332) : const Color(0xFFF8FAFC)),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? color : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    AppUtils.getAccountIcon(acc.type),
                    color: isSelected
                        ? color
                        : (isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF)),
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    acc.name,
                    style: TextStyle(
                      color: isSelected
                          ? color
                          : (isDark ? const Color(0xFFD1D5DB) : const Color(0xFF4B5563)),
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
