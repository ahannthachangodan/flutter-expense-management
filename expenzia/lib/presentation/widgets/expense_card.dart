import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../domain/entities/expense.dart';

/// A single transaction row card matching the Figma design style
class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ExpenseCard({
    super.key,
    required this.expense,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = expense.isIncome;
    final amountColor = isIncome ? AppColors.income : AppColors.expense;
    final amountText = AppFormatters.formatWithSign(expense.amount, isIncome);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Category icon container
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _getCategoryColor(expense.category).withValues(
                  alpha: 0.12,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getCategoryIcon(expense.category),
                color: _getCategoryColor(expense.category),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),

            // Title and date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    AppFormatters.formatGroupHeader(expense.date),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Amount and actions
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amountText,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: amountColor,
                  ),
                ),
                if (onEdit != null || onDelete != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (onEdit != null)
                        GestureDetector(
                          onTap: onEdit,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.edit_outlined,
                              size: 14,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      if (onEdit != null && onDelete != null)
                        const SizedBox(width: 6),
                      if (onDelete != null)
                        GestureDetector(
                          onTap: onDelete,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.expense.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              size: 14,
                              color: AppColors.expense,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('food') || lower.contains('dining')) {
      return Icons.restaurant_rounded;
    } else if (lower.contains('shopping')) {
      return Icons.shopping_bag_rounded;
    } else if (lower.contains('transport') || lower.contains('travel')) {
      return Icons.directions_car_rounded;
    } else if (lower.contains('entertainment')) {
      return Icons.movie_rounded;
    } else if (lower.contains('health') || lower.contains('medical')) {
      return Icons.favorite_rounded;
    } else if (lower.contains('education')) {
      return Icons.school_rounded;
    } else if (lower.contains('bills') || lower.contains('utilities')) {
      return Icons.receipt_long_rounded;
    } else if (lower.contains('transfer')) {
      return Icons.swap_horiz_rounded;
    } else if (lower.contains('salary') || lower.contains('income')) {
      return Icons.account_balance_wallet_rounded;
    } else if (lower.contains('freelance')) {
      return Icons.laptop_mac_rounded;
    } else if (lower.contains('business')) {
      return Icons.business_center_rounded;
    } else if (lower.contains('investment')) {
      return Icons.trending_up_rounded;
    } else {
      return Icons.attach_money_rounded;
    }
  }

  Color _getCategoryColor(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('food') || lower.contains('dining')) {
      return const Color(0xFFFF6B35);
    } else if (lower.contains('shopping')) {
      return const Color(0xFF9B59B6);
    } else if (lower.contains('transport') || lower.contains('travel')) {
      return const Color(0xFF3498DB);
    } else if (lower.contains('entertainment')) {
      return const Color(0xFFE91E63);
    } else if (lower.contains('health') || lower.contains('medical')) {
      return const Color(0xFFE74C3C);
    } else if (lower.contains('education')) {
      return const Color(0xFF2ECC71);
    } else if (lower.contains('bills') || lower.contains('utilities')) {
      return const Color(0xFFF39C12);
    } else if (lower.contains('transfer')) {
      return AppColors.primary;
    } else if (lower.contains('salary') ||
        lower.contains('income') ||
        lower.contains('freelance') ||
        lower.contains('business') ||
        lower.contains('investment')) {
      return AppColors.income;
    } else {
      return AppColors.textSecondary;
    }
  }
}
