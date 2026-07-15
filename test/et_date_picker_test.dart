import 'package:et_date_picker/src/et_date_converter.dart';
import 'package:et_date_picker/src/ethiopian_date.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EthiopianDate model', () {
    test('month names are correct', () {
      expect(EthiopianMonths.nameOf(1), 'መስከረም');
      expect(EthiopianMonths.nameOf(2), 'ጥቅምት');
      expect(EthiopianMonths.nameOf(13), 'ጳጉሜ');
    });

    test('daysInMonth is 30 for months 1–12', () {
      for (int m = 1; m <= 12; m++) {
        final d = EthiopianDate(year: 2017, month: m, day: 1);
        expect(d.daysInMonth, 30, reason: 'Month $m should have 30 days');
      }
    });

    test('Pagume has 5 days in non-leap ET year', () {
      // 2017 ET: 2017 % 4 = 1 → not a leap year
      final d = EthiopianDate(year: 2017, month: 13, day: 1);
      expect(d.daysInMonth, 5);
    });

    test('Pagume has 6 days in ET leap year', () {
      // 2015 ET: 2015 % 4 = 3 → leap year
      final d = EthiopianDate(year: 2015, month: 13, day: 1);
      expect(d.daysInMonth, 6);
    });

    test('isEthiopianLeapYear', () {
      expect(EthiopianDate.isEthiopianLeapYear(2015), isTrue); // 2015%4=3
      expect(EthiopianDate.isEthiopianLeapYear(2019), isTrue); // 2019%4=3
      expect(EthiopianDate.isEthiopianLeapYear(2017), isFalse);
      expect(EthiopianDate.isEthiopianLeapYear(2016), isFalse);
    });

    test('addMonths wraps year correctly forward', () {
      final d = EthiopianDate(year: 2017, month: 12, day: 15);
      expect(d.addMonths(1).month, 13);
      expect(d.addMonths(1).year, 2017);
      expect(d.addMonths(2).month, 1);
      expect(d.addMonths(2).year, 2018);
    });

    test('addMonths handles negative (previous month)', () {
      final d = EthiopianDate(year: 2017, month: 1, day: 10);
      final prev = d.addMonths(-1);
      expect(prev.month, 13);
      expect(prev.year, 2016);
    });

    test('addMonths handles negative (previous month)', () {
      final d = EthiopianDate(year: 2017, month: 1, day: 10);
      final prev = d.addMonths(-1);
      expect(prev.month, 13);
      expect(prev.year, 2016);
      // Day 10 doesn't exist in Pagume 2016 (only 5 days), so it clamps to 5
      expect(prev.day, 5);
    });

    // Also worth adding a case where the day fits cleanly
    test('addMonths negative with valid day in target month', () {
      final d = EthiopianDate(year: 2017, month: 1, day: 3);
      final prev = d.addMonths(-1);
      expect(prev.year, 2016);
      expect(prev.month, 13);
      expect(prev.day, 3); // day 3 is valid in Pagume, no clamping
    });

    test('addMonths handles negative (previous month)', () {
      final d = EthiopianDate(year: 2017, month: 1, day: 10);
      final prev = d.addMonths(-1);
      expect(prev.month, 13);
      expect(prev.year, 2016);
      // Day 10 doesn't exist in Pagume 2016 (only 5 days), so it clamps to 5
      expect(prev.day, 5);
    });

    // Also worth adding a case where the day fits cleanly
    test('addMonths negative with valid day in target month', () {
      final d = EthiopianDate(year: 2017, month: 1, day: 3);
      final prev = d.addMonths(-1);
      expect(prev.year, 2016);
      expect(prev.month, 13);
      expect(prev.day, 3); // day 3 is valid in Pagume, no clamping
    });

    test('toAmharicString formats correctly', () {
      final d = EthiopianDate(year: 2017, month: 2, day: 9);
      expect(d.toAmharicString(), '9 ጥቅምት 2017');
    });

    test('EthiopicNumerals.of returns correct symbols', () {
      expect(EthiopicNumerals.of(1), '፩');
      expect(EthiopicNumerals.of(10), '፲');
      expect(EthiopicNumerals.of(20), '፳');
      expect(EthiopicNumerals.of(30), '፴');
    });
  });

  group('EtDateConverter.toEthiopian (GC → ET)', () {
    // Reference dates verified against ethiopiancalendar.net and
    // Reingold & Dershowitz "Calendrical Calculations".

    test('11 Sep 2024 GC = 1 Meskerem 2017 ET', () {
      final et = EtDateConverter.toEthiopian(DateTime(2024, 9, 11));
      expect(et.year, 2017);
      expect(et.month, 1);
      expect(et.day, 1);
    });

    test('19 Oct 2024 GC = 9 Tikimt 2017 ET', () {
      final et = EtDateConverter.toEthiopian(DateTime(2024, 10, 19));
      expect(et.year, 2017);
      expect(et.month, 2);
      expect(et.day, 9);
    });

    test('1 Jan 2024 GC = 22 Tahsas 2016 ET', () {
      final et = EtDateConverter.toEthiopian(DateTime(2024, 1, 1));
      expect(et.year, 2016);
      expect(et.month, 4);
      expect(et.day, 22);
    });

    // 2016 ET New Year is Sep 12 (because 2015 ET was a leap year)
    test('12 Sep 2023 GC = 1 Meskerem 2016 ET', () {
      final et = EtDateConverter.toEthiopian(DateTime(2023, 9, 12));
      expect(et.year, 2016);
      expect(et.month, 1);
      expect(et.day, 1);
    });

    test('11 Sep 2023 GC = Pagume 6 2015 ET (last day of leap year)', () {
      final et = EtDateConverter.toEthiopian(DateTime(2023, 9, 11));
      expect(et.year, 2015);
      expect(et.month, 13);
      expect(et.day, 6);
    });

    // 2000 ET New Year: 1999 ET was leap (1999%4=3), so New Year = Sep 12
    test('12 Sep 2007 GC = 1 Meskerem 2000 ET', () {
      final et = EtDateConverter.toEthiopian(DateTime(2007, 9, 12));
      expect(et.year, 2000);
      expect(et.month, 1);
      expect(et.day, 1);
    });
  });

  group('EtDateConverter.toGregorian (ET → GC)', () {
    test('1 Meskerem 2017 ET → 11 Sep 2024 GC', () {
      final gc = EtDateConverter.toGregorian(
        EthiopianDate(year: 2017, month: 1, day: 1),
      );
      expect(gc.year, 2024);
      expect(gc.month, 9);
      expect(gc.day, 11);
    });

    test('9 Tikimt 2017 ET → 19 Oct 2024 GC', () {
      final gc = EtDateConverter.toGregorian(
        EthiopianDate(year: 2017, month: 2, day: 9),
      );
      expect(gc.year, 2024);
      expect(gc.month, 10);
      expect(gc.day, 19);
    });

    test('1 Meskerem 2000 ET → 12 Sep 2007 GC', () {
      final gc = EtDateConverter.toGregorian(
        EthiopianDate(year: 2000, month: 1, day: 1),
      );
      expect(gc.year, 2007);
      expect(gc.month, 9);
      expect(gc.day, 12);
    });

    test('Pagume 6 2015 ET → 11 Sep 2023 GC', () {
      final gc = EtDateConverter.toGregorian(
        EthiopianDate(year: 2015, month: 13, day: 6),
      );
      expect(gc.year, 2023);
      expect(gc.month, 9);
      expect(gc.day, 11);
    });
  });

  group('Round-trip conversions', () {
    void roundTripGC(int y, int m, int d) {
      final original = DateTime.utc(y, m, d);
      final et = EtDateConverter.toEthiopian(original);
      final back = EtDateConverter.toGregorian(et);
      expect(back.year, y, reason: 'GC→ET→GC year mismatch for $y-$m-$d');
      expect(back.month, m, reason: 'GC→ET→GC month mismatch for $y-$m-$d');
      expect(back.day, d, reason: 'GC→ET→GC day mismatch for $y-$m-$d');
    }

    void roundTripET(int y, int m, int d) {
      final original = EthiopianDate(year: y, month: m, day: d);
      final gc = EtDateConverter.toGregorian(original);
      final back = EtDateConverter.toEthiopian(gc);
      expect(back.year, y, reason: 'ET→GC→ET year mismatch for $y-$m-$d');
      expect(back.month, m, reason: 'ET→GC→ET month mismatch for $y-$m-$d');
      expect(back.day, d, reason: 'ET→GC→ET day mismatch for $y-$m-$d');
    }

    test('GC → ET → GC', () {
      roundTripGC(2024, 1, 1);
      roundTripGC(2024, 6, 15);
      roundTripGC(2024, 9, 11);
      roundTripGC(2023, 9, 12);
      roundTripGC(2000, 1, 1);
      roundTripGC(1990, 5, 20);
    });

    test('ET → GC → ET', () {
      roundTripET(2017, 1, 1);
      roundTripET(2017, 6, 15);
      roundTripET(2017, 13, 3);
      roundTripET(2016, 12, 30);
      roundTripET(2000, 1, 1);
      roundTripET(1990, 7, 22);
      roundTripET(2015, 13, 6); // last day of ET leap year
    });
  });

  group('Utilities', () {
    test('today() returns a valid EthiopianDate', () {
      final t = EtDateConverter.today();
      expect(t.year, greaterThan(2000));
      expect(t.month, inInclusiveRange(1, 13));
      expect(t.day, inInclusiveRange(1, 30));
    });

    test('isSameDay', () {
      expect(
        EtDateConverter.isSameDay(
          DateTime(2024, 10, 19),
          DateTime(2024, 10, 19),
        ),
        isTrue,
      );
      expect(
        EtDateConverter.isSameDay(
          DateTime(2024, 10, 19),
          DateTime(2024, 10, 20),
        ),
        isFalse,
      );
    });
  });
}
