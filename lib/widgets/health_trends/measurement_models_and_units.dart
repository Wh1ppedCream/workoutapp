part of '../health_trends_section.dart';

class _MeasurementTrend {
  final MeasurementDefinition definition;
  final List<Measurement> entries;

  const _MeasurementTrend({required this.definition, required this.entries});

  Measurement? get latest => entries.isEmpty ? null : entries.last;

  Measurement? get previous =>
      entries.length < 2 ? null : entries[entries.length - 2];

  double? get delta {
    final last = latest;
    final prior = previous;
    if (last == null || prior == null) return null;
    return _measurementDelta(definition, last, prior);
  }
}

String _measurementTrendSemanticsLabel(
  MeasurementDefinition definition,
  List<Measurement> entries,
  AppLocalizations strings,
  Locale locale,
) {
  final latest = entries.isEmpty ? null : entries.last;
  final latestValue = latest == null
      ? strings.healthNoEntry
      : _formatMeasurement(latest, locale);
  final summary = strings.healthTrendChartSemantics(
    _measurementTitle(definition, strings),
    entries.length,
    latestValue,
  );
  final latestDate = latest == null
      ? null
      : '${strings.healthLatest}: ${LocalizedFormatters.dateTime(latest.displayDateTime, locale)}';
  final sparseState = entries.isEmpty
      ? strings.healthTrendNeedEntries
      : entries.length == 1
      ? strings.healthTrendNeedOneMore
      : null;
  return [summary, latestDate, sparseState].whereType<String>().join(' ');
}

String _measurementPointSemanticsValue(Measurement entry, Locale locale) {
  return '${LocalizedFormatters.dateTime(entry.displayDateTime, locale)}, ${_formatMeasurement(entry, locale)}';
}

class _MeasurementEntryInput {
  final DateTime timestamp;
  final double value;
  final String unit;
  final String? note;
  final MeasurementContext? context;

  const _MeasurementEntryInput({
    required this.timestamp,
    required this.value,
    required this.unit,
    this.note,
    this.context,
  });
}

String _measurementValidationMessage(
  AppLocalizations strings,
  MeasurementValidationException error,
) {
  return switch (error.error) {
    MeasurementValidationError.missingName ||
    MeasurementValidationError.invalidName ||
    MeasurementValidationError.duplicateName ||
    MeasurementValidationError.invalidUnit => strings.healthMetricInvalid,
    MeasurementValidationError.unsupportedUnit ||
    MeasurementValidationError.invalidValue ||
    MeasurementValidationError.implausibleValue ||
    MeasurementValidationError.invalidContext =>
      strings.healthMeasurementEntryInvalid,
  };
}

class _MeasurementDefinitionInput {
  final String name;
  final String unit;
  final double? initialValue;
  final String? note;

  const _MeasurementDefinitionInput({
    required this.name,
    required this.unit,
    this.initialValue,
    this.note,
  });
}

class _ChartBounds {
  final double minY;
  final double maxY;
  final double interval;

  const _ChartBounds({
    required this.minY,
    required this.maxY,
    required this.interval,
  });
}

double? _measurementDelta(
  MeasurementDefinition definition,
  Measurement? latest,
  Measurement? previous,
) => MeasurementComparison.delta(definition.type, latest, previous);

double _comparableValue(
  MeasurementDefinition definition,
  Measurement entry,
  String targetUnit,
) => MeasurementComparison.valueInUnit(definition.type, entry, targetUnit)!;

List<FlSpot> _spotsFor(
  MeasurementDefinition definition,
  List<Measurement> entries,
) {
  return List.generate(
    entries.length,
    (index) => FlSpot(
      index.toDouble(),
      _comparableValue(definition, entries[index], entries.last.unit),
    ),
  );
}

Set<int> _measurementDateTickIndexes(List<Measurement> entries) {
  final firstIndexByDay = <String, int>{};
  for (var index = 0; index < entries.length; index++) {
    firstIndexByDay.putIfAbsent(
      entries[index].calendarDay.storageKey,
      () => index,
    );
  }
  final dayIndexes = firstIndexByDay.values.toList(growable: false);
  const maxLabels = 5;
  if (dayIndexes.length <= maxLabels) return dayIndexes.toSet();

  return List.generate(
    maxLabels,
    (index) =>
        dayIndexes[(index * (dayIndexes.length - 1) / (maxLabels - 1)).round()],
  ).toSet();
}

