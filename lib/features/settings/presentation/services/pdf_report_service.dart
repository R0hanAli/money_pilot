import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:money_pilot/domain/entities/expense_entity.dart';
import 'package:money_pilot/domain/entities/income_entity.dart';
import 'package:money_pilot/domain/entities/budget_entity.dart';
import 'package:money_pilot/domain/entities/category_budget_entity.dart';
import 'package:money_pilot/core/utils/currency_formatter.dart';

class PdfReportService {
  PdfReportService._();

  static Future<void> generate({
    required List<ExpenseEntity> expenses,
    required List<IncomeEntity> incomes,
    required BudgetEntity? budget,
    required List<CategoryBudgetEntity> categoryBudgets,
    required String currency,
    required String month,
  }) async {
    final doc = pw.Document();
    final font = await PdfGoogleFonts.nunitoRegular();
    final fontBold = await PdfGoogleFonts.nunitoBold();
    final fontSemiBold = await PdfGoogleFonts.nunitoSemiBold();

    final totalIncome = incomes.fold(0.0, (s, i) => s + i.amount);
    final totalExpense = expenses.fold(0.0, (s, e) => s + e.amount);
    final netSavings = totalIncome - totalExpense;

    final categoryMap = <String, _CategorySummary>{};
    for (final e in expenses) {
      final existing = categoryMap[e.category];
      if (existing == null) {
        categoryMap[e.category] = _CategorySummary(
          category: e.category,
          count: 1,
          total: e.amount,
        );
      } else {
        categoryMap[e.category] = _CategorySummary(
          category: e.category,
          count: existing.count + 1,
          total: existing.total + e.amount,
        );
      }
    }

    final sortedCategories = categoryMap.values.toList()
      ..sort((a, b) => b.total.compareTo(a.total));

    final recentTransactions = <_TransactionRow>[];
    for (final e in expenses) {
      recentTransactions.add(_TransactionRow(
        date: DateFormat('dd MMM yyyy').format(e.transactionDate),
        label: e.category,
        description: e.description,
        amount: CurrencyFormatter.format(e.amount, currency),
        isExpense: true,
      ));
    }
    for (final i in incomes) {
      recentTransactions.add(_TransactionRow(
        date: DateFormat('dd MMM yyyy').format(i.transactionDate),
        label: i.source,
        description: i.notes,
        amount: CurrencyFormatter.format(i.amount, currency),
        isExpense: false,
      ));
    }
    recentTransactions.sort((a, b) => b.date.compareTo(a.date));
    final recent = recentTransactions.take(20).toList();

    final headerBlue = PdfColor.fromHex('#0D47A1');
    final lightBlue = PdfColor.fromHex('#E3F2FD');
    final rowAlt = PdfColor.fromHex('#F5F5F5');
    final incomeGreen = PdfColor.fromHex('#2E7D32');
    final expenseRed = PdfColor.fromHex('#C62828');
    final textDark = PdfColor.fromHex('#212121');
    final textGrey = PdfColor.fromHex('#757575');

    final pageMargin = pw.EdgeInsets.all(32);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pageMargin,
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: double.infinity,
              padding: pw.EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: pw.BoxDecoration(
                color: headerBlue,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Money Pilot – Financial Report',
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 18,
                          color: PdfColors.white,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        month,
                        style: pw.TextStyle(
                          font: font,
                          fontSize: 12,
                          color: PdfColor.fromHex('#E0E0E0'),
                        ),
                      ),
                    ],
                  ),
                  pw.Text(
                    'Generated: ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 10,
                      color: PdfColor.fromHex('#E0E0E0'),
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),
          ],
        ),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.center,
          padding: pw.EdgeInsets.only(top: 12),
          decoration: pw.BoxDecoration(
            border: pw.Border(
              top: pw.BorderSide(color: PdfColor.fromHex('#BDBDBD'), width: 0.5),
            ),
          ),
          child: pw.Text(
            'Generated by Money Pilot  •  Page ${context.pageNumber} of ${context.pagesCount}',
            style: pw.TextStyle(
              font: font,
              fontSize: 9,
              color: textGrey,
            ),
          ),
        ),
        build: (context) {
          final widgets = <pw.Widget>[];

          widgets.add(
            pw.Text(
              'Financial Summary',
              style: pw.TextStyle(
                font: fontBold,
                fontSize: 14,
                color: headerBlue,
              ),
            ),
          );
          widgets.add(pw.SizedBox(height: 8));

          widgets.add(
            pw.Table(
              border: pw.TableBorder.all(
                color: PdfColor.fromHex('#E0E0E0'),
                width: 0.5,
              ),
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: headerBlue),
                  children: [
                    _headerCell('Metric', fontBold),
                    _headerCell('Amount', fontBold),
                  ],
                ),
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: lightBlue),
                  children: [
                    _dataCell('Total Income', font, textDark),
                    _dataCell(
                      CurrencyFormatter.format(totalIncome, currency),
                      fontSemiBold,
                      incomeGreen,
                    ),
                  ],
                ),
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColors.white),
                  children: [
                    _dataCell('Total Expense', font, textDark),
                    _dataCell(
                      CurrencyFormatter.format(totalExpense, currency),
                      fontSemiBold,
                      expenseRed,
                    ),
                  ],
                ),
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: lightBlue),
                  children: [
                    _dataCell('Net Savings', fontBold, textDark),
                    _dataCell(
                      CurrencyFormatter.format(netSavings.abs(), currency),
                      fontBold,
                      netSavings >= 0 ? incomeGreen : expenseRed,
                    ),
                  ],
                ),
              ],
            ),
          );

          widgets.add(pw.SizedBox(height: 24));

          if (sortedCategories.isNotEmpty) {
            widgets.add(
              pw.Text(
                'Expenses by Category',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 14,
                  color: headerBlue,
                ),
              ),
            );
            widgets.add(pw.SizedBox(height: 8));

            final categoryRows = <pw.TableRow>[
              pw.TableRow(
                decoration: pw.BoxDecoration(color: headerBlue),
                children: [
                  _headerCell('Category', fontBold),
                  _headerCell('Transactions', fontBold),
                  _headerCell('Total Amount', fontBold),
                ],
              ),
            ];

            for (var i = 0; i < sortedCategories.length; i++) {
              final cat = sortedCategories[i];
              categoryRows.add(
                pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: i.isEven ? PdfColors.white : rowAlt,
                  ),
                  children: [
                    _dataCell(cat.category, font, textDark),
                    _dataCellCenter('${cat.count}', font, textDark),
                    _dataCell(
                      CurrencyFormatter.format(cat.total, currency),
                      fontSemiBold,
                      expenseRed,
                    ),
                  ],
                ),
              );
            }

            widgets.add(
              pw.Table(
                border: pw.TableBorder.all(
                  color: PdfColor.fromHex('#E0E0E0'),
                  width: 0.5,
                ),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(2),
                },
                children: categoryRows,
              ),
            );

            widgets.add(pw.SizedBox(height: 24));
          }

          if (recent.isNotEmpty) {
            widgets.add(
              pw.Text(
                'Recent Transactions (Last 20)',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 14,
                  color: headerBlue,
                ),
              ),
            );
            widgets.add(pw.SizedBox(height: 8));

            final txRows = <pw.TableRow>[
              pw.TableRow(
                decoration: pw.BoxDecoration(color: headerBlue),
                children: [
                  _headerCell('Date', fontBold),
                  _headerCell('Category/Source', fontBold),
                  _headerCell('Description', fontBold),
                  _headerCell('Amount', fontBold),
                ],
              ),
            ];

            for (var i = 0; i < recent.length; i++) {
              final tx = recent[i];
              txRows.add(
                pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: i.isEven ? PdfColors.white : rowAlt,
                  ),
                  children: [
                    _dataCell(tx.date, font, textGrey),
                    _dataCell(tx.label, font, textDark),
                    _dataCell(
                      tx.description.isEmpty ? '–' : tx.description,
                      font,
                      textGrey,
                    ),
                    _dataCell(
                      tx.amount,
                      fontSemiBold,
                      tx.isExpense ? expenseRed : incomeGreen,
                    ),
                  ],
                ),
              );
            }

            widgets.add(
              pw.Table(
                border: pw.TableBorder.all(
                  color: PdfColor.fromHex('#E0E0E0'),
                  width: 0.5,
                ),
                columnWidths: {
                  0: const pw.FlexColumnWidth(1.5),
                  1: const pw.FlexColumnWidth(1.5),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FlexColumnWidth(1.5),
                },
                children: txRows,
              ),
            );

            widgets.add(pw.SizedBox(height: 24));
          }

          if (budget != null) {
            widgets.add(
              pw.Text(
                'Budget Analysis',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 14,
                  color: headerBlue,
                ),
              ),
            );
            widgets.add(pw.SizedBox(height: 8));

            final usagePercent = budget.usagePercentage;
            final budgetColor = usagePercent >= 100
                ? expenseRed
                : usagePercent >= 80
                    ? PdfColor.fromHex('#E65100')
                    : incomeGreen;

            widgets.add(
              pw.Table(
                border: pw.TableBorder.all(
                  color: PdfColor.fromHex('#E0E0E0'),
                  width: 0.5,
                ),
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: headerBlue),
                    children: [
                      _headerCell('Budget Metric', fontBold),
                      _headerCell('Value', fontBold),
                    ],
                  ),
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: lightBlue),
                    children: [
                      _dataCell('Total Budget', font, textDark),
                      _dataCell(
                        CurrencyFormatter.format(budget.totalBudget, currency),
                        fontSemiBold,
                        textDark,
                      ),
                    ],
                  ),
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.white),
                    children: [
                      _dataCell('Used', font, textDark),
                      _dataCell(
                        CurrencyFormatter.format(budget.usedBudget, currency),
                        fontSemiBold,
                        budgetColor,
                      ),
                    ],
                  ),
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: lightBlue),
                    children: [
                      _dataCell('Remaining', font, textDark),
                      _dataCell(
                        CurrencyFormatter.format(
                            budget.remainingBudget, currency),
                        fontSemiBold,
                        budget.remainingBudget >= 0 ? incomeGreen : expenseRed,
                      ),
                    ],
                  ),
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.white),
                    children: [
                      _dataCell('Usage', font, textDark),
                      _dataCell(
                        '${usagePercent.toStringAsFixed(1)}%',
                        fontBold,
                        budgetColor,
                      ),
                    ],
                  ),
                ],
              ),
            );

            if (categoryBudgets.isNotEmpty) {
              widgets.add(pw.SizedBox(height: 16));
              widgets.add(
                pw.Text(
                  'Category Budget Breakdown',
                  style: pw.TextStyle(
                    font: fontSemiBold,
                    fontSize: 12,
                    color: headerBlue,
                  ),
                ),
              );
              widgets.add(pw.SizedBox(height: 8));

              final cbRows = <pw.TableRow>[
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: headerBlue),
                  children: [
                    _headerCell('Category', fontBold),
                    _headerCell('Allocated', fontBold),
                    _headerCell('Spent', fontBold),
                    _headerCell('Remaining', fontBold),
                    _headerCell('Usage %', fontBold),
                  ],
                ),
              ];

              for (var i = 0; i < categoryBudgets.length; i++) {
                final cb = categoryBudgets[i];
                final pct = cb.spentPercentage;
                final color = pct >= 100
                    ? expenseRed
                    : pct >= 80
                        ? PdfColor.fromHex('#E65100')
                        : incomeGreen;
                cbRows.add(
                  pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: i.isEven ? PdfColors.white : rowAlt,
                    ),
                    children: [
                      _dataCell(cb.category, font, textDark),
                      _dataCell(
                        CurrencyFormatter.format(cb.allocatedAmount, currency),
                        font,
                        textDark,
                      ),
                      _dataCell(
                        CurrencyFormatter.format(cb.spentAmount, currency),
                        fontSemiBold,
                        color,
                      ),
                      _dataCell(
                        CurrencyFormatter.format(
                            cb.remainingAmount.abs(), currency),
                        font,
                        cb.remainingAmount >= 0 ? incomeGreen : expenseRed,
                      ),
                      _dataCellCenter(
                        '${pct.toStringAsFixed(1)}%',
                        fontSemiBold,
                        color,
                      ),
                    ],
                  ),
                );
              }

              widgets.add(
                pw.Table(
                  border: pw.TableBorder.all(
                    color: PdfColor.fromHex('#E0E0E0'),
                    width: 0.5,
                  ),
                  children: cbRows,
                ),
              );
            }
          }

          return widgets;
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await doc.save(),
      filename:
          'money_pilot_report_${month.replaceAll(' ', '_').toLowerCase()}.pdf',
    );
  }

  static pw.Widget _headerCell(String text, pw.Font font) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: 10,
          color: PdfColors.white,
        ),
      ),
    );
  }

  static pw.Widget _dataCell(String text, pw.Font font, PdfColor color) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: 9,
          color: color,
        ),
      ),
    );
  }

  static pw.Widget _dataCellCenter(String text, pw.Font font, PdfColor color) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          font: font,
          fontSize: 9,
          color: color,
        ),
      ),
    );
  }
}

class _CategorySummary {
  final String category;
  final int count;
  final double total;

  const _CategorySummary({
    required this.category,
    required this.count,
    required this.total,
  });
}

class _TransactionRow {
  final String date;
  final String label;
  final String description;
  final String amount;
  final bool isExpense;

  const _TransactionRow({
    required this.date,
    required this.label,
    required this.description,
    required this.amount,
    required this.isExpense,
  });
}
