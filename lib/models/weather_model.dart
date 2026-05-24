import 'forecast_model.dart';

class WeatherModel {
  final String city;
  final String country;
  final int temperature;
  final String condition;
  final int humidity;
  final int windSpeed;
  final int pressure;
  final List<ForecastModel> forecast;

  WeatherModel({
    required this.city,
    required this.country,
    required this.temperature,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.forecast,
  });
}
