import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import 'package:flutter/services.dart';

class LoanSettingsView extends GetView<DashboardController> {
  const LoanSettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loan Settings'),
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
                    'Interest Rate Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRateSettings(
                    title: 'Personal Loan',
                    subtitle: 'Current rate: 10.5%',
                    initialValue: '10.5',
                    onSaved: (value) {
                      Get.snackbar(
                        'Rate Updated',
                        'Personal loan rate updated to $value%',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  ),
                  const Divider(height: 32),
                  _buildRateSettings(
                    title: 'Business Loan',
                    subtitle: 'Current rate: 8.5%',
                    initialValue: '8.5',
                    onSaved: (value) {
                      Get.snackbar(
                        'Rate Updated',
                        'Business loan rate updated to $value%',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  ),
                  const Divider(height: 32),
                  _buildRateSettings(
                    title: 'Quick Cash',
                    subtitle: 'Current rate: 12.0%',
                    initialValue: '12.0',
                    onSaved: (value) {
                      Get.snackbar(
                        'Rate Updated',
                        'Quick cash rate updated to $value%',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
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
                    'Loan Limits',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildLimitSettings(
                    title: 'Personal Loan',
                    minSubtitle: 'Minimum amount: ₹5,000',
                    maxSubtitle: 'Maximum amount: ₹500,000',
                    minInitialValue: '5000',
                    maxInitialValue: '500000',
                    onSaved: (min, max) {
                      Get.snackbar(
                        'Limits Updated',
                        'Personal loan limits updated to ₹$min - ₹$max',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  ),
                  const Divider(height: 32),
                  _buildLimitSettings(
                    title: 'Business Loan',
                    minSubtitle: 'Minimum amount: ₹50,000',
                    maxSubtitle: 'Maximum amount: ₹2,000,000',
                    minInitialValue: '50000',
                    maxInitialValue: '2000000',
                    onSaved: (min, max) {
                      Get.snackbar(
                        'Limits Updated',
                        'Business loan limits updated to ₹$min - ₹$max',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  ),
                  const Divider(height: 32),
                  _buildLimitSettings(
                    title: 'Quick Cash',
                    minSubtitle: 'Minimum amount: ₹1,000',
                    maxSubtitle: 'Maximum amount: ₹50,000',
                    minInitialValue: '1000',
                    maxInitialValue: '50000',
                    onSaved: (min, max) {
                      Get.snackbar(
                        'Limits Updated',
                        'Quick cash limits updated to ₹$min - ₹$max',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
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
                    'Tenure Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTenureSettings(
                    title: 'Personal Loan',
                    subtitle: 'Available tenures (months)',
                    options: ['3', '6', '12', '24', '36', '48', '60'],
                    selected: ['3', '6', '12', '24', '36'],
                    onChanged: (values) {
                      Get.snackbar(
                        'Tenures Updated',
                        'Personal loan tenures updated to ${values.join(", ")} months',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  ),
                  const Divider(height: 32),
                  _buildTenureSettings(
                    title: 'Business Loan',
                    subtitle: 'Available tenures (months)',
                    options: ['6', '12', '24', '36', '48', '60'],
                    selected: ['12', '24', '36'],
                    onChanged: (values) {
                      Get.snackbar(
                        'Tenures Updated',
                        'Business loan tenures updated to ${values.join(", ")} months',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  ),
                  const Divider(height: 32),
                  _buildTenureSettings(
                    title: 'Quick Cash',
                    subtitle: 'Available tenures (months)',
                    options: ['1', '2', '3', '6', '12'],
                    selected: ['1', '3', '6'],
                    onChanged: (values) {
                      Get.snackbar(
                        'Tenures Updated',
                        'Quick cash tenures updated to ${values.join(", ")} months',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRateSettings({
    required String title,
    required String subtitle,
    required String initialValue,
    required Function(String) onSaved,
  }) {
    final TextEditingController controller = TextEditingController(text: initialValue);
    
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 100,
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            decoration: InputDecoration(
              suffix: const Text('%'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () => onSaved(controller.text),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildLimitSettings({
    required String title,
    required String minSubtitle,
    required String maxSubtitle,
    required String minInitialValue,
    required String maxInitialValue,
    required Function(String, String) onSaved,
  }) {
    final TextEditingController minController = TextEditingController(text: minInitialValue);
    final TextEditingController maxController = TextEditingController(text: maxInitialValue);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    minSubtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: minController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                      prefixText: '₹ ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    maxSubtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: maxController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                      prefixText: '₹ ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => onSaved(minController.text, maxController.text),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Save Limits'),
          ),
        ),
      ],
    );
  }

  Widget _buildTenureSettings({
    required String title,
    required String subtitle,
    required List<String> options,
    required List<String> selected,
    required Function(List<String>) onChanged,
  }) {
    final selectedOptions = selected.toList();
    
    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: options.map((option) {
                final isSelected = selectedOptions.contains(option);
                
                return FilterChip(
                  label: Text('$option months'),
                  selected: isSelected,
                  onSelected: (value) {
                    setState(() {
                      if (value) {
                        selectedOptions.add(option);
                      } else {
                        selectedOptions.remove(option);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => onChanged(selectedOptions),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Save Tenures'),
              ),
            ),
          ],
        );
      },
    );
  }
} 