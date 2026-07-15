import 'package:flutter/material.dart';
import 'ethiopian_calendar_controller.dart';
import 'ethiopian_date.dart';
import 'ethiopian_date_picker_theme.dart';
import 'et_date_converter.dart';

typedef EthiopianDateSelectedCallback =
    void Function(EthiopianDate ethiopianDate, DateTime gregorianDate);

/// Ethiopian calendar date picker — pure Flutter, no third-party calendar deps.
///
/// Tap the header to jump straight to a year, then a month, instead of
/// paging one month at a time. Three internal views:
/// - **Days** — the default 7-column day grid for one ET month
/// - **Months** — a 13-cell grid of ET month names for the focused year
/// - **Years** — a scrollable grid of years
///
/// Supports swipe left/right to navigate months in the day view.
class EthiopianDatePicker extends StatefulWidget {
  const EthiopianDatePicker({
    super.key,
    this.controller,
    this.onDateSelected,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.useEthiopicNumerals = false,
    this.theme,
  });

  final EthiopianCalendarController? controller;
  final EthiopianDateSelectedCallback? onDateSelected;
  final EthiopianDate? initialDate;
  final EthiopianDate? firstDate;
  final EthiopianDate? lastDate;
  final bool useEthiopicNumerals;

  final EthiopianDatePickerTheme? theme;

  @override
  State<EthiopianDatePicker> createState() => _EthiopianDatePickerState();
}

class _EthiopianDatePickerState extends State<EthiopianDatePicker> {
  late EthiopianCalendarController _controller;
  bool _ownsController = false;
  late PageController _pageController;
  bool _syncingPage = false;

