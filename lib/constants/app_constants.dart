class AppConstants {
  // App Info
  static const String appName = 'Postify';
  static const String appVersion = '1.0.0';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String templatesCollection = 'templates';
  static const String postersCollection = 'posters';
  
  // Poster Categories
  static const List<String> posterCategories = [
    'Political',
    'Festival',
    'General',
    'Social Media',
  ];
  
  // Political Poster Types
  static const List<String> politicalTypes = [
    'Candidate Introduction',
    'Party Symbol',
    'Voting Appeal',
    'Manifesto',
    'Polling Day Reminder',
    'Victory Celebration',
    'Rally & Event',
    'Achievements',
    'Opposition Criticism',
    'Respected Leader Tribute',
    'Constituency Maps',
    'Voter List Awareness',
    'Countdown',
    'Women Empowerment',
    'Youth-Focused',
    'Booth-Level',
  ];
  
  // Festival Types
  static const List<String> festivalTypes = [
    'Diwali',
    'Holi',
    'Eid',
    'Christmas',
    'Dussehra',
    'Ganesh Chaturthi',
    'Navratri',
    'Karva Chauth',
    'Raksha Bandhan',
  ];
  
  // Poster Formats
  static const Map<String, Map<String, int>> posterFormats = {
    'Portrait A4': {'width': 2480, 'height': 3508},
    'Portrait A3': {'width': 3508, 'height': 4961},
    'Portrait Mobile': {'width': 1080, 'height': 1920},
    'Landscape HD': {'width': 1920, 'height': 1080},
    'Facebook Cover': {'width': 1200, 'height': 628},
    'Instagram Square': {'width': 1080, 'height': 1080},
  };
  
  // Supported Languages
  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'hi': 'हिंदी',
    'bn': 'বাংলা',
    'ta': 'தமிழ்',
    'te': 'తెలుగు',
    'gu': 'ગુજરાતી',
    'mr': 'मराठी',
    'ur': 'اردو',
  };
  
  // Ad Unit IDs (Test IDs - Replace with actual IDs)
  static const String bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  
  // Razorpay Key (Test Key - Replace with actual key)
  static const String razorpayKey = 'rzp_test_1DP5mmOlF5G5ag';
}