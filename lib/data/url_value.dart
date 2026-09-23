/// Returns [value] trimmed when it is an absolute HTTP URL, or null otherwise.
///
/// The API can omit a field, send an empty string, or send a value that is not
/// a usable link. Treating those as unknown keeps unusable values out of the
/// application, where they would render as a broken control.
String? absoluteUrl(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  final uri = Uri.tryParse(trimmed);
  if (uri == null || uri.host.isEmpty) return null;
  return uri.scheme == 'http' || uri.scheme == 'https' ? trimmed : null;
}
