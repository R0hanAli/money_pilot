import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_pilot/core/theme/app_colors.dart';
import 'package:money_pilot/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:money_pilot/features/expense/presentation/pages/expense_list_page.dart';
import 'package:money_pilot/features/income/presentation/pages/income_list_page.dart';
import 'package:money_pilot/features/analytics/presentation/pages/analytics_page.dart';
import 'package:money_pilot/features/settings/presentation/pages/settings_page.dart';
import 'package:money_pilot/routes/app_routes.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    ExpenseListPage(),
    IncomeListPage(),
    AnalyticsPage(),
    SettingsPage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryDark : AppColors.primary;
    final backgroundColor =
        isDark ? AppColors.surfaceDark : AppColors.background;
    final unselectedColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'main_navigation_fab',
        onPressed: () => Get.toNamed(AppRoutes.addExpense),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 6,
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.border,
              width: 0.5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  isSelected: _currentIndex == 0,
                  selectedColor: primaryColor,
                  unselectedColor: unselectedColor,
                  onTap: () => _onTabTapped(0),
                ),
                _NavItem(
                  icon: Icons.receipt_rounded,
                  label: 'Expenses',
                  isSelected: _currentIndex == 1,
                  selectedColor: primaryColor,
                  unselectedColor: unselectedColor,
                  onTap: () => _onTabTapped(1),
                ),
                _NavItem(
                  icon: Icons.add_circle_rounded,
                  label: 'Income',
                  isSelected: _currentIndex == 2,
                  selectedColor: primaryColor,
                  unselectedColor: unselectedColor,
                  onTap: () => _onTabTapped(2),
                ),
                _NavItem(
                  icon: Icons.bar_chart_rounded,
                  label: 'Analytics',
                  isSelected: _currentIndex == 3,
                  selectedColor: primaryColor,
                  unselectedColor: unselectedColor,
                  onTap: () => _onTabTapped(3),
                ),
                _NavItem(
                  icon: Icons.settings_rounded,
                  label: 'Settings',
                  isSelected: _currentIndex == 4,
                  selectedColor: primaryColor,
                  unselectedColor: unselectedColor,
                  onTap: () => _onTabTapped(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.selectedColor,
    required this.unselectedColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final Color selectedColor;
  final Color unselectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? selectedColor.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? selectedColor : unselectedColor,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? selectedColor : unselectedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
