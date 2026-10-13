import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../core/widgets/error_widget.dart';
import '../providers/expense_provider.dart';
import '../widgets/expense_card.dart';
import '../widgets/total_balance_card.dart';
import '../widgets/bottom_nav_bar.dart';
import '../../domain/entities/expense.dart';
import 'add_expense_screen.dart';
import 'transaction_history_screen.dart';
import 'edit_expense_screen.dart';
import 'profile_screen.dart';

/// Main dashboard screen — matches Figma homepage design
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().loadExpenses();
    });
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Future<void> _navigateToAdd() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
    );
    if (result == true && mounted) {
      context.read<ExpenseProvider>().loadExpenses();
    }
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

  Future<void> _confirmDelete(
    BuildContext context,
    Expense expense,
  ) async {
    final provider = context.read<ExpenseProvider>();
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
      final error = await provider.deleteExpense(expense.id!);
      if (mounted) {
        _showSnackbar(
          error ?? AppStrings.expenseDeleted,
          isError: error != null,
        );
      }
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.expense : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _onNavTap(int index) {
    if (index == _currentNavIndex) return;
    setState(() => _currentNavIndex = index);

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const TransactionHistoryScreen()),
      ).then((_) => setState(() => _currentNavIndex = 0));
    } else if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      ).then((_) => setState(() => _currentNavIndex = 0));
    } else {
      setState(() => _currentNavIndex = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<ExpenseProvider>(
          builder: (context, provider, _) {
            return Column(
              children: [
                // Header
                _buildHeader(),

                // Scrollable content
                Expanded(
                  child: _buildBody(provider),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: _onNavTap,
        onAddTap: _navigateToAdd,
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        color: AppColors.primary,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_greeting,',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  AppStrings.userName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ExpenseProvider provider) {
    if (provider.isLoading) {
      return const AppLoadingWidget(message: 'Loading transactions...');
    }
    if (provider.hasError) {
      return AppErrorWidget(
        message: provider.errorMessage ?? AppStrings.loadFailed,
        onRetry: () => provider.loadExpenses(),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => provider.loadExpenses(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Balance Card
            TotalBalanceCard(
              totalBalance: provider.totalBalance,
              totalIncome: provider.totalIncome,
              totalExpenses: provider.totalExpenses,
            ),

            const SizedBox(height: 20),

            // Analytics row — Daily Average & Weekly
            _buildAnalyticsRow(provider),

            const SizedBox(height: 24),

            // Recent Transactions section
            _buildRecentTransactions(provider),

            // Extra space for FAB
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsRow(ExpenseProvider provider) {
    // Calculate daily average and weekly totals from expenses
    final now = DateTime.now();
    final dailyExpenses = provider.expenses
        .where((e) =>
            e.date.year == now.year &&
            e.date.month == now.month &&
            e.date.day == now.day)
        .fold(0.0, (sum, e) => sum + e.amount);

    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weeklyExpenses = provider.expenses
        .where((e) =>
            e.date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
            e.date.isBefore(now.add(const Duration(days: 1))))
        .fold(0.0, (sum, e) => sum + e.amount);

    return Row(
      children: [
        Expanded(
          child: _AnalyticsCard(
            label: AppStrings.dailyAverage,
            amount: dailyExpenses,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _AnalyticsCard(
            label: AppStrings.weekly,
            amount: weeklyExpenses,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactions(ExpenseProvider provider) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              AppStrings.transactionsHistory,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TransactionHistoryScreen(),
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                AppStrings.seeAll,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (provider.isEmpty)
          EmptyStateWidget(
            title: AppStrings.noTransactions,
            subtitle: AppStrings.noTransactionsSubtitle,
            onAction: _navigateToAdd,
            actionLabel: 'Add First Transaction',
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.recentExpenses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final expense = provider.recentExpenses[i];
              return ExpenseCard(
                expense: expense,
                onTap: () => _navigateToEdit(expense),
                onEdit: () => _navigateToEdit(expense),
                onDelete: () => _confirmDelete(context, expense),
              );
            },
          ),
      ],
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  final String label;
  final double amount;

  const _AnalyticsCard({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppFormatters.formatCurrencyShort(amount),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
