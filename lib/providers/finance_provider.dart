import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../models/account_model.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';

class FinanceProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<AccountModel> _accounts = [];
  List<TransactionModel> _transactions = [];
  List<TransactionModel> _todayTransactions = [];
  List<CategoryModel> _categories = [];
  Map<String, double> _todaySummary = {'kirim': 0, 'chiqim': 0};
  double _totalBalance = 0;
  bool _isLoading = false;

  List<AccountModel> get accounts => _accounts;
  List<TransactionModel> get transactions => _transactions;
  List<TransactionModel> get todayTransactions => _todayTransactions;
  List<CategoryModel> get categories => _categories;
  Map<String, double> get todaySummary => _todaySummary;
  double get totalBalance => _totalBalance;
  bool get isLoading => _isLoading;

  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();

    await Future.wait([
      _loadAccounts(),
      _loadTransactions(),
      _loadTodayTransactions(),
      _loadCategories(),
      _loadTodaySummary(),
    ]);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadAccounts() async {
    _accounts = await _db.getAccounts();
    _totalBalance = await _db.getTotalBalance();
  }

  Future<void> _loadTransactions() async {
    _transactions = await _db.getTransactions(limit: 30);
  }

  Future<void> _loadTodayTransactions() async {
    _todayTransactions = await _db.getTodayTransactions();
  }

  Future<void> _loadCategories() async {
    _categories = await _db.getCategories();
  }

  Future<void> _loadTodaySummary() async {
    final today = DateTime.now();
    final dateStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    _todaySummary = await _db.getDailySummary(dateStr);
  }

  Future<bool> addTransaction(TransactionModel txn) async {
    try {
      await _db.insertTransaction(txn);
      await loadAll();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteTransaction(int id) async {
    try {
      await _db.deleteTransaction(id);
      await loadAll();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<TransactionModel>> getTransactionsByRange(String from, String to) async {
    return await _db.getTransactionsByDateRange(from, to);
  }

  Future<Map<String, double>> getRangeSummary(String from, String to) async {
    return await _db.getRangeSummary(from, to);
  }

  Future<List<Map<String, dynamic>>> getCategoryStats(String from, String to) async {
    return await _db.getCategoryStats(from, to);
  }

  List<CategoryModel> getCategoriesByType(String type) {
    return _categories.where((c) => c.type == type).toList();
  }

  AccountModel? getAccountById(int id) {
    try {
      return _accounts.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  CategoryModel? getCategoryById(int id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
