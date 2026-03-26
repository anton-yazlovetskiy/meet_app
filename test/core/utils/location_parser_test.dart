import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:meet_app/core/utils/location_parser.dart';
import 'package:meet_app/domain/exceptions/location_parsing_exception.dart';
import 'package:mocktail/mocktail.dart';

class MockHttpClient extends Mock implements http.Client {}

class MockStreamedResponse extends Mock implements http.StreamedResponse {}

class FakeRequest extends Fake implements http.BaseRequest {}

void main() {
  late LocationParser locationParser;
  late MockHttpClient mockHttpClient;

  setUpAll(() {
    registerFallbackValue(FakeRequest());
  });

  setUp(() {
    mockHttpClient = MockHttpClient();
    locationParser = LocationParser(client: mockHttpClient);
  });

  group('LocationParser', () {
    const double lat = 55.7558;
    const double lng = 37.6177;

    test('успешно парсит стандартный URL Google Maps', () async {
      const url = 'https://www.google.com/maps/place/Kremlin/@$lat,$lng,15z/data=!4m2!3m1!1s0x0:0x3d5c8a5a5a5a5a5a';
      final result = await locationParser.parse(url);
      expect(result.lat, lat);
      expect(result.lng, lng);
      expect(result.address, 'Kremlin');
      expect(result.mapLink, url);
    });

    test('успешно парсит стандартный URL Yandex Maps', () async {
      const url = 'https://yandex.ru/maps/?ll=$lng%2C$lat&z=14';
      final result = await locationParser.parse(url);
      expect(result.lat, lat);
      expect(result.lng, lng);
      expect(result.mapLink, url);
    });

    test('успешно парсит URL Yandex Maps с параметром text', () async {
      const url = 'https://yandex.ru/maps/213/moscow/?ll=$lng%2C$lat&text=Red%20Square';
      final result = await locationParser.parse(url);
      expect(result.lat, lat);
      expect(result.lng, lng);
      expect(result.address, 'Red Square');
      expect(result.mapLink, url);
    });

    test('раскрывает и парсит короткую ссылку Google Maps', () async {
      const shortUrl = 'https://maps.app.goo.gl/shortId';
      const longUrl = 'https://www.google.com/maps/place/Kremlin/@$lat,$lng,15z';

      final mockResponse = MockStreamedResponse();
      when(() => mockResponse.statusCode).thenReturn(302);
      when(() => mockResponse.headers).thenReturn({'location': longUrl});

      when(() => mockHttpClient.send(any())).thenAnswer((_) async => mockResponse);

      final result = await locationParser.parse(shortUrl);

      expect(result.lat, lat);
      expect(result.lng, lng);
      expect(result.address, 'Kremlin');
      expect(result.mapLink, shortUrl);
    });

    test('выбрасывает ошибку parsingFailed для URL Google Maps без координат', () {
      const url = 'https://www.google.com/maps/search/restaurants/';
      expect(() => locationParser.parse(url), throwsA(isA<LocationParsingException>().having((e) => e.error, 'error', LocationParsingError.parsingFailed)));
    });

    test('выбрасывает ошибку invalidUrl для некорректного URL', () {
      const url = 'not a valid url';
      expect(() => locationParser.parse(url), throwsA(isA<LocationParsingException>().having((e) => e.error, 'error', LocationParsingError.invalidUrl)));
    });

    test('выбрасывает ошибку unsupportedMapProvider для URL, не являющегося картой', () {
      const url = 'https://example.com';
      expect(() => locationParser.parse(url), throwsA(isA<LocationParsingException>().having((e) => e.error, 'error', LocationParsingError.unsupportedMapProvider)));
    });

    test('выбрасывает ошибку networkError при ошибке раскрытия короткой ссылки', () {
      const shortUrl = 'https://maps.app.goo.gl/shortId';
      when(() => mockHttpClient.send(any())).thenThrow(Exception('Network failed'));

      expect(() => locationParser.parse(shortUrl), throwsA(isA<LocationParsingException>().having((e) => e.error, 'error', LocationParsingError.networkError)));
    });
  });
}
