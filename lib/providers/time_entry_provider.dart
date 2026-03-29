import 'package:flutter/foundation.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../config/constants.dart';
import '../models/company.dart';
import '../models/time_entry.dart';
import '../services/mongodb_service.dart';

class TimeEntryProvider extends ChangeNotifier {
  final MongoDbService _db;

  List<TimeEntry> _entries = [];
  TimeEntry? _activeEntry;
  bool _isLoading = false;
  String? _error;

  TimeEntryProvider(this._db);

  List<TimeEntry> get entries => _entries;
  TimeEntry? get activeEntry => _activeEntry;
  bool get isLoading => _isLoading;
  bool get isClockedIn => _activeEntry != null;
  String? get error => _error;

  Future<void> fetchAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final docs = await _db.find(
        AppConstants.timeEntriesCollection,
        sort: {'clockIn': -1},
      );
      _entries = docs.map((d) => TimeEntry.fromMap(d)).toList();
      _activeEntry = _entries.where((e) => e.isActive).firstOrNull;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> clockIn(Company company) async {
    if (_activeEntry != null) return; // Already clocked in

    try {
      final entry = TimeEntry(
        companyId: company.id!,
        companyName: company.name,
        clockIn: DateTime.now(),
      );
      final map = entry.toMap();
      map['_id'] = ObjectId();
      await _db.insert(AppConstants.timeEntriesCollection, map);
      await fetchAll();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<TimeEntry?> clockOut(double hourlyRate) async {
    if (_activeEntry == null) return null;

    try {
      final completed = _activeEntry!.clockOutNow(hourlyRate);
      await _db.replaceDoc(
        AppConstants.timeEntriesCollection,
        completed.id!,
        completed.toMap(),
      );
      await fetchAll();
      return completed;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> delete(ObjectId id) async {
    try {
      await _db.delete(AppConstants.timeEntriesCollection, id);
      _entries.removeWhere((e) => e.id == id);
      if (_activeEntry?.id == id) _activeEntry = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  List<TimeEntry> entriesByCompany(ObjectId companyId) {
    return _entries.where((e) => e.companyId == companyId).toList();
  }

  List<TimeEntry> entriesByDateRange(DateTime start, DateTime end) {
    return _entries
        .where((e) =>
            e.clockIn.isAfter(start) &&
            e.clockIn.isBefore(end.add(const Duration(days: 1))))
        .toList();
  }
}
