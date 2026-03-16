import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../models/debt_model.dart';
import '../database/database_helper.dart';
import '../utils/app_utils.dart';
import '../theme/app_theme.dart';

class DebtScreen extends StatefulWidget {
  const DebtScreen({super.key});

  @override
  State<DebtScreen> createState() => _DebtScreenState();
}

class _DebtScreenState extends State<DebtScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<DebtModel> _debts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadDebts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDebts() async {
    setState(() => _loading = true);
    final debts = await DatabaseHelper.instance.getDebts();
    setState(() {
      _debts = debts;
      _loading = false;
    });
  }

  List<DebtModel> get _qarzdorlar => _debts.where((d) => d.type == 'qarzdor' && !d.isPaid).toList();
  List<DebtModel> get _qarzlar => _debts.where((d) => d.type == 'qarz' && !d.isPaid).toList();

  double get _qarzdorTotal => _qarzdorlar.fold(0, (s, d) => s + d.remainingAmount);
  double get _qarzTotal => _qarzlar.fold(0, (s, d) => s + d.remainingAmount);

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final bg = isDark ? const Color(0xFF0A0E1A) : const Color(0xFFF0F4F8);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0A0E1A) : Colors.white,
        title: const Text('QARZLAR'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryGreen,
          labelColor: AppTheme.primaryGreen,
          unselectedLabelColor: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: const [
            Tab(text: 'Qarzdorlar'),
            Tab(text: 'Qarzlarim'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryGreen,
        onPressed: () => _showAddDebtDialog(context, isDark),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildList(_qarzdorlar, _qarzdorTotal, 'qarzdor', isDark),
                _buildList(_qarzlar, _qarzTotal, 'qarz', isDark),
              ],
            ),
    );
  }

  Widget _buildList(List<DebtModel> list, double total, String type, bool isDark) {
    final color = type == 'qarzdor' ? AppTheme.primaryGreen : const Color(0xFFFF4757);
    final cardBg = isDark ? const Color(0xFF131929) : Colors.white;

    return RefreshIndicator(
      onRefresh: _loadDebts,
      color: AppTheme.primaryGreen,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Jami
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.25)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  type == 'qarzdor' ? 'Jami olishim kerak' : 'Jami qaytarishim kerak',
                  style: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280), fontSize: 13),
                ),
                Text(
                  '${AppUtils.formatAmount(total)} so\'m',
                  style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (list.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
              child: Center(
                child: Text(
                  type == 'qarzdor' ? 'Qarzdorlar yo\'q' : 'Qarzlar yo\'q',
                  style: TextStyle(color: isDark ? const Color(0xFF4A5568) : const Color(0xFF9CA3AF)),
                ),
              ),
            )
          else
            ...list.map((debt) => _buildDebtCard(debt, color, cardBg, isDark)),
        ],
      ),
    );
  }

  Widget _buildDebtCard(DebtModel debt, Color color, Color cardBg, bool isDark) {
    final progress = debt.amount > 0 ? (debt.paidAmount / debt.amount).clamp(0.0, 1.0) : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    debt.personName.isNotEmpty ? debt.personName[0].toUpperCase() : '?',
                    style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(debt.personName,
                        style: TextStyle(
                            color: isDark ? Colors.white : const Color(0xFF1A2332),
                            fontWeight: FontWeight.w700, fontSize: 15)),
                    if (debt.note != null)
                      Text(debt.note!,
                          style: TextStyle(
                              color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                              fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${AppUtils.formatAmount(debt.remainingAmount)} so\'m',
                    style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 15),
                  ),
                  if (debt.dueDate != null)
                    Text(
                      'Muddat: ${AppUtils.formatDate(debt.dueDate!)}',
                      style: const TextStyle(color: Color(0xFFFF9800), fontSize: 11),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'To\'langan: ${AppUtils.formatAmount(debt.paidAmount)} so\'m',
                style: TextStyle(
                    color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF), fontSize: 11),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () => _showPayDialog(context, debt, isDark),
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
                    child: Text('To\'lash', style: TextStyle(color: color, fontSize: 12)),
                  ),
                  TextButton(
                    onPressed: () => _markAsPaid(debt),
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
                    child: const Text('Yopish', style: TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showAddDebtDialog(BuildContext context, bool isDark) async {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    String selectedType = 'qarzdor';
    DateTime? dueDate;

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
              Text('Yangi qarz',
                  style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1A2332),
                      fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setModalState(() => selectedType = 'qarzdor'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: selectedType == 'qarzdor'
                              ? AppTheme.primaryGreen.withOpacity(0.15)
                              : (isDark ? const Color(0xFF1A2332) : const Color(0xFFF8FAFC)),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selectedType == 'qarzdor' ? AppTheme.primaryGreen : Colors.transparent,
                          ),
                        ),
                        child: Text('Qarzdor (menga qarzi bor)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: selectedType == 'qarzdor'
                                    ? AppTheme.primaryGreen
                                    : (isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF)),
                                fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setModalState(() => selectedType = 'qarz'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: selectedType == 'qarz'
                              ? const Color(0xFFFF4757).withOpacity(0.15)
                              : (isDark ? const Color(0xFF1A2332) : const Color(0xFFF8FAFC)),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selectedType == 'qarz' ? const Color(0xFFFF4757) : Colors.transparent,
                          ),
                        ),
                        child: Text('Qarz (men oldim)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: selectedType == 'qarz'
                                    ? const Color(0xFFFF4757)
                                    : (isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF)),
                                fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1A2332)),
                decoration: const InputDecoration(
                  labelText: 'Ism',
                  prefixIcon: Icon(Icons.person_rounded, color: AppTheme.primaryGreen),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1A2332)),
                decoration: const InputDecoration(
                  labelText: 'Summa',
                  prefixIcon: Icon(Icons.payments_rounded, color: AppTheme.primaryGreen),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: noteController,
                style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1A2332)),
                decoration: const InputDecoration(
                  labelText: 'Izoh (ixtiyoriy)',
                  prefixIcon: Icon(Icons.notes_rounded, color: AppTheme.primaryGreen),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final amount = double.tryParse(amountController.text.trim());
                    if (name.isEmpty || amount == null || amount <= 0) return;

                    final debt = DebtModel(
                      type: selectedType,
                      personName: name,
                      amount: amount,
                      note: noteController.text.isEmpty ? null : noteController.text,
                      date: AppUtils.dateString(DateTime.now()),
                      dueDate: dueDate != null ? AppUtils.dateString(dueDate!) : null,
                    );
                    await DatabaseHelper.instance.insertDebt(debt);
                    if (ctx.mounted) Navigator.pop(ctx);
                    _loadDebts();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('SAQLASH',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showPayDialog(BuildContext context, DebtModel debt, bool isDark) async {
    final amountController = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF131929) : Colors.white,
        title: Text('To\'lov qo\'shish',
            style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1A2332))),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1A2332)),
          decoration: const InputDecoration(labelText: 'To\'langan summa'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Bekor')),
          TextButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text.trim());
              if (amount == null || amount <= 0) return;
              await DatabaseHelper.instance.updateDebtPayment(debt.id!, debt.paidAmount + amount);
              if (ctx.mounted) Navigator.pop(ctx);
              _loadDebts();
            },
            child: const Text('Saqlash', style: TextStyle(color: AppTheme.primaryGreen)),
          ),
        ],
      ),
    );
  }

  Future<void> _markAsPaid(DebtModel debt) async {
    await DatabaseHelper.instance.markDebtAsPaid(debt.id!);
    _loadDebts();
  }
}
