import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/finance_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/app_utils.dart';
import '../theme/app_theme.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, double> _summary = {'kirim': 0, 'chiqim': 0};
  List<Map<String, dynamic>> _categoryStats = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadData(0);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) return;
    _loadData(_tabController.index);
  }

  Future<void> _loadData(int index) async {
    setState(() => _loading = true);
    final finance = context.read<FinanceProvider>();
    String from, to;

    if (index == 0) {
      from = to = AppUtils.todayString();
    } else if (index == 1) {
      final range = AppUtils.getWeekRange();
      from = range[0]; to = range[1];
    } else {
      final range = AppUtils.getMonthRange();
      from = range[0]; to = range[1];
    }

    final summary = await finance.getRangeSummary(from, to);
    final stats = await finance.getCategoryStats(from, to);

    setState(() {
      _summary = summary;
      _categoryStats = stats;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        title: const Text('HISOBOT'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryGreen,
          labelColor: AppTheme.primaryGreen,
          unselectedLabelColor: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: const [
            Tab(text: 'Bugun'),
            Tab(text: 'Hafta'),
            Tab(text: 'Oy'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildReport(isDark, cardBg),
                _buildReport(isDark, cardBg),
                _buildReport(isDark, cardBg),
              ],
            ),
    );
  }

  Widget _buildReport(bool isDark, Color cardBg) {
    final income = _summary['kirim'] ?? 0;
    final expense = _summary['chiqim'] ?? 0;
    final balance = income - expense;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Summary cards
          Row(
            children: [
              Expanded(child: _StatCard(
                label: 'Kirim',
                amount: income,
                color: AppTheme.primaryGreen,
                icon: Icons.arrow_downward_rounded,
                isDark: isDark,
              )),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(
                label: 'Chiqim',
                amount: expense,
                color: const Color(0xFFFF4757),
                icon: Icons.arrow_upward_rounded,
                isDark: isDark,
              )),
            ],
          ),
          const SizedBox(height: 12),

          // Balance card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: balance >= 0
                    ? [AppTheme.primaryGreen.withOpacity(0.2), AppTheme.primaryBlue.withOpacity(0.1)]
                    : [const Color(0xFFFF4757).withOpacity(0.2), const Color(0xFFFF6B35).withOpacity(0.1)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: balance >= 0 ? AppTheme.primaryGreen.withOpacity(0.3) : const Color(0xFFFF4757).withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'BALANS',
                  style: TextStyle(
                    color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                    fontSize: 12,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${balance >= 0 ? '+' : '-'} ${AppUtils.formatAmount(balance)} so\'m',
                  style: TextStyle(
                    color: balance >= 0 ? AppTheme.primaryGreen : const Color(0xFFFF4757),
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Pie chart
          if (_categoryStats.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kategoriyalar bo\'yicha',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1A2332),
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sections: _buildPieSections(),
                        centerSpaceRadius: 50,
                        sectionsSpace: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildCategoryLegend(isDark),
                ],
              ),
            ),
          ] else
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
              child: Center(
                child: Text(
                  'Ma\'lumot yo\'q',
                  style: TextStyle(color: isDark ? const Color(0xFF4A5568) : const Color(0xFF9CA3AF)),
                ),
              ),
            ),

          const SizedBox(height: 20),

          // Income vs Expense bar
          if (income > 0 || expense > 0)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kirim vs Chiqim',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1A2332),
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildBarComparison(income, expense, isDark),
                ],
              ),
            ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections() {
    final total = _categoryStats.fold<double>(0, (s, e) => s + ((e['total'] as num?)?.toDouble() ?? 0));
    return _categoryStats.asMap().entries.map((entry) {
      final stat = entry.value;
      final amount = (stat['total'] as num?)?.toDouble() ?? 0;
      final pct = total > 0 ? (amount / total * 100) : 0;
      final color = AppUtils.parseColor(stat['color'] as String?);
      return PieChartSectionData(
        value: amount,
        color: color,
        title: '${pct.toStringAsFixed(0)}%',
        titleStyle: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
        radius: 60,
      );
    }).toList();
  }

  Widget _buildCategoryLegend(bool isDark) {
    return Column(
      children: _categoryStats.map((stat) {
        final color = AppUtils.parseColor(stat['color'] as String?);
        final amount = (stat['total'] as num?)?.toDouble() ?? 0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  stat['name'] as String? ?? '',
                  style: TextStyle(color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF4B5563), fontSize: 13),
                ),
              ),
              Text(
                '${AppUtils.formatAmount(amount)} so\'m',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1A2332),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBarComparison(double income, double expense, bool isDark) {
    final max = income > expense ? income : expense;
    return Column(
      children: [
        _BarRow(label: 'Kirim', amount: income, max: max, color: AppTheme.primaryGreen, isDark: isDark),
        const SizedBox(height: 12),
        _BarRow(label: 'Chiqim', amount: expense, max: max, color: const Color(0xFFFF4757), isDark: isDark),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;
  final bool isDark;

  const _StatCard({required this.label, required this.amount, required this.color, required this.icon, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF131929) : Colors.white;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280), fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            AppUtils.formatAmount(amount),
            style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w800),
          ),
          Text('so\'m', style: TextStyle(color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF), fontSize: 12)),
        ],
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  final String label;
  final double amount;
  final double max;
  final Color color;
  final bool isDark;

  const _BarRow({required this.label, required this.amount, required this.max, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final ratio = max > 0 ? amount / max : 0.0;
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(label, style: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280), fontSize: 12)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio.toDouble(),
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 12,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          AppUtils.formatAmount(amount),
          style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1A2332), fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
