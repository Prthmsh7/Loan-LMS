import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';

class SecuritySettingsView extends GetView<DashboardController> {
  const SecuritySettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => Get.offNamed('/dashboard'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Password Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPasswordTextField(
                    label: 'Current Password',
                    hint: 'Enter your current password',
                  ),
                  const SizedBox(height: 16),
                  _buildPasswordTextField(
                    label: 'New Password',
                    hint: 'Enter your new password',
                  ),
                  const SizedBox(height: 16),
                  _buildPasswordTextField(
                    label: 'Confirm New Password',
                    hint: 'Confirm your new password',
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.snackbar(
                          'Password Updated',
                          'Your password has been updated successfully',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Update Password'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Two-Factor Authentication',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Enable Two-Factor Authentication'),
                    subtitle: const Text('Enhance your account security with an additional verification step'),
                    value: false,
                    onChanged: (value) {
                      Get.snackbar(
                        'Two-Factor Authentication',
                        value ? 'Enabled successfully' : 'Disabled successfully',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'When enabled, you will need to enter a verification code from your authentication app each time you log in.',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Session Management',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Auto Logout'),
                    subtitle: const Text('Automatically log out after inactivity'),
                    trailing: DropdownButton<String>(
                      value: '30 minutes',
                      onChanged: (value) {
                        Get.snackbar(
                          'Auto Logout',
                          'Set to $value',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                      items: const [
                        DropdownMenuItem(value: '15 minutes', child: Text('15 minutes')),
                        DropdownMenuItem(value: '30 minutes', child: Text('30 minutes')),
                        DropdownMenuItem(value: '1 hour', child: Text('1 hour')),
                        DropdownMenuItem(value: 'Never', child: Text('Never')),
                      ],
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Active Sessions'),
                    subtitle: const Text('Current device is the only active session'),
                    trailing: TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Active Sessions'),
                              content: const SizedBox(
                                width: double.maxFinite,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: Icon(Icons.laptop),
                                      title: Text('Current Device'),
                                      subtitle: Text('Last active: Just now'),
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Close'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Get.snackbar(
                                      'Sessions Terminated',
                                      'All other sessions have been terminated',
                                      snackPosition: SnackPosition.BOTTOM,
                                    );
                                  },
                                  child: const Text('Logout All'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: const Text('View All'),
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

  Widget _buildPasswordTextField({
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          obscureText: true,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
} 