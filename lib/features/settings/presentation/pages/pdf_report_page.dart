import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:money_pilot/core/theme/app_colors.dart';
import 'package:money_pilot/core/utils/date_formatter.dart';
import 'package:money_pilot/domain/entities/budget_entity.dart';
import 'package:money_pilot/domain/repositories/auth_repository.dart';
import 'package:money_pilot/domain/repositories/budget_repository.dart';
import 'package:money_pilot/domain/repositories/expense_repository.dart';
import 'package:money_pilot/domain/repositories/income_repository.dart';
import 'package:money_pilot/features/settings/presentation/services/pdf_report_service.dart';

class PdfReportPage extends StatefulWidget {
  const PdfReportPage({super.key});

  @override
  State<PdfReportPage> createState() => _PdfReportPageState();
}

class _ProfileMonthsInfo {
  final String label;
  final String key;

  _ProfileMonthsInfo({required this.label, required this.key});
}

class _PdfReportPageState extends State<PdfReportPage> {
  late final List<_ProfileMonthsInfo> _monthsList;
  late _ProfileMonthsInfo _selectedMonth;
  bool _isGenerating = false;

  late ExpenseRepository _expenseRepo;
  late IncomeRepository _incomeRepo;
  late BudgetRepository _budgetRepo;
  late AuthRepository _authRepo;

  @override
  void initState() {
    super.initState();
    _expenseRepo = Get.find<ExpenseRepository>();
    _incomeRepo = Get.find<IncomeRepository>();
    _budgetRepo = Get.find<BudgetRepository>();
    _authRepo = Get.find<AuthRepository>();

    final months = DateFormatter.last12Months();
    _monthsList = months.map((m) {
      return _ProfileMonthsInfo(
        label: DateFormatter.formatMonth(m),
        key: DateFormatter.formatMonthKey(m),
      );
    }).toList();

    _selectedMonth = _monthsList.last;
  }

  Future<void> _export() async {
    final userId = _authRepo.currentUserId ?? '';
    if (userId.isEmpty) return;

    setState(() {
      _isGenerating = true;
    });

    try {
      final results = await Future.wait([
        _expenseRepo.getExpensesByMonth(userId, _selectedMonth.key),
        _incomeRepo.getIncomeByMonth(userId, _selectedMonth.key),
        _budgetRepo.getBudget(userId, _selectedMonth.key),
        _budgetRepo.getCategoryBudgets(userId, _selectedMonth.key),
      ]);

      final expenses = results[0] as List;
      final incomes = results[1] as List;
      final budget = results[2] as BudgetEntity?;
      final categoryBudgets = results[3] as List;

      final prefs = await SharedPreferences.getInstance();
      final currency = prefs.getString('currency') ?? 'USD';

      await PdfReportService.generate(
        expenses: expenses.cast(),
        incomes: incomes.cast(),
        budget: budget,
        categoryBudgets: categoryBudgets.cast(),
        currency: currency,
        month: _selectedMonth.label,
      );

      Get.snackbar('Success', 'PDF report generated successfully.');
    } catch (_) {
      Get.snackbar('Error', 'Failed to generate PDF report.');
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDark : AppColors.primary;
    final textCol = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final subTextCol = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final cardBg = isDark ? AppColors.cardDark : AppColors.card;
    final borderCol = isDark ? AppColors.borderDark : AppColors.border;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textCol),
        ),
        title: Text(
          'Financial Reports',
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
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: borderCol),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.picture_as_pdf_rounded,
                    color: primary,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Export Financial Data',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textCol,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Generate a professional PDF statement including transaction summaries, budget evaluations, and category distributions.',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: subTextCol,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Select Month',
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: textCol,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderCol),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<_ProfileMonthsInfo>(
                  value: _selectedMonth,
                  isExpanded: true,
                  dropdownColor: cardBg,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: textCol,
                    fontWeight: FontWeight.w600,
                  ),
                  items: _monthsList.map((m) {
                    return DropdownMenuItem(
                      value: m,
                      child: Text(m.label),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedMonth = val;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 40),
            _isGenerating
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    onPressed: _export,
                    icon: const Icon(Icons.file_download_rounded, size: 20),
                    label: const Text('Export PDF Report'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
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
}
