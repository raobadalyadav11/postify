import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentController extends GetxController {
  static PaymentController get instance => Get.find<PaymentController>();
  
  late Razorpay _razorpay;
  final RxBool _isProcessing = false.obs;
  
  bool get isProcessing => _isProcessing.value;
  
  @override
  void onInit() {
    super.onInit();
    _initializeRazorpay();
  }
  
  void _initializeRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }
  
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _isProcessing.value = false;
    Get.snackbar(
      'Payment Successful',
      'Thank you for your donation!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  void _handlePaymentError(PaymentFailureResponse response) {
    _isProcessing.value = false;
    Get.snackbar(
      'Payment Failed',
      response.message ?? 'Payment failed. Please try again.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  void _handleExternalWallet(ExternalWalletResponse response) {
    _isProcessing.value = false;
    Get.snackbar(
      'External Wallet',
      'Selected wallet: ${response.walletName}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  void makeDonation(double amount) {
    if (_isProcessing.value) return;
    
    _isProcessing.value = true;
    
    var options = {
      'key': 'rzp_test_1DP5mmOlF5G5ag', // Replace with your Razorpay key
      'amount': (amount * 100).toInt(), // Amount in paise
      'name': 'Postify',
      'description': 'Donation to support Postify',
      'prefill': {
        'contact': '9999999999',
        'email': 'support@postify.com'
      },
      'theme': {
        'color': '#2196F3'
      }
    };
    
    try {
      _razorpay.open(options);
    } catch (e) {
      _isProcessing.value = false;
      Get.snackbar('Error', 'Failed to open payment gateway');
    }
  }
  
  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }
}