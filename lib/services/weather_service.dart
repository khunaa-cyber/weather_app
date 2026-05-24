import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../models/forecast_model.dart';

class WeatherService {
  static const String _geoUrl = 'https://geocoding-api.open-meteo.com/v1/search';
  static const String _weatherUrl = 'https://api.open-meteo.com/v1/forecast';

  Future<WeatherModel> fetchWeather(String city) async {
    final geoUri = Uri.parse('$_geoUrl?name=$city&count=1&language=en&format=json');
    final geoResponse = await http.get(geoUri);

    if (geoResponse.statusCode != 200) {
      throw Exception('Сервертэй холбогдож чадсангүй');
    }

    final geoData = jsonDecode(geoResponse.body) as Map<String, dynamic>;
    final results = geoData['results'] as List<dynamic>?;

    if (results == null || results.isEmpty) {
      throw Exception('Хот олдсонгүй');
    }

    final location = results[0] as Map<String, dynamic>;
    final lat = location['latitude'] as double;
    final lon = location['longitude'] as double;
    final cityName = location['name'] as String;
    final country = location['country_code'] as String;

    final weatherUri = Uri.parse(
      '$_weatherUrl?latitude=$lat&longitude=$lon'
      '&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m,surface_pressure'
      '&daily=weather_code,temperature_2m_max,temperature_2m_min'
      '&timezone=auto&forecast_days=6',
    );

    final weatherResponse = await http.get(weatherUri);
    if (weatherResponse.statusCode != 200) {
      throw Exception('Цаг агаарын мэдээлэл авч чадсангүй');
    }

    final weatherData = jsonDecode(weatherResponse.body) as Map<String, dynamic>;
    return _parse(weatherData, cityName, country);
  }

  WeatherModel _parse(
    Map<String, dynamic> data,
    String cityName,
    String country,
  ) {
    final current = data['current'] as Map<String, dynamic>;
    final daily = data['daily'] as Map<String, dynamic>;

    final dates = daily['time'] as List<dynamic>;
    final codes = daily['weather_code'] as List<dynamic>;
    final maxTemps = daily['temperature_2m_max'] as List<dynamic>;
    final minTemps = daily['temperature_2m_min'] as List<dynamic>;

    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    final forecasts = List.generate(5, (i) {
      final date = DateTime.parse(dates[i + 1] as String);
      final code = codes[i + 1] as int;
      return ForecastModel(
        day: dayNames[date.weekday - 1],
        icon: _mapIcon(code),
        high: (maxTemps[i + 1] as num).round(),
        low: (minTemps[i + 1] as num).round(),
      );
    });

    final weatherCode = current['weather_code'] as int;
    final windKmh = (current['wind_speed_10m'] as num).round();
    final pressure = (current['surface_pressure'] as num).round();

    return WeatherModel(
      city: cityName,
      country: country,
      temperature: (current['temperature_2m'] as num).round(),
      condition: _conditionText(weatherCode),
      humidity: (current['relative_humidity_2m'] as num).round(),
      windSpeed: windKmh,
      pressure: pressure,
      forecast: forecasts,
    );
  }

  String _mapIcon(int code) {
    if (code == 0) return 'sunny';
    if (code <= 3) return 'cloudy';
    if (code <= 48) return 'cloudy';
    if (code <= 67) return 'rainy';
    if (code <= 77) return 'snowy';
    if (code <= 82) return 'rainy';
    if (code <= 86) return 'snowy';
    return 'stormy';
  }

  String _conditionText(int code) {
    if (code == 0) return 'Clear Sky';
    if (code == 1) return 'Mainly Clear';
    if (code == 2) return 'Partly Cloudy';
    if (code == 3) return 'Overcast';
    if (code <= 48) return 'Foggy';
    if (code <= 57) return 'Drizzle';
    if (code <= 67) return 'Rainy';
    if (code <= 77) return 'Snowy';
    if (code <= 82) return 'Rain Showers';
    if (code <= 86) return 'Snow Showers';
    return 'Thunderstorm';
  }
}
