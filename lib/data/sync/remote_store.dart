import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_bootstrap.dart';

/// The remote half of sync, behind an interface so the merge logic can be
/// tested without a Firebase project.
///
/// Firestore documents only — there is deliberately no Firebase Storage in this
/// app. Progress photos never leave the device (Storage requires billing), so
/// the remote store has no file operations at all.
abstract class RemoteStore {
  Future<void> upsert(
    String collection,
    String id,
    Map<String, dynamic> data,
  );

  /// Documents whose `updatedAt` is strictly after [sinceIso] (UTC ISO-8601).
  Future<List<Map<String, dynamic>>> fetchSince(
    String collection,
    String? sinceIso,
  );
}

class FirestoreRemoteStore implements RemoteStore {
  FirestoreRemoteStore({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Single-user app: everything hangs off the anonymous uid, which makes the
  /// security rules a one-liner.
  CollectionReference<Map<String, dynamic>> _col(String collection) {
    final uid = FirebaseBootstrap.uid;
    if (uid == null) {
      throw StateError('Firebase not signed in');
    }
    return _firestore.collection('users').doc(uid).collection(collection);
  }

  @override
  Future<void> upsert(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    await _col(collection).doc(id).set(data, SetOptions(merge: true));
  }

  @override
  Future<List<Map<String, dynamic>>> fetchSince(
    String collection,
    String? sinceIso,
  ) async {
    Query<Map<String, dynamic>> query = _col(collection);
    if (sinceIso != null) {
      query = query.where('updatedAt', isGreaterThan: sinceIso);
    }
    final snapshot = await query.get();
    return snapshot.docs.map((d) => d.data()).toList();
  }
}
