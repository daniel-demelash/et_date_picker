import 'package:flutter/foundation.dart';
import 'ethiopian_date.dart';
import 'et_date_converter.dart';

/// Which screen the picker is currently showing.
enum EthiopianPickerView {
  /// The 7-column day grid for one ET month.
  days,

  /// A grid of the 13 ET months for the focused year.
  months,

  /// A scrollable grid of years, centered on the current year.
  years,
}

class EthiopianCalendarController extends ChangeNotifier {
  EthiopianCalendarController({EthiopianDate? initialDate}) {
    final today = EtDateConverter.today();
    _focusedEtMonth = (initialDate ?? today).firstDayOfMonth;
    _selectedEtDate = initialDate;
  }

  late EthiopianDate _focusedEtMonth;
  EthiopianDate? _selectedEtDate;
  EthiopianPickerView _view = EthiopianPickerView.days;

  /// The Ethiopian month currently displayed (always day 1).
  EthiopianDate get focusedEtMonth => _focusedEtMonth;

  /// The currently selected Ethiopian date (null if nothing selected yet).
  EthiopianDate? get selectedEtDate => _selectedEtDate;

  /// Which screen is currently visible — days, months, or years.
  EthiopianPickerView get view => _view;

  /// The focused month as a Gregorian [DateTime] (day 1 of the ET month).
  DateTime get focusedDay => EtDateConverter.toGregorian(_focusedEtMonth);

  /// The selected day as a Gregorian [DateTime], or null.
  DateTime? get selectedDay => _selectedEtDate != null
      ? EtDateConverter.toGregorian(_selectedEtDate!)
      : null;

  /// Number of grid rows needed to display [focusedEtMonth] (5 or 6),
  /// based on which day-of-week ET day 1 falls on and the month's length.
  int get focusedMonthRowCount {
    final gc = EtDateConverter.toGregorian(_focusedEtMonth);
    final startOffset = gc.weekday % 7; // Sun=0 … Sat=6
    final daysInMonth = _focusedEtMonth.daysInMonth;
    final totalCells = startOffset + daysInMonth;
    return (totalCells / 7).ceil();
  }

  // ── Day-view navigation ────────────────────────────────────────────────

  /// Step forward one ET month (header "next" arrow).
  void nextMonth() {
    _focusedEtMonth = _focusedEtMonth.addMonths(1);
    notifyListeners();
  }

  /// Step backward one ET month (header "previous" arrow).
  void previousMonth() {
    _focusedEtMonth = _focusedEtMonth.addMonths(-1);
    notifyListeners();
  }

  /// Jump directly to the ET month containing [et] — used to sync the
  /// header when the user swipes the page view instead of using the arrows.
  void jumpToEtMonth(EthiopianDate et) {
    final target = et.firstDayOfMonth;
    if (target.year == _focusedEtMonth.year &&
        target.month == _focusedEtMonth.month) {
      return;
    }
    _focusedEtMonth = target;
    notifyListeners();
  }

  /// Called when the user taps a day cell.
  void selectDay(DateTime gregorianDay) {
    _selectedEtDate = EtDateConverter.toEthiopian(gregorianDay);
    _focusedEtMonth = _selectedEtDate!.firstDayOfMonth;
    notifyListeners();
  }

  /// Clears the current selection.
  void clearSelection() {
    _selectedEtDate = null;
    notifyListeners();
  }

  // ── View switching (header tap → month grid → year grid) ──────────────

  /// Opens the year-grid view. Triggered by tapping the header.
  void showYearPicker() {
    _view = EthiopianPickerView.years;
    notifyListeners();
  }

  /// Opens the month-grid (13 months) view for the focused year.
  void showMonthPicker() {
    _view = EthiopianPickerView.months;
    notifyListeners();
  }

  /// Returns to the day grid without changing the focused month.
  void showDayView() {
    _view = EthiopianPickerView.days;
    notifyListeners();
  }

  /// Called when a year is tapped in the year grid — moves focus to that
  /// year (keeping the current month number) and advances to the month grid.
  void selectYear(int year) {
    _focusedEtMonth = EthiopianDate(
      year: year,
      month: _focusedEtMonth.month,
      day: 1,
    );
    _view = EthiopianPickerView.months;
    notifyListeners();
  }

  /// Called when a month is tapped in the month grid — moves focus to that
  /// month and returns to the day grid.
  void selectMonth(int month) {
    _focusedEtMonth = EthiopianDate(
      year: _focusedEtMonth.year,
      month: month,
      day: 1,
    );
    _view = EthiopianPickerView.days;
    notifyListeners();
  }
}
