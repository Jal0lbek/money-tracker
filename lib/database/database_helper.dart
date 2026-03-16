import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';
import '../models/account_model.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'money_tracker.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
      onOpen: (db) async {
        await _seedDefaultData(db);
      },
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE accounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        balance REAL NOT NULL DEFAULT 0,
        type TEXT NOT NULL,
        currency TEXT NOT NULL DEFAULT 'UZS',
        icon TEXT,
        color TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        account_from INTEGER,
        account_to INTEGER,
        category_id INTEGER,
        note TEXT,
        date TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        icon TEXT,
        color TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    await _seedDefaultData(db);
  }

  Future<void> _seedDefaultData(Database db) async {
    // Check if accounts already exist
    final accounts = await db.query('accounts');
    if (accounts.isEmpty) {
      // Default accounts
      await db.insert('accounts', {'name': 'Naqd', 'balance': 0, 'type': 'naqd', 'currency': 'UZS', 'icon': 'cash', 'color': '#4CAF50'});
      await db.insert('accounts', {'name': 'Karta', 'balance': 0, 'type': 'karta', 'currency': 'UZS', 'icon': 'card', 'color': '#2196F3'});
      await db.insert('accounts', {'name': 'Bank', 'balance': 0, 'type': 'bank', 'currency': 'UZS', 'icon': 'bank', 'color': '#9C27B0'});
      await db.insert('accounts', {'name': 'Valyuta', 'balance': 0, 'type': 'valyuta', 'currency': 'USD', 'icon': 'currency', 'color': '#FF9800'});
    }

    final categories = await db.query('categories');
    if (categories.isEmpty) {
      // Expense categories
      final expenseCategories = [
        {'name': 'Benzin', 'type': 'chiqim', 'icon': 'gas', 'color': '#F44336'},
        {'name': 'Ovqat', 'type': 'chiqim', 'icon': 'food', 'color': '#FF9800'},
        {'name': 'Servis', 'type': 'chiqim', 'icon': 'service', 'color': '#9C27B0'},
        {'name': 'Uy', 'type': 'chiqim', 'icon': 'home', 'color': '#2196F3'},
        {'name': 'Transport', 'type': 'chiqim', 'icon': 'transport', 'color': '#00BCD4'},
        {'name': 'Kiyim', 'type': 'chiqim', 'icon': 'clothes', 'color': '#E91E63'},
        {'name': 'Salomatlik', 'type': 'chiqim', 'icon': 'health', 'color': '#4CAF50'},
        {'name': 'Ta\'lim', 'type': 'chiqim', 'icon': 'education', 'color': '#3F51B5'},
        {'name': 'Ko\'ngilochar', 'type': 'chiqim', 'icon': 'entertainment', 'color': '#FF5722'},
        {'name': 'Boshqa', 'type': 'chiqim', 'icon': 'other', 'color': '#607D8B'},
      ];
      for (var cat in expenseCategories) {
        await db.insert('categories', cat);
      }

      // Income categories
      final incomeCategories = [
        {'name': 'Ish haqi', 'type': 'kirim', 'icon': 'salary', 'color': '#4CAF50'},
        {'name': 'Savdo', 'type': 'kirim', 'icon': 'trade', 'color': '#2196F3'},
        {'name': 'Mijoz to\'lovi', 'type': 'kirim', 'icon': 'client', 'color': '#00BCD4'},
        {'name': 'Investitsiya', 'type': 'kirim', 'icon': 'invest', 'color': '#9C27B0'},
        {'name': 'Sovg\'a', 'type': 'kirim', 'icon': 'gift', 'color': '#E91E63'},
        {'name': 'Boshqa', 'type': 'kirim', 'icon': 'other', 'color': '#607D8B'},
      ];
      for (var cat in incomeCategories) {
        await db.insert('categories', cat);
      }
    }
  }

  // ACCOUNTS
  Future<List<AccountModel>> getAccounts() async {
    final db = await database;
    final maps = await db.query('accounts');
    return maps.map((m) => AccountModel.fromMap(m)).toList();
  }

  Future<AccountModel?> getAccount(int id) async {
    final db = await database;
    final maps = await db.query('accounts', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return AccountModel.fromMap(maps.first);
  }

  Future<int> insertAccount(AccountModel account) async {
    final db = await database;
    return await db.insert('accounts', account.toMap());
  }

  Future<void> updateAccountBalance(int id, double newBalance) async {
    final db = await database;
    await db.update('accounts', {'balance': newBalance}, where: 'id = ?', whereArgs: [id]);
  }

  Future<double> getTotalBalance() async {
    final db = await database;
    final result = await db.rawQuery('SELECT SUM(balance) as total FROM accounts WHERE type != "valyuta"');
    return (result.first['total'] as num?)?.toDouble() ?? 0;
  }

  // TRANSACTIONS
  Future<int> insertTransaction(TransactionModel txn) async {
    final db = await database;

    await db.transaction((txnDb) async {
      await txnDb.insert('transactions', txn.toMap());

      if (txn.type == 'kirim' && txn.accountTo != null) {
        final acc = await getAccount(txn.accountTo!);
        if (acc != null) {
          await txnDb.update('accounts', {'balance': acc.balance + txn.amount},
              where: 'id = ?', whereArgs: [acc.id]);
        }
      } else if (txn.type == 'chiqim' && txn.accountFrom != null) {
        final acc = await getAccount(txn.accountFrom!);
        if (acc != null) {
          await txnDb.update('accounts', {'balance': acc.balance - txn.amount},
              where: 'id = ?', whereArgs: [acc.id]);
        }
      } else if (txn.type == 'otkazma') {
        if (txn.accountFrom != null) {
          final accFrom = await getAccount(txn.accountFrom!);
          if (accFrom != null) {
            await txnDb.update('accounts', {'balance': accFrom.balance - txn.amount},
                where: 'id = ?', whereArgs: [accFrom.id]);
          }
        }
        if (txn.accountTo != null) {
          final accTo = await getAccount(txn.accountTo!);
          if (accTo != null) {
            await txnDb.update('accounts', {'balance': accTo.balance + txn.amount},
                where: 'id = ?', whereArgs: [accTo.id]);
          }
        }
      }
    });

    return 0;
  }

  Future<List<TransactionModel>> getTransactions({int limit = 50, int offset = 0}) async {
    final db = await database;
    final maps = await db.query('transactions',
        orderBy: 'date DESC, created_at DESC', limit: limit, offset: offset);
    return maps.map((m) => TransactionModel.fromMap(m)).toList();
  }

  Future<List<TransactionModel>> getTransactionsByDateRange(String from, String to) async {
    final db = await database;
    final maps = await db.query('transactions',
        where: 'date >= ? AND date <= ?',
        whereArgs: [from, to],
        orderBy: 'date DESC, created_at DESC');
    return maps.map((m) => TransactionModel.fromMap(m)).toList();
  }

  Future<List<TransactionModel>> getTodayTransactions() async {
    final today = DateTime.now();
    final dateStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final db = await database;
    final maps = await db.query('transactions',
        where: 'date = ?', whereArgs: [dateStr], orderBy: 'created_at DESC');
    return maps.map((m) => TransactionModel.fromMap(m)).toList();
  }

  Future<Map<String, double>> getDailySummary(String date) async {
    final db = await database;
    final income = await db.rawQuery(
        'SELECT COALESCE(SUM(amount), 0) as total FROM transactions WHERE type = "kirim" AND date = ?', [date]);
    final expense = await db.rawQuery(
        'SELECT COALESCE(SUM(amount), 0) as total FROM transactions WHERE type = "chiqim" AND date = ?', [date]);
    return {
      'kirim': (income.first['total'] as num?)?.toDouble() ?? 0,
      'chiqim': (expense.first['total'] as num?)?.toDouble() ?? 0,
    };
  }

  Future<Map<String, double>> getRangeSummary(String from, String to) async {
    final db = await database;
    final income = await db.rawQuery(
        'SELECT COALESCE(SUM(amount), 0) as total FROM transactions WHERE type = "kirim" AND date >= ? AND date <= ?', [from, to]);
    final expense = await db.rawQuery(
        'SELECT COALESCE(SUM(amount), 0) as total FROM transactions WHERE type = "chiqim" AND date >= ? AND date <= ?', [from, to]);
    return {
      'kirim': (income.first['total'] as num?)?.toDouble() ?? 0,
      'chiqim': (expense.first['total'] as num?)?.toDouble() ?? 0,
    };
  }

  Future<List<Map<String, dynamic>>> getCategoryStats(String from, String to) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT c.name, c.color, c.icon, SUM(t.amount) as total
      FROM transactions t
      JOIN categories c ON t.category_id = c.id
      WHERE t.type = "chiqim" AND t.date >= ? AND t.date <= ?
      GROUP BY c.id
      ORDER BY total DESC
    ''', [from, to]);
  }

  Future<void> deleteTransaction(int id) async {
    final db = await database;
    // Get transaction first to reverse balance
    final maps = await db.query('transactions', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return;
    final txn = TransactionModel.fromMap(maps.first);

    await db.transaction((txnDb) async {
      await txnDb.delete('transactions', where: 'id = ?', whereArgs: [id]);
      // Reverse the balance change
      if (txn.type == 'kirim' && txn.accountTo != null) {
        final acc = await getAccount(txn.accountTo!);
        if (acc != null) await txnDb.update('accounts', {'balance': acc.balance - txn.amount}, where: 'id = ?', whereArgs: [acc.id]);
      } else if (txn.type == 'chiqim' && txn.accountFrom != null) {
        final acc = await getAccount(txn.accountFrom!);
        if (acc != null) await txnDb.update('accounts', {'balance': acc.balance + txn.amount}, where: 'id = ?', whereArgs: [acc.id]);
      }
    });
  }

  // CATEGORIES
  Future<List<CategoryModel>> getCategories({String? type}) async {
    final db = await database;
    if (type != null) {
      final maps = await db.query('categories', where: 'type = ?', whereArgs: [type]);
      return maps.map((m) => CategoryModel.fromMap(m)).toList();
    }
    final maps = await db.query('categories');
    return maps.map((m) => CategoryModel.fromMap(m)).toList();
  }

  // SETTINGS
  Future<String?> getSetting(String key) async {
    final db = await database;
    final maps = await db.query('settings', where: 'key = ?', whereArgs: [key]);
    if (maps.isEmpty) return null;
    return maps.first['value'] as String;
  }

  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert('settings', {'key': key, 'value': value},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
