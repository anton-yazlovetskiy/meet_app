import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:meet_app/domain/entities/event.dart';
import 'package:meet_app/domain/exceptions/location_parsing_exception.dart';

/// Парсер для ссылок на онлайн-карты (Google, Yandex).
///
/// Принимает URL, пытается извлечь из него координаты и адрес.
/// Обрабатывает короткие ссылки, делая дополнительный сетевой запрос.
class LocationParser {
  final http.Client _client;

  LocationParser({http.Client? client}) : _client = client ?? http.Client();

  /// Основной метод парсинга.
  ///
  /// Принимает [url] в виде строки, возвращает объект [Location].
  /// В случае неудачи выбрасывает [LocationParsingException].
  Future<Location> parse(String url) async {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw LocationParsingException(LocationParsingError.invalidUrl);
    }

    String urlToParse = url;
    // Если ссылка короткая, получаем полную версию
    if (uri.host == 'maps.app.goo.gl') {
      urlToParse = await _resolveShortUrl(url);
    }

    final Uri finalUri = Uri.parse(urlToParse);

    if (finalUri.host.contains('google')) {
      return _parseGoogleMapsUrl(finalUri, originalUrl: url);
    } else if (finalUri.host.contains('yandex')) {
      return _parseYandexMapsUrl(finalUri, originalUrl: url);
    } else {
      throw LocationParsingException(LocationParsingError.unsupportedMapProvider);
    }
  }

  /// Раскрывает короткую ссылку, возвращая полный URL.
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
    // Если по какой-то причине не удалось получить полную ссылку
    throw LocationParsingException(LocationParsingError.parsingFailed);
  }

  /// Парсит URL из Google Maps.
  Location _parseGoogleMapsUrl(Uri uri, {required String originalUrl}) {
    // Пример: /maps/place/Some+Place/@40.7128,-74.0060,15z
    final path = uri.path;
    final regex = RegExp(r'@(-?\d+\.\d+),(-?\d+\.\d+)');
    final match = regex.firstMatch(path);

    if (match != null && match.groupCount == 2) {
      final lat = double.tryParse(match.group(1)!);
      final lng = double.tryParse(match.group(2)!);
      if (lat != null && lng != null) {
        // Пробуем извлечь адрес из пути
        final pathSegments = uri.pathSegments;
        String? address;
        if (pathSegments.length > 2 && pathSegments[0] == 'maps' && pathSegments[1] == 'place') {
          address = pathSegments[2].replaceAll('+', ' ');
        }
        return Location(mapLink: originalUrl, lat: lat, lng: lng, address: address);
      }
    }
    throw LocationParsingException(LocationParsingError.parsingFailed);
  }

  /// Парсит URL из Yandex Maps.
  Location _parseYandexMapsUrl(Uri uri, {required String originalUrl}) {
    // Пример: yandex.ru/maps/?ll=37.6177%2C55.7558&z=14
    final ll = uri.queryParameters['ll'];
    if (ll != null) {
      final parts = ll.split(',');
      if (parts.length == 2) {
        // У Яндекса порядок: долгота, широта
        final lng = double.tryParse(parts[0]);
        final lat = double.tryParse(parts[1]);
        if (lat != null && lng != null) {
          final address = uri.queryParameters['text']?.replaceAll('+', ' ');
          return Location(mapLink: originalUrl, lat: lat, lng: lng, address: address);
        }
      }
    }
    throw LocationParsingException(LocationParsingError.parsingFailed);
  }
}
