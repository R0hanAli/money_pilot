import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense_model.dart';
import '../models/income_model.dart';
import '../models/budget_model.dart';
import '../models/category_budget_model.dart';
import '../models/sync_queue_model.dart';
import '../models/user_model.dart';

class LocalDatabase {
  static const String _dbName = 'money_pilot.db';
  static const int _version = 1;

  static LocalDatabase? _instance;
  Database? _database;

  LocalDatabase._();

  static LocalDatabase get instance {
    _instance ??= LocalDatabase._();
    return _instance!;
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), _dbName);
    return openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        paymentMethod TEXT NOT NULL,
        description TEXT NOT NULL,
        transactionDate TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE income (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        amount REAL NOT NULL,
        source TEXT NOT NULL,
        notes TEXT NOT NULL,
        transactionDate TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE budgets (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        month TEXT NOT NULL,
        totalBudget REAL NOT NULL,
        remainingBudget REAL NOT NULL,
        usedBudget REAL NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE category_budgets (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        month TEXT NOT NULL,
        category TEXT NOT NULL,
        allocatedAmount REAL NOT NULL,
        spentAmount REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE sync_queue (
        id TEXT PRIMARY KEY,
        action TEXT NOT NULL,
        entityType TEXT NOT NULL,
        payload TEXT NOT NULL,
        syncStatus TEXT NOT NULL,
        entityId TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        fullName TEXT NOT NULL,
        email TEXT NOT NULL,
        preferredCurrency TEXT NOT NULL,
        biometricEnabled INTEGER NOT NULL,
        themeMode TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  Future<void> insertExpense(ExpenseModel expense) async {
    final db = await database;
    await db.insert(
      'expenses',
      expense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    final db = await database;
    await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<void> deleteExpense(String id) async {
    final db = await database;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<ExpenseModel>> getExpensesByUser(String userId) async {
    final db = await database;
    final rows = await db.query(
      'expenses',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'transactionDate DESC',
    );
    return rows.map(ExpenseModel.fromMap).toList();
  }

  Future<ExpenseModel?> getExpenseById(String id) async {
    final db = await database;
    final rows = await db.query('expenses', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return ExpenseModel.fromMap(rows.first);
  }

  Future<List<ExpenseModel>> getExpensesByMonth(
      String userId, String month) async {
    final db = await database;
    final rows = await db.query(
      'expenses',
      where: 'userId = ? AND transactionDate LIKE ?',
      whereArgs: [userId, '$month%'],
      orderBy: 'transactionDate DESC',
    );
    return rows.map(ExpenseModel.fromMap).toList();
  }

  Future<List<ExpenseModel>> getExpensesByCategory(
      String userId, String category) async {
    final db = await database;
    final rows = await db.query(
      'expenses',
      where: 'userId = ? AND category = ?',
      whereArgs: [userId, category],
      orderBy: 'transactionDate DESC',
    );
    return rows.map(ExpenseModel.fromMap).toList();
  }

  Future<void> insertIncome(IncomeModel income) async {
    final db = await database;
    await db.insert(
      'income',
      income.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateIncome(IncomeModel income) async {
    final db = await database;
    await db.update(
      'income',
      income.toMap(),
      where: 'id = ?',
      whereArgs: [income.id],
    );
  }

  Future<void> deleteIncome(String id) async {
    final db = await database;
    await db.delete('income', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<IncomeModel>> getIncomeByUser(String userId) async {
    final db = await database;
    final rows = await db.query(
      'income',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'transactionDate DESC',
    );
    return rows.map(IncomeModel.fromMap).toList();
  }

  Future<List<IncomeModel>> getIncomeByMonth(
      String userId, String month) async {
    final db = await database;
    final rows = await db.query(
      'income',
      where: 'userId = ? AND transactionDate LIKE ?',
      whereArgs: [userId, '$month%'],
      orderBy: 'transactionDate DESC',
    );
    return rows.map(IncomeModel.fromMap).toList();
  }

  Future<void> upsertBudget(BudgetModel budget) async {
    final db = await database;
    await db.insert(
      'budgets',
      budget.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<BudgetModel?> getBudget(String userId, String month) async {
    final db = await database;
    final rows = await db.query(
      'budgets',
      where: 'userId = ? AND month = ?',
      whereArgs: [userId, month],
    );
    if (rows.isEmpty) return null;
    return BudgetModel.fromMap(rows.first);
  }

  Future<void> updateBudgetUsage(
      String userId, String month, double usedAmount) async {
    final db = await database;
    final existing = await getBudget(userId, month);
    if (existing == null) return;
    final remaining = existing.totalBudget - usedAmount;
    await db.update(
      'budgets',
      {
        'usedBudget': usedAmount,
        'remainingBudget': remaining < 0 ? 0 : remaining,
      },
      where: 'userId = ? AND month = ?',
      whereArgs: [userId, month],
    );
  }

  Future<void> upsertCategoryBudget(CategoryBudgetModel cb) async {
    final db = await database;
    await db.insert(
      'category_budgets',
      cb.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<CategoryBudgetModel>> getCategoryBudgets(
      String userId, String month) async {
    final db = await database;
    final rows = await db.query(
      'category_budgets',
      where: 'userId = ? AND month = ?',
      whereArgs: [userId, month],
    );
    return rows.map(CategoryBudgetModel.fromMap).toList();
  }

  Future<void> updateCategorySpent(
      String userId, String month, String category, double spentAmount) async {
    final db = await database;
    await db.update(
      'category_budgets',
      {'spentAmount': spentAmount},
      where: 'userId = ? AND month = ? AND category = ?',
      whereArgs: [userId, month, category],
    );
  }

  Future<void> insertSyncItem(SyncQueueModel item) async {
    final db = await database;
    await db.insert(
      'sync_queue',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<SyncQueueModel>> getPendingSyncItems() async {
    final db = await database;
    final rows = await db.query(
      'sync_queue',
      where: 'syncStatus = ?',
      whereArgs: [SyncStatus.pending.value],
      orderBy: 'createdAt ASC',
    );
    return rows.map(SyncQueueModel.fromMap).toList();
  }

  Future<void> updateSyncStatus(String id, SyncStatus status) async {
    final db = await database;
    await db.update(
      'sync_queue',
      {'syncStatus': status.value},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteSyncItem(String id) async {
    final db = await database;
    await db.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> insertUser(UserModel user) async {
    final db = await database;
    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserModel?> getUser(String id) async {
    final db = await database;
    final rows = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return UserModel.fromMap(rows.first);
  }

  Future<void> updateUser(UserModel user) async {
    final db = await database;
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }
}
