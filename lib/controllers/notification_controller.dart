import 'package:get/get.dart';
import '../services/firebase_service.dart';

class NotificationController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService.instance;
  
  final RxList<NotificationModel> _notifications = <NotificationModel>[].obs;
  final RxInt _unreadCount = 0.obs;
  
  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount.value;
  
  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }
  
  Future<void> loadNotifications() async {
    try {
      final querySnapshot = await _firebaseService.firestore
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();
      
      final notifications = querySnapshot.docs
          .map((doc) => NotificationModel.fromJson(doc.data()))
          .toList();
      
      _notifications.value = notifications;
      _updateUnreadCount();
    } catch (e) {
      // Handle error
    }
  }
  
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firebaseService.updateDocument(
        'notifications',
        notificationId,
        {'isRead': true},
      );
      
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        _updateUnreadCount();
      }
    } catch (e) {
      // Handle error
    }
  }
  
  Future<void> markAllAsRead() async {
    try {
      final batch = _firebaseService.firestore.batch();
      
      for (final notification in _notifications.where((n) => !n.isRead)) {
        final docRef = _firebaseService.firestore
            .collection('notifications')
            .doc(notification.id);
        batch.update(docRef, {'isRead': true});
      }
      
      await batch.commit();
      
      _notifications.value = _notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
      _updateUnreadCount();
    } catch (e) {
      // Handle error
    }
  }
  
  void _updateUnreadCount() {
    _unreadCount.value = _notifications.where((n) => !n.isRead).length;
  }
  
  Future<void> sendNotification({
    required String title,
    required String message,
    String? userId,
    Map<String, dynamic>? data,
  }) async {
    try {
      final notification = NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        message: message,
        userId: userId,
        data: data ?? {},
        createdAt: DateTime.now(),
        isRead: false,
      );
      
      await _firebaseService.setDocument(
        'notifications',
        notification.id,
        notification.toJson(),
      );
    } catch (e) {
      // Handle error
    }
  }
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String? userId;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final bool isRead;
  
  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    this.userId,
    required this.data,
    required this.createdAt,
    required this.isRead,
  });
  
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      userId: json['userId'],
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      createdAt: DateTime.parse(json['createdAt']),
      isRead: json['isRead'] ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'userId': userId,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
    };
  }
  
  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? userId,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      userId: userId ?? this.userId,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}