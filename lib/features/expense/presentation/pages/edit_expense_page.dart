import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_pilot/core/config/app_config.dart';
import 'package:money_pilot/core/theme/app_colors.dart';
import 'package:money_pilot/core/utils/date_formatter.dart';
import 'package:money_pilot/core/utils/validators.dart';
import 'package:money_pilot/domain/entities/expense_entity.dart';
import 'package:money_pilot/features/expense/presentation/controllers/expense_controller.dart';

class EditExpensePage extends StatefulWidget {
  const EditExpensePage({super.key});

  @override
  State<EditExpensePage> createState() => _EditExpensePageState();
}

class _EditExpensePageState extends State<EditExpensePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;

  late final ExpenseEntity _originalExpense;
  late String _selectedCategory;
  late String _selectedPaymentMethod;
  late DateTime _selectedDate;

  late ExpenseController _expenseController;

  @override
  void initState() {
    super.initState();
    _expenseController = Get.find<ExpenseController>();
    _originalExpense = Get.arguments as ExpenseEntity;

    _amountController =
        TextEditingController(text: _originalExpense.amount.toStringAsFixed(2));
    _descriptionController =
        TextEditingController(text: _originalExpense.description);
    _selectedCategory = _originalExpense.category;
    _selectedPaymentMethod = _originalExpense.paymentMethod;
    _selectedDate = _originalExpense.transactionDate;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;

    final updated = _originalExpense.copyWith(
      amount: amount,
      category: _selectedCategory,
      paymentMethod: _selectedPaymentMethod,
      description: _descriptionController.text.trim(),
      transactionDate: _selectedDate,
      updatedAt: DateTime.now(),
    );

    await _expenseController.updateExpense(updated);
    Get.back();
    Get.back(
        result:
            updated); // Return updated data to detail page if popped twice or updated
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDark : AppColors.primary;
    final textCol = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final subTextCol =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final cardBg = isDark ? AppColors.cardDark : AppColors.card;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textCol),
        ),
        title: Text(
          'Edit Expense',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textCol,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Amount',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: subTextCol,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.expense,
                      ),
                      decoration: InputDecoration(
                        prefixText: '\$ ',
                        prefixStyle: GoogleFonts.outfit(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.expense,
                        ),
                        hintText: '0.00',
                        hintStyle: GoogleFonts.outfit(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.expense.withOpacity(0.4),
                        ),
                        border: InputBorder.none,
                        filled: false,
                        contentPadding: EdgeInsets.zero,
                      ),
                      validator: Validators.amount,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Category',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: textCol,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConfig.expenseCategories.map((category) {
                  final isSelected = _selectedCategory == category;
                  final icon = AppConfig.categoryIcons[category] ??
                      Icons.more_horiz_rounded;
                  return ChoiceChip(
                    avatar: Icon(
                      icon,
                      color: isSelected ? Colors.white : primary,
                      size: 16,
                    ),
                    label: Text(
                      category,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : textCol,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: primary,
                    backgroundColor: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.black.withOpacity(0.03),
                    checkmarkColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected
                            ? primary
                            : (isDark
                                ? AppColors.borderDark
                                : AppColors.border),
                      ),
                    ),
                    onSelected: (val) {
                      if (val) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Text(
                'Details',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: textCol,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                  ),
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.03)
                              : Colors.black.withOpacity(0.02),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today_rounded,
                                color: primary, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              DateFormatter.format(_selectedDate),
                              style: GoogleFonts.outfit(
                                  fontSize: 14, color: textCol),
                            ),
                            const Spacer(),
                            Icon(Icons.chevron_right_rounded,
                                color: subTextCol, size: 20),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedPaymentMethod,
                      style: GoogleFonts.outfit(fontSize: 14, color: textCol),
                      dropdownColor: cardBg,
                      decoration: InputDecoration(
                        labelText: 'Payment Method',
                        labelStyle:
                            GoogleFonts.outfit(fontSize: 13, color: subTextCol),
                        prefixIcon: Icon(Icons.payment_rounded,
                            color: primary, size: 20),
                        filled: true,
                        fillColor: isDark
                            ? Colors.white.withOpacity(0.03)
                            : Colors.black.withOpacity(0.02),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                      ),
                      items: AppConfig.paymentMethods.map((method) {
                        return DropdownMenuItem(
                          value: method,
                          child: Text(method),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedPaymentMethod = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      style: GoogleFonts.outfit(fontSize: 14, color: textCol),
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Description (Optional)',
                        labelStyle:
                            GoogleFonts.outfit(fontSize: 13, color: subTextCol),
                        prefixIcon:
                            Icon(Icons.notes_rounded, color: primary, size: 20),
                        filled: true,
                        fillColor: isDark
                            ? Colors.white.withOpacity(0.03)
                            : Colors.black.withOpacity(0.02),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Obx(() => _expenseController.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Save Changes',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )),
            ],
          ),
        ),
      ),
    );
  }
}
