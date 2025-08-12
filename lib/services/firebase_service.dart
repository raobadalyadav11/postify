import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();
  
  static FirebaseService get instance => _instance;
  
  late FirebaseFirestore _firestore;
  late FirebaseAuth _auth;
  late FirebaseStorage _storage;
  
  FirebaseFirestore get firestore => _firestore;
  FirebaseAuth get auth => _auth;
  FirebaseStorage get storage => _storage;
  
  Future<void> initialize() async {
    _firestore = FirebaseFirestore.instance;
    _auth = FirebaseAuth.instance;
    _storage = FirebaseStorage.instance;
    
    // Enable offline persistence
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }
  
  // Auth Methods
  Future<UserCredential?> signInWithPhone(String phoneNumber) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: phoneNumber,
        smsCode: '123456', // For demo purposes
      );
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      throw Exception('Phone authentication failed: $e');
    }
  }
  
  Future<void> signOut() async {
    await _auth.signOut();
  }
  
  User? get currentUser => _auth.currentUser;
  
  // Firestore Methods
  Future<DocumentReference> addDocument(String collection, Map<String, dynamic> data) async {
    return await _firestore.collection(collection).add(data);
  }
  
  Future<void> setDocument(String collection, String docId, Map<String, dynamic> data) async {
    await _firestore.collection(collection).doc(docId).set(data, SetOptions(merge: true));
  }
  
  Future<DocumentSnapshot> getDocument(String collection, String docId) async {
    return await _firestore.collection(collection).doc(docId).get();
  }
  
  Future<QuerySnapshot> getCollection(String collection) async {
    return await _firestore.collection(collection).get();
  }
  
  Stream<QuerySnapshot> streamCollection(String collection) {
    return _firestore.collection(collection).snapshots();
  }
  
  Future<void> updateDocument(String collection, String docId, Map<String, dynamic> data) async {
    await _firestore.collection(collection).doc(docId).update(data);
  }
  
  Future<void> deleteDocument(String collection, String docId) async {
    await _firestore.collection(collection).doc(docId).delete();
  }
  
  // Storage Methods
  Future<String> uploadFile(String path, List<int> data) async {
    final ref = _storage.ref().child(path);
    final uploadTask = ref.putData(Uint8List.fromList(data));
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }
  
  Future<void> deleteFile(String path) async {
    final ref = _storage.ref().child(path);
    await ref.delete();
  }
}