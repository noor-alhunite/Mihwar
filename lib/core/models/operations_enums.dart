enum BinStatus { empty, half, full, broken }

enum TruckType { old, modern }

enum RoadType { uphill, downhill, flat }

enum DieselPeriod { daily, weekly, monthly, yearly }

enum DieselMode { before, after }

enum DriverEventType { skipAttempt, lateRoute, bypassAttempt }

enum ShiftPeriod { morning, noon, afternoon, evening }

enum SeasonType { normal, ramadan, summerHoliday }

extension BinStatusX on BinStatus {
  String get value => name;

  static BinStatus fromValue(String value) {
    return BinStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => BinStatus.half,
    );
  }
}

extension TruckTypeX on TruckType {
  String get value => name;

  static TruckType fromValue(String value) {
    return TruckType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => TruckType.modern,
    );
  }
}

extension RoadTypeX on RoadType {
  String get value => name;

  static RoadType fromValue(String value) {
    return RoadType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => RoadType.flat,
    );
  }
}

extension DieselPeriodX on DieselPeriod {
  String get value => name;

  static DieselPeriod fromValue(String value) {
    return DieselPeriod.values.firstWhere(
      (period) => period.name == value,
      orElse: () => DieselPeriod.daily,
    );
  }
}

extension DieselModeX on DieselMode {
  String get value => name;

  static DieselMode fromValue(String value) {
    return DieselMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => DieselMode.before,
    );
  }
}

extension DriverEventTypeX on DriverEventType {
  String get value => name;

  static DriverEventType fromValue(String value) {
    return DriverEventType.values.firstWhere(
      (eventType) => eventType.name == value,
      orElse: () => DriverEventType.skipAttempt,
    );
  }
}

extension ShiftPeriodX on ShiftPeriod {
  String get value => name;

  static ShiftPeriod fromValue(String value) {
    return ShiftPeriod.values.firstWhere(
      (shift) => shift.name == value,
      orElse: () => ShiftPeriod.morning,
    );
  }
}

extension SeasonTypeX on SeasonType {
  String get value => name;

  static SeasonType fromValue(String value) {
    return SeasonType.values.firstWhere(
      (season) => season.name == value,
      orElse: () => SeasonType.normal,
    );
  }
}
