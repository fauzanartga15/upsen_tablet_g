import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:upsen_tablet_get/config.dart';

import '../data/local/database_helper.dart';
import '../data/models/attendance_record.dart';
import '../data/models/repositories/attendance_repository.dart';

class SyncService {
  final AttendanceRepository _repository;
  final DatabaseHelper _databaseHelper;

  Timer? _syncTimer;
  bool _isSyncing = false;

  SyncService(this._repository, this._databaseHelper);

  void startAutoSync() {
    _syncTimer = Timer.periodic(
      Duration(minutes: AppConfig.syncIntervalMinutes),
      (_) => syncPendingRecords(),
    );
  }

  Future<bool> syncPendingRecords() async {
    if (_isSyncing) return false;

    try {
      _isSyncing = true;

      // Check connectivity
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity == ConnectivityResult.none) {
        print('No internet connection - skipping sync');
        return false;
      }

      // Get unsynced records
      final unsyncedRecords = await _databaseHelper.getUnsyncedRecords();
      if (unsyncedRecords.isEmpty) return true;

      // Prepare batch data
      final batchData = unsyncedRecords
          .map(
            (record) => {
              'local_id': record.id.toString(),
              'type': record.type == 1 ? 'check_in' : 'check_out',
              'data': record.toJson(),
            },
          )
          .toList();

      // Send to server
      final success = await _repository.syncOfflineRecords(batchData);

      if (success) {
        // Mark as synced in local database
        await _markRecordsAsSynced(unsyncedRecords);
        print('Successfully synced ${unsyncedRecords.length} records');
      }

      return success;
    } catch (e) {
      print('Sync error: $e');
      return false;
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _markRecordsAsSynced(List<AttendanceRecord> records) async {
    final db = await _databaseHelper.database;

    for (final record in records) {
      await db.update(
        'attendance_records',
        {'is_synced': 1},
        where: 'id = ?',
        whereArgs: [record.id],
      );
    }
  }

  void stopAutoSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }
}
