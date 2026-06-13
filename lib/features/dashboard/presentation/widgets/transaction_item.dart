import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_pilot/core/theme/app_colors.dart';

class TransactionItem extends StatelessWidget {
  const TransactionItem({
    super.key,
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isExpense,
    required this.icon,
    required this.iconColor,
    required this.currency,
    this.onTap,
    this.onDelete,
  });

  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final bool isExpense;
  final IconData icon;
  final Color iconColor;
  final String currency;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? AppColors.cardDark : AppColors.card;
    final textCol = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final subTextCol = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final borderCol = isDark ? AppColors.borderDark : AppColors.border;

    Widget itemContent = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textCol,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: subTextCol,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${isExpense ? '-' : '+'}${_formatAmount(amount)}',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isExpense ? AppColors.expense : AppColors.income,
              ),
            ),
          ],
        ),
      ),
    );

    if (onDelete != null) {
      return Dismissible(
        key: Key('transaction_$id'),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            color: AppColors.error,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.delete_sweep_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
        onDismissed: (_) {
          onDelete?.call();
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderCol, width: 1),
          ),
          child: itemContent,
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderCol, width: 1),
      ),
      child: itemContent,
    );
  }

  String _formatAmount(double amt) {
    return amt.toStringAsFixed(2);
  }
}
