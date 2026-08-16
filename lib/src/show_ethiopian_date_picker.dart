import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'ethiopian_date.dart';
import 'ethiopian_date_picker.dart';
import 'ethiopian_date_picker_theme.dart';

/// Maximum dialog width, aligned with Flutter Material 3 date picker.
const double kEthiopianDatePickerMaxDialogWidth = 360;

/// Default [Dialog.insetPadding], aligned with Flutter Material date picker.
const EdgeInsets kEthiopianDatePickerInsetPadding = EdgeInsets.symmetric(
  horizontal: 16,
  vertical: 24,
);

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

  /// The date to show initially. Accepts a Gregorian [DateTime]; converted
  /// internally to [EthiopianDate].
  DateTime? initialDate,

  /// Earliest selectable date as a Gregorian [DateTime]; converted internally.
  DateTime? firstDate,

  /// Latest selectable date as a Gregorian [DateTime]; converted internally.
  DateTime? lastDate,
  bool useEthiopicNumerals = false,

  /// When true, shows a live preview of the selected Ethiopian and Gregorian
  /// dates above the dialog buttons.
  bool showSelectedDatePreview = false,
  EthiopianDatePickerTheme? theme,

  /// Label for the cancel button.
  ///
  /// When null, uses [MaterialLocalizations.cancelButtonLabel] from the ambient
  /// locale (same as Flutter's [showDatePicker]).
  String? cancelText,

  /// Label for the confirm button.
  ///
  /// When null, uses [MaterialLocalizations.okButtonLabel] from the ambient
  /// locale (same as Flutter's [showDatePicker]).
  String? confirmText,

  /// Maximum width of the dialog (logical pixels).
  ///
  /// Defaults to [kEthiopianDatePickerMaxDialogWidth] (360), matching Flutter's
  /// Material 3 date picker. The actual width is clamped to the available screen
  /// width minus [insetPadding].
  double width = kEthiopianDatePickerMaxDialogWidth,

  /// Padding between the dialog and the screen edges.
  ///
  /// Defaults to [kEthiopianDatePickerInsetPadding] (16 horizontal, 24 vertical),
  /// matching Flutter's Material date picker.
  EdgeInsets insetPadding = kEthiopianDatePickerInsetPadding,

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
      showSelectedDatePreview: showSelectedDatePreview,
      theme: theme,
      cancelText: cancelText,
      confirmText: confirmText,
      width: width,
      insetPadding: insetPadding,
      shape: shape,
    ),
  );
}

/// Resolves the dialog width for [context], clamping [maxWidth] to the space
/// available after [insetPadding].
double resolveEthiopianDatePickerDialogWidth(
  BuildContext context, {
  double maxWidth = kEthiopianDatePickerMaxDialogWidth,
  EdgeInsets insetPadding = kEthiopianDatePickerInsetPadding,
}) {
  final availableWidth =
      MediaQuery.sizeOf(context).width - insetPadding.horizontal;
  return math.min(maxWidth, availableWidth);
}

/// The dialog widget. Kept private — callers use [showEthiopianDatePickerDialog].
class _EthiopianDatePickerDialog extends StatefulWidget {
  const _EthiopianDatePickerDialog({
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.useEthiopicNumerals = false,
    this.showSelectedDatePreview = false,
    this.theme,
    this.cancelText,
    this.confirmText,
    this.width = kEthiopianDatePickerMaxDialogWidth,
    this.insetPadding = kEthiopianDatePickerInsetPadding,
    this.shape,
  });

  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool useEthiopicNumerals;
  final bool showSelectedDatePreview;
  final EthiopianDatePickerTheme? theme;
  final String? cancelText;
  final String? confirmText;
  final double width;
  final EdgeInsets insetPadding;
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

    final dialogWidth = resolveEthiopianDatePickerDialogWidth(
      context,
      maxWidth: widget.width,
      insetPadding: widget.insetPadding,
    );
    final localizations = MaterialLocalizations.of(context);
    final cancelText =
        widget.cancelText ?? localizations.cancelButtonLabel;
    final confirmText = widget.confirmText ?? localizations.okButtonLabel;

    return Dialog(
      backgroundColor: pickerTheme.backgroundColor,
      shape:
          widget.shape ??
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: widget.insetPadding,
      child: SizedBox(
        width: dialogWidth,
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

              if (widget.showSelectedDatePreview)
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
                      child: Text(cancelText),
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
                      child: Text(confirmText),
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