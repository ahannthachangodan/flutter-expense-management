import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';

/// The main Total Balance card on the dashboard — matching Figma teal gradient card
class TotalBalanceCard extends StatelessWidget {
  final double totalBalance;
  final double totalIncome;
  final double totalExpenses;

  const TotalBalanceCard({
    super.key,
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpenses,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.cardGradientStart,
            AppColors.cardGradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Balance',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppFormatters.formatCurrency(totalBalance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _BalanceSubCard(
                  label: 'Income',
                  amount: totalIncome,
                  icon: Icons.arrow_downward_rounded,
                  isIncome: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _BalanceSubCard(
                  label: 'Expenses',
                  amount: totalExpenses,
                  icon: Icons.arrow_upward_rounded,
                  isIncome: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceSubCard extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final bool isIncome;

  const _BalanceSubCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.isIncome,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isIncome ? AppColors.income : AppColors.expense,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppFormatters.formatCurrencyShort(amount),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
