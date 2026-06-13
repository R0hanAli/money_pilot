import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_pilot/core/config/app_config.dart';
import 'package:money_pilot/core/theme/app_colors.dart';
import 'package:money_pilot/core/utils/date_formatter.dart';
import 'package:money_pilot/features/auth/presentation/controllers/auth_controller.dart';
import 'package:money_pilot/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:money_pilot/features/dashboard/presentation/widgets/balance_card.dart';
import 'package:money_pilot/features/dashboard/presentation/widgets/budget_overview_card.dart';
import 'package:money_pilot/features/dashboard/presentation/widgets/transaction_item.dart';
import 'package:money_pilot/routes/app_routes.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();
    final authController = Get.find<AuthController>();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final subTextCol = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Obx(() {
          final user = authController.currentUser.value;
          final name = user?.fullName.split(' ').first ?? 'User';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGreeting(),
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: subTextCol,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Hey $name!',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textCol,
                ),
              ),
            ],
          );
        }),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () => Get.toNamed(AppRoutes.pdfReport),
              icon: Icon(
                Icons.analytics_outlined,
                color: isDark ? AppColors.primaryDark : AppColors.primary,
                size: 22,
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshDashboard,
        child: Obx(() {
          if (controller.isLoading.value &&
              controller.recentExpenses.isEmpty &&
              controller.recentIncome.isEmpty &&
              controller.currentBudget.value == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final currency = controller.selectedCurrency.value;

          final combinedTransactions = <_CombinedTransaction>[];
          for (final e in controller.recentExpenses) {
            combinedTransactions.add(_CombinedTransaction(
              id: e.id,
              title: e.category,
              subtitle: e.description.isEmpty ? 'Spent on ${e.category}' : e.description,
              amount: e.amount,
              isExpense: true,
              date: e.transactionDate,
              icon: AppConfig.categoryIcons[e.category] ?? Icons.more_horiz_rounded,
              iconColor: AppColors.expense,
            ));
          }
          for (final i in controller.recentIncome) {
            combinedTransactions.add(_CombinedTransaction(
              id: i.id,
              title: i.source,
              subtitle: i.notes.isEmpty ? 'Received from ${i.source}' : i.notes,
              amount: i.amount,
              isExpense: false,
              date: i.transactionDate,
              icon: AppConfig.categoryIcons[i.source] ?? Icons.attach_money_rounded,
              iconColor: AppColors.income,
            ));
          }

          combinedTransactions.sort((a, b) => b.date.compareTo(a.date));
          final recent5 = combinedTransactions.take(5).toList();

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BalanceCard(
                  balance: controller.totalSavings.value,
                  income: controller.totalIncome.value,
                  expense: controller.totalExpense.value,
                  currency: currency,
                ),
                const SizedBox(height: 24),
                BudgetOverviewCard(
                  budget: controller.currentBudget.value,
                  currency: currency,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Transactions',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textCol,
                      ),
                    ),
                    if (recent5.isNotEmpty)
                      GestureDetector(
                        onTap: () => Get.toNamed(AppRoutes.expenseList),
                        child: Text(
                          'See All',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.primaryDark : AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (recent5.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.border,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long_rounded,
                          color: subTextCol.withOpacity(0.5),
                          size: 44,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No Transactions Yet',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textCol,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Start tracking your expenses and income.',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: subTextCol,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recent5.length,
                    itemBuilder: (context, index) {
                      final item = recent5[index];
                      return TransactionItem(
                        id: item.id,
                        title: item.title,
                        subtitle: DateFormatter.relativeDay(item.date),
                        amount: item.amount,
                        isExpense: item.isExpense,
                        icon: item.icon,
                        iconColor: item.iconColor,
                        currency: currency,
                        onDelete: () {
                          if (item.isExpense) {
                            controller.deleteExpense(item.id);
                          } else {
                            controller.deleteIncome(item.id);
                          }
                        },
                      );
                    },
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }
}

class _CombinedTransaction {
  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final bool isExpense;
  final DateTime date;
  final IconData icon;
  final Color iconColor;

  _CombinedTransaction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isExpense,
    required this.date,
    required this.icon,
    required this.iconColor,
  });
}
