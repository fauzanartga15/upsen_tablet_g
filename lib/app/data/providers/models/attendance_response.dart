class AttendanceResponse {
  final bool status;
  final String message;
  final double similarity;
  final AttendanceData attendance;
  final UserData user;

  AttendanceResponse({
    required this.status,
    required this.message,
    required this.similarity,
    required this.attendance,
    required this.user,
  });

  factory AttendanceResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      similarity: (json['similarity'] ?? 0.0).toDouble(),
      attendance: AttendanceData.fromJson(json['attendance'] ?? {}),
      user: UserData.fromJson(json['user'] ?? {}),
    );
  }
}

class AttendanceData {
  final int id;
  final int userId;
  final String date;
  final String? timeIn;
  final String? timeOut;
  final String statusTime;
  final String statusPlace;

  AttendanceData({
    required this.id,
    required this.userId,
    required this.date,
    this.timeIn,
    this.timeOut,
    required this.statusTime,
    required this.statusPlace,
  });

  factory AttendanceData.fromJson(Map<String, dynamic> json) {
    return AttendanceData(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      date: json['date'] ?? '',
      timeIn: json['time_in'],
      timeOut: json['time_out'],
      statusTime: json['status_time'] ?? '',
      statusPlace: json['status_place'] ?? '',
    );
  }
}

class UserData {
  final int id;
  final String name;
  final String email;
  final String? department;
  final String? position;
  final String? imageUrl;

  UserData({
    required this.id,
    required this.name,
    required this.email,
    this.department,
    this.position,
    this.imageUrl,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      department: json['department'],
      position: json['position'],
      imageUrl: json['image_url'],
    );
  }
}
