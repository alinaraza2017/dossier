class Validators {
  Validators._();

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Name: required, 2 to 80 characters (§7.1).
  static String? validateName(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Scholarship name is required';
    if (v.length < 2) return 'Use at least 2 characters';
    if (v.length > 80) return 'Keep the name under 80 characters';
    return null;
  }

  /// Country: optional, up to 60 characters.
  static String? validateCountry(String? value) {
    if ((value?.trim().length ?? 0) > 60) {
      return 'Keep the country under 60 characters';
    }
    return null;
  }

  /// Notes: optional, up to 1,000 characters.
  static String? validateNotes(String? value) {
    if ((value?.trim().length ?? 0) > 1000) {
      return 'Keep notes under 1,000 characters';
    }
    return null;
  }

  /// Adds "https://" when the user typed a link without a scheme (§7.1).
  static String normalizeUrl(String value) {
    final v = value.trim();
    if (v.isEmpty) return v;
    if (RegExp(r'^[a-zA-Z][a-zA-Z0-9+.-]*://').hasMatch(v)) return v;
    return 'https://$v';
  }

  static String? validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // URL is optional
    }

    final trimmed = normalizeUrl(value);
    final uri = Uri.tryParse(trimmed);
    if (uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty ||
        !uri.host.contains('.')) {
      return 'Enter a valid link, e.g. daad.de';
    }

    return null;
  }

  static String? validateRequirementTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Requirement title cannot be empty';
    }
    return null;
  }
}
