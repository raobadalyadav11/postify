import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _autoSaveEnabled = true;
  bool _highQualityExport = false;
  String _selectedLanguage = 'English';
  String _selectedTheme = 'System';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth > 600;
          return CustomScrollView(
            slivers: [
              _buildAppBar(context, isTablet),
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 32 : 16,
                  vertical: 24,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildGeneralSettings(isTablet),
                    const SizedBox(height: 24),
                    _buildAppearanceSettings(isTablet),
                    const SizedBox(height: 24),
                    _buildExportSettings(isTablet),
                    const SizedBox(height: 24),
                    _buildPrivacySettings(isTablet),
                    const SizedBox(height: 24),
                    _buildAboutSection(isTablet),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isTablet) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradientDecoration,
          ),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildGeneralSettings(bool isTablet) {
    return _buildSettingsCard(
      'General',
      isTablet,
      [
        _buildSwitchTile(
          'Notifications',
          'Receive app notifications',
          Icons.notifications_outlined,
          _notificationsEnabled,
          (value) => setState(() => _notificationsEnabled = value),
        ),
        _buildSwitchTile(
          'Auto Save',
          'Automatically save your work',
          Icons.save_outlined,
          _autoSaveEnabled,
          (value) => setState(() => _autoSaveEnabled = value),
        ),
        _buildDropdownTile(
          'Language',
          'App language',
          Icons.language_outlined,
          _selectedLanguage,
          ['English', 'Hindi', 'Tamil', 'Bengali'],
          (value) => setState(() => _selectedLanguage = value!),
        ),
      ],
    );
  }

  Widget _buildAppearanceSettings(bool isTablet) {
    return _buildSettingsCard(
      'Appearance',
      isTablet,
      [
        _buildDropdownTile(
          'Theme',
          'App theme preference',
          Icons.palette_outlined,
          _selectedTheme,
          ['System', 'Light', 'Dark'],
          (value) => setState(() => _selectedTheme = value!),
        ),
        _buildActionTile(
          'Font Size',
          'Adjust text size',
          Icons.text_fields_outlined,
          () => _showFontSizeDialog(),
        ),
      ],
    );
  }

  Widget _buildExportSettings(bool isTablet) {
    return _buildSettingsCard(
      'Export & Quality',
      isTablet,
      [
        _buildSwitchTile(
          'High Quality Export',
          'Export in highest quality (larger file size)',
          Icons.high_quality_outlined,
          _highQualityExport,
          (value) => setState(() => _highQualityExport = value),
        ),
        _buildActionTile(
          'Default Export Format',
          'PNG (Recommended)',
          Icons.image_outlined,
          () => _showExportFormatDialog(),
        ),
        _buildActionTile(
          'Storage Location',
          'Choose where to save exports',
          Icons.folder_outlined,
          () => _showStorageDialog(),
        ),
      ],
    );
  }

  Widget _buildPrivacySettings(bool isTablet) {
    return _buildSettingsCard(
      'Privacy & Security',
      isTablet,
      [
        _buildActionTile(
          'Clear Cache',
          'Free up storage space',
          Icons.cleaning_services_outlined,
          () => _clearCache(),
        ),
        _buildActionTile(
          'Data Usage',
          'View app data usage',
          Icons.data_usage_outlined,
          () => _showDataUsage(),
        ),
        _buildActionTile(
          'Privacy Policy',
          'Read our privacy policy',
          Icons.privacy_tip_outlined,
          () => _openPrivacyPolicy(),
        ),
      ],
    );
  }

  Widget _buildAboutSection(bool isTablet) {
    return _buildSettingsCard(
      'About',
      isTablet,
      [
        _buildInfoTile(
          'Version',
          '1.0.0',
          Icons.info_outlined,
        ),
        _buildActionTile(
          'Check for Updates',
          'Get the latest features',
          Icons.system_update_outlined,
          () => _checkForUpdates(),
        ),
        _buildActionTile(
          'Rate App',
          'Rate us on Play Store',
          Icons.star_outline,
          () => _rateApp(),
        ),
        _buildActionTile(
          'Contact Support',
          'Get help and support',
          Icons.support_outlined,
          () => _contactSupport(),
        ),
      ],
    );
  }

  Widget _buildSettingsCard(String title, bool isTablet, List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isTablet ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildDropdownTile(
    String title,
    String subtitle,
    IconData icon,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(subtitle),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        items: options.map((option) {
          return DropdownMenuItem(
            value: option,
            child: Text(option),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildInfoTile(String title, String value, IconData icon) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      trailing: Text(
        value,
        style: TextStyle(
          color: Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showFontSizeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Font Size'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Small'),
              leading: Radio<String>(
                value: 'small',
                groupValue: 'medium',
                onChanged: (value) {},
              ),
            ),
            ListTile(
              title: const Text('Medium'),
              leading: Radio<String>(
                value: 'medium',
                groupValue: 'medium',
                onChanged: (value) {},
              ),
            ),
            ListTile(
              title: const Text('Large'),
              leading: Radio<String>(
                value: 'large',
                groupValue: 'medium',
                onChanged: (value) {},
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showExportFormatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Export Format'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('PNG (Recommended)'),
              subtitle: const Text('Best quality, larger file size'),
              leading: Radio<String>(
                value: 'png',
                groupValue: 'png',
                onChanged: (value) {},
              ),
            ),
            ListTile(
              title: const Text('JPEG'),
              subtitle: const Text('Smaller file size, good quality'),
              leading: Radio<String>(
                value: 'jpeg',
                groupValue: 'png',
                onChanged: (value) {},
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showStorageDialog() {
    Get.snackbar(
      'Storage Location',
      'Storage settings updated',
      backgroundColor: AppTheme.primaryColor,
      colorText: Colors.white,
    );
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear Cache'),
        content: const Text('This will clear all cached data. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Get.snackbar(
                'Success',
                'Cache cleared successfully',
                backgroundColor: AppTheme.successColor,
                colorText: Colors.white,
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showDataUsage() {
    Get.snackbar(
      'Data Usage',
      'Total data used: 25.6 MB',
      backgroundColor: AppTheme.primaryColor,
      colorText: Colors.white,
    );
  }

  void _openPrivacyPolicy() {
    Get.snackbar(
      'Privacy Policy',
      'Opening privacy policy...',
      backgroundColor: AppTheme.primaryColor,
      colorText: Colors.white,
    );
  }

  void _checkForUpdates() {
    Get.snackbar(
      'Updates',
      'You are using the latest version',
      backgroundColor: AppTheme.successColor,
      colorText: Colors.white,
    );
  }

  void _rateApp() {
    Get.snackbar(
      'Rate App',
      'Thank you for your feedback!',
      backgroundColor: AppTheme.primaryColor,
      colorText: Colors.white,
    );
  }

  void _contactSupport() {
    Get.snackbar(
      'Support',
      'Opening support chat...',
      backgroundColor: AppTheme.primaryColor,
      colorText: Colors.white,
    );
  }
}