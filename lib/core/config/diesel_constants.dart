class DieselConstants {
  const DieselConstants._();

  // Keep this value in one place for easy updates.
  static const double jordanDieselPriceJodPerLiter = 0.645;

  // Base consumption for a modern truck on flat roads.
  static const double modernFlatLitersPerKm = 0.33;

  static double truckMultiplier(bool isOldTruck) => isOldTruck ? 1.18 : 1.0;

  static double roadMultiplier(String roadType) {
    switch (roadType) {
      case 'uphill':
        return 1.34;
      case 'downhill':
        return 0.84;
      case 'flat':
      default:
        return 1.0;
    }
  }
}
