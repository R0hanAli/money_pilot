import 'package:get/get.dart';
import 'package:money_pilot/features/auth/presentation/bindings/auth_binding.dart';
import 'package:money_pilot/features/auth/presentation/pages/login_page.dart';
import 'package:money_pilot/features/auth/presentation/pages/register_page.dart';
import 'package:money_pilot/features/auth/presentation/pages/splash_page.dart';
import 'package:money_pilot/features/analytics/presentation/bindings/analytics_binding.dart';
import 'package:money_pilot/features/analytics/presentation/pages/analytics_page.dart';
import 'package:money_pilot/features/budget/presentation/bindings/budget_binding.dart';
import 'package:money_pilot/features/budget/presentation/pages/budget_page.dart';
import 'package:money_pilot/features/budget/presentation/pages/set_budget_page.dart';
import 'package:money_pilot/features/dashboard/presentation/bindings/dashboard_binding.dart';
import 'package:money_pilot/features/expense/presentation/bindings/expense_binding.dart';
import 'package:money_pilot/features/expense/presentation/pages/add_expense_page.dart';
import 'package:money_pilot/features/expense/presentation/pages/edit_expense_page.dart';
import 'package:money_pilot/features/expense/presentation/pages/expense_detail_page.dart';
import 'package:money_pilot/features/expense/presentation/pages/expense_list_page.dart';
import 'package:money_pilot/features/income/presentation/bindings/income_binding.dart';
import 'package:money_pilot/features/income/presentation/pages/add_income_page.dart';
import 'package:money_pilot/features/income/presentation/pages/edit_income_page.dart';
import 'package:money_pilot/features/income/presentation/pages/income_list_page.dart';
import 'package:money_pilot/features/settings/presentation/bindings/settings_binding.dart';
import 'package:money_pilot/features/settings/presentation/pages/pdf_report_page.dart';
import 'package:money_pilot/features/settings/presentation/pages/profile_page.dart';
import 'package:money_pilot/features/settings/presentation/pages/settings_page.dart';
import 'package:money_pilot/presentation/navigation/main_navigation.dart';
import 'package:money_pilot/routes/app_routes.dart';

class AppPages {
  static const initial = AppRoutes.splash;

  static final List<GetPage> pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const MainNavigation(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.addExpense,
      page: () => const AddExpensePage(),
      binding: ExpenseBinding(),
    ),
    GetPage(
      name: AppRoutes.editExpense,
      page: () => const EditExpensePage(),
      binding: ExpenseBinding(),
    ),
    GetPage(
      name: AppRoutes.expenseDetail,
      page: () => const ExpenseDetailPage(),
      binding: ExpenseBinding(),
    ),
    GetPage(
      name: AppRoutes.expenseList,
      page: () => const ExpenseListPage(),
      binding: ExpenseBinding(),
    ),
    GetPage(
      name: AppRoutes.addIncome,
      page: () => const AddIncomePage(),
      binding: IncomeBinding(),
    ),
    GetPage(
      name: AppRoutes.editIncome,
      page: () => const EditIncomePage(),
      binding: IncomeBinding(),
    ),
    GetPage(
      name: AppRoutes.incomeList,
      page: () => const IncomeListPage(),
      binding: IncomeBinding(),
    ),
    GetPage(
      name: AppRoutes.budgets,
      page: () => const BudgetPage(),
      binding: BudgetBinding(),
    ),
    GetPage(
      name: AppRoutes.setBudget,
      page: () => const SetBudgetPage(),
      binding: BudgetBinding(),
    ),
    GetPage(
      name: AppRoutes.analytics,
      page: () => const AnalyticsPage(),
      binding: AnalyticsBinding(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsPage(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfilePage(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: AppRoutes.pdfReport,
      page: () => const PdfReportPage(),
      binding: SettingsBinding(),
    ),
  ];
}
