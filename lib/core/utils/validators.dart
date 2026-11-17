class Validators {
  Validators._();

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // URL is optional
    }

    final trimmed = value.trim();
    final uri = Uri.tryParse(trimmed);
    if (uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty) {
      return 'Please enter a valid website link (e.g. https://example.com)';
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
