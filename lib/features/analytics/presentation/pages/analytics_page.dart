import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_pilot/core/theme/app_colors.dart';
import 'package:money_pilot/core/utils/currency_formatter.dart';
import 'package:money_pilot/features/analytics/presentation/controllers/analytics_controller.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AnalyticsController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final cardBg = isDark ? AppColors.cardDark : AppColors.card;
    final borderCol = isDark ? AppColors.borderDark : AppColors.border;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        elevation: 0,
        title: Text(
          'Analytics',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textCol,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: controller.loadAnalyticsData,
        child: Obx(() {
          if (controller.isLoading.value && controller.monthlyExpenses.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.monthlyExpenses.isEmpty && controller.monthlyIncome.isEmpty) {
            return _buildEmptyState(isDark);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildIncomeVsExpenseCard(controller, cardBg, borderCol, textCol),
                const SizedBox(height: 16),
                _buildSpendingTrendCard(controller, cardBg, borderCol, textCol, isDark),
                const SizedBox(height: 16),
                _buildCategoryAllocationCard(controller, cardBg, borderCol, textCol, isDark),
                const SizedBox(height: 16),
                _buildWeeklySpendingCard(controller, cardBg, borderCol, textCol, isDark),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    final subTextCol = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final textCol = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart_rounded, size: 64, color: subTextCol.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            'No Analytics Data Available',
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: textCol),
          ),
          const SizedBox(height: 8),
          Text(
            'Please add transactions to see spending analytics.',
            style: GoogleFonts.outfit(fontSize: 13, color: subTextCol),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeVsExpenseCard(
    AnalyticsController controller,
    Color cardBg,
    Color borderCol,
    Color textCol,
  ) {
    final double income = controller.totalIncome.value;
    final double expense = controller.totalExpense.value;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Inflow vs Outflow',
            style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: textCol),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (income > expense ? income : expense) * 1.15,
                barTouchData: BarTouchData(enabled: true),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, _) {
                        if (val == 0) return Text('Inflow', style: GoogleFonts.outfit(fontSize: 11, color: textCol));
                        if (val == 1) return Text('Outflow', style: GoogleFonts.outfit(fontSize: 11, color: textCol));
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: income,
                        gradient: AppColors.incomeGradient,
                        width: 48,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: expense,
                        gradient: AppColors.expenseGradient,
                        width: 48,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text('Total Inflow', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 2),
                  Text(
                    CurrencyFormatter.format(income, 'USD'),
                    style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.success),
                  ),
                ],
              ),
              Column(
                children: [
                  Text('Total Outflow', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 2),
                  Text(
                    CurrencyFormatter.format(expense, 'USD'),
                    style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.error),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingTrendCard(
    AnalyticsController controller,
    Color cardBg,
    Color borderCol,
    Color textCol,
    bool isDark,
  ) {
    final trend = controller.monthlySpendingTrend;
    final months = controller.trendMonths;

    if (trend.isEmpty) return const SizedBox.shrink();

    double maxVal = 100;
    for (final v in trend) {
      if (v > maxVal) maxVal = v;
    }
    maxVal = maxVal * 1.15;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '6-Month Spending Trend',
            style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: textCol),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxVal,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, _) {
                        final idx = val.toInt();
                        if (idx >= 0 && idx < months.length) {
                          return Text(
                            months[idx],
                            style: GoogleFonts.outfit(fontSize: 10, color: textCol),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => isDark ? Colors.grey.shade900 : Colors.white,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          CurrencyFormatter.formatCompact(spot.y, 'USD'),
                          GoogleFonts.outfit(
                            color: isDark ? Colors.white : AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: AppColors.expense,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.expense.withOpacity(0.25),
                          AppColors.expense.withOpacity(0.0),
                        ],
                      ),
                    ),
                    spots: List.generate(
                      trend.length,
                      (i) => FlSpot(i.toDouble(), trend[i]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryAllocationCard(
    AnalyticsController controller,
    Color cardBg,
    Color borderCol,
    Color textCol,
    bool isDark,
  ) {
    final breakdown = controller.categoryBreakdown;
    if (breakdown.isEmpty) return const SizedBox.shrink();

    final List<PieChartSectionData> sections = [];
    final List<Widget> legendItems = [];

    final colors = [
      const Color(0xFFF59E0B),
      const Color(0xFF3B82F6),
      const Color(0xFFEC4899),
      const Color(0xFF8B5CF6),
      const Color(0xFFEF4444),
      const Color(0xFF10B981),
      const Color(0xFF06B6D4),
      const Color(0xFF6B7280),
      const Color(0xFF6366F1),
    ];

    int colorIndex = 0;
    final total = controller.totalExpense.value;

    breakdown.forEach((category, amount) {
      final color = colors[colorIndex % colors.length];
      colorIndex++;
      final percentage = total > 0 ? (amount / total * 100) : 0.0;

      sections.add(
        PieChartSectionData(
          color: color,
          value: amount,
          title: '${percentage.toStringAsFixed(0)}%',
          radius: 40,
          titleStyle: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );

      legendItems.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  category,
                  style: GoogleFonts.outfit(fontSize: 13, color: textCol, fontWeight: FontWeight.w500),
                ),
              ),
              Text(
                CurrencyFormatter.formatCompact(amount, 'USD'),
                style: GoogleFonts.outfit(fontSize: 13, color: textCol, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    });

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spending Category Allocation',
            style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: textCol),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 25,
                    sections: sections,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: legendItems,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklySpendingCard(
    AnalyticsController controller,
    Color cardBg,
    Color borderCol,
    Color textCol,
    bool isDark,
  ) {
    final weekly = controller.weeklySpending;

    double maxVal = 100;
    for (final w in weekly) {
      if (w > maxVal) maxVal = w;
    }
    maxVal = maxVal * 1.15;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Outflow Summary',
            style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: textCol),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxVal,
                barTouchData: BarTouchData(enabled: true),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, _) {
                        final idx = val.toInt();
                        if (idx >= 0 && idx < 4) {
                          return Text('Week ${idx + 1}', style: GoogleFonts.outfit(fontSize: 10, color: textCol));
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(4, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: weekly[i],
                        gradient: AppColors.expenseGradient,
                        width: 24,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
