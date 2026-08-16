# et_date_picker

A Flutter package that lets users pick dates on the Ethiopian (Ge'ez) calendar. Developers can use either the Ethiopian date or the auto-converted Gregorian date, whichever fits their app.

## Screenshots

<table>
  <tr>
    <td align="center"><b>Day picker</b></td>
    <td align="center"><b>Dark theme</b></td>
    <td align="center"><b>Year picker</b></td>
  </tr>
  <tr>
    <td align="center"><img src="screenshots/screenshot3.jpg" width="250" alt="Day picker — light theme"/></td>
    <td align="center"><img src="screenshots/screenshot2.jpg" width="250" alt="Day picker — dark theme with ET/GC preview"/></td>
    <td align="center"><img src="screenshots/screenshot1.jpg" width="250" alt="Year grid picker"/></td>
  </tr>
</table>

---

## Features

- Full Ethiopian calendar UI with Amharic month names and day-of-week labels
- Bidirectional date conversion — Ethiopian ↔ Gregorian
- Ethiopian time conversion (የኢትዮጵያ ሰዓት) — sunrise-based clock with ቀን / ሌሊት periods
- Correct 13-month calendar including Pagume (5 or 6 days)
- Optional Ethiopic numeral rendering (፩ ፪ ፫ …) with bundled Noto Sans Ethiopic font
- Swipeable month navigation with smooth page transitions
- Year and month grid picker — tap the header to jump to any year or month
- Dialog presentation via `showEthiopianDatePickerDialog`
- `initialDate`, `firstDate`, and `lastDate` accept Gregorian `DateTime` — converted internally for the Ethiopian calendar UI
- Responsive dialog sizing — max 360dp width, clamped to fit smaller phones (Material 3 aligned)
- Localized Cancel / OK button labels via `MaterialLocalizations` (overridable)
- Optional ET/GC selected-date preview strip in the dialog
- Fully themeable — respects your app's `ColorScheme`
- Unit tests covering date conversion edge cases including leap years

---

## Getting started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  et_date_picker: ^0.0.4
```

Then run:

```bash
flutter pub get
```

Import in your Dart file:

```dart
import 'package:et_date_picker/et_date_picker.dart';
```

---

## Usage

### Dialog

```dart
final today = DateTime.now();
final result = await showEthiopianDatePickerDialog(
  context: context,
  initialDate: today,
);

if (result != null) {
  print(result.ethiopianDate.toAmharicString());
  print(result.gregorianDate);
}
```

The dialog returns both calendar representations on confirm. Tap the header to open the year grid, pick a year, then pick a month — or swipe left/right to move one month at a time. Button labels follow your app locale (`Cancel` / `OK` in English).

### Selected date preview

By default the ET/GC preview strip above the buttons is hidden. Enable it when you want users to see both calendars before confirming:

```dart
final result = await showEthiopianDatePickerDialog(
  context: context,
  showSelectedDatePreview: true,
);
```

### Ethiopic numerals

```dart
final result = await showEthiopianDatePickerDialog(
  context: context,
  useEthiopicNumerals: true, // renders ፩ ፪ ፫ instead of 1 2 3
);
```

When `useEthiopicNumerals` is true, day numbers use the bundled Noto Sans Ethiopic font.

### Setting a date range

```dart
final result = await showEthiopianDatePickerDialog(
  context: context,
  firstDate: DateTime(2007, 9, 12),
  lastDate: DateTime(2024, 9, 11),
);
```

`initialDate`, `firstDate`, and `lastDate` accept Gregorian `DateTime` values. Only the calendar date (year, month, day) is used; the picker converts them internally for the Ethiopian calendar UI.

### Custom theme

```dart
final result = await showEthiopianDatePickerDialog(
  context: context,
  theme: EthiopianDatePickerTheme(
    dayTextStyle: TextStyle(color: Colors.black87),
    todayTextStyle: TextStyle(color: Colors.green.shade400),
    selectedDayTextStyle: TextStyle(
      color: Colors.white,
      backgroundColor: Colors.green.shade800,
      fontWeight: FontWeight.bold,
    ),
    confirmButtonStyle: ButtonStyle(
      backgroundColor: WidgetStatePropertyAll(Colors.green.shade800),
      foregroundColor: WidgetStatePropertyAll(Colors.white),
    ),
  ),
);
```

Unset theme properties fall back to the ambient `ThemeData` / `ColorScheme`.

### Date conversion only (no UI)

```dart
// Gregorian → Ethiopian
final etDate = EtDateConverter.toEthiopian(DateTime(2024, 10, 19));
print(etDate.toAmharicString()); // 9 ጥቅምት 2017
print(etDate.monthName);         // ጥቅምት
print(etDate.year);              // 2017
print(etDate.month);             // 2
print(etDate.day);               // 9

// Ethiopian → Gregorian
final gcDate = EtDateConverter.toGregorian(
  EthiopianDate(year: 2017, month: 2, day: 9),
);
print(gcDate); // 2024-10-19

// Today in Ethiopian calendar
final today = EtDateConverter.today();
```

### Time conversion

Ethiopian time counts from sunrise — standard 6:00 AM equals ET 12:00 ቀን.

```dart
// Standard DateTime → Ethiopian time
final etTime = EtDateConverter.toEthiopianTime(DateTime.now());
print(etTime.format()); // e.g. "3:30 ቀን"

// From explicit hour/minute/second (24-hour standard clock)
final etTime2 = EtDateConverter.toEthiopianTimeFromParts(
  hour: 15,
  minute: 30,
);

// Combined date + time
final etDateTime = EtDateConverter.toEthiopianDateTime(DateTime.now());
print(etDateTime.format()); // e.g. "9 ጥቅምት 2017 3:30 ቀን"

// Back to standard 24-hour clock
final standardHour = EtDateConverter.toStandardHour(etTime);
```

---

## Ethiopian calendar basics

The Ethiopian calendar (Ge'ez calendar) differs from the Gregorian calendar in a few key ways:

| | Ethiopian | Gregorian |
|---|---|---|
| Months | 13 | 12 |
| Days per month | 30 (fixed) | 28–31 |
| 13th month (Pagume) | 5 days (6 in leap year) | — |
| New Year | ~11 Sep (12 Sep after leap year) | 1 Jan |
| Year difference | ~7–8 years behind | — |

### Month names

| # | Amharic | Gregorian equivalent |
|---|---|---|
| 1 | መስከረም (Meskerem) | Sep – Oct |
| 2 | ጥቅምት (Tikimt) | Oct – Nov |
| 3 | ኅዳር (Hidar) | Nov – Dec |
| 4 | ታኅሣሥ (Tahsas) | Dec – Jan |
| 5 | ጥር (Tir) | Jan – Feb |
| 6 | የካቲት (Yekatit) | Feb – Mar |
| 7 | መጋቢት (Megabit) | Mar – Apr |
| 8 | ሚያዝያ (Miazia) | Apr – May |
| 9 | ግንቦት (Ginbot) | May – Jun |
| 10 | ሰኔ (Sene) | Jun – Jul |
| 11 | ሐምሌ (Hamle) | Jul – Aug |
| 12 | ነሐሴ (Nehase) | Aug – Sep |
| 13 | ጳጉሜ (Pagume) | Sep (5–6 days) |

---

## API reference

### `EthiopianDate`

```dart
EthiopianDate({
  required int year,
  required int month,  // 1–13
  required int day,    // 1–30 (1–6 for Pagume)
})
```

| Property / Method | Description |
|---|---|
| `monthName` | Amharic name of the month |
| `daysInMonth` | 30, or 5/6 for Pagume |
| `isPagume` | Whether this is the 13th month |
| `firstDayOfMonth` | Same year/month, day 1 |
| `lastDayOfMonth` | Same year/month, last valid day |
| `copyWith(...)` | Returns a copy with updated fields |
| `addMonths(int n)` | Navigate forward/backward by months |
| `toAmharicString()` | e.g. `"9 ጥቅምት 2017"` |
| `isEthiopianLeapYear(int year)` | Static — true when `year % 4 == 3` |

### `EtDateConverter`

| Method | Description |
|---|---|
| `toEthiopian(DateTime)` | Gregorian → Ethiopian date |
| `toGregorian(EthiopianDate)` | Ethiopian → Gregorian date |
| `today()` | Current date as `EthiopianDate` |
| `isSameDay(DateTime, DateTime)` | Day equality check |
| `isLeapYear(int year)` | Whether an Ethiopian year is a leap year |
| `toEthiopianTime(DateTime)` | Standard time → `EthiopianTime` |
| `toEthiopianTimeFromParts({hour, minute, second})` | Build `EthiopianTime` from clock parts |
| `toStandardHour(EthiopianTime)` | Ethiopian time → standard 24-hour hour |
| `toEthiopianDateTime(DateTime)` | Combined `EthiopianDateTime` |

### `EthiopianTime`

| Property / Method     | Description                     |
| -----------------------| ---------------------------------|
| `hour`                | 12-hour dial value (1–12)       |
| `minute`, `second`    | Same as standard clock          |
| `isDay`, `isNight`    | Whether the period is ቀን or ሌሊት |
| `periodLabel`         | `"ቀን"` or `"ሌሊት"`               |
| `format()`            | e.g. `"3:30 ቀን"`                |
| `formatWithSeconds()` | e.g. `"3:30:45 ቀን"`             |

### `showEthiopianDatePickerDialog`

```dart
Future<EthiopianPickerResult?> showEthiopianDatePickerDialog({
  required BuildContext context,
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
  bool useEthiopicNumerals = false,
  bool showSelectedDatePreview = false,
  EthiopianDatePickerTheme? theme,
  String? cancelText,
  String? confirmText,
  double width = 360, // max width; clamped to available screen space
  EdgeInsets insetPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 24),
  ShapeBorder? shape,
})
```

`width` defaults to 360 (Flutter Material 3 date picker size) but is automatically clamped to fit smaller screens. `insetPadding` matches Flutter's Material date picker defaults.

`cancelText` and `confirmText` are optional. When omitted, they follow the app locale via `MaterialLocalizations` — the same behavior as Flutter's `showDatePicker` (`Cancel` / `OK` in English). For Amharic buttons:

```dart
await showEthiopianDatePickerDialog(
  context: context,
  cancelText: 'ይቅር',
  confirmText: 'ምረጥ',
);
```

Returns `null` if the user cancels. On confirm, returns both calendar representations:

```dart
result.ethiopianDate  // EthiopianDate
result.gregorianDate  // DateTime
```

### `EthiopianCalendarController`

```dart
EthiopianCalendarController({
  DateTime? initialDate,
  EthiopianDate? initialEthiopianDate,
})
```

Provide either `initialDate` (Gregorian) or `initialEthiopianDate`, not both. Use the controller with `EthiopianDatePicker` for programmatic navigation and selection.

### `EthiopianDatePicker`

Embed the picker directly in your UI (without the dialog wrapper):

```dart
EthiopianDatePicker(
  initialDate: DateTime(2024, 10, 19),
  firstDate: DateTime(2000, 1, 1),
  lastDate: DateTime(2030, 12, 31),
  onDateSelected: (ethiopianDate, gregorianDate) {
    // ...
  },
)
```

`initialDate`, `firstDate`, and `lastDate` are Gregorian `DateTime` values, same as the dialog API.

### Dialog sizing constants

| Name | Value | Description |
|---|---|---|
| `kEthiopianDatePickerMaxDialogWidth` | `360` | Max dialog width (Material 3) |
| `kEthiopianDatePickerInsetPadding` | `16×24` | Default screen inset padding |
| `resolveEthiopianDatePickerDialogWidth()` | — | Clamps width to available screen space |

### `EthiopianDatePickerTheme`

Key styling hooks: `backgroundColor`, `headerTextStyle`, `dowTextStyle`, `dayTextStyle`, `todayTextStyle`, `selectedDayTextStyle`, `disabledDayTextStyle`, `outsideDayTextStyle`, `selectedPreviewLabelStyle`, `selectedPreviewValueStyle`, `confirmButtonStyle`, `cancelButtonStyle`, `dayCellHeight`, `dayCellMargin`.

Use `selectedDayTextStyle.backgroundColor` for the selected-day circle fill and `todayTextStyle.color` for today's border ring.

---

## Upgrading from 0.0.2

`initialDate`, `firstDate`, and `lastDate` now take Gregorian `DateTime` instead of `EthiopianDate`.

```dart
// Before (0.0.2)
initialDate: EthiopianDate(year: 2017, month: 2, day: 9),
firstDate: EthiopianDate(year: 2015, month: 1, day: 1),

// After (0.0.3)
initialDate: DateTime(2024, 10, 19),
firstDate: DateTime(2007, 9, 12),
```

If you already have an `EthiopianDate`, convert it with `EtDateConverter.toGregorian(etDate)`. If you have a previous picker result, use `result.gregorianDate` directly.

## Upgrading from 0.0.3

- `cancelLabel` / `confirmLabel` were renamed to `cancelText` / `confirmText` and are now optional. Omit them to use localized `Cancel` / `OK` labels.

```dart
// Before (0.0.3)
cancelLabel: 'Cancel',
confirmLabel: 'OK',

// After (0.0.4) — localized by default
// or override explicitly:
cancelText: 'ይቅር',
confirmText: 'ምረጥ',
```

- The ET/GC preview strip is now opt-in via `showSelectedDatePreview: true` (default `false`).
- Dialog `insetPadding` default changed from `24×40` to `16×24` (Material aligned). Dialog width is clamped on narrow screens.

---

## Contributing

Contributions are welcome. Please open an issue before submitting a pull request for significant changes.

When adding features, ensure:

- Conversion logic is covered by unit tests in `test/et_date_picker_test.dart`
- The example app demonstrates the new feature

---

## License

MIT License — see [LICENSE](LICENSE) for details.
