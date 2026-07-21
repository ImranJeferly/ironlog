import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/date_x.dart';
import '../../domain/enums.dart';
import '../db/database.dart';

class PhotoRepository {
  PhotoRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();
  final _picker = ImagePicker();

  Stream<List<PhotoRow>> watchAll() => _db.watchPhotos();

  Future<List<PhotoRow>> readAll() => _db.allPhotos();

  /// Photos live on local **external** storage, in the app-scoped external
  /// files directory — no runtime permission, never uploaded anywhere (there is
  /// no Firebase Storage in this app, so nothing about photos is ever billed).
  ///
  /// On iOS/desktop, where there is no external storage, this falls back to the
  /// app documents directory.
  Future<Directory> photosDir() async {
    Directory base;
    try {
      base = await getExternalStorageDirectory() ??
          await getApplicationDocumentsDirectory();
    } on Object {
      base = await getApplicationDocumentsDirectory();
    }
    final dir = Directory(p.join(base.path, 'progress_photos'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<XFile?> pick({required bool fromCamera}) {
    return _picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 95,
      maxWidth: 2400,
      maxHeight: 2400,
    );
  }

  /// Copies the picked file into app storage, compressing it first. The
  /// compressed local copy is what every screen reads, so photos render with no
  /// network and the Storage upload is a background nicety.
  Future<PhotoRow?> importPhoto({
    required XFile source,
    required PhotoPose pose,
    DateTime? date,
    String? note,
  }) async {
    final dir = await photosDir();
    final id = _uuid.v4();
    final target = p.join(dir.path, '$id.jpg');

    File? saved;
    try {
      final result = await FlutterImageCompress.compressAndGetFile(
        source.path,
        target,
        quality: 82,
        minWidth: 1080,
        minHeight: 1080,
        keepExif: false,
      );
      if (result != null) saved = File(result.path);
    } on Exception catch (e) {
      debugPrint('IronLog: photo compression failed ($e), storing original');
    }

    // Compression is unavailable on some platforms; keeping the original is
    // better than losing the photo.
    saved ??= await File(source.path).copy(target);

    final stat = await saved.stat();
    final now = DateTime.now();
    final row = PhotosCompanion.insert(
      id: id,
      date: (date ?? now).dayStart,
      pose: pose,
      localPath: saved.path,
      byteSize: Value(stat.size),
      note: Value(note),
      updatedAt: Value(now),
    );

    await _db.into(_db.photos).insert(row);
    return (await (_db.select(
      _db.photos,
    )..where((t) => t.id.equals(id))).getSingleOrNull());
  }

  Future<void> updatePhoto(
    String id, {
    PhotoPose? pose,
    DateTime? date,
    String? note,
  }) async {
    await (_db.update(_db.photos)..where((t) => t.id.equals(id))).write(
      PhotosCompanion(
        pose: pose == null ? const Value.absent() : Value(pose),
        date: date == null ? const Value.absent() : Value(date.dayStart),
        note: note == null ? const Value.absent() : Value(note),
        updatedAt: Value(DateTime.now()),
        synced: const Value(false),
      ),
    );
  }

  /// Soft-deletes so the tombstone reaches Firestore, then removes the local
  /// file to reclaim space.
  Future<void> deletePhoto(String id) async {
    final row = await (_db.select(
      _db.photos,
    )..where((t) => t.id.equals(id))).getSingleOrNull();

    await (_db.update(_db.photos)..where((t) => t.id.equals(id))).write(
      PhotosCompanion(
        deleted: const Value(true),
        updatedAt: Value(DateTime.now()),
        synced: const Value(false),
      ),
    );

    if (row != null) {
      final file = File(row.localPath);
      if (await file.exists()) {
        try {
          await file.delete();
        } on FileSystemException catch (e) {
          debugPrint('IronLog: could not delete photo file ($e)');
        }
      }
    }
  }

  /// Photos grouped by day, newest first — the timeline layout.
  Future<List<(DateTime, List<PhotoRow>)>> timeline() async {
    final all = await readAll();
    final grouped = <DateTime, List<PhotoRow>>{};
    for (final photo in all) {
      grouped.putIfAbsent(photo.date, () => []).add(photo);
    }
    final entries = grouped.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));
    return entries.map((e) {
      final list = e.value..sort((a, b) => a.pose.index.compareTo(b.pose.index));
      return (e.key, list);
    }).toList();
  }

  /// Distinct dates that have a photo for [pose] — the compare picker's options.
  Future<List<DateTime>> datesForPose(PhotoPose pose) async {
    final all = await readAll();
    final dates = all.where((p) => p.pose == pose).map((p) => p.date).toSet();
    final list = dates.toList()..sort();
    return list;
  }

  Future<PhotoRow?> photoFor(PhotoPose pose, DateTime date) async {
    final all = await readAll();
    for (final photo in all) {
      if (photo.pose == pose && photo.date.isSameDay(date)) return photo;
    }
    return null;
  }
}
