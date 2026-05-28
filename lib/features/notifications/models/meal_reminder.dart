class MealReminder {
  const MealReminder({
    required this.id,
    required this.title,
    required this.body,
    required this.hour,
    required this.minute,
  });

  final int id;
  final String title;
  final String body;
  final int hour;
  final int minute;

  String get formattedTime {
    final suffix = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final displayMinute = minute.toString().padLeft(2, '0');
    return '$displayHour:$displayMinute $suffix';
  }
}
