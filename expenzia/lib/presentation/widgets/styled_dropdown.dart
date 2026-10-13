import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Generic styled dropdown matching the Figma input field style.
/// Shared between AddExpenseScreen and EditExpenseScreen.
class StyledDropdown<T> extends StatelessWidget {
  final T? value;
  final String? hint;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;
  final String? Function(T?)? validator;

  const StyledDropdown({
    super.key,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.value,
    this.hint,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      validator: validator,
      isExpanded: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.expense),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      hint: Text(
        hint ?? 'Select',
        style:
            const TextStyle(color: AppColors.textMuted, fontSize: 15),
      ),
      dropdownColor: AppColors.surface,
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: AppColors.textSecondary,
      ),
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(itemLabel(item)),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
