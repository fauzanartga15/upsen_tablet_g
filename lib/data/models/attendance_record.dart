class AttendanceRecord {
  final int? id;
  final int userId;
  final String date;
  final String? timeIn;
  final String? timeOut;
  final String? latLonIn;
  final String? latLonOut;
  final String statusPlace;
  final String statusTime;
  final String? statusPlaceOut;
  final String? statusTimeOut;
  final String? delay;
  final String? delayOut;
  final int type; // 1 = check-in, 2 = check-out
  final String attendanceType;
  final double? confidenceScore;
  final bool isSynced;
  final DateTime createdAt;
  final DateTime updatedAt;

  AttendanceRecord({
    this.id,
    required this.userId,
    required this.date,
    this.timeIn,
    this.timeOut,
    this.latLonIn,
    this.latLonOut,
    required this.statusPlace,
    required this.statusTime,
    this.statusPlaceOut,
    this.statusTimeOut,
    this.delay,
    this.delayOut,
    required this.type,
    required this.attendanceType,
    this.confidenceScore,
    this.isSynced = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'],
      userId: json['user_id'] ?? 0,
      date: json['date'] ?? '',
      timeIn: json['time_in'],
      timeOut: json['time_out'],
      latLonIn: json['latlon_in'],
      latLonOut: json['latlon_out'],
      statusPlace: json['status_place'] ?? '',
      statusTime: json['status_time'] ?? '',
      statusPlaceOut: json['status_place_out'],
      statusTimeOut: json['status_time_out'],
      delay: json['delay'],
      delayOut: json['delay_out'],
      type: json['type'] ?? 1,
      attendanceType: json['attandence_type'] ?? '',
      confidenceScore: json['confidence_score']?.toDouble(),
      isSynced: json['is_synced'] ?? false,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'date': date,
    'time_in': timeIn,
    'time_out': timeOut,
    'latlon_in': latLonIn,
    'latlon_out': latLonOut,
    'status_place': statusPlace,
    'status_time': statusTime,
    'status_place_out': statusPlaceOut,
    'status_time_out': statusTimeOut,
    'delay': delay,
    'delay_out': delayOut,
    'type': type,
    'attandence_type': attendanceType,
    'confidence_score': confidenceScore,
    'is_synced': isSynced,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}

// Supporting models
class Department {
  final int id;
  final String name;

  Department({required this.id, required this.name});

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(id: json['id'] ?? 0, name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class Position {
  final int id;
  final String name;

  Position({required this.id, required this.name});

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(id: json['id'] ?? 0, name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class Shift {
  final int id;
  final String name;
  final String timeIn;
  final String timeOut;

  Shift({
    required this.id,
    required this.name,
    required this.timeIn,
    required this.timeOut,
  });

  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      timeIn: json['masuk'] ?? json['time_in'] ?? '08:00:00',
      timeOut: json['pulang'] ?? json['time_out'] ?? '17:00:00',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'time_in': timeIn,
    'time_out': timeOut,
  };
}

class Company {
  final int id;
  final String name;
  final String? email;
  final String? address;
  final String? logoUrl;

  Company({
    required this.id,
    required this.name,
    this.email,
    this.address,
    this.logoUrl,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'],
      address: json['address'],
      logoUrl: json['logo'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'address': address,
    'logo': logoUrl,
  };
}
