import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/theme_controller.dart';
import '../legal/privacy_policy_screen.dart';
import '../legal/terms_of_service_screen.dart';
import '../legal/about_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('settings'.tr),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            context,
            'Appearance',
            [
              Obx(() => SwitchListTile(
                title: Text('dark_mode'.tr),
                subtitle: Text(themeController.isDarkMode ? 'Enabled' : 'Disabled'),
                value: themeController.isDarkMode,
                onChanged: (_) => themeController.toggleTheme(),
                secondary: Icon(
                  themeController.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: Theme.of(context).primaryColor,
                ),
              )),
              ListTile(
                title: Text('language'.tr),
                subtitle: Obx(() => Text(themeController.supportedLanguages[themeController.currentLanguage] ?? 'English')),
                leading: Icon(Icons.language, color: Theme.of(context).primaryColor),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showLanguageDialog(context, themeController),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            'Legal',
            [
              ListTile(
                title: Text('privacy_policy'.tr),
                leading: Icon(Icons.privacy_tip, color: Theme.of(context).primaryColor),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Get.to(() => const PrivacyPolicyScreen()),
              ),
              ListTile(
                title: Text('terms_of_service'.tr),
                leading: Icon(Icons.description, color: Theme.of(context).primaryColor),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Get.to(() => const TermsOfServiceScreen()),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            'About',
            [
              ListTile(
                title: Text('about'.tr),
                leading: Icon(Icons.info, color: Theme.of(context).primaryColor),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Get.to(() => const AboutScreen()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Card(
          child: Column(children: children),
        ),
      ],
    );
  }

  void _showLanguageDialog(BuildContext context, ThemeController themeController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('language'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: themeController.supportedLanguages.entries.map((entry) {
            return Obx(() => RadioListTile<String>(
              title: Text(entry.value),
              value: entry.key,
              groupValue: themeController.currentLanguage,
              onChanged: (value) {
                if (value != null) {
                  themeController.changeLanguage(value);
                  Get.back();
                }
              },
            ));
          }).toList(),
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
}