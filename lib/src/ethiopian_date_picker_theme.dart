import 'package:flutter/material.dart';

/// Styling options for [EthiopianDatePicker] and
/// [showEthiopianDatePickerDialog].
///
/// Unset properties fall back to the ambient [ThemeData].
///
/// Prefer [TextStyle] for typography and colors. [selectedDayTextStyle.backgroundColor]
/// sets the selected-day circle fill; [todayTextStyle.color] sets today's border
/// and label color. Preview strip background comes from
/// [selectedPreviewLabelStyle.backgroundColor] or
/// [selectedPreviewValueStyle.backgroundColor]. Dialog buttons use [ButtonStyle].
@immutable
class EthiopianDatePickerTheme {
  const EthiopianDatePickerTheme({
    this.backgroundColor,
    this.headerTextStyle,
    this.dowTextStyle,
    this.dayTextStyle,
    this.todayTextStyle,
    this.selectedDayTextStyle,
    this.disabledDayTextStyle,
    this.outsideDayTextStyle,
    this.selectedPreviewLabelStyle,
    this.selectedPreviewValueStyle,
    this.confirmButtonStyle,
    this.cancelButtonStyle,
    this.dayCellHeight,
    this.dayCellMargin,
  });

  /// Background of the picker and dialog. Falls back to [ThemeData.colorScheme.surface].
  final Color? backgroundColor;

  /// Month/year label and navigation icon color in the header.
  final TextStyle? headerTextStyle;

  /// Day-of-week row labels (እሁ, ሰኞ, …).
  final TextStyle? dowTextStyle;

  /// Regular, enabled day numbers.
  final TextStyle? dayTextStyle;

  /// Today. [TextStyle.color] is also used for today's border ring.
  final TextStyle? todayTextStyle;

  /// Selected day. [TextStyle.color] is the label; [TextStyle.backgroundColor]
  /// is the circle fill.
  final TextStyle? selectedDayTextStyle;

  /// Days outside the [firstDate]/[lastDate] range.
  final TextStyle? disabledDayTextStyle;

  /// Overflow days from adjacent months.
  final TextStyle? outsideDayTextStyle;

  /// Preview strip labels (e.g. "የኢትዮጵያ ቀን"). [backgroundColor] tints the strip.
  final TextStyle? selectedPreviewLabelStyle;

  /// Preview strip date values. [backgroundColor] tints the strip when the label
  /// style has none.
  final TextStyle? selectedPreviewValueStyle;

  /// Confirm button in the dialog.
  final ButtonStyle? confirmButtonStyle;

  /// Cancel button in the dialog.
  final ButtonStyle? cancelButtonStyle;

  /// Height of each day cell in the grid.
  final double? dayCellHeight;

  /// Margin around each day cell.
  final EdgeInsets? dayCellMargin;

