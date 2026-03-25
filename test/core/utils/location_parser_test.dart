import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:meet_app/core/utils/location_parser.dart';
import 'package:meet_app/domain/entities/location_data.dart';
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
    const double lon = 37.6177;

    test('parses a standard Google Maps URL successfully', () async {
      const url =
          'https://www.google.com/maps/place/Kremlin/@$lat,$lon,15z/data=!4m2!3m1!1s0x0:0x3d5c8a5a5a5a5a5a';
      final result = await locationParser.parse(url);
      expect(result.latitude, lat);
      expect(result.longitude, lon);
      expect(result.address, 'Kremlin');
    });

    test('parses a standard Yandex Maps URL successfully', () async {
      const url = 'https://yandex.ru/maps/?ll=$lon%2C$lat&z=14';
      final result = await locationParser.parse(url);
      expect(result.latitude, lat);
      expect(result.longitude, lon);
    });
    
    test('parses a Yandex Maps URL with text successfully', () async {
      const url = 'https://yandex.ru/maps/213/moscow/?ll=$lon%2C$lat&text=Red%20Square';
      final result = await locationParser.parse(url);
      expect(result.latitude, lat);
      expect(result.longitude, lon);
      expect(result.address, 'Red Square');
    });

    test('resolves and parses a short Google Maps URL', () async {
      const shortUrl = 'https://maps.app.goo.gl/shortId';
      const longUrl = 'https://www.google.com/maps/place/Kremlin/@$lat,$lon,15z';

      final mockResponse = MockStreamedResponse();
      when(() => mockResponse.statusCode).thenReturn(302);
      when(() => mockResponse.headers).thenReturn({'location': longUrl});
      
      when(() => mockHttpClient.send(any())).thenAnswer((_) async => mockResponse);

      final result = await locationParser.parse(shortUrl);

      expect(result.latitude, lat);
      expect(result.longitude, lon);
      expect(result.address, 'Kremlin');
    });

    test('throws parsingFailed for a Google Maps URL without coordinates', () {
      const url = 'https://www.google.com/maps/search/restaurants/';
      expect(
        () => locationParser.parse(url),
        throwsA(
          isA<LocationParsingException>()
              .having((e) => e.error, 'error', LocationParsingError.parsingFailed),
        ),
      );
    });

    test('throws invalidUrl for a malformed URL', () {
      const url = 'not a valid url';
      expect(
        () => locationParser.parse(url),
        throwsA(
          isA<LocationParsingException>()
              .having((e) => e.error, 'error', LocationParsingError.invalidUrl),
        ),
      );
    });

    test('throws unsupportedMapProvider for a non-map URL', () {
      const url = 'https://example.com';
      expect(
        () => locationParser.parse(url),
        throwsA(
          isA<LocationParsingException>().having(
              (e) => e.error, 'error', LocationParsingError.unsupportedMapProvider),
        ),
      );
    });

    test('throws networkError when resolving short link fails', () {
       const shortUrl = 'https://maps.app.goo.gl/shortId';
       when(() => mockHttpClient.send(any())).thenThrow(Exception('Network failed'));

      expect(
            () => locationParser.parse(shortUrl),
        throwsA(
          isA<LocationParsingException>()
              .having((e) => e.error, 'error', LocationParsingError.networkError),
        ),
      );
    });
  });
}
