import 'package:flutter/material.dart';

import 'ethiopian_date.dart';
import 'ethiopian_date_picker.dart';
import 'ethiopian_date_picker_theme.dart';

/// Shows the Ethiopian date picker in a [Dialog].
///
/// Returns an [EthiopianPickerResult] containing both the selected
/// [EthiopianDate] and its Gregorian [DateTime] equivalent, or null if the
/// user dismissed without selecting.
///
/// ## Example
///
/// ```dart
/// final result = await showEthiopianDatePickerDialog(context: context);
/// if (result != null) {
///   print('ET: ${result.ethiopianDate.toAmharicString()}');
///   print('GC: ${result.gregorianDate}');
/// }
/// ```
Future<EthiopianPickerResult?> showEthiopianDatePickerDialog({
  required BuildContext context,
  EthiopianDate? initialDate,
  EthiopianDate? firstDate,
  EthiopianDate? lastDate,
  bool useEthiopicNumerals = false,
  EthiopianDatePickerTheme? theme,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',

  /// Width of the dialog. Defaults to 360 which fits comfortably on most phones.
  double width = 360,

  /// Dialog outline shape. Defaults to a 20px rounded rectangle.
  ShapeBorder? shape,
}) async {
  return showDialog<EthiopianPickerResult>(
    context: context,
    builder: (context) => _EthiopianDatePickerDialog(
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      useEthiopicNumerals: useEthiopicNumerals,
      theme: theme,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      width: width,
      shape: shape,
    ),
  );
}

/// The dialog widget. Kept private — callers use [showEthiopianDatePickerDialog].
class _EthiopianDatePickerDialog extends StatefulWidget {
  const _EthiopianDatePickerDialog({
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.useEthiopicNumerals = false,
    this.theme,
    this.confirmLabel = 'ምረጥ',
    this.cancelLabel = 'ይቅር',
    this.width = 360,
    this.shape,
  });

  final EthiopianDate? initialDate;
  final EthiopianDate? firstDate;
  final EthiopianDate? lastDate;
  final bool useEthiopicNumerals;
  final EthiopianDatePickerTheme? theme;
  final String confirmLabel;
  final String cancelLabel;
  final double width;
  final ShapeBorder? shape;

  @override
  State<_EthiopianDatePickerDialog> createState() =>
      _EthiopianDatePickerDialogState();
}

class _EthiopianDatePickerDialogState
    extends State<_EthiopianDatePickerDialog> {
  EthiopianDate? _selectedEt;
  DateTime? _selectedGc;

  @override
  Widget build(BuildContext context) {
    final pickerTheme = EthiopianDatePickerTheme.resolve(
      context,
      theme: widget.theme,
    );

    return Dialog(
      backgroundColor: pickerTheme.backgroundColor,
      shape:
          widget.shape ??
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: SizedBox(
        width: widget.width,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              EthiopianDatePicker(
                initialDate: widget.initialDate,
                firstDate: widget.firstDate,
                lastDate: widget.lastDate,
                useEthiopicNumerals: widget.useEthiopicNumerals,
                theme: widget.theme,
                onDateSelected: (etDate, gcDate) {
                  setState(() {
                    _selectedEt = etDate;
                    _selectedGc = gcDate;
                  });
                },
              ),

              const SizedBox(height: 8),

              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: _selectedEt != null
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _SelectedDatePreview(
                          ethiopianDate: _selectedEt!,
                          gregorianDate: _selectedGc!,
                          theme: pickerTheme,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: pickerTheme.cancelButtonStyle,
                      onPressed: () => Navigator.pop(context),
                      child: Text(widget.cancelLabel),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: FilledButton(
                      style: pickerTheme.confirmButtonStyle,
                      onPressed: _selectedEt == null
                          ? null
                          : () => Navigator.pop(
                              context,
                              EthiopianPickerResult(
                                ethiopianDate: _selectedEt!,
                                gregorianDate: _selectedGc!,
                              ),
                            ),
                      child: Text(widget.confirmLabel),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The result returned by [showEthiopianDatePickerDialog].
class EthiopianPickerResult {
  const EthiopianPickerResult({
    required this.ethiopianDate,
    required this.gregorianDate,
  });

  /// The selected date in the Ethiopian calendar.
  final EthiopianDate ethiopianDate;

  /// The equivalent date in the Gregorian calendar.
  final DateTime gregorianDate;

  @override
  String toString() =>
      'EthiopianPickerResult(et: ${ethiopianDate.toAmharicString()}, gc: $gregorianDate)';
}

class _SelectedDatePreview extends StatelessWidget {
  const _SelectedDatePreview({
    required this.ethiopianDate,
    required this.gregorianDate,
    required this.theme,
  });

  final EthiopianDate ethiopianDate;
  final DateTime gregorianDate;
  final EthiopianDatePickerThemeData theme;

  static const _gregorianMonths = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static String _formatGregorian(DateTime date) {
    final local = date.toLocal();
    return '${local.day} ${_gregorianMonths[local.month - 1]} ${local.year}';
  }

  @override
  Widget build(BuildContext context) {
    final gcLabel = _formatGregorian(gregorianDate);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: theme.selectedPreviewBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('የኢትዮጵያ ቀን', style: theme.selectedPreviewLabelStyle),
              Text(
                ethiopianDate.toAmharicString(),
                style: theme.selectedPreviewValueStyle,
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Gregorian Date', style: theme.selectedPreviewLabelStyle),
              Text(gcLabel, style: theme.selectedPreviewValueStyle),
            ],
          ),
        ],
      ),
    );
  }
}
