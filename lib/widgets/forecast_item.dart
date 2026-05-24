import 'package:flutter/material.dart';
import '../models/forecast_model.dart';


class ForecastItem extends StatelessWidget {
  final ForecastModel forecast;

  const ForecastItem({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            forecast.day,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Icon(
            _iconData(forecast.icon),
            color: _iconColor(forecast.icon),
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            '${forecast.high}°',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${forecast.low}°',
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 13,
            ),
          ),
        ],
      ),
    ));
  }

  IconData _iconData(String icon) {
    switch (icon) {
      case 'sunny':
        return Icons.wb_sunny_rounded;
      case 'rainy':
        return Icons.umbrella_rounded;
      case 'snowy':
        return Icons.ac_unit_rounded;
      case 'stormy':
        return Icons.thunderstorm_rounded;
      default:
        return Icons.cloud_rounded;
    }
  }

  Color _iconColor(String icon) {
    switch (icon) {
      case 'sunny':
        return Colors.amber;
      case 'rainy':
        return Colors.lightBlueAccent;
      case 'snowy':
        return Colors.lightBlue;
      case 'stormy':
        return Colors.purpleAccent;
      default:
        return Colors.white70;
    }
  }
}
