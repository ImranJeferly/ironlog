import 'dart:io';

import 'package:drift/drift.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../db/database.dart';
import 'firebase_bootstrap.dart';

/// Backs progress photos up to Storage under `users/{uid}/photos/{id}.jpg`.
///
/// Photos stay local-first: the file on the phone is what every screen reads,
/// and this only ever runs in the background. The point is surviving a lost
/// or replaced phone, which is the one thing local-only storage can't do.
/// Nothing here is allowed to throw into the app.
class PhotoSync {
  PhotoSync(this._db, {FirebaseStorage? storage}) : _storage = storage;

  final AppDatabase _db;
  final FirebaseStorage? _storage;

  FirebaseStorage get _files => _storage ?? FirebaseStorage.instance;

  /// A photo that has never been uploaded is one with no `storagePath`.
  Future<List<PhotoRow>> _pendingUploads() async {
    final rows = await _db.allPhotos();
    return [
      for (final r in rows)
        if (!r.deleted && r.storagePath == null) r,
    ];
  }

  /// Uploads anything new, then pulls down anything this device is missing.
  /// Returns (uploaded, downloaded).
  Future<(int, int)> sync() async {
    final uid = FirebaseBootstrap.uid;
    if (uid == null) return (0, 0);
    var up = 0;
    var down = 0;
    try {
      up = await _pushNew(uid);
      down = await _pullMissing(uid);
      await _reapDeleted();
    } on Object catch (e) {
      debugPrint('IronLog: photo sync failed ($e)');
    }
    return (up, down);
  }

  /// Tombstoned photos still have a file in Storage costing money. Clear it
  /// and drop the path so this only runs once per photo.
  Future<void> _reapDeleted() async {
    for (final row in await _db.allPhotos()) {
      if (!row.deleted || row.storagePath == null) continue;
      await deleteRemote(row.storagePath);
      await (_db.update(_db.photos)..where((t) => t.id.equals(row.id))).write(
        PhotosCompanion(
          storagePath: const Value(null),
          updatedAt: Value(DateTime.now()),
          synced: const Value(false),
        ),
      );
    }
  }

  Future<int> _pushNew(String uid) async {
    var count = 0;
    for (final row in await _pendingUploads()) {
      final file = File(row.localPath);
      if (!await file.exists()) continue;
      final path = 'users/$uid/photos/${row.id}.jpg';
      try {
        await _files
            .ref(path)
            .putFile(file, SettableMetadata(contentType: 'image/jpeg'));
        await (_db.update(_db.photos)..where((t) => t.id.equals(row.id))).write(
          PhotosCompanion(
            storagePath: Value(path),
            updatedAt: Value(DateTime.now()),
            synced: const Value(false),
          ),
        );
        count++;
      } on Object catch (e) {
        debugPrint('IronLog: photo upload failed for ${row.id} ($e)');
        // Leave storagePath null so the next run retries it.
      }
    }
    return count;
  }

  /// Rows that arrived through Firestore sync from another device carry a
  /// `storagePath` but point at a `localPath` that doesn't exist here.
  Future<int> _pullMissing(String uid) async {
    var count = 0;
    final rows = await _db.allPhotos();
    for (final row in rows) {
      if (row.deleted || row.storagePath == null) continue;
      if (await File(row.localPath).exists()) continue;
      try {
        final dir = Directory(p.dirname(row.localPath));
        if (!await dir.exists()) await dir.create(recursive: true);
        await _files.ref(row.storagePath!).writeToFile(File(row.localPath));
        count++;
      } on Object catch (e) {
        debugPrint('IronLog: photo download failed for ${row.id} ($e)');
      }
    }
    return count;
  }

  /// Removes the remote copy when a photo is deleted locally. Best-effort.
  Future<void> deleteRemote(String? storagePath) async {
    if (storagePath == null) return;
    try {
      await _files.ref(storagePath).delete();
    } on Object catch (e) {
      debugPrint('IronLog: could not delete remote photo ($e)');
    }
  }
}
