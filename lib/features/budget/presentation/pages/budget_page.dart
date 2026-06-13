import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_pilot/core/config/app_config.dart';
import 'package:money_pilot/core/theme/app_colors.dart';
import 'package:money_pilot/core/utils/currency_formatter.dart';
import 'package:money_pilot/domain/entities/category_budget_entity.dart';
import 'package:money_pilot/features/budget/presentation/controllers/budget_controller.dart';
import 'package:money_pilot/routes/app_routes.dart';

class BudgetPage extends StatelessWidget {
  const BudgetPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BudgetController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDark : AppColors.primary;
    final textCol = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final subTextCol = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final cardBg = isDark ? AppColors.cardDark : AppColors.card;
    final borderCol = isDark ? AppColors.borderDark : AppColors.border;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textCol),
        ),
        title: Text(
          'Budgets',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textCol,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Get.toNamed(AppRoutes.setBudget),
            icon: Icon(Icons.add_rounded, color: primary),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: primary,
        onRefresh: controller.loadBudgets,
        child: Obx(() {
          if (controller.isLoading.value &&
              controller.currentBudget.value == null &&
              controller.categoryBudgets.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final budget = controller.currentBudget.value;
          final categories = controller.categoryBudgets;
          final currency = controller.selectedCurrency.value;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (budget == null)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderCol),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.donut_large_rounded, color: primary, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'No Budget Set Yet',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textCol,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Set up your monthly limit to monitor expenses.',
                        style: GoogleFonts.outfit(fontSize: 13, color: subTextCol),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => Get.toNamed(AppRoutes.setBudget),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'Configure Monthly Budget',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                _buildOverallCard(budget, currency, isDark),
                const SizedBox(height: 24),
                Text(
                  'Category Budgets',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textCol,
                  ),
                ),
                const SizedBox(height: 12),
                if (categories.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderCol),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.category_rounded, color: subTextCol.withOpacity(0.5), size: 40),
                        const SizedBox(height: 12),
                        Text(
                          'No Category Budgets Configured',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textCol,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Allocate amounts to specific categories in configurations.',
                          style: GoogleFonts.outfit(fontSize: 12, color: subTextCol),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildCategoryItem(categories[index], currency, isDark);
                    },
                  ),
              ],
            ],
          );
        }),
      ),
    );
  }

  Widget _buildOverallCard(dynamic budget, String currency, bool isDark) {
    final double usage = budget.usagePercentage;
    final double fraction = (usage / 100).clamp(0.0, 1.0);
    final remaining = budget.remainingBudget;

    Color color;
    if (usage < 50) {
      color = AppColors.success;
    } else if (usage < 80) {
      color = AppColors.warning;
    } else {
      color = AppColors.error;
    }

    final cardColor = isDark ? AppColors.cardDark : AppColors.card;
    final textCol = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final subTextCol = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final borderCol = isDark ? AppColors.borderDark : AppColors.border;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Overall Budget Progress',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: textCol,
                ),
              ),
              Text(
                '${usage.toStringAsFixed(1)}%',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: fraction,
              backgroundColor: isDark ? Colors.white12 : Colors.black12,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Limit', style: GoogleFonts.outfit(fontSize: 12, color: subTextCol)),
                  const SizedBox(height: 2),
                  Text(
                    CurrencyFormatter.format(budget.totalBudget, currency),
                    style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: textCol),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Used', style: GoogleFonts.outfit(fontSize: 12, color: subTextCol)),
                  const SizedBox(height: 2),
                  Text(
                    CurrencyFormatter.format(budget.usedBudget, currency),
                    style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: textCol),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Remaining', style: GoogleFonts.outfit(fontSize: 12, color: subTextCol)),
                  const SizedBox(height: 2),
                  Text(
                    CurrencyFormatter.format(remaining, currency),
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: remaining < 0 ? AppColors.error : AppColors.success,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(CategoryBudgetEntity cb, String currency, bool isDark) {
    final double usage = cb.spentPercentage;
    final double fraction = (usage / 100).clamp(0.0, 1.0);
    final remaining = cb.remainingAmount;
    final icon = AppConfig.categoryIcons[cb.category] ?? Icons.category_rounded;

    Color color;
    if (usage < 50) {
      color = AppColors.success;
    } else if (usage < 80) {
      color = AppColors.warning;
    } else {
      color = AppColors.error;
    }

    final cardColor = isDark ? AppColors.cardDark : AppColors.card;
    final textCol = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final subTextCol = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final borderCol = isDark ? AppColors.borderDark : AppColors.border;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  cb.category,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textCol,
                  ),
                ),
              ),
              Text(
                '${usage.toStringAsFixed(0)}%',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: fraction,
              backgroundColor: isDark ? Colors.white12 : Colors.black12,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${CurrencyFormatter.format(cb.spentAmount, currency)} of ${CurrencyFormatter.formatCompact(cb.allocatedAmount, currency)}',
                style: GoogleFonts.outfit(fontSize: 12, color: subTextCol),
              ),
              Text(
                remaining < 0
                    ? 'Exceeded by ${CurrencyFormatter.format(remaining.abs(), currency)}'
                    : '${CurrencyFormatter.format(remaining, currency)} left',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: remaining < 0 ? AppColors.error : AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
