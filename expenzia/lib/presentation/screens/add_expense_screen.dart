import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/formatters.dart';
import '../../domain/entities/expense.dart';
import '../providers/expense_provider.dart';
import '../widgets/styled_dropdown.dart';

/// Add Expense screen — matches Figma "Transaction" form design.
/// Transaction type dropdown → Name → Category → Amount → Date → Save
class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  String _selectedType = AppStrings.expense;
  String? _selectedCategory;
  DateTime? _selectedDate;
  String? _dateError;

  bool _submitting = false;

  List<String> get _currentCategories => _selectedType == AppStrings.income
      ? AppStrings.incomeCategories
      : AppStrings.expenseCategories;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(2000),
      lastDate: now,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateError = null;
      });
    }
  }

  Future<void> _submit() async {
    if (_submitting) return;

    final dateErr = Validators.validateDate(_selectedDate);
    setState(() => _dateError = dateErr);

    if (!_formKey.currentState!.validate() || dateErr != null) return;

    setState(() => _submitting = true);

    final now = DateTime.now();
    final expense = Expense(
      title: _nameController.text.trim(),
      amount: double.parse(_amountController.text.trim().replaceAll(',', '')),
      category: _selectedCategory ?? _currentCategories.first,
      date: _selectedDate!,
      description: null,
      createdAt: now,
      updatedAt: now,
    );

    final provider = context.read<ExpenseProvider>();
    final error = await provider.addExpense(expense);

    if (!mounted) return;
    setState(() => _submitting = false);

    if (error != null) {
      _showSnackbar(error, isError: true);
    } else {
      _showSnackbar(AppStrings.expenseSaved);
      Navigator.pop(context, true);
    }
  }

  void _showSnackbar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppColors.expense : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
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
          AppStrings.transaction,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionLabel(AppStrings.transactionType),
                const SizedBox(height: 8),
                _buildTypeDropdown(),
                const SizedBox(height: 20),

                _buildSectionLabel(AppStrings.name),
                const SizedBox(height: 8),
                _buildNameField(),
                const SizedBox(height: 20),

                _buildSectionLabel('CATEGORY'),
                const SizedBox(height: 8),
                _buildCategoryDropdown(),
                const SizedBox(height: 20),

                _buildSectionLabel(AppStrings.amount),
                const SizedBox(height: 8),
                _buildAmountField(),
                const SizedBox(height: 20),

                _buildSectionLabel(AppStrings.date),
                const SizedBox(height: 8),
                _buildDatePicker(),

                const SizedBox(height: 40),
                _buildSaveButton(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildTypeDropdown() {
    return StyledDropdown<String>(
      value: _selectedType,
      items: [AppStrings.expense, AppStrings.income],
      itemLabel: (item) => item,
      onChanged: (val) {
        if (val != null) {
          setState(() {
            _selectedType = val;
            _selectedCategory = null;
          });
        }
      },
    );
  }

  Widget _buildCategoryDropdown() {
    return StyledDropdown<String>(
      value: _selectedCategory,
      hint: 'Select category',
      items: _currentCategories,
      itemLabel: (item) => item,
      onChanged: (val) => setState(() => _selectedCategory = val),
      validator: Validators.validateCategory,
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      validator: Validators.validateTitle,
      textCapitalization: TextCapitalization.words,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      decoration: _inputDecoration(hint: 'e.g. Netflix'),
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      validator: Validators.validateAmount,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      decoration: _inputDecoration(
        prefix: '₹ ',
        hint: '0.00',
        suffix: _amountController.text.isNotEmpty
            ? TextButton(
                onPressed: () {
                  _amountController.clear();
                  setState(() {});
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(AppStrings.clear),
              )
            : null,
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _pickDate,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _dateError != null ? AppColors.expense : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDate != null
                        ? AppFormatters.formatDisplayDate(_selectedDate!)
                        : 'Select date',
                    style: TextStyle(
                      fontSize: 15,
                      color: _selectedDate != null
                          ? AppColors.textPrimary
                          : AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
        if (_dateError != null) ...[
          const SizedBox(height: 6),
          Text(
            _dateError!,
            style: const TextStyle(color: AppColors.expense, fontSize: 12),
          ),
        ],
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _submitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _submitting
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Text(
                AppStrings.save,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    String? hint,
    String? prefix,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixText: prefix,
      prefixStyle: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      suffix: suffix,
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
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.expense, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
