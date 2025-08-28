import 'attendance_record.dart';

class Employee {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? employeeId;
  final String? imageUrl;
  final List<double> faceEmbedding;
  final Department department;
  final Position position;
  final Shift shift;
  final Company company;
  final String statusKaryawan;
  final String attendanceType;
  final DateTime? joinDate;
  final bool isActive;

  Employee({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.employeeId,
    this.imageUrl,
    required this.faceEmbedding,
    required this.department,
    required this.position,
    required this.shift,
    required this.company,
    required this.statusKaryawan,
    required this.attendanceType,
    this.joinDate,
    this.isActive = true,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    // Parse face_embedding string to List<double>
    final embeddingString = json['face_embedding'] ?? '';
    final embedding = embeddingString.isEmpty
        ? <double>[]
        : embeddingString
              .split(',')
              .map((e) => double.tryParse(e.trim()) ?? 0.0)
              .toList();

    return Employee(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      employeeId: json['nip'],
      imageUrl: json['image_url'],
      faceEmbedding: embedding,
      department: Department.fromJson(json['department'] ?? {}),
      position: Position.fromJson(json['position'] ?? {}),
      shift: Shift.fromJson(json['shift'] ?? {}),
      company: Company.fromJson(json['company'] ?? {}),
      statusKaryawan: json['status_karyawan'] ?? '',
      attendanceType: json['attandence_type'] ?? '',
      joinDate: json['join_date'] != null
          ? DateTime.tryParse(json['join_date'])
          : null,
      isActive: true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'nip': employeeId,
    'image_url': imageUrl,
    'face_embedding': faceEmbedding.join(','),
    'department': department.toJson(),
    'position': position.toJson(),
    'shift': shift.toJson(),
    'company': company.toJson(),
    'status_karyawan': statusKaryawan,
    'attandence_type': attendanceType,
    'join_date': joinDate?.toIso8601String(),
  };
}
