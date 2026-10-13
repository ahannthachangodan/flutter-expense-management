import '../../core/constants/app_strings.dart';
import '../../domain/entities/expense.dart';

/// Data model for SQLite serialization/deserialization
class ExpenseModel extends Expense {
  const ExpenseModel({
    super.id,
    required super.title,
    required super.amount,
    required super.category,
    required super.date,
    super.description,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create a model from a SQLite row map
  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map[AppStrings.colId] as int?,
      title: map[AppStrings.colTitle] as String,
      amount: (map[AppStrings.colAmount] as num).toDouble(),
      category: map[AppStrings.colCategory] as String,
      date: DateTime.parse(map[AppStrings.colDate] as String),
      description: map[AppStrings.colDescription] as String?,
      createdAt: DateTime.parse(map[AppStrings.colCreatedAt] as String),
      updatedAt: DateTime.parse(map[AppStrings.colUpdatedAt] as String),
    );
  }

  /// Serialize to a SQLite-compatible map (excludes id for inserts)
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      AppStrings.colTitle: title,
      AppStrings.colAmount: amount,
      AppStrings.colCategory: category,
      AppStrings.colDate: date.toIso8601String(),
      AppStrings.colDescription: description,
      AppStrings.colCreatedAt: createdAt.toIso8601String(),
      AppStrings.colUpdatedAt: updatedAt.toIso8601String(),
    };
    if (id != null) {
      map[AppStrings.colId] = id;
    }
    return map;
  }

  /// Convert from domain entity to model
  factory ExpenseModel.fromEntity(Expense expense) {
    return ExpenseModel(
      id: expense.id,
      title: expense.title,
      amount: expense.amount,
      category: expense.category,
      date: expense.date,
      description: expense.description,
      createdAt: expense.createdAt,
      updatedAt: expense.updatedAt,
    );
  }
}
