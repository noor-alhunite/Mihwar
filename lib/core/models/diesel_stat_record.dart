import 'operations_enums.dart';

class DieselStatRecord {
  const DieselStatRecord({
    this.id,
    required this.mode,
    required this.period,
    required this.value,
  });

  final int? id;
  final DieselMode mode;
  final DieselPeriod period;
  final double value;

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'mode': mode.value,
      'period': period.value,
      'value': value,
    };
  }

  factory DieselStatRecord.fromMap(Map<String, Object?> map) {
    return DieselStatRecord(
      id: map['id'] as int?,
      mode: DieselModeX.fromValue(map['mode'] as String),
      period: DieselPeriodX.fromValue(map['period'] as String),
      value: (map['value'] as num).toDouble(),
    );
  }
}

class DieselComparison {
  const DieselComparison({
    required this.period,
    required this.before,
    required this.after,
  });

  final DieselPeriod period;
  final double before;
  final double after;

  double get saved => before - after;
  double get savedPercent => before == 0 ? 0 : (saved / before) * 100;
}
