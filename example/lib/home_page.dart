import 'dart:async';

import 'package:et_date_picker/et_date_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late EthiopianDateTime _now;
  Timer? _clockTimer;

  EthiopianPickerResult? _picked;
  EthiopianPickerResult? _themeResult;
  EthiopianPickerResult? _birthDate;
  EthiopianPickerResult? _alarmDate;
  EthiopianPickerResult? _eventDate;

  @override
  void initState() {
    super.initState();
    _tickClock();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(_tickClock);
    });
  }

  void _tickClock() {
    _now = EtDateConverter.toEthiopianDateTime(DateTime.now());
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  Future<void> _openPicker({
    EthiopianDatePickerTheme? theme,
    EthiopianDate? initialDate,
    EthiopianDate? firstDate,
    EthiopianDate? lastDate,
    required void Function(EthiopianPickerResult) onPicked,
  }) async {
    final result = await showEthiopianDatePickerDialog(
      context: context,
      theme: theme ?? _lightTheme,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (result != null && mounted) {
      setState(() => onPicked(result));
    }
  }

  Future<void> _pickForBackend() async {
    await _openPicker(
      initialDate: _picked?.ethiopianDate ?? EtDateConverter.today(),
      onPicked: (r) => _picked = r,
    );
  }

  void _copy(String label, String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied $label'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = EtDateConverter.today();
    final colorScheme = Theme.of(context).colorScheme;
    final standardNow = DateTime.now();
    final etTime = _now.time;
    final stdHour = EtDateConverter.toStandardHour(etTime);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(title: const Text('et_date_picker'), centerTitle: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How to use',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Let users pick an Ethiopian date, then send either calendar '
              'to your backend.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // ── Main example ────────────────────────────────────────────
            _SectionLabel('Pick a date for your API'),
            const SizedBox(height: 4),
            Text(
              'The picker returns date objects — format them yourself for '
              'your UI or backend.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _pickForBackend,
              icon: const Icon(Icons.calendar_month_outlined),
              label: Text(
                _picked == null ? 'Choose Ethiopian date' : 'Change date',
              ),
            ),
            if (_picked != null) ...[
              const SizedBox(height: 12),
              _BackendPayloadCard(result: _picked!, onCopy: _copy),
            ],
            const SizedBox(height: 28),

            // ── Themes ──────────────────────────────────────────────────
            _SectionLabel('Dialog themes'),
            const SizedBox(height: 4),
            Text(
              'Pass EthiopianDatePickerTheme to style the dialog.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            _ActionTile(
              icon: Icons.crop_square_rounded,
              title: 'Minimal',
              subtitle: 'Monochrome, simple look',
              trailing: _themeResult?.ethiopianDate.toAmharicString(),
              onTap: () => _openPicker(
                theme: _minimalTheme,
                initialDate: _themeResult?.ethiopianDate ?? today,
                onPicked: (r) => _themeResult = r,
              ),
            ),
            _ActionTile(
              icon: Icons.wb_sunny_outlined,
              title: 'Light',
              subtitle: 'Bright surface with green accent',
              trailing: _themeResult?.ethiopianDate.toAmharicString(),
              onTap: () => _openPicker(
                theme: _lightTheme,
                initialDate: _themeResult?.ethiopianDate ?? today,
                onPicked: (r) => _themeResult = r,
              ),
            ),
            _ActionTile(
              icon: Icons.dark_mode_outlined,
              title: 'Dark',
              subtitle: 'Dark surface with warm accent',
              trailing: _themeResult?.ethiopianDate.toAmharicString(),
              onTap: () => _openPicker(
                theme: _darkTheme,
                initialDate: _themeResult?.ethiopianDate ?? today,
                onPicked: (r) => _themeResult = r,
              ),
            ),
            const SizedBox(height: 28),

            // ── Date limits ─────────────────────────────────────────────
            _SectionLabel('Date range limits'),
            const SizedBox(height: 4),
            Text(
              'Use firstDate and lastDate for birthdays, alarms, and more.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            _ActionTile(
              icon: Icons.cake_outlined,
              title: 'Birth date',
              subtitle: 'Past dates only · lastDate: today',
              trailing: _birthDate?.ethiopianDate.toAmharicString(),
              onTap: () => _openPicker(
                initialDate:
                    _birthDate?.ethiopianDate ??
                    EthiopianDate(year: today.year - 20, month: 1, day: 1),
                firstDate: EthiopianDate(
                  year: today.year - 120,
                  month: 1,
                  day: 1,
                ),
                lastDate: today,
                onPicked: (r) => _birthDate = r,
              ),
            ),
            _ActionTile(
              icon: Icons.alarm_outlined,
              title: 'Alarm / reminder',
              subtitle: 'Future dates only · firstDate: tomorrow',
              trailing: _alarmDate?.ethiopianDate.toAmharicString(),
              onTap: () {
                final nextDay = EtDateConverter.toEthiopian(
                  EtDateConverter.toGregorian(
                    today,
                  ).add(const Duration(days: 1)),
                );
                _openPicker(
                  initialDate: _alarmDate?.ethiopianDate ?? nextDay,
                  firstDate: nextDay,
                  lastDate: EthiopianDate(
                    year: today.year + 5,
                    month: 13,
                    day: 5,
                  ),
                  onPicked: (r) => _alarmDate = r,
                );
              },
            ),
            _ActionTile(
              icon: Icons.event_outlined,
              title: 'Event window',
              subtitle: '±1 year around today',
              trailing: _eventDate?.ethiopianDate.toAmharicString(),
              onTap: () => _openPicker(
                initialDate: _eventDate?.ethiopianDate ?? today,
                firstDate: EthiopianDate(
                  year: today.year - 1,
                  month: 1,
                  day: 1,
                ),
                lastDate: EthiopianDate(
                  year: today.year + 1,
                  month: 13,
                  day: 5,
                ),
                onPicked: (r) => _eventDate = r,
              ),
            ),
            const SizedBox(height: 28),

            // ── Current date & time ─────────────────────────────────────
            _SectionLabel('Current date & time'),
            const SizedBox(height: 8),
            _NowCard(now: _now, standard: standardNow),
            const SizedBox(height: 28),

            // ── Time conversion ─────────────────────────────────────────
            _SectionLabel('Time conversion'),
            const SizedBox(height: 4),
            Text(
              'Ethiopian time starts at sunrise (6:00 AM standard = 12:00 ቀን).',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            _TimeConversionCard(
              standardNow: standardNow,
              ethiopianTime: etTime,
              standardHourFromEt: stdHour,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Themes ────────────────────────────────────────────────────────────────────

const _minimalTheme = EthiopianDatePickerTheme(
  backgroundColor: Colors.white,
  headerTextStyle: TextStyle(
    color: Color(0xFF212121),
    fontSize: 16,
    fontWeight: FontWeight.w600,
  ),
  dayTextStyle: TextStyle(color: Color(0xFF424242)),
  selectedDayTextStyle: TextStyle(
    color: Colors.white,
    backgroundColor: Color(0xFF212121),
    fontWeight: FontWeight.bold,
  ),
  todayTextStyle: TextStyle(color: Color(0xFF616161)),
  confirmButtonStyle: ButtonStyle(
    backgroundColor: WidgetStatePropertyAll(Color(0xFF212121)),
    foregroundColor: WidgetStatePropertyAll(Colors.white),
  ),
  cancelButtonStyle: ButtonStyle(
    foregroundColor: WidgetStatePropertyAll(Color(0xFF616161)),
    side: WidgetStatePropertyAll(BorderSide(color: Color(0xFFBDBDBD))),
  ),
  selectedPreviewLabelStyle: TextStyle(
    color: Color(0xFF757575),
    backgroundColor: Color(0xFFF5F5F5),
  ),
  selectedPreviewValueStyle: TextStyle(
    color: Color(0xFF212121),
    fontWeight: FontWeight.bold,
  ),
);

const _lightTheme = EthiopianDatePickerTheme(
  backgroundColor: Color(0xFFF7FBF9),
  headerTextStyle: TextStyle(
    color: Color(0xFF006A4E),
    fontSize: 17,
    fontWeight: FontWeight.bold,
  ),
  dayTextStyle: TextStyle(color: Color(0xFF1B1B1B)),
  selectedDayTextStyle: TextStyle(
    color: Colors.white,
    backgroundColor: Color(0xFF006A4E),
    fontWeight: FontWeight.bold,
  ),
  todayTextStyle: TextStyle(color: Color(0xFF006A4E)),
  confirmButtonStyle: ButtonStyle(
    backgroundColor: WidgetStatePropertyAll(Color(0xFF006A4E)),
    foregroundColor: WidgetStatePropertyAll(Colors.white),
  ),
  cancelButtonStyle: ButtonStyle(
    foregroundColor: WidgetStatePropertyAll(Color(0xFF006A4E)),
    side: WidgetStatePropertyAll(BorderSide(color: Color(0xFF006A4E))),
  ),
  selectedPreviewLabelStyle: TextStyle(
    color: Color(0xFF006A4E),
    backgroundColor: Color(0xFFD4EDDF),
  ),
);

const _darkTheme = EthiopianDatePickerTheme(
  backgroundColor: Color(0xFF1B1B2F),
  headerTextStyle: TextStyle(
    color: Color(0xFFE94560),
    fontSize: 17,
    fontWeight: FontWeight.bold,
  ),
  dowTextStyle: TextStyle(
    color: Color(0x99FFFFFF),
    fontWeight: FontWeight.w600,
  ),
  dayTextStyle: TextStyle(color: Color(0xFFE0E0E0)),
  selectedDayTextStyle: TextStyle(
    color: Colors.white,
    backgroundColor: Color(0xFFE94560),
    fontWeight: FontWeight.bold,
  ),
  todayTextStyle: TextStyle(color: Color(0xFF82A0D8)),
  disabledDayTextStyle: TextStyle(color: Color(0x55FFFFFF)),
  outsideDayTextStyle: TextStyle(color: Color(0x33FFFFFF)),
  confirmButtonStyle: ButtonStyle(
    backgroundColor: WidgetStatePropertyAll(Color(0xFFE94560)),
    foregroundColor: WidgetStatePropertyAll(Colors.white),
  ),
  cancelButtonStyle: ButtonStyle(
    foregroundColor: WidgetStatePropertyAll(Color(0xFFE94560)),
    side: WidgetStatePropertyAll(BorderSide(color: Color(0xFFE94560))),
  ),
  selectedPreviewLabelStyle: TextStyle(
    color: Color(0xFFE94560),
    backgroundColor: Color(0xFF252545),
  ),
  selectedPreviewValueStyle: TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
  ),
);

// ── Helpers ───────────────────────────────────────────────────────────────────

String _isoDate(DateTime date) {
  final d = date.toLocal();
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '${d.year}-$m-$day';
}

String _pad2(int n) => n.toString().padLeft(2, '0');

// ── Widgets ───────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _BackendPayloadCard extends StatelessWidget {
  const _BackendPayloadCard({required this.result, required this.onCopy});

  final EthiopianPickerResult result;
  final void Function(String label, String value) onCopy;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final et = result.ethiopianDate;
    final gc = result.gregorianDate.toLocal();
    final etPayload =
        '{"year": ${et.year}, "month": ${et.month}, "day": ${et.day}}';
    final gcIso = _isoDate(gc);
    final etSlash = '${et.day}/${et.month}/${et.year}';
    final gcSlash = '${gc.day}/${gc.month}/${gc.year}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Use either calendar in your request body',
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: colorScheme.primary),
          ),
          const SizedBox(height: 8),
          Text(
            'You own the format — the package returns '
            'EthiopianDate and DateTime objects.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          _PayloadRow(
            title: 'Ethiopian (EthiopianDate)',
            display: et.toAmharicString(),
            code: etPayload,
            onCopy: () => onCopy('Ethiopian payload', etPayload),
          ),
          const Divider(height: 24),
          _PayloadRow(
            title: 'Gregorian (DateTime)',
            display: gcIso,
            code: '"$gcIso"',
            onCopy: () => onCopy('Gregorian date', gcIso),
          ),
          const SizedBox(height: 16),
          Text(
            'Format examples',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _FormatExample(
            label: 'Amharic',
            value: 'et.toAmharicString() → ${et.toAmharicString()}',
          ),
          _FormatExample(
            label: 'Parts',
            value: 'et.day / et.month / et.year → $etSlash',
          ),
          _FormatExample(label: 'ISO', value: 'gregorianDate → $gcIso'),
          _FormatExample(label: 'Custom', value: 'd/m/y → $gcSlash'),
          const SizedBox(height: 12),
          Text(
            'final result = await showEthiopianDatePickerDialog(...);\n'
            'final et = result.ethiopianDate; // EthiopianDate\n'
            'final gc = result.gregorianDate; // DateTime\n'
            '// format et / gc however your backend expects',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontFamily: 'monospace',
              color: colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _FormatExample extends StatelessWidget {
  const _FormatExample({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PayloadRow extends StatelessWidget {
  const _PayloadRow({
    required this.title,
    required this.display,
    required this.code,
    required this.onCopy,
  });

  final String title;
  final String display;
  final String code;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            IconButton(
              tooltip: 'Copy',
              onPressed: onCopy,
              icon: const Icon(Icons.copy_rounded, size: 18),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        Text(display, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            code,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _NowCard extends StatelessWidget {
  const _NowCard({required this.now, required this.standard});

  final EthiopianDateTime now;
  final DateTime standard;

  static const _gcMonths = [
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final gcLabel =
        '${standard.day} ${_gcMonths[standard.month - 1]} ${standard.year}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            now.date.toAmharicString(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            now.time.formatWithSeconds(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Gregorian · $gcLabel · ${_pad2(standard.hour)}:${_pad2(standard.minute)}:${_pad2(standard.second)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeConversionCard extends StatelessWidget {
  const _TimeConversionCard({
    required this.standardNow,
    required this.ethiopianTime,
    required this.standardHourFromEt,
  });

  final DateTime standardNow;
  final EthiopianTime ethiopianTime;
  final int standardHourFromEt;

  static const _samples = <(int hour, int minute, String label)>[
    (6, 0, 'Sunrise'),
    (9, 30, 'Morning'),
    (12, 0, 'Noon'),
    (15, 0, 'Afternoon'),
    (18, 0, 'Evening'),
    (0, 0, 'Midnight'),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final stdLabel =
        '${_pad2(standardNow.hour)}:${_pad2(standardNow.minute)}:${_pad2(standardNow.second)}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TimePair(
            leftLabel: 'Standard',
            leftValue: stdLabel,
            rightLabel: 'Ethiopian',
            rightValue: ethiopianTime.formatWithSeconds(),
          ),
          const SizedBox(height: 8),
          Text(
            'EtDateConverter.toStandardHour → ${_pad2(standardHourFromEt)}:00',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontFamily: 'monospace',
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Examples',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ..._samples.map((sample) {
            final et = EtDateConverter.toEthiopianTimeFromParts(
              hour: sample.$1,
              minute: sample.$2,
            );
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 72,
                    child: Text(
                      sample.$3,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${_pad2(sample.$1)}:${_pad2(sample.$2)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const Icon(Icons.arrow_forward, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      et.format(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _TimePair extends StatelessWidget {
  const _TimePair({
    required this.leftLabel,
    required this.leftValue,
    required this.rightLabel,
    required this.rightValue,
  });

  final String leftLabel;
  final String leftValue;
  final String rightLabel;
  final String rightValue;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                leftLabel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                leftValue,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
        Icon(Icons.sync_alt, color: colorScheme.primary, size: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                rightLabel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                rightValue,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: colorScheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: colorScheme.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        trailing ?? subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: trailing != null
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                          fontWeight: trailing != null ? FontWeight.w500 : null,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
