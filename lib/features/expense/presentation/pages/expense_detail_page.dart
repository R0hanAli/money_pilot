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

class ExpenseDetailPage extends StatelessWidget {
  const ExpenseDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ExpenseEntity expense = Get.arguments as ExpenseEntity;
    final controller = Get.find<ExpenseController>();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDark : AppColors.primary;
    final textCol = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final cardBg = isDark ? AppColors.cardDark : AppColors.card;
    final borderCol = isDark ? AppColors.borderDark : AppColors.border;

    final icon =
        AppConfig.categoryIcons[expense.category] ?? Icons.more_horiz_rounded;

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
          'Transaction Details',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textCol,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () =>
                Get.toNamed(AppRoutes.editExpense, arguments: expense),
            icon: Icon(Icons.edit_rounded, color: primary),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: borderCol, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.expense.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: AppColors.expense,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    expense.category,
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textCol,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Expense',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.expense,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '-${CurrencyFormatter.format(expense.amount, 'USD')}',
                    style: GoogleFonts.outfit(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppColors.expense,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderCol, width: 1),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    label: 'Payment Method',
                    value: expense.paymentMethod,
                    icon: Icons.payment_rounded,
                    isDark: isDark,
                    primary: primary,
                  ),
                  const Divider(height: 32, thickness: 1),
                  _buildDetailRow(
                    label: 'Date',
                    value: DateFormatter.formatFull(expense.transactionDate),
                    icon: Icons.calendar_today_rounded,
                    isDark: isDark,
                    primary: primary,
                  ),
                  if (expense.description.isNotEmpty) ...[
                    const Divider(height: 32, thickness: 1),
                    _buildDetailRow(
                      label: 'Notes',
                      value: expense.description,
                      icon: Icons.notes_rounded,
                      isDark: isDark,
                      primary: primary,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () => _confirmDelete(context, controller, expense.id),
              icon: const Icon(Icons.delete_rounded, size: 18),
              label: const Text('Delete Transaction'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    required IconData icon,
    required bool isDark,
    required Color primary,
  }) {
    final textCol = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final subTextCol =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: primary, size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: subTextCol,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  color: textCol,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, ExpenseController controller, String id) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Delete Transaction',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete this transaction record?',
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
    );

    if (confirm == true) {
      await controller.deleteExpense(id);
      Get.back();
    }
  }
}
