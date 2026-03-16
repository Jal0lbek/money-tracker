import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';
import '../providers/theme_provider.dart';
import '../models/transaction_model.dart';
import '../models/account_model.dart';
import '../utils/app_utils.dart';
import '../theme/app_theme.dart';
import '../widgets/amount_input.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _amountController = TextEditingController();
  AccountModel? _fromAccount;
  AccountModel? _toAccount;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final accounts = context.read<FinanceProvider>().accounts;
      if (accounts.length >= 2) {
        setState(() {
          _fromAccount = accounts[1]; // karta
          _toAccount = accounts[0]; // naqd
        });
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_amountController.text.isEmpty) {
      _showError('Summani kiriting');
      return;
    }
    if (_fromAccount == null || _toAccount == null) {
      _showError('Hisoblarni tanlang');
      return;
    }
    if (_fromAccount!.id == _toAccount!.id) {
      _showError('Bir xil hisobga o\'tkazib bo\'lmaydi');
      return;
    }

    final amount = double.tryParse(_amountController.text.replaceAll(' ', ''));
    if (amount == null || amount <= 0) {
      _showError('To\'g\'ri summa kiriting');
      return;
    }

    setState(() => _isSaving = true);

    final txn = TransactionModel(
      type: 'otkazma',
      amount: amount,
      accountFrom: _fromAccount!.id,
      accountTo: _toAccount!.id,
      note: '${_fromAccount!.name} → ${_toAccount!.name}',
      date: AppUtils.dateString(DateTime.now()),
      createdAt: AppUtils.nowString(),
    );

    final success = await context.read<FinanceProvider>().addTransaction(txn);
    setState(() => _isSaving = false);

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O\'tkazma amalga oshirildi! ✓'),
          backgroundColor: AppTheme.kartaColor,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: const Color(0xFFFF4757)),
    );
  }

  void _swapAccounts() {
    setState(() {
      final temp = _fromAccount;
      _fromAccount = _toAccount;
      _toAccount = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final bg = isDark ? const Color(0xFF0A0E1A) : const Color(0xFFF0F4F8);
    final finance = context.watch<FinanceProvider>();
    const transferColor = AppTheme.kartaColor;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0A0E1A) : Colors.white,
        title: const Text('O\'TKAZMA'),
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
              color: transferColor,
              hint: '0',
              label: 'Summa',
            ),
            const SizedBox(height: 24),

            // Transfer flow
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF131929) : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildAccountPicker('Qayerdan', _fromAccount, finance.accounts, isDark, (acc) {
                    setState(() => _fromAccount = acc);
                  }),
                  const SizedBox(height: 16),
                  // Swap button
                  Center(
                    child: GestureDetector(
                      onTap: _swapAccounts,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: transferColor.withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: transferColor.withOpacity(0.3)),
                        ),
                        child: const Icon(Icons.swap_vert_rounded, color: transferColor, size: 22),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildAccountPicker('Qayerga', _toAccount, finance.accounts, isDark, (acc) {
                    setState(() => _toAccount = acc);
                  }),
                ],
              ),
            ),

            if (_fromAccount != null && _toAccount != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: transferColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: transferColor.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(AppUtils.getAccountIcon(_fromAccount!.type), color: transferColor, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      _fromAccount!.name,
                      style: const TextStyle(color: transferColor, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.arrow_forward_rounded, color: transferColor, size: 18),
                    const SizedBox(width: 12),
                    Icon(AppUtils.getAccountIcon(_toAccount!.type), color: transferColor, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      _toAccount!.name,
                      style: const TextStyle(color: transferColor, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: transferColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isSaving
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text(
                        'SAQLASH',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 1.5),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountPicker(String label, AccountModel? selected, List<AccountModel> accounts, bool isDark, Function(AccountModel) onSelect) {
    final accountColors = {
      'naqd': AppTheme.naqdColor,
      'karta': AppTheme.kartaColor,
      'bank': AppTheme.bankColor,
      'valyuta': AppTheme.valyutaColor,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: accounts.map((acc) {
            final isSelected = selected?.id == acc.id;
            final color = accountColors[acc.type] ?? AppTheme.primaryGreen;
            return Expanded(
              child: GestureDetector(
                onTap: () => onSelect(acc),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? color.withOpacity(0.2) : (isDark ? const Color(0xFF1A2332) : const Color(0xFFF8FAFC)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? color : Colors.transparent, width: 1.5),
                  ),
                  child: Column(
                    children: [
                      Icon(AppUtils.getAccountIcon(acc.type), color: isSelected ? color : (isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF)), size: 20),
                      const SizedBox(height: 4),
                      Text(
                        acc.name,
                        style: TextStyle(
                          color: isSelected ? color : (isDark ? const Color(0xFFD1D5DB) : const Color(0xFF4B5563)),
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
        ),
      ],
    );
  }
}
