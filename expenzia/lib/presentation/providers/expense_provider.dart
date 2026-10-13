import 'package:flutter/foundation.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../data/repositories/expense_repository_impl.dart';

enum ExpenseStatus { initial, loading, loaded, error }

/// Provider managing all expense state for the application.
class ExpenseProvider extends ChangeNotifier {
  final ExpenseRepository _repository;

  ExpenseProvider({ExpenseRepository? repository})
    : _repository = repository ?? ExpenseRepositoryImpl.instance;

  // --- State ---
  List<Expense> _expenses = [];
  double _totalIncome = 0;
  double _totalExpenses = 0;
  ExpenseStatus _status = ExpenseStatus.initial;
  String? _errorMessage;
  bool _isSaving = false;

  // --- Getters ---
  List<Expense> get expenses => List.unmodifiable(_expenses);
  double get totalIncome => _totalIncome;
  double get totalExpenses => _totalExpenses;

  /// Net balance = income - expenses
  double get totalBalance => _totalIncome - _totalExpenses;

  ExpenseStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isSaving => _isSaving;
  bool get isLoading => _status == ExpenseStatus.loading;
  bool get hasError => _status == ExpenseStatus.error;
  bool get isEmpty => _expenses.isEmpty && _status == ExpenseStatus.loaded;

  /// Most recent 3 expenses for dashboard preview
  List<Expense> get recentExpenses =>
      _expenses.length > 3 ? _expenses.sublist(0, 3) : _expenses;

  // --- Load ---

  Future<void> loadExpenses() async {
    _status = ExpenseStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _expenses = await _repository.getAllExpenses();
      await _refreshTotals();
      _status = ExpenseStatus.loaded;
    } catch (e) {
      _status = ExpenseStatus.error;
      _errorMessage = 'Failed to load transactions. Please try again.';
      debugPrint('ExpenseProvider.loadExpenses error: $e');
    }
    notifyListeners();
  }

  // --- Insert ---

  /// Returns null on success, or an error message on failure.
  Future<String?> addExpense(Expense expense) async {
    if (_isSaving) return null;
    _isSaving = true;
    notifyListeners();

    final int id;
    try {
      id = await _repository.insertExpense(expense);
    } catch (e) {
      debugPrint('ExpenseProvider.addExpense error: $e');
      _isSaving = false;
      notifyListeners();
      return 'Failed to save transaction. Please try again.';
    }

    // Insert succeeded — update in-memory state and totals.
    // Any error here must NOT be reported as a save failure.
    try {
      final saved = expense.copyWith(id: id);
      _expenses.insert(0, saved);
      _expenses.sort((a, b) => b.date.compareTo(a.date));
      await _refreshTotals();
    } catch (e) {
      debugPrint('ExpenseProvider.addExpense post-insert update error: $e');
    } finally {
      _isSaving = false;
      notifyListeners();
    }
    return null;
  }

  // --- Update ---

  Future<String?> updateExpense(Expense expense) async {
    if (_isSaving) return null;
    _isSaving = true;
    notifyListeners();

    try {
      await _repository.updateExpense(expense);
    } catch (e) {
      debugPrint('ExpenseProvider.updateExpense error: $e');
      _isSaving = false;
      notifyListeners();
      return 'Failed to update transaction. Please try again.';
    }

    // Update succeeded — sync in-memory state and totals.
    // Any error here must NOT be reported as an update failure.
    try {
      final idx = _expenses.indexWhere((e) => e.id == expense.id);
      if (idx != -1) {
        _expenses[idx] = expense;
        _expenses.sort((a, b) => b.date.compareTo(a.date));
      }
      await _refreshTotals();
    } catch (e) {
      debugPrint('ExpenseProvider.updateExpense post-update sync error: $e');
    } finally {
      _isSaving = false;
      notifyListeners();
    }
    return null;
  }

  // --- Delete ---

  Future<String?> deleteExpense(int id) async {
    try {
      await _repository.deleteExpense(id);
      _expenses.removeWhere((e) => e.id == id);
      await _refreshTotals();
      notifyListeners();
      return null;
    } catch (e) {
      debugPrint('ExpenseProvider.deleteExpense error: $e');
      return 'Failed to delete transaction. Please try again.';
    }
  }

  // --- Get by ID (from cache or DB) ---

  Future<Expense?> getExpenseById(int id) async {
    final cached = _expenses.where((e) => e.id == id).firstOrNull;
    if (cached != null) return cached;
    return await _repository.getExpenseById(id);
  }

  // --- Clear All ---

  Future<String?> clearAll() async {
    try {
      await _repository.clearAll();
      _expenses.clear();
      _totalIncome = 0;
      _totalExpenses = 0;
      notifyListeners();
      return null;
    } catch (e) {
      debugPrint('ExpenseProvider.clearAll error: $e');
      return 'Failed to clear data. Please try again.';
    }
  }

  // --- Private helpers ---

  Future<void> _refreshTotals() async {
    _totalIncome = await _repository.getTotalIncome();
    _totalExpenses = await _repository.getTotalExpenses();
  }
}
