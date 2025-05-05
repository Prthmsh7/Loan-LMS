import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_pages.dart';
import '../../../shared/widgets/app_logo.dart';

class AdminSettingsView extends GetView<DashboardController> {
  const AdminSettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => Get.offNamed(Routes.DASHBOARD),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Admin Profile Section
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.indigo[100],
                        radius: 30,
                        child: Icon(
                          Icons.admin_panel_settings,
                          size: 30,
                          color: Colors.indigo[700],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(() => Text(
                              authService.currentUser.value?.fullName ?? 'Admin User',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                            Obx(() => Text(
                              authService.currentUser.value?.email ?? 'admin@example.com',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            )),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Admin Access',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green[800],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  Text(
                    'Account Settings',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSettingsTile(
                    icon: Icons.security,
                    title: 'Security Settings',
                    subtitle: 'Password, login verification',
                    onTap: () => controller.navigateToSecuritySettings(),
                  ),
                  _buildSettingsTile(
                    icon: Icons.notifications,
                    title: 'Notification Settings',
                    subtitle: 'New loans, repayments, alerts',
                    onTap: () => Get.snackbar('Coming Soon', 'This feature will be available soon'),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Application Settings
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Application Settings',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSettingsTile(
                    icon: Icons.language,
                    title: 'Language',
                    subtitle: 'Change application language',
                    onTap: () => _showLanguageSelection(context),
                  ),
                  _buildSettingsTile(
                    icon: Icons.account_balance,
                    title: 'Loan Settings',
                    subtitle: 'Interest rates, loan limits',
                    onTap: () => controller.navigateToLoanSettings(),
                  ),
                  _buildSettingsTile(
                    icon: Icons.people,
                    title: 'User Approval Settings',
                    subtitle: 'KYC verification requirements',
                    onTap: () => Get.snackbar('Coming Soon', 'This feature will be available soon'),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // System Settings
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'System',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSettingsTile(
                    icon: Icons.info_outline,
                    title: 'About',
                    subtitle: 'Application version, legal information',
                    onTap: () => _showAboutDialog(context),
                  ),
                  _buildSettingsTile(
                    icon: Icons.logout,
                    title: 'Logout',
                    subtitle: 'Sign out from admin panel',
                    onTap: () => controller.logout(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.blue[700], size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showLanguageSelection(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              onTap: () {
                // Handle language change
                Get.back();
              },
            ),
            ListTile(
              title: const Text('हिन्दी (Hindi)'),
              onTap: () {
                // Handle language change
                Get.back();
              },
            ),
            ListTile(
              title: const Text('മലയാളം (Malayalam)'),
              onTap: () {
                // Handle language change
                Get.back();
              },
            ),
            ListTile(
              title: const Text('தமிழ் (Tamil)'),
              onTap: () {
                // Handle language change
                Get.back();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'LoanBee Admin',
      applicationVersion: '1.0.0',
      applicationIcon: const AppLogo(size: 40),
      applicationLegalese: '© 2023 LoanBee. All rights reserved.',
      children: [
        const SizedBox(height: 16),
        const Text(
          'LoanBee is a comprehensive loan management platform that helps '
          'financial institutions manage their loan operations efficiently.',
        ),
      ],
    );
  }
} 