  static const int _initialPage = 1200; // ~100 years of months from anchor
  late EthiopianDate _anchorMonth;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = EthiopianCalendarController(
        initialDate: widget.initialDate,
      );
      _ownsController = true;
    }
    _controller.addListener(_onControllerChanged);

    _anchorMonth =
        (widget.firstDate ?? EthiopianDate(year: 2000, month: 1, day: 1))
            .firstDayOfMonth;

    _pageController = PageController(
      initialPage: _pageIndexOf(_controller.focusedEtMonth),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    if (_ownsController) _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (_controller.view == EthiopianPickerView.days) {
      _syncPageToFocusedMonth();
    }
    setState(() {});
  }

  /// Keeps the day-view [PageController] aligned with [focusedEtMonth].
  ///
  /// When switching back from the year/month grids, the day view is rebuilt
  /// while the controller still points at the previously visible page (often
  /// today). Without an immediate jump, [PageView.onPageChanged] fires for
  /// that stale page and overwrites the user's year/month selection.
  void _syncPageToFocusedMonth() {
    final targetPage = _pageIndexOf(_controller.focusedEtMonth);

    void apply() {
      if (!_pageController.hasClients) return;
      if (_pageController.page?.round() == targetPage) return;
      _syncingPage = true;
      _pageController.jumpToPage(targetPage);
      _syncingPage = false;
    }

    if (_pageController.hasClients) {
      apply();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => apply());
    }
  }

  int _pageIndexOf(EthiopianDate month) {
    final anchorTotalMonths = _anchorMonth.year * 13 + (_anchorMonth.month - 1);
    final monthTotalMonths = month.year * 13 + (month.month - 1);
    return _initialPage + (monthTotalMonths - anchorTotalMonths);
  }

  EthiopianDate _monthForPage(int page) {
    final anchorTotalMonths = _anchorMonth.year * 13 + (_anchorMonth.month - 1);
    final totalMonths = anchorTotalMonths + (page - _initialPage);
    final year = totalMonths ~/ 13;
    final month = totalMonths % 13 + 1;
    return EthiopianDate(year: year, month: month, day: 1);
  }

  bool _isBeforeFirstDate(EthiopianDate date) {
    final first = widget.firstDate;
    if (first == null) return false;
    if (date.year != first.year) return date.year < first.year;
    if (date.month != first.month) return date.month < first.month;
    return date.day < first.day;
  }

  bool _isAfterLastDate(EthiopianDate date) {
    final last = widget.lastDate;
    if (last == null) return false;
    if (date.year != last.year) return date.year > last.year;
    if (date.month != last.month) return date.month > last.month;
    return date.day > last.day;
  }

  bool _isDisabled(EthiopianDate date) =>
      _isBeforeFirstDate(date) || _isAfterLastDate(date);

  /// Whether any day in [year]/[month] is selectable given [firstDate]/[lastDate].
  bool _isMonthInRange(int year, int month) {
    final first = widget.firstDate;
    if (first != null) {
      if (year < first.year || (year == first.year && month < first.month)) {
        return false;
      }
    }
    final last = widget.lastDate;
    if (last != null) {
      if (year > last.year || (year == last.year && month > last.month)) {
        return false;
      }
    }
    return true;
  }

  /// Year range available in the year grid, derived from firstDate/lastDate
  /// (defaulting to a ±100 year span around today if unset).
  ({int min, int max}) get _yearRange {
    final todayYear = EtDateConverter.today().year;
    final min = widget.firstDate?.year ?? (todayYear - 100);
    final max = widget.lastDate?.year ?? (todayYear + 100);
    return (min: min, max: max);
  }

  EthiopianDatePickerThemeData _resolveTheme(BuildContext context) {
    return EthiopianDatePickerTheme.resolve(context, theme: widget.theme);
  }

  @override
  Widget build(BuildContext context) {
    final pickerTheme = _resolveTheme(context);

    return ColoredBox(
      color: pickerTheme.backgroundColor,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: switch (_controller.view) {
          EthiopianPickerView.days => _buildDayView(pickerTheme),
          EthiopianPickerView.months => _buildMonthView(pickerTheme),
          EthiopianPickerView.years => _buildYearView(pickerTheme),
        },
      ),
    );
  }

  // ── Day view (default) ────────────────────────────────────────────────

  Widget _buildDayView(EthiopianDatePickerThemeData pickerTheme) {
    final currentRows = _controller.focusedMonthRowCount;
    final cellHeight = pickerTheme.dayCellHeight;
    final height = currentRows < 6 ? 5 * cellHeight : currentRows * cellHeight;

    return Column(
      key: const ValueKey('days'),
      mainAxisSize: MainAxisSize.min,
      children: [
        _EthiopianHeader(
          controller: _controller,
          theme: pickerTheme,
          onTap: _controller.showYearPicker,
        ),
        _DowRow(theme: pickerTheme),
        AnimatedContainer(
          height: height,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (page) {
              if (_syncingPage) return;
              final month = _monthForPage(page);
              _controller.jumpToEtMonth(month);
            },
            itemBuilder: (context, page) {
              final month = _monthForPage(page);
              return _MonthGrid(
                month: month,
                selectedEtDate: _controller.selectedEtDate,
                today: EtDateConverter.today(),
                useEthiopicNumerals: widget.useEthiopicNumerals,
                theme: pickerTheme,
                isDisabled: _isDisabled,
                onDayTap: (etDate) {
                  final gcDate = EtDateConverter.toGregorian(etDate);
                  _controller.selectDay(gcDate);
                  widget.onDateSelected?.call(etDate, gcDate);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Month-grid view ───────────────────────────────────────────────────

  Widget _buildMonthView(EthiopianDatePickerThemeData pickerTheme) {
    final year = _controller.focusedEtMonth.year;

    return Column(
      key: const ValueKey('months'),
      mainAxisSize: MainAxisSize.min,
      children: [
        _SimpleHeader(
          label: '$year',
          theme: pickerTheme,
          onPrev: () => _controller.selectYear(year - 1),
          onNext: () => _controller.selectYear(year + 1),
          onLabelTap: _controller.showYearPicker,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisExtent: 56,
            ),
            itemCount: 13,
            itemBuilder: (context, index) {
              final monthNumber = index + 1;
              final isFocused = monthNumber == _controller.focusedEtMonth.month;
              final isEnabled = _isMonthInRange(year, monthNumber);
              return _GridChoiceCell(
                label: EthiopianMonths.nameOf(monthNumber),
                isSelected: isFocused && isEnabled,
                isDisabled: !isEnabled,
                theme: pickerTheme,
                onTap: isEnabled
                    ? () => _controller.selectMonth(monthNumber)
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Year-grid view ────────────────────────────────────────────────────

  Widget _buildYearView(EthiopianDatePickerThemeData pickerTheme) {
    final range = _yearRange;
    final years = List.generate(
      range.max - range.min + 1,
      (i) => range.min + i,
    );
    final focusedYear = _controller.focusedEtMonth.year;

    // Scroll so the focused year is roughly centered on first open.
    final initialIndex = years.indexOf(focusedYear).clamp(0, years.length - 1);
    final scrollController = ScrollController(
      initialScrollOffset: (initialIndex ~/ 3) * 56.0 - 100,
    );

    return Column(
      key: const ValueKey('years'),
      mainAxisSize: MainAxisSize.min,
      children: [
        _SimpleHeader(
          label: '${range.min} – ${range.max}',
          theme: pickerTheme,
          onPrev: null, // year range is fixed by firstDate/lastDate
          onNext: null,
          onLabelTap: null,
        ),
        SizedBox(
          height: 5 * 56.0,
          child: GridView.builder(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(vertical: 8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisExtent: 56,
            ),
            itemCount: years.length,
            itemBuilder: (context, index) {
              final year = years[index];
              final isFocused = year == focusedYear;
              return _GridChoiceCell(
                label: '$year',
                isSelected: isFocused,
                theme: pickerTheme,
                onTap: () => _controller.selectYear(year),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Month grid (day view) ────────────────────────────────────────────────────

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.selectedEtDate,
    required this.today,
    required this.useEthiopicNumerals,
    required this.theme,
    required this.isDisabled,
    required this.onDayTap,
  });

  final EthiopianDate month;
  final EthiopianDate? selectedEtDate;
  final EthiopianDate today;
  final bool useEthiopicNumerals;
  final EthiopianDatePickerThemeData theme;
  final bool Function(EthiopianDate) isDisabled;
  final void Function(EthiopianDate) onDayTap;

  int get _startDow {
    final gc = EtDateConverter.toGregorian(month.firstDayOfMonth);
    return gc.weekday % 7;
  }

  EthiopianDate get _prevMonth => month.addMonths(-1);

  @override
  Widget build(BuildContext context) {
    final daysInMonth = month.daysInMonth;
    final startOffset = _startDow;
    final totalCells = startOffset + daysInMonth;
    final rowCount = (totalCells / 7).ceil();

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisExtent: theme.dayCellHeight,
      ),
      itemCount: rowCount * 7,
      itemBuilder: (context, index) {
        final dayNumber = index - startOffset + 1;

        if (dayNumber < 1) {
          final prevDay = _prevMonth.daysInMonth + dayNumber;
          final label = useEthiopicNumerals
              ? EthiopicNumerals.of(prevDay)
              : prevDay.toString();
          return _DayCell(
            label: label,
            isSelected: false,
            isToday: false,
            isDisabled: true,
            isOutside: true,
            theme: theme,
            onTap: null,
            useEthiopicNumerals: useEthiopicNumerals,
          );
        }

        if (dayNumber > daysInMonth) {
          final nextDay = dayNumber - daysInMonth;
          final label = useEthiopicNumerals
              ? EthiopicNumerals.of(nextDay)
              : nextDay.toString();
          return _DayCell(
            label: label,
            isSelected: false,
            isToday: false,
            isDisabled: true,
            isOutside: true,
            theme: theme,
            onTap: null,
            useEthiopicNumerals: useEthiopicNumerals,
          );
        }

        final etDate = EthiopianDate(
          year: month.year,
          month: month.month,
          day: dayNumber,
        );

        final isSelected =
            selectedEtDate != null &&
            etDate.year == selectedEtDate!.year &&
            etDate.month == selectedEtDate!.month &&
            etDate.day == selectedEtDate!.day;

        final isToday =
            etDate.year == today.year &&
            etDate.month == today.month &&
            etDate.day == today.day;

        final disabled = isDisabled(etDate);

        final label = useEthiopicNumerals
            ? EthiopicNumerals.of(dayNumber)
            : dayNumber.toString();

        return _DayCell(
          label: label,
          isSelected: isSelected,
          isToday: isToday,
          isDisabled: disabled,
          isOutside: false,
          theme: theme,
          onTap: disabled ? null : () => onDayTap(etDate),
          useEthiopicNumerals: useEthiopicNumerals,
        );
      },
    );
  }
}

// ── Header (day view) — tappable to open year picker ─────────────────────────

class _EthiopianHeader extends StatelessWidget {
  const _EthiopianHeader({
    required this.controller,
    required this.theme,
    required this.onTap,
  });

  final EthiopianCalendarController controller;
  final EthiopianDatePickerThemeData theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final et = controller.focusedEtMonth;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left, color: theme.headerTextStyle.color),
          onPressed: controller.previousMonth,
          tooltip: 'ቀዳሚ ወር',
        ),
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${et.monthName}  ${et.year}',
                  style: theme.headerTextStyle,
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_drop_down,
                  color: theme.headerTextStyle.color,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.chevron_right, color: theme.headerTextStyle.color),
          onPressed: controller.nextMonth,
          tooltip: 'ቀጣይ ወር',
        ),
      ],
    );
  }
}

/// Header used by the month-grid and year-grid views — simpler, with
/// optional prev/next arrows (years view has none, since the range is fixed).
class _SimpleHeader extends StatelessWidget {
  const _SimpleHeader({
    required this.label,
    required this.theme,
    required this.onPrev,
    required this.onNext,
    required this.onLabelTap,
  });

  final String label;
  final EthiopianDatePickerThemeData theme;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final VoidCallback? onLabelTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left, color: theme.headerTextStyle.color),
          onPressed: onPrev,
        ),
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onLabelTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(label, style: theme.headerTextStyle),
          ),
        ),
        IconButton(
          icon: Icon(Icons.chevron_right, color: theme.headerTextStyle.color),
          onPressed: onNext,
        ),
      ],
    );
  }
}

