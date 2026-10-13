import '../../core/constants/app_strings.dart';

/// Core domain entity representing a financial transaction
class Expense {
  final int? id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Whether this is an income transaction (positive money flow)
  bool get isIncome =>
      category == AppStrings.income ||
      [
        'Salary',
        'Freelance',
        'Business',
        'Investment',
      ].any((c) => category.contains(c));

  /// Whether this is an expense transaction
  bool get isExpense => !isIncome;

  /// Creates a copy with updated fields
  Expense copyWith({
    int? id,
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Expense && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Expense{id: $id, title: $title, amount: $amount, category: $category}';
}
