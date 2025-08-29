// Data model for detected user
class DetectedUser {
  final int id;
  final String name;
  final String department;
  final String position;
  final String? imageUrl;
  final double confidence;
  final String action;
  final DateTime timestamp;

  DetectedUser({
    required this.id,
    required this.name,
    required this.department,
    required this.position,
    this.imageUrl,
    required this.confidence,
    required this.action,
    required this.timestamp,
  });
}
