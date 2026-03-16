import 'package:flutter/material.dart';
import '../models/account_model.dart';
import '../utils/app_utils.dart';

class AccountCard extends StatelessWidget {
  final AccountModel account;
  final Color color;
  final bool isDark;

  const AccountCard({super.key, required this.account, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(AppUtils.getAccountIcon(account.type), color: color, size: 18),
              const SizedBox(width: 6),
              Text(
                account.name,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            AppUtils.formatAmount(account.balance),
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1A2332),
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            account.currency,
            style: TextStyle(
              color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
