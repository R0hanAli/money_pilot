import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_pilot/core/theme/app_colors.dart';
import 'package:money_pilot/core/utils/currency_formatter.dart';
import 'package:money_pilot/domain/entities/budget_entity.dart';
import 'package:money_pilot/routes/app_routes.dart';

class BudgetOverviewCard extends StatelessWidget {
  const BudgetOverviewCard({
    super.key,
    required this.budget,
    required this.currency,
  });

  final BudgetEntity? budget;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? AppColors.cardDark : AppColors.card;
    final textCol = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final subTextCol =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final borderCol = isDark ? AppColors.borderDark : AppColors.border;

    if (budget == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderCol, width: 1),
        ),
        child: Column(
          children: [
            Icon(
              Icons.donut_large_rounded,
              color: isDark ? AppColors.primaryDark : AppColors.primary,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              'No Budget Set',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textCol,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Set up a budget to keep track of your goals.',
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: subTextCol,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Get.toNamed(AppRoutes.setBudget),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Configure Budget'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                minimumSize: const Size(0, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final double usagePercent = budget!.usagePercentage;
    final double fraction = (usagePercent / 100).clamp(0.0, 1.0);

    Color progressColor;
    if (usagePercent < 50) {
      progressColor = AppColors.success;
    } else if (usagePercent < 80) {
      progressColor = AppColors.warning;
    } else {
      progressColor = AppColors.error;
    }

    final remaining = budget!.remainingBudget;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderCol, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Budget Progress',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textCol,
                ),
              ),
              GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.budgets),
                child: Text(
                  'Manage',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.primaryDark : AppColors.primary,
                  ),
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
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Remaining',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: subTextCol,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    CurrencyFormatter.format(remaining, currency),
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: remaining < 0 ? AppColors.error : textCol,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Used',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: subTextCol,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${CurrencyFormatter.format(budget!.usedBudget, currency)} / ${CurrencyFormatter.formatCompact(budget!.totalBudget, currency)}',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textCol,
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
}