_ChartBounds _chartBounds(List<double> values) {
  if (values.isEmpty) {
    return const _ChartBounds(minY: 0, maxY: 1, interval: 1);
  }

  final dataMin = values.reduce(math.min);
  final dataMax = values.reduce(math.max);
  final range = dataMax - dataMin;
  final valueScale = math.max(dataMin.abs(), dataMax.abs()).toDouble();
  final precisionFloor = valueScale * 2.220446049250313e-16 * 8;
  final padding = range == 0
      ? (valueScale == 0
            ? 1.0
            : math.max(valueScale * 0.04, precisionFloor).toDouble())
      : math.max(range * 0.08, precisionFloor).toDouble();
  final rawInterval = math
      .max((range + 2 * padding) / 4, precisionFloor)
      .toDouble();
  final interval = _niceChartInterval(rawInterval);
  final minY = (((dataMin - padding) / interval).floor() * interval).toDouble();
  final maxY = (((dataMax + padding) / interval).ceil() * interval).toDouble();
  return _ChartBounds(
    minY: minY,
    maxY: maxY > minY ? maxY : minY + interval,
    interval: interval,
  );
}

double _niceChartInterval(double interval) {
  if (!interval.isFinite || interval <= 0) return 1;
  final exponent = math.pow(10, (math.log(interval) / math.ln10).floor());
  final magnitude = exponent.toDouble();
  final fraction = interval / magnitude;
  final niceFraction = switch (fraction) {
    <= 1 => 1.0,
    <= 2 => 2.0,
    <= 2.5 => 2.5,
    <= 5 => 5.0,
    _ => 10.0,
  };
  return niceFraction * magnitude;
}

List<double> _chartYAxisTickValues(_ChartBounds bounds) {
  final count = ((bounds.maxY - bounds.minY) / bounds.interval)
      .round()
      .clamp(1, 8)
      .toInt();
  return List.generate(
    count + 1,
    (index) => bounds.minY + bounds.interval * index,
  );
}

List<String> _formatChartYAxisLabels(
  List<double> values,
  double interval,
  Locale locale,
) {
  final compactLabels = values
      .map((value) => LocalizedFormatters.compactNumber(value, locale))
      .toList(growable: false);
  if (compactLabels.toSet().length == compactLabels.length) {
    return compactLabels;
  }

  var fractionDigits = _chartIntervalFractionDigits(interval);
  while (fractionDigits <= 12) {
    final labels = values
        .map(
          (value) => LocalizedFormatters.number(
            value,
            locale,
            minimumFractionDigits: fractionDigits,
            maximumFractionDigits: fractionDigits,
          ),
        )
        .toList(growable: false);
    if (labels.toSet().length == labels.length) return labels;
    fractionDigits++;
  }

  return values
      .map(
        (value) => LocalizedFormatters.number(
          value,
          locale,
          maximumFractionDigits: 12,
        ),
      )
      .toList(growable: false);
}

int _chartIntervalFractionDigits(double interval) {
  for (var fractionDigits = 0; fractionDigits <= 12; fractionDigits++) {
    final scale = math.pow(10, fractionDigits).toDouble();
    final scaledInterval = interval * scale;
    if ((scaledInterval - scaledInterval.round()).abs() < 1e-7) {
      return fractionDigits;
    }
  }
  return 12;
}

