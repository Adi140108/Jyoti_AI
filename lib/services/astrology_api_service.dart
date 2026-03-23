import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// HTTP client for the Free Astrology API (https://freeastrologyapi.com).
/// All endpoints use POST with JSON body and x-api-key header.
class AstrologyApiService {
  static const String _baseUrl = 'https://json.freeastrologyapi.com';

  static String? get _apiKey => dotenv.env['ASTROLOGY_API_KEY'];

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'x-api-key': _apiKey ?? '',
      };

  /// Whether the API key is configured
  static bool get isConfigured =>
      _apiKey != null &&
      _apiKey!.isNotEmpty &&
      _apiKey != 'YOUR_ASTROLOGY_API_KEY_HERE';

  // ── Common request body builder ──

  static Map<String, dynamic> _birthBody({
    required int year,
    required int month,
    required int date,
    required int hours,
    required int minutes,
    required int seconds,
    required double latitude,
    required double longitude,
    required double timezone,
    String observationPoint = 'topocentric',
    String ayanamsha = 'lahiri',
  }) =>
      {
        'year': year,
        'month': month,
        'date': date,
        'hours': hours,
        'minutes': minutes,
        'seconds': seconds,
        'latitude': latitude,
        'longitude': longitude,
        'timezone': timezone,
        'settings': {
          'observation_point': observationPoint,
          'ayanamsha': ayanamsha,
        },
      };

  static Future<Map<String, dynamic>> _post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$_baseUrl/$endpoint');
    try {
      final response = await http.post(
        uri,
        headers: _headers,
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return {
        'error': true,
        'statusCode': response.statusCode,
        'message': 'API returned status ${response.statusCode}',
      };
    } catch (e) {
      return {'error': true, 'message': 'Network error: $e'};
    }
  }

  // ════════════════════════════════════════════════
  //  INDIAN ASTROLOGY — Planet Positions
  // ════════════════════════════════════════════════

  /// Get planet positions in Rasi chart
  static Future<Map<String, dynamic>> getPlanets({
    required int year,
    required int month,
    required int date,
    required int hours,
    required int minutes,
    required int seconds,
    required double latitude,
    required double longitude,
    required double timezone,
  }) async {
    return _post(
      'planets',
      _birthBody(
        year: year,
        month: month,
        date: date,
        hours: hours,
        minutes: minutes,
        seconds: seconds,
        latitude: latitude,
        longitude: longitude,
        timezone: timezone,
      ),
    );
  }

  /// Get extended planet info
  static Future<Map<String, dynamic>> getPlanetsExtended({
    required int year,
    required int month,
    required int date,
    required int hours,
    required int minutes,
    required int seconds,
    required double latitude,
    required double longitude,
    required double timezone,
  }) async {
    return _post(
      'planets/extended',
      _birthBody(
        year: year,
        month: month,
        date: date,
        hours: hours,
        minutes: minutes,
        seconds: seconds,
        latitude: latitude,
        longitude: longitude,
        timezone: timezone,
      ),
    );
  }

  /// Get any divisional chart info (D2-D60)
  /// chartType examples: "navamsa-chart-info", "d2-chart-info", "d3-chart-info", etc.
  static Future<Map<String, dynamic>> getDivisionalChart({
    required String chartType,
    required int year,
    required int month,
    required int date,
    required int hours,
    required int minutes,
    required int seconds,
    required double latitude,
    required double longitude,
    required double timezone,
  }) async {
    return _post(
      chartType,
      _birthBody(
        year: year,
        month: month,
        date: date,
        hours: hours,
        minutes: minutes,
        seconds: seconds,
        latitude: latitude,
        longitude: longitude,
        timezone: timezone,
      ),
    );
  }

  // ════════════════════════════════════════════════
  //  PANCHANG
  // ════════════════════════════════════════════════

  /// Get sunrise and sunset times
  static Future<Map<String, dynamic>> getSunriseAndSet({
    required int year,
    required int month,
    required int date,
    required int hours,
    required int minutes,
    required int seconds,
    required double latitude,
    required double longitude,
    required double timezone,
  }) async {
    return _post(
      'getsunriseandset',
      _birthBody(
        year: year,
        month: month,
        date: date,
        hours: hours,
        minutes: minutes,
        seconds: seconds,
        latitude: latitude,
        longitude: longitude,
        timezone: timezone,
      ),
    );
  }

  /// Generic panchang endpoint caller
  static Future<Map<String, dynamic>> _panchangEndpoint(
    String endpoint, {
    required int year,
    required int month,
    required int date,
    required int hours,
    required int minutes,
    required int seconds,
    required double latitude,
    required double longitude,
    required double timezone,
  }) async {
    return _post(
      endpoint,
      _birthBody(
        year: year,
        month: month,
        date: date,
        hours: hours,
        minutes: minutes,
        seconds: seconds,
        latitude: latitude,
        longitude: longitude,
        timezone: timezone,
      ),
    );
  }

  /// Fetch comprehensive panchang data by calling multiple endpoints
  static Future<Map<String, dynamic>> getFullPanchang({
    required int year,
    required int month,
    required int date,
    required int hours,
    required int minutes,
    required int seconds,
    required double latitude,
    required double longitude,
    required double timezone,
  }) async {
    final args = {
      'year': year,
      'month': month,
      'date': date,
      'hours': hours,
      'minutes': minutes,
      'seconds': seconds,
      'latitude': latitude,
      'longitude': longitude,
      'timezone': timezone,
    };

    // Call multiple panchang endpoints in parallel
    final results = await Future.wait([
      _panchangEndpoint('getsunriseandset', year: year, month: month, date: date, hours: hours, minutes: minutes, seconds: seconds, latitude: latitude, longitude: longitude, timezone: timezone),
      _panchangEndpoint('tithi-durations', year: year, month: month, date: date, hours: hours, minutes: minutes, seconds: seconds, latitude: latitude, longitude: longitude, timezone: timezone),
      _panchangEndpoint('nakshatra-durations', year: year, month: month, date: date, hours: hours, minutes: minutes, seconds: seconds, latitude: latitude, longitude: longitude, timezone: timezone),
      _panchangEndpoint('yoga-durations', year: year, month: month, date: date, hours: hours, minutes: minutes, seconds: seconds, latitude: latitude, longitude: longitude, timezone: timezone),
      _panchangEndpoint('karana-durations', year: year, month: month, date: date, hours: hours, minutes: minutes, seconds: seconds, latitude: latitude, longitude: longitude, timezone: timezone),
      _panchangEndpoint('vedicweekday', year: year, month: month, date: date, hours: hours, minutes: minutes, seconds: seconds, latitude: latitude, longitude: longitude, timezone: timezone),
    ]);

    return {
      'statusCode': 200,
      'input': args,
      'output': {
        'sunrise_sunset': results[0]['output'],
        'tithi': results[1]['output'],
        'nakshatra': results[2]['output'],
        'yoga': results[3]['output'],
        'karana': results[4]['output'],
        'weekday': results[5]['output'],
      },
    };
  }

  /// Get Rahu Kalam, Gulika Kalam, good/bad times
  static Future<Map<String, dynamic>> getMuhuratTimes({
    required int year,
    required int month,
    required int date,
    required int hours,
    required int minutes,
    required int seconds,
    required double latitude,
    required double longitude,
    required double timezone,
  }) async {
    final results = await Future.wait([
      _panchangEndpoint('rahu-kalam', year: year, month: month, date: date, hours: hours, minutes: minutes, seconds: seconds, latitude: latitude, longitude: longitude, timezone: timezone),
      _panchangEndpoint('yama-gandam', year: year, month: month, date: date, hours: hours, minutes: minutes, seconds: seconds, latitude: latitude, longitude: longitude, timezone: timezone),
      _panchangEndpoint('gulika-kalam', year: year, month: month, date: date, hours: hours, minutes: minutes, seconds: seconds, latitude: latitude, longitude: longitude, timezone: timezone),
      _panchangEndpoint('good-bad-times', year: year, month: month, date: date, hours: hours, minutes: minutes, seconds: seconds, latitude: latitude, longitude: longitude, timezone: timezone),
      _panchangEndpoint('abhijit-muhurat', year: year, month: month, date: date, hours: hours, minutes: minutes, seconds: seconds, latitude: latitude, longitude: longitude, timezone: timezone),
      _panchangEndpoint('hora-timings', year: year, month: month, date: date, hours: hours, minutes: minutes, seconds: seconds, latitude: latitude, longitude: longitude, timezone: timezone),
    ]);

    return {
      'statusCode': 200,
      'output': {
        'rahu_kalam': results[0]['output'],
        'yama_gandam': results[1]['output'],
        'gulika_kalam': results[2]['output'],
        'good_bad_times': results[3]['output'],
        'abhijit_muhurat': results[4]['output'],
        'hora_timings': results[5]['output'],
      },
    };
  }

  // ════════════════════════════════════════════════
  //  MATCH MAKING
  // ════════════════════════════════════════════════

  /// Get Ashtakoot compatibility score between two people
  static Future<Map<String, dynamic>> getAshtakootScore({
    required int maleYear,
    required int maleMonth,
    required int maleDate,
    required int maleHours,
    required int maleMinutes,
    required int maleSeconds,
    required double maleLatitude,
    required double maleLongitude,
    required double maleTimezone,
    required int femaleYear,
    required int femaleMonth,
    required int femaleDate,
    required int femaleHours,
    required int femaleMinutes,
    required int femaleSeconds,
    required double femaleLatitude,
    required double femaleLongitude,
    required double femaleTimezone,
  }) async {
    return _post('ashtakoot-score', {
      'male': {
        'year': maleYear,
        'month': maleMonth,
        'date': maleDate,
        'hours': maleHours,
        'minutes': maleMinutes,
        'seconds': maleSeconds,
        'latitude': maleLatitude,
        'longitude': maleLongitude,
        'timezone': maleTimezone,
        'settings': {
          'observation_point': 'topocentric',
          'ayanamsha': 'lahiri',
        },
      },
      'female': {
        'year': femaleYear,
        'month': femaleMonth,
        'date': femaleDate,
        'hours': femaleHours,
        'minutes': femaleMinutes,
        'seconds': femaleSeconds,
        'latitude': femaleLatitude,
        'longitude': femaleLongitude,
        'timezone': femaleTimezone,
        'settings': {
          'observation_point': 'topocentric',
          'ayanamsha': 'lahiri',
        },
      },
    });
  }

  // ════════════════════════════════════════════════
  //  VIMSOTTARI DASA
  // ════════════════════════════════════════════════

  /// Get all Vimsottari Maha Dasa periods
  static Future<Map<String, dynamic>> getMahaDasas({
    required int year,
    required int month,
    required int date,
    required int hours,
    required int minutes,
    required int seconds,
    required double latitude,
    required double longitude,
    required double timezone,
  }) async {
    return _post(
      'vimsottari/maha-dasas',
      _birthBody(
        year: year,
        month: month,
        date: date,
        hours: hours,
        minutes: minutes,
        seconds: seconds,
        latitude: latitude,
        longitude: longitude,
        timezone: timezone,
      ),
    );
  }

  /// Get Maha Dasas with Antar Dasas
  static Future<Map<String, dynamic>> getMahaDasasAndAntarDasas({
    required int year,
    required int month,
    required int date,
    required int hours,
    required int minutes,
    required int seconds,
    required double latitude,
    required double longitude,
    required double timezone,
  }) async {
    return _post(
      'vimsottari/maha-dasas-and-antar-dasas',
      _birthBody(
        year: year,
        month: month,
        date: date,
        hours: hours,
        minutes: minutes,
        seconds: seconds,
        latitude: latitude,
        longitude: longitude,
        timezone: timezone,
      ),
    );
  }

  /// Get dasha information for a given date
  static Future<Map<String, dynamic>> getDasaForDate({
    required int birthYear,
    required int birthMonth,
    required int birthDate,
    required int birthHours,
    required int birthMinutes,
    required int birthSeconds,
    required double latitude,
    required double longitude,
    required double timezone,
    required int queryYear,
    required int queryMonth,
    required int queryDate,
  }) async {
    final body = _birthBody(
      year: birthYear,
      month: birthMonth,
      date: birthDate,
      hours: birthHours,
      minutes: birthMinutes,
      seconds: birthSeconds,
      latitude: latitude,
      longitude: longitude,
      timezone: timezone,
    );
    body['query_date'] = {
      'year': queryYear,
      'month': queryMonth,
      'date': queryDate,
    };
    return _post('vimsottari/dasa-information', body);
  }

  // ════════════════════════════════════════════════
  //  SHAD BALA
  // ════════════════════════════════════════════════

  /// Get Shad Bala summary for all planets
  static Future<Map<String, dynamic>> getShadBalaSummary({
    required int year,
    required int month,
    required int date,
    required int hours,
    required int minutes,
    required int seconds,
    required double latitude,
    required double longitude,
    required double timezone,
  }) async {
    return _post(
      'shadbala/shadbala-summary',
      _birthBody(
        year: year,
        month: month,
        date: date,
        hours: hours,
        minutes: minutes,
        seconds: seconds,
        latitude: latitude,
        longitude: longitude,
        timezone: timezone,
      ),
    );
  }

  // ════════════════════════════════════════════════
  //  CHART IMAGES (SVG URL)
  // ════════════════════════════════════════════════

  /// Get SVG chart image URL.
  /// chartType: "horoscope-chart-url", "navamsa-chart-url", "d2-chart-url", etc.
  static Future<Map<String, dynamic>> getChartImageUrl({
    required String chartType,
    required int year,
    required int month,
    required int date,
    required int hours,
    required int minutes,
    required int seconds,
    required double latitude,
    required double longitude,
    required double timezone,
  }) async {
    return _post(
      chartType,
      _birthBody(
        year: year,
        month: month,
        date: date,
        hours: hours,
        minutes: minutes,
        seconds: seconds,
        latitude: latitude,
        longitude: longitude,
        timezone: timezone,
      ),
    );
  }

  // ════════════════════════════════════════════════
  //  GEO LOCATION & TIMEZONE
  // ════════════════════════════════════════════════

  /// Get geo coordinates for a place name
  static Future<Map<String, dynamic>> getGeoLocation(String placeName) async {
    return _post('geo-location/geo-details', {'place_name': placeName});
  }

  /// Get timezone with DST info
  static Future<Map<String, dynamic>> getTimezoneWithDst({
    required double latitude,
    required double longitude,
    required int year,
    required int month,
    required int date,
  }) async {
    return _post('time-zone-api-docs/time-zone-with-dst', {
      'latitude': latitude,
      'longitude': longitude,
      'year': year,
      'month': month,
      'date': date,
    });
  }

  // ════════════════════════════════════════════════
  //  WESTERN ASTROLOGY
  // ════════════════════════════════════════════════

  /// Get Western astrology planet positions
  static Future<Map<String, dynamic>> getWesternPlanets({
    required int year,
    required int month,
    required int date,
    required int hours,
    required int minutes,
    required int seconds,
    required double latitude,
    required double longitude,
    required double timezone,
  }) async {
    return _post(
      'western-astrology/planets',
      _birthBody(
        year: year,
        month: month,
        date: date,
        hours: hours,
        minutes: minutes,
        seconds: seconds,
        latitude: latitude,
        longitude: longitude,
        timezone: timezone,
      ),
    );
  }

  /// Get Western astrology houses
  static Future<Map<String, dynamic>> getWesternHouses({
    required int year,
    required int month,
    required int date,
    required int hours,
    required int minutes,
    required int seconds,
    required double latitude,
    required double longitude,
    required double timezone,
  }) async {
    return _post(
      'western-astrology/houses',
      _birthBody(
        year: year,
        month: month,
        date: date,
        hours: hours,
        minutes: minutes,
        seconds: seconds,
        latitude: latitude,
        longitude: longitude,
        timezone: timezone,
      ),
    );
  }

  /// Get Western astrology aspects
  static Future<Map<String, dynamic>> getWesternAspects({
    required int year,
    required int month,
    required int date,
    required int hours,
    required int minutes,
    required int seconds,
    required double latitude,
    required double longitude,
    required double timezone,
  }) async {
    return _post(
      'western-astrology/aspects',
      _birthBody(
        year: year,
        month: month,
        date: date,
        hours: hours,
        minutes: minutes,
        seconds: seconds,
        latitude: latitude,
        longitude: longitude,
        timezone: timezone,
      ),
    );
  }
}
