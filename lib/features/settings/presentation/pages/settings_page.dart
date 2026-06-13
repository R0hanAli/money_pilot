import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_pilot/core/config/app_config.dart';
import 'package:money_pilot/core/theme/app_colors.dart';
import 'package:money_pilot/core/theme/theme_controller.dart';
import 'package:money_pilot/features/auth/presentation/controllers/auth_controller.dart';
import 'package:money_pilot/features/settings/presentation/controllers/settings_controller.dart';
import 'package:money_pilot/routes/app_routes.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<SettingsController>();
    final authController = Get.find<AuthController>();
    final themeController = Get.find<ThemeController>();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDark : AppColors.primary;
    final textCol = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final subTextCol =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final cardBg = isDark ? AppColors.cardDark : AppColors.card;
    final borderCol = isDark ? AppColors.borderDark : AppColors.border;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        elevation: 0,
        title: Text(
          'Settings',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textCol,
          ),
        ),
      ),
      body: Obx(() {
        final user = authController.currentUser.value;
        final name = user?.fullName ?? 'Money Pilot User';
        final email = user?.email ?? 'user@moneypilot.com';

        final initials = name
            .trim()
            .split(' ')
            .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
            .take(2)
            .join();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderCol),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: primary.withOpacity(0.12),
                      child: Text(
                        initials,
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textCol,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            email,
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: subTextCol,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.toNamed(AppRoutes.profile),
                      icon: Icon(Icons.edit_note_rounded, color: primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('Preferences', textCol),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderCol),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading:
                          Icon(Icons.monetization_on_outlined, color: primary),
                      title: Text(
                        'Currency',
                        style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: textCol),
                      ),
                      trailing: SizedBox(
                        width: 110,
                        child: DropdownButtonFormField<String>(
                          initialValue:
                              settingsController.selectedCurrency.value,
                          dropdownColor: cardBg,
                          style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: textCol,
                              fontWeight: FontWeight.bold),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          items: AppConfig.currencies.map((c) {
                            return DropdownMenuItem(
                              value: c.code,
                              child: Text('${c.symbol} ${c.code}'),
                            );
                          }).toList(),
                          onChanged: (code) {
                            if (code != null) {
                              settingsController.updateCurrency(code);
                            }
                          },
                        ),
                      ),
                    ),
                    _buildDivider(isDark),
                    SwitchListTile(
                      value: themeController.isDark,
                      activeThumbColor: primary,
                      title: Text(
                        'Dark Theme',
                        style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: textCol),
                      ),
                      secondary: Icon(Icons.dark_mode_outlined, color: primary),
                      onChanged: (_) => themeController.toggleTheme(),
                    ),
                    _buildDivider(isDark),
                    SwitchListTile(
                      value: settingsController.biometricEnabled.value,
                      activeThumbColor: primary,
                      title: Text(
                        'Biometric Login',
                        style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: textCol),
                      ),
                      secondary:
                          Icon(Icons.fingerprint_rounded, color: primary),
                      onChanged: (val) =>
                          settingsController.toggleBiometrics(val),
                    ),
                    _buildDivider(isDark),
                    SwitchListTile(
                      value: settingsController.notificationsEnabled.value,
                      activeThumbColor: primary,
                      title: Text(
                        'Notifications',
                        style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: textCol),
                      ),
                      secondary: Icon(Icons.notifications_active_outlined,
                          color: primary),
                      onChanged: (val) =>
                          settingsController.toggleNotifications(val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('Reports', textCol),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderCol),
                ),
                child: ListTile(
                  leading: Icon(Icons.picture_as_pdf_outlined, color: primary),
                  title: Text(
                    'Export Financial Report',
                    style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: textCol),
                  ),
                  subtitle: Text(
                    'Generate PDF summaries of expenses and income',
                    style: GoogleFonts.outfit(fontSize: 11, color: subTextCol),
                  ),
                  trailing:
                      Icon(Icons.chevron_right_rounded, color: subTextCol),
                  onTap: () => Get.toNamed(AppRoutes.pdfReport),
                ),
              ),
              const SizedBox(height: 32),
              OutlinedButton.icon(
                onPressed: () => _confirmSignOut(context, authController),
                icon: const Icon(Icons.logout_rounded,
                    color: AppColors.error, size: 20),
                label: Text(
                  'Sign Out',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  side: const BorderSide(color: AppColors.error),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title, Color textColor) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      color: isDark ? AppColors.borderDark : AppColors.border,
      indent: 16,
      endIndent: 16,
    );
  }

  Future<void> _confirmSignOut(
      BuildContext context, AuthController authController) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Sign Out',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to end your current session?',
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
            child: Text('Sign Out', style: GoogleFonts.outfit()),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await authController.signOut();
    }
  }
}
