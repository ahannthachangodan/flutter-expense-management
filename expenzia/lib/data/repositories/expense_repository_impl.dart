import 'package:sqflite/sqflite.dart';
import '../../core/constants/app_strings.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../database/app_database.dart';
import '../models/expense_model.dart';

/// SQLite-backed implementation of [ExpenseRepository].
class ExpenseRepositoryImpl implements ExpenseRepository {
  ExpenseRepositoryImpl._();

  static final ExpenseRepositoryImpl _instance = ExpenseRepositoryImpl._();
  static ExpenseRepositoryImpl get instance => _instance;

  Future<Database> get _db => AppDatabase.instance.database;

  @override
  Future<List<Expense>> getAllExpenses() async {
    final db = await _db;
    final result = await db.query(
      AppStrings.tableExpenses,
      orderBy: '${AppStrings.colDate} DESC, ${AppStrings.colCreatedAt} DESC',
    );
    return result.map((row) => ExpenseModel.fromMap(row)).toList();
  }

  @override
  Future<Expense?> getExpenseById(int id) async {
    final db = await _db;
    final result = await db.query(
      AppStrings.tableExpenses,
      where: '${AppStrings.colId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return ExpenseModel.fromMap(result.first);
  }

  @override
  Future<int> insertExpense(Expense expense) async {
    final db = await _db;
    final model = ExpenseModel.fromEntity(expense);
    final map = model.toMap()..remove(AppStrings.colId);
    return await db.insert(
      AppStrings.tableExpenses,
      map,
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    if (expense.id == null) {
      throw ArgumentError('Cannot update an expense without an ID');
    }
    final db = await _db;
    final model = ExpenseModel.fromEntity(expense);
    await db.update(
      AppStrings.tableExpenses,
      model.toMap(),
      where: '${AppStrings.colId} = ?',
      whereArgs: [expense.id],
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  @override
  Future<void> deleteExpense(int id) async {
    final db = await _db;
    await db.delete(
      AppStrings.tableExpenses,
      where: '${AppStrings.colId} = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<double> getTotalIncome() async {
    final db = await _db;
    // Income: categories that represent positive money flow
    final result = await db.rawQuery('''
      SELECT COALESCE(SUM(${AppStrings.colAmount}), 0) AS total
      FROM ${AppStrings.tableExpenses}
      WHERE ${AppStrings.colCategory} IN (
        'Income', 'Salary', 'Freelance', 'Business', 'Investment'
      )
      OR ${AppStrings.colCategory} LIKE '%Income%'
      OR ${AppStrings.colCategory} LIKE '%Salary%'
      OR ${AppStrings.colCategory} LIKE '%Freelance%'
      OR ${AppStrings.colCategory} LIKE '%Business%'
      OR ${AppStrings.colCategory} LIKE '%Investment%'
    ''');
    return (result.first['total'] as num? ?? 0).toDouble();
  }

  @override
  Future<double> getTotalExpenses() async {
    final db = await _db;
    // All transactions that are NOT income
    final result = await db.rawQuery('''
      SELECT COALESCE(SUM(${AppStrings.colAmount}), 0) AS total
      FROM ${AppStrings.tableExpenses}
      WHERE ${AppStrings.colCategory} NOT IN (
        'Income', 'Salary', 'Freelance', 'Business', 'Investment'
      )
      AND ${AppStrings.colCategory} NOT LIKE '%Income%'
      AND ${AppStrings.colCategory} NOT LIKE '%Salary%'
      AND ${AppStrings.colCategory} NOT LIKE '%Freelance%'
      AND ${AppStrings.colCategory} NOT LIKE '%Business%'
      AND ${AppStrings.colCategory} NOT LIKE '%Investment%'
    ''');
    return (result.first['total'] as num? ?? 0).toDouble();
  }

  @override
  Future<void> clearAll() async {
    final db = await _db;
    await db.delete(AppStrings.tableExpenses);
  }
}
