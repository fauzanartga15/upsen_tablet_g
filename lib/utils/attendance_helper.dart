class AttendanceHelper {
  static String formatTime(String timeString) {
    try {
      final time = DateTime.parse('2000-01-01 $timeString');
      final hour = time.hour;
      final minute = time.minute.toString().padLeft(2, '0');

      if (hour == 0) return '12:$minute AM';
      if (hour < 12) return '$hour:$minute AM';
      if (hour == 12) return '12:$minute PM';
      return '${hour - 12}:$minute PM';
    } catch (e) {
      return timeString;
    }
  }

  static String getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'ontime':
        return 'success';
      case 'late':
        return 'warning';
      case 'early':
        return 'info';
      default:
        return 'default';
    }
  }

  static String getAttendanceMessage(
    String action,
    String employeeName,
    String time,
  ) {
    final actionText = action == 'check_in' ? 'checked in' : 'checked out';
    return '$employeeName $actionText at ${formatTime(time)}';
  }

  static bool isWithinWorkingHours(
    String currentTime,
    String shiftStart,
    String shiftEnd,
  ) {
    try {
      final now = DateTime.parse('2000-01-01 $currentTime');
      final start = DateTime.parse('2000-01-01 $shiftStart');
      final end = DateTime.parse('2000-01-01 $shiftEnd');

      return now.isAfter(start) && now.isBefore(end);
    } catch (e) {
      return true; // Default to allow if parsing fails
    }
  }
}