// ── Day-of-week row ───────────────────────────────────────────────────────────

class _DowRow extends StatelessWidget {
  const _DowRow({required this.theme});
  final EthiopianDatePickerThemeData theme;

  static const _labels = ['እሁ', 'ሰኞ', 'ማክ', 'እሮ', 'ሐሙ', 'ዓር', 'ቅዳ'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _labels
          .map(
            (l) => Expanded(
              child: Center(child: Text(l, style: theme.dowTextStyle)),
            ),
          )
          .toList(),
    );
  }
}

// ── Day cell (day view) ───────────────────────────────────────────────────────

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.label,
    required this.isSelected,
    required this.isToday,
    required this.isDisabled,
    required this.isOutside,
    required this.theme,
    this.onTap,
    this.useEthiopicNumerals = false,
  });

  final String label;
  final bool isSelected;
  final bool isToday;
  final bool isDisabled;
  final bool isOutside;
  final EthiopianDatePickerThemeData theme;
  final VoidCallback? onTap;
  final bool useEthiopicNumerals;

  @override
  Widget build(BuildContext context) {
    Color? fillColor;
    Color? borderColor;
    Color textColor;

    if (isSelected) {
      fillColor = theme.selectedDayTextStyle.backgroundColor;
      textColor = theme.selectedDayTextStyle.color!;
    } else if (isToday) {
      borderColor = theme.todayTextStyle.color;
      textColor = theme.todayTextStyle.color!;
    } else if (isOutside) {
      textColor = theme.outsideDayTextStyle.color!;
    } else if (isDisabled) {
      textColor = theme.disabledDayTextStyle.color!;
    } else {
      textColor = theme.dayTextStyle.color!;
    }

    final baseStyle = isSelected
        ? theme.selectedDayTextStyle
        : isToday
        ? theme.todayTextStyle
        : isOutside
        ? theme.outsideDayTextStyle
        : isDisabled
        ? theme.disabledDayTextStyle
        : theme.dayTextStyle;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: theme.dayCellMargin,
        decoration: BoxDecoration(
          color: fillColor,
          shape: BoxShape.circle,
          border: borderColor != null
              ? Border.all(color: borderColor, width: 1.5)
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: baseStyle.copyWith(
            color: textColor,
            fontFamily: useEthiopicNumerals
                ? 'NotoSansEthiopic'
                : baseStyle.fontFamily,
          ),
        ),
      ),
    );
  }
}

// ── Month/Year grid choice cell (used by both month-grid and year-grid) ──────

class _GridChoiceCell extends StatelessWidget {
  const _GridChoiceCell({
    required this.label,
    required this.isSelected,
    required this.theme,
    this.onTap,
    this.isDisabled = false,
  });

  final String label;
  final bool isSelected;
  final EthiopianDatePickerThemeData theme;
  final VoidCallback? onTap;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final textStyle = isSelected
        ? theme.selectedDayTextStyle
        : isDisabled
        ? theme.disabledDayTextStyle
        : theme.dayTextStyle;

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isSelected ? theme.selectedDayTextStyle.backgroundColor : null,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? null
              : Border.all(
                  color: theme.dayTextStyle.color!.withValues(
                    alpha: isDisabled ? 0.08 : 0.15,
                  ),
                ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: textStyle.copyWith(
            fontSize: textStyle.fontSize ?? theme.dayTextStyle.fontSize ?? 14,
          ),
        ),
      ),
    );
  }
}
