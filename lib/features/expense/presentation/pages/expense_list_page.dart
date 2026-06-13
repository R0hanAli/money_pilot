import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_pilot/core/config/app_config.dart';
import 'package:money_pilot/core/theme/app_colors.dart';
import 'package:money_pilot/core/utils/currency_formatter.dart';
import 'package:money_pilot/core/utils/date_formatter.dart';
import 'package:money_pilot/domain/entities/expense_entity.dart';
import 'package:money_pilot/features/expense/presentation/controllers/expense_controller.dart';
import 'package:money_pilot/routes/app_routes.dart';

class ExpenseListPage extends StatelessWidget {
  const ExpenseListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ExpenseController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDark : AppColors.primary;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        elevation: 0,
        title: Text(
          'Expenses',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list_rounded, color: primary),
            onPressed: () =>
                _showFilterSheet(context, controller, isDark, primary),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: primary,
        onRefresh: controller.loadExpenses,
        child: Column(
          children: [
            _SearchBar(
                controller: controller, isDark: isDark, primary: primary),
            _CategoryChips(
                controller: controller, isDark: isDark, primary: primary),
            _SummaryCard(
                controller: controller, isDark: isDark, primary: primary),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.expenses.isEmpty) {
                  return Center(
                    child: CircularProgressIndicator(color: primary),
                  );
                }
                if (controller.filtered.isEmpty) {
                  return _EmptyState(isDark: isDark, primary: primary);
                }
                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: controller.filtered.length,
                  itemBuilder: (context, index) {
                    final expense = controller.filtered[index];
                    return _DismissibleExpenseItem(
                      expense: expense,
                      controller: controller,
                      isDark: isDark,
                      primary: primary,
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'expense_list_fab',
        onPressed: () => Get.toNamed(AppRoutes.addExpense),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'Add Expense',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _showFilterSheet(
    BuildContext context,
    ExpenseController controller,
    bool isDark,
    Color primary,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterBottomSheet(
        controller: controller,
        isDark: isDark,
        primary: primary,
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final ExpenseController controller;
  final bool isDark;
  final Color primary;

  const _SearchBar({
    required this.controller,
    required this.isDark,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        onChanged: (v) {
          controller.searchQuery.value = v;
          controller.applyFilters();
        },
        style: GoogleFonts.outfit(fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search expenses…',
          hintStyle: GoogleFonts.outfit(
            color:
                isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            fontSize: 14,
          ),
          prefixIcon: Icon(Icons.search_rounded,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
              size: 20),
          filled: true,
          fillColor: isDark ? AppColors.cardDark : AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  final ExpenseController controller;
  final bool isDark;
  final Color primary;

  const _CategoryChips({
    required this.controller,
    required this.isDark,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final categories = ['All', ...AppConfig.expenseCategories];
    return SizedBox(
      height: 48,
      child: Obx(() {
        final selectedCat = controller.selectedCategory.value;
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final cat = categories[i];
            final selected = selectedCat == cat;
            return FilterChip(
              label: Text(
                cat,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: selected
                      ? Colors.white
                      : (isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary),
                ),
              ),
              selected: selected,
              onSelected: (_) {
                controller.selectedCategory.value = cat;
                controller.applyFilters();
              },
              selectedColor: primary,
              backgroundColor: isDark ? AppColors.cardDark : AppColors.surface,
              checkmarkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: selected
                      ? primary
                      : (isDark ? AppColors.borderDark : AppColors.border),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
            );
          },
        );
      }),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final ExpenseController controller;
  final bool isDark;
  final Color primary;

  const _SummaryCard({
    required this.controller,
    required this.isDark,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            gradient: AppColors.expenseGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total (${controller.filtered.length} items)',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    CurrencyFormatter.format(controller.totalFiltered, 'USD'),
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.account_balance_wallet_rounded,
                color: Colors.white.withOpacity(0.7),
                size: 32,
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _DismissibleExpenseItem extends StatelessWidget {
  final ExpenseEntity expense;
  final ExpenseController controller;
  final bool isDark;
  final Color primary;

  const _DismissibleExpenseItem({
    required this.expense,
    required this.controller,
    required this.isDark,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(expense.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => controller.deleteExpense(expense.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 24),
      ),
      child: _ExpenseListItem(
        expense: expense,
        isDark: isDark,
        primary: primary,
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(
              'Delete Expense',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
            ),
            content: Text(
              'Are you sure you want to delete this expense?',
              style: GoogleFonts.outfit(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('Cancel', style: GoogleFonts.outfit()),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                ),
                child: Text('Delete', style: GoogleFonts.outfit()),
              ),
            ],
          ),
        ) ??
        false;
  }
}

class _ExpenseListItem extends StatelessWidget {
  final ExpenseEntity expense;
  final bool isDark;
  final Color primary;

  const _ExpenseListItem({
    required this.expense,
    required this.isDark,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor = _categoryColor(expense.category);
    final icon =
        AppConfig.categoryIcons[expense.category] ?? Icons.more_horiz_rounded;

    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.expenseDetail,
        arguments: expense,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: categoryColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: categoryColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.category,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    expense.description.isEmpty
                        ? expense.paymentMethod
                        : expense.description,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  CurrencyFormatter.format(expense.amount, 'USD'),
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.expense,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormatter.relativeDay(expense.transactionDate),
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _categoryColor(String category) {
    const map = {
      'Food': Color(0xFFF59E0B),
      'Transport': Color(0xFF3B82F6),
      'Shopping': Color(0xFFEC4899),
      'Bills': Color(0xFF8B5CF6),
      'Entertainment': Color(0xFFEF4444),
      'Education': Color(0xFF10B981),
      'Health': Color(0xFFEF4444),
      'Travel': Color(0xFF06B6D4),
      'Others': Color(0xFF6B7280),
    };
    return map[category] ?? const Color(0xFF6B7280);
  }
}

class _EmptyState extends StatelessWidget {
  final bool isDark;
  final Color primary;

  const _EmptyState({required this.isDark, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_rounded,
            size: 64,
            color:
                isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No expenses found',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to record your first expense',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBottomSheet extends StatefulWidget {
  final ExpenseController controller;
  final bool isDark;
  final Color primary;

  const _FilterBottomSheet({
    required this.controller,
    required this.isDark,
    required this.primary,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late String _selectedCategory;
  late String _selectedPaymentMethod;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.controller.selectedCategory.value;
    _selectedPaymentMethod = widget.controller.selectedPaymentMethod.value;
    _startDate = widget.controller.startDate.value;
    _endDate = widget.controller.endDate.value;
  }

  Future<void> _pickDate(bool isStart) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? now) : (_endDate ?? now),
      firstDate: DateTime(2020),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _apply() {
    widget.controller.selectedCategory.value = _selectedCategory;
    widget.controller.selectedPaymentMethod.value = _selectedPaymentMethod;
    widget.controller.startDate.value = _startDate;
    widget.controller.endDate.value = _endDate;
    widget.controller.applyFilters();
    Get.back();
  }

  void _clear() {
    widget.controller.clearFilters();
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.isDark ? AppColors.surfaceDark : Colors.white;
    final textColor =
        widget.isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final subtextColor =
        widget.isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color:
                      widget.isDark ? AppColors.borderDark : AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Filter Expenses',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Category',
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: subtextColor,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: textColor,
              ),
              dropdownColor: bg,
              decoration: _fieldDecoration(widget.isDark, widget.primary),
              items: ['All', ...AppConfig.expenseCategories]
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedCategory = v!),
            ),
            const SizedBox(height: 16),
            Text(
              'Payment Method',
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: subtextColor,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedPaymentMethod,
              style: GoogleFonts.outfit(fontSize: 14, color: textColor),
              dropdownColor: bg,
              decoration: _fieldDecoration(widget.isDark, widget.primary),
              items: ['All', ...AppConfig.paymentMethods]
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedPaymentMethod = v!),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _DatePickerField(
                    label: 'From',
                    date: _startDate,
                    isDark: widget.isDark,
                    primary: widget.primary,
                    onTap: () => _pickDate(true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DatePickerField(
                    label: 'To',
                    date: _endDate,
                    isDark: widget.isDark,
                    primary: widget.primary,
                    onTap: () => _pickDate(false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _clear,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      side: BorderSide(color: widget.primary),
                    ),
                    child: Text(
                      'Clear',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w600,
                        color: widget.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _apply,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: Text(
                      'Apply',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(bool isDark, Color primary) {
    return InputDecoration(
      filled: true,
      fillColor: isDark ? AppColors.cardDark : AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primary),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final bool isDark;
  final Color primary;
  final VoidCallback onTap;

  const _DatePickerField({
    required this.label,
    required this.date,
    required this.isDark,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded, size: 16, color: primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                date != null ? DateFormatter.formatShort(date!) : label,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: date != null
                      ? (isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary)
                      : (isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
