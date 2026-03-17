import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';
import '../providers/theme_provider.dart';
import '../models/transaction_model.dart';
import '../models/account_model.dart';
import '../models/category_model.dart';
import '../utils/app_utils.dart';
import '../theme/app_theme.dart';
import '../widgets/amount_input.dart';
import '../widgets/account_selector.dart';
import '../widgets/date_selector.dart';

class AddIncomeScreen extends StatefulWidget {
  const AddIncomeScreen({super.key});

  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  AccountModel? _selectedAccount;
  CategoryModel? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final finance = context.read<FinanceProvider>();
      if (finance.accounts.isNotEmpty) {
        setState(() => _selectedAccount = finance.accounts.first);
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_amountController.text.isEmpty) {
      _showError('Summani kiriting');
      return;
    }
    if (_selectedAccount == null) {
      _showError('Hisobni tanlang');
      return;
    }

    final amount = double.tryParse(
      _amountController.text.replaceAll(' ', '').replaceAll(',', '.').trim(),
    );
    if (amount == null || amount <= 0) {
      _showError('To\'g\'ri summa kiriting');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final txn = TransactionModel(
        type: 'kirim',
        amount: amount,
        accountTo: _selectedAccount!.id,
        categoryId: _selectedCategory?.id,
        note: _noteController.text.isEmpty ? null : _noteController.text,
        date: AppUtils.dateString(_selectedDate),
        createdAt: AppUtils.nowString(),
      );

      final success =
          await context.read<FinanceProvider>().addTransaction(txn);
      setState(() => _isSaving = false);

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kirim saqlandi! ✓'),
            backgroundColor: AppTheme.primaryGreen,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      _showError('Xato: $e');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: const Color(0xFFFF4757)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final bg = isDark ? const Color(0xFF0A0E1A) : const Color(0xFFF0F4F8);
    final cardBg = isDark ? const Color(0xFF131929) : Colors.white;
    final finance = context.watch<FinanceProvider>();
    final incomeCategories = finance.getCategoriesByType('kirim');

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0A0E1A) : Colors.white,
        title: const Text('KIRIM QO\'SHISH'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount
            AmountInput(
              controller: _amountController,
              isDark: isDark,
              color: AppTheme.primaryGreen,
              hint: '0',
              label: 'Summa',
            ),
            const SizedBox(height: 16),

            // Account selector
            _sectionLabel('Hisob', isDark),
            const SizedBox(height: 8),
            AccountSelector(
              accounts: finance.accounts,
              selected: _selectedAccount,
              onSelected: (acc) => setState(() => _selectedAccount = acc),
              isDark: isDark,
            ),
            const SizedBox(height: 16),

            // Category
            _sectionLabel('Sabab', isDark),
            const SizedBox(height: 8),
            _buildCategoryGrid(incomeCategories, isDark, cardBg),
            const SizedBox(height: 16),

            // Note
            _sectionLabel('Izoh (ixtiyoriy)', isDark),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1A2332)),
              decoration: InputDecoration(
                hintText: 'Mijoz to\'lovi, Savdo...',
                prefixIcon: const Icon(Icons.notes_rounded, color: AppTheme.primaryGreen),
              ),
            ),
            const SizedBox(height: 16),

            // Date
            _sectionLabel('Sana', isDark),
            const SizedBox(height: 8),
            DateSelector(
              date: _selectedDate,
              onChanged: (d) => setState(() => _selectedDate = d),
              isDark: isDark,
            ),
            const SizedBox(height: 32),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isSaving
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text(
                        'SAQLASH',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          letterSpacing: 1.5,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(List<CategoryModel> categories, bool isDark, Color cardBg) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((cat) {
        final isSelected = _selectedCategory?.id == cat.id;
        final color = AppUtils.parseColor(cat.color);
        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = isSelected ? null : cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? color.withOpacity(0.2) : (isDark ? const Color(0xFF1A2332) : const Color(0xFFF8FAFC)),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? color : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(AppUtils.getCategoryIcon(cat.icon), color: isSelected ? color : (isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF)), size: 16),
                const SizedBox(width: 6),
                Text(
                  cat.name,
                  style: TextStyle(
                    color: isSelected ? color : (isDark ? const Color(0xFFD1D5DB) : const Color(0xFF4B5563)),
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _sectionLabel(String text, bool isDark) {
    return Text(
      text,
      style: TextStyle(
        color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
      ),
    );
  }
}
