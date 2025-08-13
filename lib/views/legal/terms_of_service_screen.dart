import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('terms_of_service'.tr),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              'Terms of Service',
              'Last updated: ${DateTime.now().year}',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '1. Acceptance of Terms',
              'By accessing and using Postify, you accept and agree to be bound by the terms and provision of this agreement.',
            ),
            _buildSection(
              '2. Use License',
              'Permission is granted to temporarily use Postify for personal, non-commercial transitory viewing only.',
            ),
            _buildSection(
              '3. Disclaimer',
              'The materials on Postify are provided on an \'as is\' basis. Prachar Prashar Private Limited makes no warranties, expressed or implied.',
            ),
            _buildSection(
              '4. Limitations',
              'In no event shall Prachar Prashar Private Limited or its suppliers be liable for any damages arising out of the use or inability to use the materials on Postify.',
            ),
            _buildSection(
              '5. Accuracy of Materials',
              'The materials appearing on Postify could include technical, typographical, or photographic errors. We do not warrant that any of the materials are accurate, complete, or current.',
            ),
            _buildSection(
              '6. Links',
              'Prachar Prashar Private Limited has not reviewed all of the sites linked to our app and is not responsible for the contents of any such linked site.',
            ),
            _buildSection(
              '7. Modifications',
              'Prachar Prashar Private Limited may revise these terms of service at any time without notice. By using this app, you are agreeing to be bound by the then current version of these terms of service.',
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'copyright'.tr,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}