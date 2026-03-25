import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:meet_app/domain/entities/location_data.dart';
import 'package:meet_app/domain/exceptions/location_parsing_exception.dart';

class LocationParser {
  final http.Client _client;

  LocationParser({http.Client? client}) : _client = client ?? http.Client();

  Future<LocationData> parse(String url) async {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw LocationParsingException(LocationParsingError.invalidUrl);
    }

    String finalUrl = url;
    if (uri.host == 'maps.app.goo.gl') {
      finalUrl = await _resolveShortUrl(url);
    }

    final Uri finalUri = Uri.parse(finalUrl);

    if (finalUri.host.contains('google')) {
      return _parseGoogleMapsUrl(finalUri);
    } else if (finalUri.host.contains('yandex')) {
      return _parseYandexMapsUrl(finalUri);
    } else {
      throw LocationParsingException(LocationParsingError.unsupportedMapProvider);
    }
  }

  Future<String> _resolveShortUrl(String shortUrl) async {
    try {
      final request = http.Request('GET', Uri.parse(shortUrl))
        ..followRedirects = false;
      final response = await _client.send(request);

      if (response.statusCode >= 300 && response.statusCode < 400) {
        final location = response.headers['location'];
        if (location != null && location.isNotEmpty) {
          return location;
        }
      }
    } catch (e) {
      throw LocationParsingException(LocationParsingError.networkError);
    }
    // If the original logic fails for any reason, throw a parsing failed error.
    throw LocationParsingException(LocationParsingError.parsingFailed);
  }

  LocationData _parseGoogleMapsUrl(Uri uri) {
    // Example: /maps/place/Some+Place/@40.7128,-74.0060,15z
    final path = uri.path;
    final regex = RegExp(r'@(-?\d+\.\d+),(-?\d+\.\d+)');
    final match = regex.firstMatch(path);

    if (match != null && match.groupCount == 2) {
      final lat = double.tryParse(match.group(1)!);
      final lon = double.tryParse(match.group(2)!);
      if (lat != null && lon != null) {
        // Try to get address from path
        final pathSegments = uri.pathSegments;
        String? address;
        if (pathSegments.length > 1 && pathSegments[0] == 'maps' && pathSegments[1] == 'place') {
          address = pathSegments[2].replaceAll('+', ' ');
        }
        return LocationData(latitude: lat, longitude: lon, address: address);
      }
    }
    throw LocationParsingException(LocationParsingError.parsingFailed);
  }

  LocationData _parseYandexMapsUrl(Uri uri) {
    // Example: yandex.ru/maps/?ll=37.6177%2C55.7558&z=14
    final ll = uri.queryParameters['ll'];
    if (ll != null) {
      final parts = ll.split(',');
      if (parts.length == 2) {
        // Yandex has lon,lat order
        final lon = double.tryParse(parts[0]);
        final lat = double.tryParse(parts[1]);
        if (lat != null && lon != null) {
          final address = uri.queryParameters['text']?.replaceAll('+', ' ');
          return LocationData(latitude: lat, longitude: lon, address: address);
        }
      }
    }
    throw LocationParsingException(LocationParsingError.parsingFailed);
  }
}
