import 'ethiopian_date.dart';

/// Converts dates and times between the Ethiopian (Ge'ez) and Gregorian
/// calendars/clock systems.
///
/// ## Date algorithm
///
/// Uses the fixed-day approach from Reingold & Dershowitz "Calendrical
/// Calculations". A "fixed day" is an integer count from 1 Jan 1 CE (Gregorian
/// proleptic). The Ethiopian fixed epoch (1 Meskerem 1 ET) is fixed day 2796.
///
/// Key facts:
/// - Ethiopian year ≈ Gregorian year − 7 or − 8.
/// - ET New Year (1 Meskerem) = 11 Sep normally, 12 Sep after an ET leap year
///   (i.e. when the previous ET year had 366 days, meaning previous ET year % 4 == 3).
/// - Each month: 30 days; Pagume (13th): 5 days, 6 in an ET leap year (year % 4 == 3).
///
/// ## Time algorithm
///
/// Ethiopian time (የኢትዮጵያ ሰዓት) counts from sunrise rather than midnight.
/// Standard 6:00 AM = ET 12:00 ቀን (start of the Ethiopian day).
///
/// Conversion: `ET hour 24 = (standard hour + 6) % 24`
/// Period:
/// - **ቀን** (day)   — standard 06:00–17:59 → ET 12:00–11:59 (etHour24 ≥ 12)
/// - **ሌሊት** (night) — standard 18:00–05:59 → ET 12:00–11:59 (etHour24 < 12)
class EtDateConverter {
  EtDateConverter._();

  // Fixed day of 1 Meskerem 1 ET
  static const int _ethiopianEpochFixed = 2796;

  // JDN offset: JDN 1721426 = 1 Jan 1 CE → fixed = JDN − 1721425
  static const int _jdnToFixed = 1721425;

  // ─── Date: Public API ────────────────────────────────────────────────────

  /// Converts a Gregorian [DateTime] to an [EthiopianDate].
  static EthiopianDate toEthiopian(DateTime gregorian) {
    final fixed = _gregorianToFixed(
      gregorian.year,
      gregorian.month,
      gregorian.day,
    );
    return _fixedToEthiopian(fixed);
  }

  /// Converts an [EthiopianDate] to a Gregorian [DateTime] (midnight UTC).
  static DateTime toGregorian(EthiopianDate ethiopian) {
    final fixed = _ethiopianToFixed(
      ethiopian.year,
      ethiopian.month,
      ethiopian.day,
    );
    return _fixedToGregorian(fixed);
  }

  /// Today's date as an [EthiopianDate].
  static EthiopianDate today() => toEthiopian(DateTime.now());

  /// Whether two [DateTime] values fall on the same calendar day.
  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Whether an Ethiopian year is a leap year.
  static bool isLeapYear(int year) => EthiopianDate.isEthiopianLeapYear(year);

  // ─── Time: Public API ────────────────────────────────────────────────────

  /// Converts a standard [DateTime]'s time component to [EthiopianTime].
  ///
  /// Only the hour, minute, and second fields of [dateTime] are used.
  ///
  /// ```dart
  /// final et = EtDateConverter.toEthiopianTime(DateTime.now());
  /// print('${et.hour}:${et.minutePadded} ${et.periodLabel}'); // e.g. "3:30 ቀን"
  /// ```
  static EthiopianTime toEthiopianTime(DateTime dateTime) {
    return EthiopianTime._fromStandard(
      dateTime.hour,
      dateTime.minute,
      dateTime.second,
    );
  }

  /// Converts explicit hour/minute/second values to [EthiopianTime].
  ///
  /// [hour] is a 24-hour standard clock value (0–23).
  static EthiopianTime toEthiopianTimeFromParts({
    required int hour,
    int minute = 0,
    int second = 0,
  }) {
    return EthiopianTime._fromStandard(hour, minute, second);
  }

  /// Converts an [EthiopianTime] back to a standard 24-hour [hour] value
  /// (0–23). Useful when you need to reconstruct a [DateTime].
  ///
  /// ```dart
  /// final standardHour = EtDateConverter.toStandardHour(etTime);
  /// final dt = DateTime(2024, 10, 19, standardHour, etTime.minute);
  /// ```
  static int toStandardHour(EthiopianTime etTime) {
    // Reverse of (standardHour + 6) % 24 = etHour24
    return (etTime._etHour24 - 6 + 24) % 24;
  }

  /// Converts a [DateTime]'s date and time to a combined result.
  ///
  /// Convenience that bundles [toEthiopian] and [toEthiopianTime] together.
  static EthiopianDateTime toEthiopianDateTime(DateTime dateTime) {
    return EthiopianDateTime(
      date: toEthiopian(dateTime),
      time: toEthiopianTime(dateTime),
    );
  }

  // ─── Fixed-day helpers ────────────────────────────────────────────────────

  static int _gregorianToFixed(int year, int month, int day) {
    return _gregorianToJdn(year, month, day) - _jdnToFixed;
  }

  static DateTime _fixedToGregorian(int fixed) {
    return _jdnToGregorian(fixed + _jdnToFixed);
  }

