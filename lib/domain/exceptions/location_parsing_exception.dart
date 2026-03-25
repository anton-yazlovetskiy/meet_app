enum LocationParsingError {
  invalidUrl,
  unsupportedMapProvider,
  parsingFailed,
  networkError,
}

class LocationParsingException implements Exception {
  final LocationParsingError error;

  LocationParsingException(this.error);
}
