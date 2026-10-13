import '../../domain/entities/expense.dart';

/// Abstract contract for the expense data source
abstract class ExpenseRepository {
  /// Fetch all expenses ordered by date descending
  Future<List<Expense>> getAllExpenses();

  /// Fetch a single expense by its database ID
  Future<Expense?> getExpenseById(int id);

  /// Insert a new expense and return the new ID
  Future<int> insertExpense(Expense expense);

  /// Update an existing expense by ID
  Future<void> updateExpense(Expense expense);

  /// Delete an expense by ID
  Future<void> deleteExpense(int id);

  /// Calculate total income from all records
  Future<double> getTotalIncome();

  /// Calculate total expenses from all records
  Future<double> getTotalExpenses();

  /// Clear all expense records
  Future<void> clearAll();
}
