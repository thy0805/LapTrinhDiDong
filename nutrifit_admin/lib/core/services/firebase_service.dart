import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class FirebaseService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<T>> getStream<T>(
    String collectionPath,
    T Function(Map<String, dynamic> data, String id) fromMap, {
    Query Function(Query query)? queryBuilder,
  }) {
    Query query = _firestore.collection(collectionPath);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  Future<List<T>> getCollection<T>(
    String collectionPath,
    T Function(Map<String, dynamic> data, String id) fromMap, {
    Query Function(Query query)? queryBuilder,
  }) async {
    Query query = _firestore.collection(collectionPath);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<DocumentReference> addDocument(
    String collectionPath,
    Map<String, dynamic> data,
  ) {
    return _firestore.collection(collectionPath).add(data);
  }

  Future<void> updateDocument(
    String collectionPath,
    String docId,
    Map<String, dynamic> data,
  ) {
    return _firestore.collection(collectionPath).doc(docId).update(data);
  }

  Future<void> deleteDocument(String collectionPath, String docId) {
    return _firestore.collection(collectionPath).doc(docId).delete();
  }
}
