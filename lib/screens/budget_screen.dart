import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../models/budget_model.dart';
import '../models/category_model.dart';
import '../database/database_helper.dart';
import '../utils/app_utils.dart';
import '../theme/app_theme.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  List<BudgetModel> _budgets = [];
  List<CategoryModel> _categories = [];
  bool _loading = true;
  String _currentMonth = '';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final budgets = await DatabaseHelper.instance.getBudgets(_currentMonth);
    final categories = await DatabaseHelper.instance.getCategories(type: 'chiqim');
    await _updateSpentAmounts(budgets);
    setState(() {
      _budgets = budgets;
      _categories = categories;
      _loading = false;
    });
  }

  Future<void> _updateSpentAmounts(List<BudgetModel> budgets) async {
    final now = DateTime.now();
    final from = '${now.year}-${now.month.toString().padLeft(2, '0')}-01';
    final lastDay = DateTime(now.year, now.month + 1, 0).day;
    final to = '${now.year}-${now.month.toString().padLeft(2, '0')}-$lastDay';
    final stats = await DatabaseHelper.instance.getCategoryStats(from, to);

    for (var budget in budgets) {
      final stat = stats.firstWhere(
        (s) => s['name'] == budget.categoryName,
        orElse: () => {'total': 0.0},
      );
      budget.spentAmount;
      final spent = (stat['total'] as num?)?.toDouble() ?? 0.0;
      await DatabaseHelper.instance.updateBudgetSpent(budget.id!, spent);
      budgets[budgets.indexOf(budget)] = BudgetModel(
        id: budget.id,
        categoryId: budget.categoryId,
        categoryName: budget.categoryName,
        limitAmount: budget.limitAmount,
        spentAmount: spent,
        month: budget.month,
        color: budget.color,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final bg = isDark ? const Color(0xFF0A0E1A) : const Color(0xFFF0F4F8);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0A0E1A) : Colors.white,
        title: const Text('BYUDJET'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryGreen,
        onPressed: () => _showAddDialog(context, isDark),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
          : RefreshIndicator(
              onRefresh: _loadData,
              color: AppTheme.primaryGreen,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildMonthHeader(isDark),
                  const SizedBox(height: 16),
                  if (_budgets.isEmpty)
                    _buildEmpty(isDark)
                  else
                    ..._budgets.map((b) => _buildBudgetCard(b, isDark)),
                ],
              ),
            ),
    );
  }

  Widget _buildMonthHeader(bool isDark) {
    final now = DateTime.now();
    final monthNames = [
      '', 'Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun',
      'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr'
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_month_rounded, color: AppTheme.primaryGreen, size: 20),
          const SizedBox(width: 8),
          Text(
            '${monthNames[now.month]} ${now.year}',
            style: const TextStyle(
              color: AppTheme.primaryGreen,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard(BudgetModel budget, bool isDark) {
    final cardBg = isDark ? const Color(0xFF131929) : Colors.white;
    final color = AppUtils.parseColor(budget.color);
    final isOver = budget.isOverBudget;
    final warningColor = isOver ? const Color(0xFFFF4757) : color;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isOver ? const Color(0xFFFF4757).withOpacity(0.4) : color.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: warningColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.category_rounded, color: warningColor, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    budget.categoryName,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1A2332),
                      fontWeight: FontWeight.w700, fontSize: 15,
                    ),
                  ),
                ],
              ),
              if (isOver)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4757).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Limit oshdi!',
                      style: TextStyle(color: Color(0xFFFF4757), fontSize: 11, fontWeight: FontWeight.w700)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${AppUtils.formatAmount(budget.spentAmount)} so\'m',
                style: TextStyle(
                  color: warningColor, fontWeight: FontWeight.w800, fontSize: 16,
                ),
              ),
              Text(
                'Limit: ${AppUtils.formatAmount(budget.limitAmount)} so\'m',
                style: TextStyle(
                  color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: budget.percentage,
              backgroundColor: warningColor.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(warningColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isOver
                    ? '${AppUtils.formatAmount(budget.spentAmount - budget.limitAmount)} so\'m oshdi'
                    : 'Qoldi: ${AppUtils.formatAmount(budget.remainingAmount)} so\'m',
                style: TextStyle(
                  color: isOver ? const Color(0xFFFF4757) : AppTheme.primaryGreen,
                  fontSize: 12, fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(budget.percentage * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  color: warningColor, fontSize: 12, fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(bool isDark) {
    final cardBg = isDark ? const Color(0xFF131929) : Colors.white;
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.account_balance_wallet_rounded,
                size: 48, color: isDark ? const Color(0xFF2D3748) : const Color(0xFFE2E8F0)),
            const SizedBox(height: 12),
            Text('Byudjet limitlari yo\'q',
                style: TextStyle(
                    color: isDark ? const Color(0xFF4A5568) : const Color(0xFF9CA3AF),
                    fontSize: 14)),
            const SizedBox(height: 4),
            Text('+ tugmasini bosib qo\'shing',
                style: TextStyle(
                    color: isDark ? const Color(0xFF374151) : const Color(0xFFD1D5DB),
                    fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context, bool isDark) async {
    final amountController = TextEditingController();
    CategoryModel? selectedCategory;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF131929) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 16, right: 16, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Byudjet limiti',
                  style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1A2332),
                      fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              Text('Kategoriya',
                  style: TextStyle(
                      color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                      fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: _categories.map((cat) {
                  final isSelected = selectedCategory?.id == cat.id;
                  final color = AppUtils.parseColor(cat.color);
                  return GestureDetector(
                    onTap: () => setModalState(() => selectedCategory = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withOpacity(0.15)
                            : (isDark ? const Color(0xFF1A2332) : const Color(0xFFF8FAFC)),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: isSelected ? color : Colors.transparent),
                      ),
                      child: Text(cat.name,
                          style: TextStyle(
                              color: isSelected
                                  ? color
                                  : (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280)),
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1A2332)),
                decoration: const InputDecoration(
                  labelText: 'Oylik limit summasi',
                  prefixIcon: Icon(Icons.payments_rounded, color: AppTheme.primaryGreen),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (selectedCategory == null) return;
                    final amount = double.tryParse(amountController.text.trim());
                    if (amount == null || amount <= 0) return;

                    final budget = BudgetModel(
                      categoryId: selectedCategory!.id,
                      categoryName: selectedCategory!.name,
                      limitAmount: amount,
                      month: _currentMonth,
                      color: selectedCategory!.color,
                    );
                    await DatabaseHelper.instance.insertBudget(budget);
                    if (ctx.mounted) Navigator.pop(ctx);
                    _loadData();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('SAQLASH',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