  EthiopianDatePickerTheme copyWith({
    Color? backgroundColor,
    TextStyle? headerTextStyle,
    TextStyle? dowTextStyle,
    TextStyle? dayTextStyle,
    TextStyle? todayTextStyle,
    TextStyle? selectedDayTextStyle,
    TextStyle? disabledDayTextStyle,
    TextStyle? outsideDayTextStyle,
    TextStyle? selectedPreviewLabelStyle,
    TextStyle? selectedPreviewValueStyle,
    ButtonStyle? confirmButtonStyle,
    ButtonStyle? cancelButtonStyle,
    double? dayCellHeight,
    EdgeInsets? dayCellMargin,
  }) {
    return EthiopianDatePickerTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      headerTextStyle: headerTextStyle ?? this.headerTextStyle,
      dowTextStyle: dowTextStyle ?? this.dowTextStyle,
      dayTextStyle: dayTextStyle ?? this.dayTextStyle,
      todayTextStyle: todayTextStyle ?? this.todayTextStyle,
      selectedDayTextStyle: selectedDayTextStyle ?? this.selectedDayTextStyle,
      disabledDayTextStyle: disabledDayTextStyle ?? this.disabledDayTextStyle,
      outsideDayTextStyle: outsideDayTextStyle ?? this.outsideDayTextStyle,
      selectedPreviewLabelStyle:
          selectedPreviewLabelStyle ?? this.selectedPreviewLabelStyle,
      selectedPreviewValueStyle:
          selectedPreviewValueStyle ?? this.selectedPreviewValueStyle,
      confirmButtonStyle: confirmButtonStyle ?? this.confirmButtonStyle,
      cancelButtonStyle: cancelButtonStyle ?? this.cancelButtonStyle,
      dayCellHeight: dayCellHeight ?? this.dayCellHeight,
      dayCellMargin: dayCellMargin ?? this.dayCellMargin,
    );
  }

  /// Merges [override] on top of this theme. Values in [override] win.
  EthiopianDatePickerTheme merge(EthiopianDatePickerTheme? override) {
    if (override == null) return this;
    return copyWith(
      backgroundColor: override.backgroundColor,
      headerTextStyle: override.headerTextStyle ?? headerTextStyle,
      dowTextStyle: override.dowTextStyle ?? dowTextStyle,
      dayTextStyle: override.dayTextStyle ?? dayTextStyle,
      todayTextStyle: override.todayTextStyle ?? todayTextStyle,
      selectedDayTextStyle:
          override.selectedDayTextStyle ?? selectedDayTextStyle,
      disabledDayTextStyle:
          override.disabledDayTextStyle ?? disabledDayTextStyle,
      outsideDayTextStyle: override.outsideDayTextStyle ?? outsideDayTextStyle,
      selectedPreviewLabelStyle:
          override.selectedPreviewLabelStyle ?? selectedPreviewLabelStyle,
      selectedPreviewValueStyle:
          override.selectedPreviewValueStyle ?? selectedPreviewValueStyle,
      confirmButtonStyle: override.confirmButtonStyle ?? confirmButtonStyle,
      cancelButtonStyle: override.cancelButtonStyle ?? cancelButtonStyle,
      dayCellHeight: override.dayCellHeight,
      dayCellMargin: override.dayCellMargin,
    );
  }

  static TextStyle _withColor(TextStyle base, Color color) =>
      base.copyWith(color: color);

  /// Resolves nullable theme fields against [Theme.of(context)] defaults.
  static EthiopianDatePickerThemeData resolve(
    BuildContext context, {
    EthiopianDatePickerTheme? theme,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final onSurface = colorScheme.onSurface;

    final headerBase =
        theme?.headerTextStyle ??
        textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ) ??
        const TextStyle(fontWeight: FontWeight.bold, fontSize: 16);
    final headerTextStyle = headerBase.copyWith(
      color: theme?.headerTextStyle?.color ?? headerBase.color ?? onSurface,
    );

    final dayTextStyle = _withColor(
      theme?.dayTextStyle ??
          const TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
      theme?.dayTextStyle?.color ?? onSurface,
    );

    final todayTextStyle = _withColor(
      theme?.todayTextStyle ?? const TextStyle(fontWeight: FontWeight.normal),
      theme?.todayTextStyle?.color ?? colorScheme.secondary,
    );

    final selectedDayTextStyle =
        (theme?.selectedDayTextStyle ??
                const TextStyle(fontWeight: FontWeight.bold))
            .copyWith(
              color:
                  theme?.selectedDayTextStyle?.color ?? colorScheme.onPrimary,
              backgroundColor:
                  theme?.selectedDayTextStyle?.backgroundColor ??
                  colorScheme.primary,
              fontWeight:
                  theme?.selectedDayTextStyle?.fontWeight ?? FontWeight.bold,
            );

    final disabledDayTextStyle = _withColor(
      theme?.disabledDayTextStyle ??
          const TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
      theme?.disabledDayTextStyle?.color ?? onSurface.withValues(alpha: 0.35),
    );

    final outsideDayTextStyle = _withColor(
      theme?.outsideDayTextStyle ??
          const TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
      theme?.outsideDayTextStyle?.color ?? onSurface.withValues(alpha: 0.25),
    );

    final selectedPreviewLabelStyle =
        theme?.selectedPreviewLabelStyle ??
        textTheme.labelSmall?.copyWith(color: colorScheme.primary);

    final selectedPreviewValueStyle =
        theme?.selectedPreviewValueStyle ??
        textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold);

    final selectedPreviewBackgroundColor =
        theme?.selectedPreviewLabelStyle?.backgroundColor ??
        theme?.selectedPreviewValueStyle?.backgroundColor ??
        colorScheme.primaryContainer.withValues(alpha: 0.4);

    final confirmButtonStyle =
        theme?.confirmButtonStyle ??
        FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: onSurface.withValues(alpha: 0.12),
        );

    final cancelButtonStyle =
        theme?.cancelButtonStyle ??
        OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.outline),
        );

    return EthiopianDatePickerThemeData(
      backgroundColor: theme?.backgroundColor ?? colorScheme.surface,
      headerTextStyle: headerTextStyle,
      dowTextStyle:
          theme?.dowTextStyle ??
          textTheme.bodySmall?.copyWith(
            color: onSurface.withValues(alpha: 0.55),
            fontWeight: FontWeight.w600,
          ),
      dayTextStyle: dayTextStyle,
      todayTextStyle: todayTextStyle,
      selectedDayTextStyle: selectedDayTextStyle,
      disabledDayTextStyle: disabledDayTextStyle,
      outsideDayTextStyle: outsideDayTextStyle,
      selectedPreviewLabelStyle: selectedPreviewLabelStyle,
      selectedPreviewValueStyle: selectedPreviewValueStyle,
      selectedPreviewBackgroundColor: selectedPreviewBackgroundColor,
      confirmButtonStyle: confirmButtonStyle,
      cancelButtonStyle: cancelButtonStyle,
      dayCellHeight: theme?.dayCellHeight ?? 44,
      dayCellMargin: theme?.dayCellMargin ?? const EdgeInsets.all(3),
    );
  }
}

/// Fully resolved styling values used internally by the picker widgets.
@immutable
class EthiopianDatePickerThemeData {
  const EthiopianDatePickerThemeData({
    required this.backgroundColor,
    required this.headerTextStyle,
    required this.dowTextStyle,
    required this.dayTextStyle,
    required this.todayTextStyle,
    required this.selectedDayTextStyle,
    required this.disabledDayTextStyle,
    required this.outsideDayTextStyle,
    required this.selectedPreviewLabelStyle,
    required this.selectedPreviewValueStyle,
    required this.selectedPreviewBackgroundColor,
    required this.confirmButtonStyle,
    required this.cancelButtonStyle,
    required this.dayCellHeight,
    required this.dayCellMargin,
  });

  final Color backgroundColor;
  final TextStyle headerTextStyle;
  final TextStyle? dowTextStyle;
  final TextStyle dayTextStyle;
  final TextStyle todayTextStyle;
  final TextStyle selectedDayTextStyle;
  final TextStyle disabledDayTextStyle;
  final TextStyle outsideDayTextStyle;
  final TextStyle? selectedPreviewLabelStyle;
  final TextStyle? selectedPreviewValueStyle;
  final Color selectedPreviewBackgroundColor;
  final ButtonStyle confirmButtonStyle;
  final ButtonStyle cancelButtonStyle;
  final double dayCellHeight;
  final EdgeInsets dayCellMargin;
}