  // ─── Ethiopian ↔ Fixed ───────────────────────────────────────────────────

  static int _ethiopianToFixed(int year, int month, int day) {
    return _ethiopianEpochFixed -
        1 +
        365 * (year - 1) +
        (year ~/ 4) +
        30 * (month - 1) +
        day;
  }

  static EthiopianDate _fixedToEthiopian(int fixed) {
    final year = (4 * (fixed - _ethiopianEpochFixed) + 1463) ~/ 1461;
    final month = 1 + (fixed - _ethiopianToFixed(year, 1, 1)) ~/ 30;
    final day = fixed - _ethiopianToFixed(year, month, 1) + 1;
    return EthiopianDate(year: year, month: month, day: day);
  }

  // ─── Gregorian ↔ JDN ─────────────────────────────────────────────────────

  static int _gregorianToJdn(int year, int month, int day) {
    final a = (14 - month) ~/ 12;
    final y = year + 4800 - a;
    final m = month + 12 * a - 3;
    return day +
        (153 * m + 2) ~/ 5 +
        365 * y +
        y ~/ 4 -
        y ~/ 100 +
        y ~/ 400 -
        32045;
  }

  static DateTime _jdnToGregorian(int jdn) {
    final a = jdn + 32044;
    final b = (4 * a + 3) ~/ 146097;
    final c = a - (146097 * b) ~/ 4;
    final d = (4 * c + 3) ~/ 1461;
    final e = c - (1461 * d) ~/ 4;
    final m = (5 * e + 2) ~/ 153;
    return DateTime.utc(
      100 * b + d - 4800 + m ~/ 10,
      m + 3 - 12 * (m ~/ 10),
      e - (153 * m + 2) ~/ 5 + 1,
    );
  }
}

// ── Ethiopian time model ──────────────────────────────────────────────────────

/// A time value in the Ethiopian clock system (የኢትዮጵያ ሰዓት).
///
/// Ethiopian time starts at sunrise (standard 6:00 AM = ET 12:00 ቀን).
/// Hours run 1–12 twice per day, split into ቀን (day) and ሌሊት (night).
///
/// | Standard | ET hour | Period |
/// |----------|---------|--------|
/// | 6:00 AM  | 12:00   | ቀን     |
/// | 9:00 AM  |  3:00   | ቀን     |
/// | 12:00 PM |  6:00   | ቀን     |
/// | 3:00 PM  |  9:00   | ቀን     |
/// | 6:00 PM  | 12:00   | ሌሊት    |
/// | 9:00 PM  |  3:00   | ሌሊት    |
/// | 12:00 AM |  6:00   | ሌሊት    |
/// | 3:00 AM  |  9:00   | ሌሊት    |
class EthiopianTime {
  EthiopianTime._fromStandard(int standardHour, this.minute, this.second)
    : _etHour24 = (standardHour + 6) % 24;

  /// Internal 24-hour ET hour (0–23), where 12 = ET 12:00 ቀን = 6:00 AM std.
  final int _etHour24;

  /// Minute (0–59), identical to the standard clock.
  final int minute;

  /// Second (0–59), identical to the standard clock.
  final int second;

  /// The ET hour on a 12-hour dial (1–12).
  int get hour => _etHour24 % 12 == 0 ? 12 : _etHour24 % 12;

  /// Whether this time falls in the daytime period (ቀን).
  /// True for standard 06:00–17:59 (ET 12:00–11:59 ቀን).
  bool get isDay => _etHour24 >= 12;

  /// Whether this time falls in the night period (ሌሊት).
  bool get isNight => !isDay;

  /// The Amharic period label: **ቀን** (day) or **ሌሊት** (night).
  String get periodLabel => isDay ? 'ቀን' : 'ሌሊት';

  /// Minute as a zero-padded two-character string, e.g. `"05"`.
  String get minutePadded => minute.toString().padLeft(2, '0');

  /// Second as a zero-padded two-character string, e.g. `"09"`.
  String get secondPadded => second.toString().padLeft(2, '0');

  /// Formats the time as `"H:MM periodLabel"`, e.g. `"3:30 ቀን"`.
  String format() => '$hour:$minutePadded $periodLabel';

  /// Formats the time as `"H:MM:SS periodLabel"`, e.g. `"3:30:45 ቀን"`.
  String formatWithSeconds() =>
      '$hour:$minutePadded:$secondPadded $periodLabel';

  @override
  String toString() => format();
}

// ── Combined date + time model ────────────────────────────────────────────────

/// A combined Ethiopian date and time value.
///
/// Returned by [EtDateConverter.toEthiopianDateTime].
class EthiopianDateTime {
  const EthiopianDateTime({required this.date, required this.time});

  final EthiopianDate date;
  final EthiopianTime time;

  /// Formatted as `"day monthName year H:MM period"`,
  /// e.g. `"9 ጥቅምት 2017 3:30 ቀን"`.
  String format() => '${date.toAmharicString()} ${time.format()}';

  @override
  String toString() => format();
}
