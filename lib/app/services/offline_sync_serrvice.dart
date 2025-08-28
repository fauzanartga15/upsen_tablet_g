import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';
import '../data/providers/attendance_api.dart';

class OfflineSyncService extends GetxService {
  Database? _database;
  Timer? _syncTimer;

  final RxBool _isOnline = true.obs;
  final RxInt _queueCount = 0.obs;
  final RxBool _isSyncing = false.obs;
  final RxString _lastSyncTime = ''.obs;

  // Getters
  bool get isOnline => _isOnline.value;
  int get queueCount => _queueCount.value;
  bool get isSyncing => _isSyncing.value;
  String get lastSyncTime => _lastSyncTime.value;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initDatabase();
    await _updateQueueCount();
    _startPeriodicSync();
  }

  // Initialize SQLite database
  Future<void> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'attendance_queue.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE attendance_queue (
            id TEXT PRIMARY KEY,
            type TEXT NOT NULL,
            face_embedding TEXT NOT NULL,
            timestamp TEXT NOT NULL,
            synced INTEGER DEFAULT 0,
            retry_count INTEGER DEFAULT 0,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // Queue check-in for offline processing
  Future<void> queueCheckIn(List<double> faceEmbedding) async {
    await _addToQueue('checkin', faceEmbedding);
  }

  // Queue check-out for offline processing
  Future<void> queueCheckOut(List<double> faceEmbedding) async {
    await _addToQueue('checkout', faceEmbedding);
  }

  // Add attendance record to offline queue
  Future<void> _addToQueue(String type, List<double> faceEmbedding) async {
    if (_database == null) return;

    final id = '${type}_${DateTime.now().millisecondsSinceEpoch}';
    final now = DateTime.now().toIso8601String();

    await _database!.insert('attendance_queue', {
      'id': id,
      'type': type,
      'face_embedding': jsonEncode(faceEmbedding),
      'timestamp': now,
      'synced': 0,
      'retry_count': 0,
      'created_at': now,
    });

    await _updateQueueCount();
    print('Queued $type attendance: $id');
  }

  // Update queue count
  Future<void> _updateQueueCount() async {
    if (_database == null) return;

    final List<Map<String, dynamic>> result = await _database!.query(
      'attendance_queue',
      where: 'synced = 0',
    );

    _queueCount.value = result.length;
  }

  // Start periodic sync every 5 minutes
  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(Duration(minutes: 5), (_) {
      _syncQueuedAttendance();
    });
  }

  // Manual sync trigger
  Future<void> syncNow() async {
    await _syncQueuedAttendance();
  }

  // Sync queued attendance records
  Future<void> _syncQueuedAttendance() async {
    if (_database == null || _isSyncing.value) return;

    _isSyncing.value = true;

    try {
      // Get all unsynced records
      final List<Map<String, dynamic>> queuedRecords = await _database!.query(
        'attendance_queue',
        where: 'synced = 0 AND retry_count < 3',
        orderBy: 'created_at ASC',
        limit: 10, // Process in batches
      );

      if (queuedRecords.isEmpty) {
        _isOnline.value = true;
        _lastSyncTime.value = DateFormat('HH:mm').format(DateTime.now());
        return;
      }

      final AttendanceApi api = AttendanceApi();
      int successCount = 0;
      int failureCount = 0;

      for (final record in queuedRecords) {
        try {
          final faceEmbedding = List<double>.from(
            jsonDecode(record['face_embedding']),
          );

          Response response;
          if (record['type'] == 'checkin') {
            response = await api.checkInPublic(
              faceEmbedding: faceEmbedding,
              dateTime: DateTime.parse(record['timestamp']),
            );
          } else {
            response = await api.checkOutPublic(
              faceEmbedding: faceEmbedding,
              dateTime: DateTime.parse(record['timestamp']),
            );
          }

          if (response.isOk) {
            // Mark as synced
            await _database!.update(
              'attendance_queue',
              {'synced': 1},
              where: 'id = ?',
              whereArgs: [record['id']],
            );
            successCount++;
          } else {
            // Increment retry count
            await _database!.update(
              'attendance_queue',
              {'retry_count': record['retry_count'] + 1},
              where: 'id = ?',
              whereArgs: [record['id']],
            );
            failureCount++;
          }
        } catch (e) {
          // Increment retry count on error
          await _database!.update(
            'attendance_queue',
            {'retry_count': record['retry_count'] + 1},
            where: 'id = ?',
            whereArgs: [record['id']],
          );
          failureCount++;
          print('Sync error for ${record['id']}: $e');
        }
      }

      // Update status
      _isOnline.value = failureCount == 0;
      _lastSyncTime.value = DateFormat('HH:mm').format(DateTime.now());
      await _updateQueueCount();

      if (successCount > 0) {
        print('Synced $successCount attendance records');
      }
      if (failureCount > 0) {
        print('Failed to sync $failureCount records');
      }
    } catch (e) {
      _isOnline.value = false;
      print('Sync service error: $e');
    } finally {
      _isSyncing.value = false;
    }
  }

  // Clean up old synced records (older than 7 days)
  Future<void> cleanupOldRecords() async {
    if (_database == null) return;

    final cutoffDate = DateTime.now().subtract(Duration(days: 7));
    await _database!.delete(
      'attendance_queue',
      where: 'synced = 1 AND created_at < ?',
      whereArgs: [cutoffDate.toIso8601String()],
    );
  }

  // Get sync statistics
  Map<String, dynamic> getSyncStats() {
    return {
      'isOnline': isOnline,
      'queueCount': queueCount,
      'isSyncing': isSyncing,
      'lastSyncTime': lastSyncTime,
    };
  }

  @override
  void onClose() {
    _syncTimer?.cancel();
    _database?.close();
    super.onClose();
  }
}
