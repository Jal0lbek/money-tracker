import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
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

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  AccountModel? _selectedAccount;
  CategoryModel? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  String? _receiptPath;
  bool _isSaving = false;
  final ImagePicker _picker = ImagePicker();

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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1200,
      );
      if (image != null) {
        setState(() => _receiptPath = image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rasm olishda xato: $e'),
            backgroundColor: const Color(0xFFFF4757),
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    final isDark = context.read<ThemeProvider>().isDark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF131929) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2D3748) : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.camera_alt_rounded,
                    color: AppTheme.primaryGreen),
              ),
              title: Text('Kamera',
                  style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1A2332),
                      fontWeight: FontWeight.w600)),
              subtitle: Text('Chekni hozir suratga oling',
                  style: TextStyle(
                      color: isDark
                          ? const Color(0xFF6B7280)
                          : const Color(0xFF9CA3AF),
                      fontSize: 12)),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.kartaColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.photo_library_rounded,
                    color: AppTheme.kartaColor),
              ),
              title: Text('Galereya',
                  style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1A2332),
                      fontWeight: FontWeight.w600)),
              subtitle: Text('Screenshot yoki saqlangan rasm',
                  style: TextStyle(
                      color: isDark
                          ? const Color(0xFF6B7280)
                          : const Color(0xFF9CA3AF),
                      fontSize: 12)),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
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
        _amountController.text.replaceAll(' ', '').replaceAll(',', '.').trim());
    if (amount == null || amount <= 0) {
      _showError('To\'g\'ri summa kiriting');
      return;
    }

    setState(() => _isSaving = true);

    final txn = TransactionModel(
      type: 'chiqim',
      amount: amount,
      accountFrom: _selectedAccount!.id,
      categoryId: _selectedCategory?.id,
      note: _noteController.text.isEmpty ? null : _noteController.text,
      date: AppUtils.dateString(_selectedDate),
      createdAt: AppUtils.nowString(),
      receiptPath: _receiptPath,
    );

    final success = await context.read<FinanceProvider>().addTransaction(txn);
    setState(() => _isSaving = false);

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chiqim saqlandi! ✓'),
          backgroundColor: Color(0xFFFF4757),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(msg), backgroundColor: const Color(0xFFFF4757)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final bg = isDark ? const Color(0xFF0A0E1A) : const Color(0xFFF0F4F8);
    final finance = context.watch<FinanceProvider>();
    final expenseCategories = finance.getCategoriesByType('chiqim');
    const expenseColor = Color(0xFFFF4757);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0A0E1A) : Colors.white,
        title: const Text('CHIQIM QO\'SHISH'),
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
            AmountInput(
              controller: _amountController,
              isDark: isDark,
              color: expenseColor,
              hint: '0',
              label: 'Summa',
            ),
            const SizedBox(height: 16),

            _sectionLabel('Hisob', isDark),
            const SizedBox(height: 8),
            AccountSelector(
              accounts: finance.accounts,
              selected: _selectedAccount,
              onSelected: (acc) => setState(() => _selectedAccount = acc),
              isDark: isDark,
            ),
            const SizedBox(height: 16),

            _sectionLabel('Kategoriya', isDark),
            const SizedBox(height: 8),
            _buildCategoryGrid(expenseCategories, isDark),
            const SizedBox(height: 16),

            _sectionLabel('Izoh (ixtiyoriy)', isDark),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1A2332)),
              decoration: const InputDecoration(
                hintText: 'Benzin, Ovqat...',
                prefixIcon:
                    Icon(Icons.notes_rounded, color: expenseColor),
              ),
            ),
            const SizedBox(height: 16),

            _sectionLabel('Sana', isDark),
            const SizedBox(height: 8),
            DateSelector(
              date: _selectedDate,
              onChanged: (d) => setState(() => _selectedDate = d),
              isDark: isDark,
            ),
            const SizedBox(height: 16),

            _sectionLabel('Chek rasmi (ixtiyoriy)', isDark),
            const SizedBox(height: 8),
            _buildReceiptPicker(isDark),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: expenseColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('SAQLASH',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            letterSpacing: 1.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptPicker(bool isDark) {
    if (_receiptPath != null) {
      return Stack(
        children: [
          GestureDetector(
            onTap: _showImageSourceDialog,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(_receiptPath!),
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 8, right: 8,
            child: GestureDetector(
              onTap: () => setState(() => _receiptPath = null),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4757),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4)
                  ],
                ),
                child: const Icon(Icons.close_rounded,
                    color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2332) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? const Color(0xFF2D3748)
                : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(Icons.add_photo_alternate_rounded,
                color: isDark
                    ? const Color(0xFF4A5568)
                    : const Color(0xFF9CA3AF),
                size: 36),
            const SizedBox(height: 8),
            Text('Kamera yoki Galereya',
                style: TextStyle(
                    color: isDark
                        ? const Color(0xFF6B7280)
                        : const Color(0xFF9CA3AF),
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text('Chek, screenshot yoki to\'lov rasmi',
                style: TextStyle(
                    color: isDark
                        ? const Color(0xFF374151)
                        : const Color(0xFFD1D5DB),
                    fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(
      List<CategoryModel> categories, bool isDark) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((cat) {
        final isSelected = _selectedCategory?.id == cat.id;
        final color = AppUtils.parseColor(cat.color);
        return GestureDetector(
          onTap: () => setState(
              () => _selectedCategory = isSelected ? null : cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withOpacity(0.2)
                  : (isDark
                      ? const Color(0xFF1A2332)
                      : const Color(0xFFF8FAFC)),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: isSelected ? color : Colors.transparent,
                  width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(AppUtils.getCategoryIcon(cat.icon),
                    color: isSelected
                        ? color
                        : (isDark
                            ? const Color(0xFF6B7280)
                            : const Color(0xFF9CA3AF)),
                    size: 16),
                const SizedBox(width: 6),
                Text(cat.name,
                    style: TextStyle(
                        color: isSelected
                            ? color
                            : (isDark
                                ? const Color(0xFFD1D5DB)
                                : const Color(0xFF4B5563)),
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500)),
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
        color: isDark
            ? const Color(0xFF9CA3AF)
            : const Color(0xFF6B7280),
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
      ),
    );
  }
}
