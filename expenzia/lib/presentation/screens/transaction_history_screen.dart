import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../domain/entities/expense.dart';
import '../providers/expense_provider.dart';
import '../widgets/expense_card.dart';
import 'edit_expense_screen.dart';
import 'add_expense_screen.dart';

/// Full transaction history screen — matches Figma "Transaction History" design.
/// Groups transactions by date (Today, Yesterday, specific dates).
class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ExpenseProvider>().loadExpenses();
      }
    });
  }

  Future<void> _navigateToEdit(Expense expense) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => EditExpenseScreen(expense: expense)),
    );
    if (result == true && mounted) {
      context.read<ExpenseProvider>().loadExpenses();
    }
  }

  Future<void> _confirmDelete(Expense expense) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          AppStrings.deleteConfirm,
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text(AppStrings.deleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              AppStrings.cancel,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.expense,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final provider = context.read<ExpenseProvider>();
      final error = await provider.deleteExpense(expense.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? AppStrings.expenseDeleted),
            backgroundColor:
                error != null ? AppColors.expense : AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  /// Groups expense list by formatted date headers
  Map<String, List<Expense>> _groupByDate(List<Expense> expenses) {
    final groups = <String, List<Expense>>{};
    for (final e in expenses) {
      final key = AppFormatters.formatGroupHeader(e.date);
      groups.putIfAbsent(key, () => []).add(e);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          AppStrings.transactionHistory,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
          );
          if (result == true && mounted) {
            context.read<ExpenseProvider>().loadExpenses();
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const AppLoadingWidget(message: 'Loading transactions...');
          }

          if (provider.isEmpty) {
            return EmptyStateWidget(
              title: AppStrings.noTransactions,
              subtitle: AppStrings.noTransactionsSubtitle,
              onAction: () async {
                await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddExpenseScreen(),
                  ),
                );
              },
              actionLabel: 'Add First Transaction',
            );
          }

          final grouped = _groupByDate(provider.expenses);
          final groupKeys = grouped.keys.toList();

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => provider.loadExpenses(),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: groupKeys.length,
              itemBuilder: (context, groupIdx) {
                final key = groupKeys[groupIdx];
                final group = grouped[key]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        key,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    ...group.map(
                      (expense) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ExpenseCard(
                          expense: expense,
                          onTap: () => _navigateToEdit(expense),
                          onEdit: () => _navigateToEdit(expense),
                          onDelete: () => _confirmDelete(expense),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
