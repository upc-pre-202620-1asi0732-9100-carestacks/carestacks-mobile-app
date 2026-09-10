class CareDateFormatters {
  const CareDateFormatters._();

  static const List<String> _months = [
    'ene',
    'feb',
    'mar',
    'abr',
    'may',
    'jun',
    'jul',
    'ago',
    'sep',
    'oct',
    'nov',
    'dic',
  ];

  static String date(String? rawValue) {
    final parsed = parse(rawValue);
    if (parsed == null) {
      return rawValue?.isNotEmpty == true ? rawValue! : 'Sin fecha';
    }
    return '${parsed.day.toString().padLeft(2, '0')} ${_months[parsed.month - 1]} ${parsed.year}';
  }

  static String dateTime(String? rawValue) {
    final parsed = parse(rawValue);
    if (parsed == null) {
      return rawValue?.isNotEmpty == true ? rawValue! : 'Sin fecha';
    }
    return '${date(rawValue)}, ${time(parsed)}';
  }

  static String timeRange(String? startRaw, String? endRaw) {
    final start = parse(startRaw);
    if (start == null) return 'Hora pendiente';
    final end = parse(endRaw);
    if (end == null) return time(start);
    return '${time(start)} - ${time(end)}';
  }

  static String time(DateTime value) {
    final hour12 = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    final suffix = value.hour >= 12 ? 'p. m.' : 'a. m.';
    return '$hour12:$minute $suffix';
  }

  static DateTime? parse(String? rawValue) {
    if (rawValue == null || rawValue.isBlank) return null;
    return DateTime.tryParse(rawValue);
  }
}

extension _BlankString on String {
  bool get isBlank => trim().isEmpty;
}
