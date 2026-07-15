/// Represents a date in the Ethiopian (Ge'ez) calendar.
///
/// The Ethiopian calendar has 13 months:
/// - 12 months of exactly 30 days
/// - 1 intercalary month (Pagume) with 5 days (6 in a leap year)
class EthiopianDate {
  final int year;

  /// Month number: 1–13. Month 13 is Pagume.
  final int month;

  /// Day number: 1–30 (1–5 or 1–6 for Pagume).
  final int day;

  const EthiopianDate({
    required this.year,
    required this.month,
    required this.day,
  }) : assert(month >= 1 && month <= 13, 'Month must be between 1 and 13'),
       assert(day >= 1 && day <= 30, 'Day must be between 1 and 30');

  /// Full Amharic name of the month.
  String get monthName => EthiopianMonths.nameOf(month);

  /// Short Amharic name of the month (first 3 chars).
  // String get monthNameShort => monthName.length > 3
  //     ? monthName.substring(0, 3)
  //     : monthName;

  /// Whether this date falls in Pagume (the 13th intercalary month).
  bool get isPagume => month == 13;

  /// Number of days in this month.
  int get daysInMonth {
    if (month < 13) return 30;
    return EthiopianDate.isEthiopianLeapYear(year) ? 6 : 5;
  }

  /// Whether the given Ethiopian year is a leap year.
  /// An Ethiopian year is a leap year if (year % 4 == 3).
  static bool isEthiopianLeapYear(int year) => year % 4 == 3;

  /// Returns a new [EthiopianDate] with updated fields.
  EthiopianDate copyWith({int? year, int? month, int? day}) {
    return EthiopianDate(
      year: year ?? this.year,
      month: month ?? this.month,
      day: day ?? this.day,
    );
  }

  /// The first day of this month.
  EthiopianDate get firstDayOfMonth => copyWith(day: 1);

  /// The last day of this month.
  EthiopianDate get lastDayOfMonth => copyWith(day: daysInMonth);

  /// Add [months] Ethiopian months, handling year rollover.
  /// If the resulting day exceeds the target month's length (e.g. navigating
  /// into Pagume with day > 5/6), the day is clamped to the last valid day.
  EthiopianDate addMonths(int months) {
    // Work in total 0-based month units to avoid double-decrement bugs
    // that occur when using modulo arithmetic on negative numbers.
    final totalMonths = year * 13 + (month - 1) + months;
    final newYear = totalMonths ~/ 13;
    final newMonth = totalMonths % 13 + 1;
    final maxDay = newMonth == 13
        ? (EthiopianDate.isEthiopianLeapYear(newYear) ? 6 : 5)
        : 30;
    return EthiopianDate(
      year: newYear,
      month: newMonth,
      day: day.clamp(1, maxDay),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is EthiopianDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() =>
      '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')} (ET)';

  /// Formatted as "day monthName year" in Amharic style, e.g. "5 ጥቅምት 2017".
  String toAmharicString() => '$day $monthName $year';
}

/// Amharic month names for the Ethiopian calendar.
class EthiopianMonths {
  EthiopianMonths._();

  /// All 13 month names in order.
  static const List<String> names = [
    'መስከረም', // 1  Meskerem  (Sep–Oct)
    'ጥቅምት', // 2  Tikimt    (Oct–Nov)
    'ኅዳር', // 3  Hidar     (Nov–Dec)
    'ታኅሣሥ', // 4  Tahsas    (Dec–Jan)
    'ጥር', // 5  Tir       (Jan–Feb)
    'የካቲት', // 6  Yekatit   (Feb–Mar)
    'መጋቢት', // 7  Megabit   (Mar–Apr)
    'ሚያዝያ', // 8  Miazia    (Apr–May)
    'ግንቦት', // 9  Ginbot    (May–Jun)
    'ሰኔ', // 10 Sene      (Jun–Jul)
    'ሐምሌ', // 11 Hamle     (Jul–Aug)
    'ነሐሴ', // 12 Nehase    (Aug–Sep)
    'ጳጉሜ', // 13 Pagume    (Sep, 5–6 days)
  ];

  /// Returns the Amharic name for month [number] (1-based).
  static String nameOf(int number) {
    assert(number >= 1 && number <= 13, 'Month number must be 1–13');
    return names[number - 1];
  }

  /// Gregorian month name equivalents for reference.
  static const List<String> gregorianEquivalents = [
    'Sep–Oct',
    'Oct–Nov',
    'Nov–Dec',
    'Dec–Jan',
    'Jan–Feb',
    'Feb–Mar',
    'Mar–Apr',
    'Apr–May',
    'May–Jun',
    'Jun–Jul',
    'Jul–Aug',
    'Aug–Sep',
    'Sep',
  ];
}

/// Amharic digit representation (Ethiopic numerals).
class EthiopicNumerals {
  EthiopicNumerals._();

  static const List<String> _digits = [
    '፩',
    '፪',
    '፫',
    '፬',
    '፭',
    '፮',
    '፯',
    '፰',
    '፱',
    '፲',
    '፲፩',
    '፲፪',
    '፲፫',
    '፲፬',
    '፲፭',
    '፲፮',
    '፲፯',
    '፲፰',
    '፲፱',
    '፳',
    '፳፩',
    '፳፪',
    '፳፫',
    '፳፬',
    '፳፭',
    '፳፮',
    '፳፯',
    '፳፰',
    '፳፱',
    '፴',
  ];

  /// Convert an integer (1–30) to its Ethiopic numeral string.
  /// Falls back to Arabic numeral string if out of range.
  static String of(int number) {
    if (number >= 1 && number <= 30) return _digits[number - 1];
    return number.toString();
  }
}
