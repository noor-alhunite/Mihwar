/// Central place for Zarqa - Al-Karama map tuning.
/// Adjust these values if the target neighborhood needs refinement.
class ZarqaKaramaArea {
  const ZarqaKaramaArea._();

  /// Truck starting point (blue dot). Nudged to a street-graph node so smart demo route snaps.
  /// Graph node (3,4): minLat + 3*(maxLat-minLat)/7, minLng + 4*(maxLng-minLng)/9.
  static const double startLat = 32.07209;
  static const double startLng = 36.08797;

  /// Street-level map zoom for startup.
  static const double defaultZoom = 13.4;

  /// Optional neighborhood bounds to keep camera around Al-Karama.
  static const double minLat = 32.0678;
  static const double minLng = 36.0809;
  static const double maxLat = 32.0778;
  static const double maxLng = 36.0968;
}
