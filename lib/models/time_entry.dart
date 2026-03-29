import 'package:mongo_dart/mongo_dart.dart';

class TimeEntry {
  final ObjectId? id;
  final ObjectId companyId;
  final String companyName;
  final DateTime clockIn;
  final DateTime? clockOut;
  final int? durationMinutes;
  final double? earnings;
  final String? notes;
  final DateTime createdAt;

  TimeEntry({
    this.id,
    required this.companyId,
    required this.companyName,
    required this.clockIn,
    this.clockOut,
    this.durationMinutes,
    this.earnings,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isActive => clockOut == null;

  Duration get elapsed {
    final end = clockOut ?? DateTime.now();
    return end.difference(clockIn);
  }

  double calculateEarnings(double hourlyRate) {
    final minutes = durationMinutes ?? elapsed.inMinutes;
    return (minutes / 60.0) * hourlyRate;
  }

  TimeEntry clockOutNow(double hourlyRate) {
    final now = DateTime.now();
    final minutes = now.difference(clockIn).inMinutes;
    return TimeEntry(
      id: id,
      companyId: companyId,
      companyName: companyName,
      clockIn: clockIn,
      clockOut: now,
      durationMinutes: minutes,
      earnings: (minutes / 60.0) * hourlyRate,
      notes: notes,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) '_id': id,
      'companyId': companyId,
      'companyName': companyName,
      'clockIn': clockIn.toUtc(),
      'clockOut': clockOut?.toUtc(),
      'durationMinutes': durationMinutes,
      'earnings': earnings,
      'notes': notes,
      'createdAt': createdAt.toUtc(),
    };
  }

  factory TimeEntry.fromMap(Map<String, dynamic> map) {
    return TimeEntry(
      id: map['_id'] as ObjectId?,
      companyId: map['companyId'] as ObjectId,
      companyName: map['companyName'] as String? ?? '',
      clockIn: map['clockIn'] is DateTime
          ? map['clockIn'] as DateTime
          : DateTime.now(),
      clockOut: map['clockOut'] as DateTime?,
      durationMinutes: map['durationMinutes'] as int?,
      earnings: (map['earnings'] as num?)?.toDouble(),
      notes: map['notes'] as String?,
      createdAt: map['createdAt'] is DateTime
          ? map['createdAt'] as DateTime
          : DateTime.now(),
    );
  }
}
