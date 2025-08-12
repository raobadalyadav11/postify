import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../controllers/payment_controller.dart';
import '../../controllers/ads_controller.dart';
import '../../services/premium_service.dart';
import '../../widgets/ad_banner_widget.dart';

class DonationScreen extends StatefulWidget {
  const DonationScreen({super.key});

  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  final PaymentController _paymentController = Get.find<PaymentController>();
  final AdsController _adsController = Get.find<AdsController>();
  final PremiumService _premiumService = Get.find<PremiumService>();
  final List<double> _donationAmounts = [10, 25, 50, 100, 250, 500];
  double _selectedAmount = 50;
  final TextEditingController _customAmountController = TextEditingController();

  @override
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support Postify'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildDonationAmounts(),
                  const SizedBox(height: 24),
                  _buildCustomAmount(),
                  const SizedBox(height: 24),
                  _buildRewardedAdSection(),
                  const SizedBox(height: 32),
                  _buildDonateButton(),
                ],
              ),
            ),
          ),
          const AdBannerWidget(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.favorite,
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          const Text(
            'Support Our Work',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Help us keep Postify free and improve it with new features',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationAmounts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose Amount (₹)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2,
          ),
          itemCount: _donationAmounts.length,
          itemBuilder: (context, index) {
            final amount = _donationAmounts[index];
            final isSelected = _selectedAmount == amount;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedAmount = amount;
                  _customAmountController.clear();
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? Theme.of(context).primaryColor : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '₹${amount.toInt()}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCustomAmount() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Or Enter Custom Amount',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _customAmountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixText: '₹ ',
            hintText: 'Enter amount',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: (value) {
            if (value.isNotEmpty) {
              setState(() {
                _selectedAmount = double.tryParse(value) ?? 0;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildDonateButton() {
    return Obx(() => SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _paymentController.isProcessing ? null : _donate,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _paymentController.isProcessing
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                'Donate ₹${_selectedAmount.toInt()}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    ));
  }

  Widget _buildRewardedAdSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.video_library,
            size: 32,
            color: Colors.green,
          ),
          const SizedBox(height: 12),
          const Text(
            'Watch Ad for Premium Templates',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Watch a short video to unlock 5 premium templates for free!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          Obx(() => ElevatedButton(
            onPressed: _adsController.isRewardedAdLoaded ? _watchRewardedAd : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text(_adsController.isRewardedAdLoaded ? 'Watch Ad' : 'Loading...'),
          )),
        ],
      ),
    );
  }

  void _watchRewardedAd() {
    _adsController.showRewardedAd(
      onUserEarnedReward: (RewardItem reward) {
        _premiumService.unlockPremiumTemplates(5);
      },
    );
  }

  void _donate() {
    if (_selectedAmount <= 0) {
      Get.snackbar('Error', 'Please select a valid amount');
      return;
    }
    
    _paymentController.makeDonation(_selectedAmount);
  }
}