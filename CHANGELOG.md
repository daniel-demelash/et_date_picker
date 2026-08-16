## 0.0.3

- **Breaking:** `initialDate`, `firstDate`, and `lastDate` on `EthiopianDatePicker` and `showEthiopianDatePickerDialog` now accept Gregorian `DateTime` instead of `EthiopianDate`. Only the calendar date (year, month, day) is used; values are converted internally for the Ethiopian calendar UI.
- `EthiopianCalendarController` accepts either `initialDate` (Gregorian `DateTime`) or `initialEthiopianDate` (`EthiopianDate`), not both.

## 0.0.2

- Added `homepage` and `repository` URLs to pubspec
- Added pub.dev `screenshots` metadata for package listing

## 0.0.1

- Initial release
- Ethiopian date picker widget (EthiopianDatePicker)
- Dialog date picker (showEthiopianDatePickerDialog)
- Bidirectional date conversion — ET ↔ Gregorian (EtDateConverter)
- Ethiopian time conversion (toEthiopianTime)
- EthiopianCalendarController for programmatic navigation
- Year/month grid picker (tap header to jump to any year)
- Custom theming via EthiopianDatePickerTheme
- Ethiopic numeral support (፩ ፪ ፫ …)