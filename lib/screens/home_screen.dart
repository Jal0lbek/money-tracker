import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/finance_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/app_utils.dart';
import '../theme/app_theme.dart';
import '../widgets/account_card.dart';
import '../widgets/transaction_item.dart';
import '../widgets/summary_card.dart';
import 'add_income_screen.dart';
import 'add_expense_screen.dart';
import 'transfer_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FinanceProvider>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final bg = isDark ? const Color(0xFF0A0E1A) : const Color(0xFFF0F4F8);
    final cardBg = isDark ? const Color(0xFF131929) : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      body: Consumer<FinanceProvider>(
        builder: (context, finance, _) {
          if (finance.isLoading && finance.accounts.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen));
          }

          return RefreshIndicator(
            color: AppTheme.primaryGreen,
            onRefresh: () => finance.loadAll(),
            child: CustomScrollView(
              slivers: [
                _buildAppBar(isDark),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      _buildTotalBalance(finance, isDark),
                      _buildAccountCards(finance, isDark),
                      _buildActionButtons(isDark),
                      _buildTodaySummary(finance, cardBg, isDark),
                      _buildRecentTransactions(finance, isDark),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(bool isDark) {
    return SliverAppBar(
      floating: true,
      backgroundColor: isDark ? const Color(0xFF0A0E1A) : Colors.white,
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'MONEY TRACKER',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1A2332),
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
          Row(
            children: [
              Consumer<ThemeProvider>(
                builder: (context, theme, _) => IconButton(
                  icon: Icon(
                    theme.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    color: AppTheme.primaryGreen,
                  ),
                  onPressed: () => theme.toggleTheme(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.settings_rounded, color: AppTheme.primaryGreen),
                onPressed: () => Navigator.pushNamed(context, '/settings'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalBalance(FinanceProvider finance, bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF00D4AA).withOpacity(0.15),
            const Color(0xFF0066FF).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.primaryGreen.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            'JAMI PUL',
            style: TextStyle(
              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppUtils.formatAmount(finance.totalBalance),
            style: const TextStyle(
              color: AppTheme.primaryGreen,
              fontSize: 38,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2),
          Text(
            'so\'m',
            style: TextStyle(
              color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildAccountCards(FinanceProvider finance, bool isDark) {
    final accountColors = {
      'naqd': AppTheme.naqdColor,
      'karta': AppTheme.kartaColor,
      'bank': AppTheme.bankColor,
      'valyuta': AppTheme.valyutaColor,
    };

    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        itemCount: finance.accounts.length,
        itemBuilder: (context, i) {
          final acc = finance.accounts[i];
          final color = accountColors[acc.type] ?? AppTheme.primaryGreen;
          return AccountCard(account: acc, color: color, isDark: isDark)
              .animate(delay: Duration(milliseconds: 100 * i))
              .fadeIn()
              .slideX(begin: 0.3);
        },
      ),
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Row(
        children: [
          _ActionButton(
            label: 'Kirim',
            icon: Icons.add_circle_rounded,
            color: AppTheme.naqdColor,
            onTap: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddIncomeScreen()));
              if (mounted) context.read<FinanceProvider>().loadAll();
            },
          ),
          const SizedBox(width: 10),
          _ActionButton(
            label: 'Chiqim',
            icon: Icons.remove_circle_rounded,
            color: const Color(0xFFFF4757),
            onTap: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExpenseScreen()));
              if (mounted) context.read<FinanceProvider>().loadAll();
            },
          ),
          const SizedBox(width: 10),
          _ActionButton(
            label: 'O\'tkazma',
            icon: Icons.sync_alt_rounded,
            color: AppTheme.kartaColor,
            onTap: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const TransferScreen()));
              if (mounted) context.read<FinanceProvider>().loadAll();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySummary(FinanceProvider finance, Color cardBg, bool isDark) {
    final income = finance.todaySummary['kirim'] ?? 0;
    final expense = finance.todaySummary['chiqim'] ?? 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bugungi hisobot',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1A2332),
                fontWeight: FontWeight.w700,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: SummaryCard(
                  label: 'Kirim',
                  amount: income,
                  isIncome: true,
                  isDark: isDark,
                )),
                const SizedBox(width: 12),
                Expanded(child: SummaryCard(
                  label: 'Chiqim',
                  amount: expense,
                  isIncome: false,
                  isDark: isDark,
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions(FinanceProvider finance, bool isDark) {
    final cardBg = isDark ? const Color(0xFF131929) : Colors.white;
    final transactions = finance.transactions.take(5).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'So\'nggi tranzaksiyalar',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1A2332),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
                child: const Text(
                  'Tarixni ko\'rish',
                  style: TextStyle(color: AppTheme.primaryGreen, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (transactions.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
              child: Center(
                child: Text(
                  'Hali tranzaksiyalar yo\'q',
                  style: TextStyle(color: isDark ? const Color(0xFF4A5568) : const Color(0xFF9CA3AF)),
                ),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: transactions.asMap().entries.map((e) {
                  final isLast = e.key == transactions.length - 1;
                  return TransactionItem(
                    transaction: e.value,
                    finance: finance,
                    isDark: isDark,
                    showDivider: !isLast,
                  ).animate(delay: Duration(milliseconds: 50 * e.key)).fadeIn().slideX(begin: 0.1);
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.3), width: 1),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