double _chartYAxisReservedSize(
  BuildContext context,
  List<String> labels,
  TextStyle? style,
  Locale locale,
) {
  var widestLabel = 0.0;
  for (final label in labels) {
    final painter = TextPainter(
      text: TextSpan(text: label, style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      locale: locale,
      maxLines: 1,
    )..layout();
    widestLabel = math.max(widestLabel, painter.width).toDouble();
  }
  return (widestLabel + 8).clamp(42.0, 100.0).toDouble();
}

int _definitionOrder(MeasurementDefinition definition) {
  const order = <MeasurementType, int>{
    MeasurementType.BodyWeight: 0,
    MeasurementType.Height: 1,
    MeasurementType.Chest: 2,
    MeasurementType.Waist: 3,
    MeasurementType.Hip: 4,
    MeasurementType.Shoulder: 5,
    MeasurementType.Arm: 6,
    MeasurementType.Forearm: 7,
    MeasurementType.Thigh: 8,
    MeasurementType.Calf: 9,
    MeasurementType.Neck: 10,
    MeasurementType.Custom: 100,
  };
  return order[definition.type] ?? 100;
}

String _measurementTitle(
  MeasurementDefinition definition,
  AppLocalizations strings,
) {
  if (definition.type == MeasurementType.Custom) return definition.name;
  return switch (definition.type) {
    MeasurementType.BodyWeight => strings.measurementWeight,
    MeasurementType.Height => strings.measurementHeight,
    MeasurementType.Forearm => strings.measurementForearm,
    MeasurementType.Arm => strings.measurementArm,
    MeasurementType.Neck => strings.measurementNeck,
    MeasurementType.Shoulder => strings.measurementShoulders,
    MeasurementType.Chest => strings.measurementChest,
    MeasurementType.Waist => strings.measurementWaist,
    MeasurementType.Hip => strings.measurementHips,
    MeasurementType.Thigh => strings.measurementThigh,
    MeasurementType.Calf => strings.measurementCalves,
    MeasurementType.Custom => definition.name,
  };
}

String _measurementSortName(MeasurementDefinition definition) {
  if (definition.type == MeasurementType.Custom) return definition.name;
  return switch (definition.type) {
    MeasurementType.BodyWeight => 'Weight',
    MeasurementType.Height => 'Height',
    MeasurementType.Forearm => 'Forearm',
    MeasurementType.Arm => 'Arm',
    MeasurementType.Neck => 'Neck',
    MeasurementType.Shoulder => 'Shoulders',
    MeasurementType.Chest => 'Chest',
    MeasurementType.Waist => 'Waist',
    MeasurementType.Hip => 'Hips',
    MeasurementType.Thigh => 'Thigh',
    MeasurementType.Calf => 'Calves',
    MeasurementType.Custom => definition.name,
  };
}

String _defaultUnitFor(
  MeasurementDefinition definition, [
  WeightUnit weightUnit = WeightUnit.pounds,
]) {
  return switch (definition.type) {
    MeasurementType.BodyWeight => weightUnit.shortLabel,
    MeasurementType.Height => 'in',
    MeasurementType.Custom => '',
    _ => 'in',
  };
}

String _formatMeasurement(Measurement entry, Locale locale) {
  return '${_localizedNumber(entry.value, locale, maximumFractionDigits: 6)} ${entry.unit}'
      .trim();
}

String _formatDelta(
  double? delta,
  AppLocalizations strings,
  Locale locale, {
  String? unit,
}) {
  if (delta == null || delta == 0) return strings.healthNoChange;
  final prefix = delta > 0 ? '+' : '';
  return strings.healthChangeSinceLast(
    '$prefix${_localizedNumber(delta, locale)}${unit == null ? '' : ' $unit'}',
  );
}

String _formatSignedMeasurementDelta(double delta, String unit, Locale locale) {
  final prefix = delta > 0 ? '+' : '';
  return '$prefix${_localizedNumber(delta, locale)} $unit';
}

String _localizedNumber(
  double value,
  Locale locale, {
  int? maximumFractionDigits,
}) {
  final magnitude = value.abs();
  final digits =
      maximumFractionDigits ??
      (magnitude > 0 && magnitude < 0.05
          ? ((-math.log(magnitude) / math.ln10).ceil() + 2).clamp(1, 12)
          : 1);
  return LocalizedFormatters.number(
    value,
    locale,
    maximumFractionDigits: value == value.roundToDouble() ? 0 : digits,
  );
}

String? _measurementContextLabel(
  Measurement entry,
  AppLocalizations strings,
  MeasurementType type,
) {
  final context =
      entry.context ??
      MeasurementValidation.legacyContextFor(type: type, note: entry.note);
  return switch (context) {
    MeasurementContext.wakeUp => strings.measurementWakeUp,
    MeasurementContext.bedtime => strings.measurementBedtime,
    MeasurementContext.overall => strings.measurementOverall,
    MeasurementContext.withPump => strings.measurementWithPump,
    MeasurementContext.withoutPump => strings.measurementWithoutPump,
    null => null,
  };
}

String? _measurementNote(Measurement entry, MeasurementType type) {
  final note = entry.note?.trim();
  if (note == null || note.isEmpty) return null;
  return entry.context != null ||
          MeasurementValidation.legacyContextFor(type: type, note: note) == null
      ? note
      : null;
}

Color? _deltaColor(BuildContext context, double? delta) {
  if (delta == null || delta == 0) {
    return Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7);
  }
  final surface = _healthTrendCardSurface(context);
  return delta > 0
      ? tonosHealthIncreaseForSurface(context, surface)
      : tonosHealthDecreaseForSurface(context, surface);
}

String _cleanNumber(double value) {
  final text = value.toString();
  return text.endsWith('.0') ? text.substring(0, text.length - 2) : text;
}

String _shortDate(DateTime value, Locale locale) {
  return LocalizedFormatters.shortDate(value, locale);
}

String _formatDateTime(DateTime value, Locale locale) {
  return LocalizedFormatters.dateTime(value, locale);
}
