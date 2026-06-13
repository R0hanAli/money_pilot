import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_pilot/core/config/app_config.dart';
import 'package:money_pilot/core/theme/app_colors.dart';
import 'package:money_pilot/core/utils/validators.dart';
import 'package:money_pilot/features/budget/presentation/controllers/budget_controller.dart';

class SetBudgetPage extends StatefulWidget {
  const SetBudgetPage({super.key});

  @override
  State<SetBudgetPage> createState() => _SetBudgetPageState();
}

class _SetBudgetPageState extends State<SetBudgetPage> {
  final _overallFormKey = GlobalKey<FormState>();
  final _overallController = TextEditingController();
  final _categoryFormKey = GlobalKey<FormState>();
  final _categoryController = TextEditingController();

  late BudgetController _budgetController;
  String _selectedCategory = AppConfig.expenseCategories.first;

  @override
  void initState() {
    super.initState();
    _budgetController = Get.find<BudgetController>();
    if (_budgetController.currentBudget.value != null) {
      _overallController.text =
          _budgetController.currentBudget.value!.totalBudget.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _overallController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _saveOverall() async {
    if (!_overallFormKey.currentState!.validate()) return;
    final amount = double.tryParse(_overallController.text.trim()) ?? 0.0;
    await _budgetController.setMonthlyBudget(amount);
    Get.snackbar('Success', 'Monthly budget updated successfully.');
  }

  Future<void> _saveCategory() async {
    if (!_categoryFormKey.currentState!.validate()) return;
    final amount = double.tryParse(_categoryController.text.trim()) ?? 0.0;
    await _budgetController.setCategoryBudget(_selectedCategory, amount);
    _categoryController.clear();
    Get.snackbar('Success', '$_selectedCategory budget allocation updated.');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDark : AppColors.primary;
    final textCol = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final subTextCol =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final cardBg = isDark ? AppColors.cardDark : AppColors.card;
    final borderCol = isDark ? AppColors.borderDark : AppColors.border;

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
          'Configure Budgets',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textCol,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Limit',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textCol,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderCol, width: 1),
              ),
              child: Form(
                key: _overallFormKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _overallController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      style: GoogleFonts.outfit(fontSize: 14, color: textCol),
                      decoration: InputDecoration(
                        labelText: 'Total Monthly Budget Limit',
                        labelStyle:
                            GoogleFonts.outfit(fontSize: 13, color: subTextCol),
                        prefixIcon: Icon(Icons.wallet_rounded,
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
                      validator: Validators.amount,
                    ),
                    const SizedBox(height: 16),
                    Obx(() => _budgetController.isLoading.value
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _saveOverall,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Update Monthly Limit',
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Category Allocations',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textCol,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderCol, width: 1),
              ),
              child: Form(
                key: _categoryFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      style: GoogleFonts.outfit(fontSize: 14, color: textCol),
                      dropdownColor: cardBg,
                      decoration: InputDecoration(
                        labelText: 'Select Category',
                        labelStyle:
                            GoogleFonts.outfit(fontSize: 13, color: subTextCol),
                        prefixIcon: Icon(Icons.category_rounded,
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
                      items: AppConfig.expenseCategories.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedCategory = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _categoryController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      style: GoogleFonts.outfit(fontSize: 14, color: textCol),
                      decoration: InputDecoration(
                        labelText: 'Limit for selected category',
                        labelStyle:
                            GoogleFonts.outfit(fontSize: 13, color: subTextCol),
                        prefixIcon: Icon(Icons.monetization_on_rounded,
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
                      validator: Validators.amount,
                    ),
                    const SizedBox(height: 16),
                    Obx(() => _budgetController.isLoading.value
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _saveCategory,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Save Category Allocation',
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
