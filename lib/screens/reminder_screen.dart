import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../models/reminder_model.dart';
import '../database/database_helper.dart';
import '../utils/app_utils.dart';
import '../theme/app_theme.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  List<ReminderModel> _reminders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    setState(() => _loading = true);
    final reminders = await DatabaseHelper.instance.getReminders();
    setState(() {
      _reminders = reminders;
      _loading = false;
    });
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
        title: const Text('ESLATMALAR'),
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
          : _reminders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.notifications_none_rounded,
                          size: 64,
                          color: isDark ? const Color(0xFF2D3748) : const Color(0xFFE2E8F0)),
                      const SizedBox(height: 16),
                      Text('Eslatmalar yo\'q',
                          style: TextStyle(
                              color: isDark ? const Color(0xFF4A5568) : const Color(0xFF9CA3AF))),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadReminders,
                  color: AppTheme.primaryGreen,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _reminders.length,
                    itemBuilder: (context, i) {
                      final r = _reminders[i];
                      final isIncome = r.type == 'kirim';
                      final color = isIncome ? AppTheme.primaryGreen : const Color(0xFFFF4757);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: color.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48, height: 48,
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${r.dayOfMonth}',
                                    style: TextStyle(
                                        color: color, fontSize: 18, fontWeight: FontWeight.w800),
                                  ),
                                  Text('kun',
                                      style: TextStyle(color: color, fontSize: 9)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(r.title,
                                      style: TextStyle(
                                          color: isDark ? Colors.white : const Color(0xFF1A2332),
                                          fontWeight: FontWeight.w700, fontSize: 14)),
                                  Text(
                                    '${AppUtils.formatAmount(r.amount)} so\'m · '
                                    '${isIncome ? 'Kirim' : 'Chiqim'} · '
                                    'Har oy ${r.dayOfMonth}-sana',
                                    style: TextStyle(
                                        color: isDark
                                            ? const Color(0xFF6B7280)
                                            : const Color(0xFF9CA3AF),
                                        fontSize: 12),
                                  ),
                                  if (r.note != null)
                                    Text(r.note!,
                                        style: TextStyle(
                                            color: isDark
                                                ? const Color(0xFF4A5568)
                                                : const Color(0xFFD1D5DB),
                                            fontSize: 11)),
                                ],
                              ),
                            ),
                            Switch(
                              value: r.isActive,
                              activeColor: AppTheme.primaryGreen,
                              onChanged: (val) async {
                                await DatabaseHelper.instance.toggleReminder(r.id!, val);
                                _loadReminders();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Future<void> _showAddDialog(BuildContext context, bool isDark) async {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    String selectedType = 'chiqim';
    int selectedDay = 1;

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
              Text('Yangi eslatma',
                  style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1A2332),
                      fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setModalState(() => selectedType = 'kirim'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: selectedType == 'kirim'
                              ? AppTheme.primaryGreen.withOpacity(0.15)
                              : (isDark ? const Color(0xFF1A2332) : const Color(0xFFF8FAFC)),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selectedType == 'kirim'
                                ? AppTheme.primaryGreen
                                : Colors.transparent,
                          ),
                        ),
                        child: Text('Kirim',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: selectedType == 'kirim'
                                    ? AppTheme.primaryGreen
                                    : (isDark
                                        ? const Color(0xFF6B7280)
                                        : const Color(0xFF9CA3AF)),
                                fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setModalState(() => selectedType = 'chiqim'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: selectedType == 'chiqim'
                              ? const Color(0xFFFF4757).withOpacity(0.15)
                              : (isDark ? const Color(0xFF1A2332) : const Color(0xFFF8FAFC)),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selectedType == 'chiqim'
                                ? const Color(0xFFFF4757)
                                : Colors.transparent,
                          ),
                        ),
                        child: Text('Chiqim',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: selectedType == 'chiqim'
                                    ? const Color(0xFFFF4757)
                                    : (isDark
                                        ? const Color(0xFF6B7280)
                                        : const Color(0xFF9CA3AF)),
                                fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleController,
                style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1A2332)),
                decoration: const InputDecoration(
                  labelText: 'Nima uchun? (masalan: Ingliz tili kursi)',
                  prefixIcon: Icon(Icons.title_rounded, color: AppTheme.primaryGreen),
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
              Text('Oyning nechanchi sanasida?',
                  style: TextStyle(
                      color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                      fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 28,
                  itemBuilder: (ctx, i) {
                    final day = i + 1;
                    final isSelected = selectedDay == day;
                    return GestureDetector(
                      onTap: () => setModalState(() => selectedDay = day),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 40, height: 40,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryGreen
                              : (isDark ? const Color(0xFF1A2332) : const Color(0xFFF8FAFC)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text('$day',
                              style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark
                                          ? const Color(0xFF6B7280)
                                          : const Color(0xFF9CA3AF)),
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500)),
                        ),
                      ),
                    );
                  },
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
                    final title = titleController.text.trim();
                    final amount = double.tryParse(amountController.text.trim());
                    if (title.isEmpty || amount == null || amount <= 0) return;

                    final reminder = ReminderModel(
                      title: title,
                      amount: amount,
                      type: selectedType,
                      dayOfMonth: selectedDay,
                      note: noteController.text.isEmpty ? null : noteController.text,
                      createdAt: AppUtils.nowString(),
                    );
                    await DatabaseHelper.instance.insertReminder(reminder);
                    if (ctx.mounted) Navigator.pop(ctx);
                    _loadReminders();
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
