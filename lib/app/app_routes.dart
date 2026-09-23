/// Addressable application routes.
///
/// The router and the screens that navigate share these values so a path is
/// declared once and cannot drift between definition and use.
abstract final class AppRoutes {
  /// Name of the breed identifier inside the detail path.
  static const String breedIdParameter = 'id';

  static const String splash = '/';
  static const String breeds = '/breeds';
  static const String breedDetail = '$breeds/:$breedIdParameter';

  /// Concrete `/breeds/:id` location for [breedId].
  static String breedDetailPath(String breedId) => '$breeds/$breedId';
}
