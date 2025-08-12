import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> logEvent(String eventName, Map<String, dynamic> parameters) async {
    try {
      await _firestore.collection('analytics').add({
        'event': eventName,
        'parameters': parameters,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> logPosterCreated(String templateId, String category) async {
    await logEvent('poster_created', {
      'template_id': templateId,
      'category': category,
    });
  }

  Future<void> logPosterShared(String posterId, String platform) async {
    await logEvent('poster_shared', {
      'poster_id': posterId,
      'platform': platform,
    });
  }

  Future<void> logTemplateViewed(String templateId) async {
    await logEvent('template_viewed', {
      'template_id': templateId,
    });
  }

  Future<void> logUserLogin(String userId) async {
    await logEvent('user_login', {
      'user_id': userId,
    });
  }

  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      final postersQuery = await _firestore
          .collection('posters')
          .where('userId', isEqualTo: userId)
          .get();

      final sharesQuery = await _firestore
          .collection('analytics')
          .where('event', isEqualTo: 'poster_shared')
          .where('parameters.user_id', isEqualTo: userId)
          .get();

      return {
        'total_posters': postersQuery.docs.length,
        'total_shares': sharesQuery.docs.length,
        'join_date': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {};
    }
  }
}