import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../widgets/forecast_item.dart';
import '../widgets/weather_info_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService _service = WeatherService();
  final TextEditingController _searchController = TextEditingController();

  WeatherModel? _weather;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadWeather('Ulaanbaatar');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadWeather(String city) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final weather = await _service.fetchWeather(city);
      setState(() {
        _weather = weather;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _onSearch() {
    final city = _searchController.text.trim();
    if (city.isNotEmpty) {
      _loadWeather(city);
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _gradientColors(),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildSearchBar(),
                const SizedBox(height: 20),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Color> _gradientColors() {
    if (_weather == null) {
      return [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)];
    }
    final condition = _weather!.condition.toLowerCase();
    if (condition.contains('clear') || condition.contains('sunny') || condition.contains('mainly clear')) {
      return [Color(0xFF1a2a3a), Color(0xFF1e3a5f), Color(0xFF0f2744)];
    }
    if (condition.contains('rain') || condition.contains('drizzle') || condition.contains('shower')) {
      return [Color(0xFF141e2e), Color(0xFF1a2840), Color(0xFF0d1f35)];
    }
    if (condition.contains('snow')) {
      return [Color(0xFF1a2535), Color(0xFF1e2f45), Color(0xFF16253a)];
    }
    if (condition.contains('thunder') || condition.contains('storm')) {
      return [Color(0xFF150f2a), Color(0xFF1a1235), Color(0xFF0f0d20)];
    }
    if (condition.contains('fog') || condition.contains('mist') || condition.contains('overcast')) {
      return [Color(0xFF1c1f2e), Color(0xFF1e2235), Color(0xFF181b2a)];
    }
    return [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)];
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      style: const TextStyle(color: Colors.white),
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => _onSearch(),
      decoration: InputDecoration(
        hintText: 'Search city...',
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIcon: const Icon(Icons.search, color: Colors.white54),
        suffixIcon: IconButton(
          icon: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 18),
          onPressed: _onSearch,
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, color: Colors.white54, size: 64),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _loadWeather(
                _searchController.text.trim().isEmpty
                    ? 'Ulaanbaatar'
                    : _searchController.text.trim(),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white24,
                foregroundColor: Colors.white,
              ),
              child: const Text('Дахин оролдох'),
            ),
          ],
        ),
      );
    }

    if (_weather == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildCurrentWeather(),
          const SizedBox(height: 28),
          _buildInfoCards(),
          const SizedBox(height: 28),
          _buildForecastSection(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCurrentWeather() {
    final w = _weather!;
    return Column(
      children: [
        const SizedBox(height: 10),
        Text(
          '${w.city}, ${w.country}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${w.temperature}°',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 90,
            fontWeight: FontWeight.w200,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          w.condition,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 20,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCards() {
    final w = _weather!;
    return Row(
      children: [
        WeatherInfoCard(
          icon: Icons.water_drop_outlined,
          value: '${w.humidity}%',
          label: 'Humidity',
        ),
        const SizedBox(width: 10),
        WeatherInfoCard(
          icon: Icons.air,
          value: '${w.windSpeed} km/h',
          label: 'Wind',
        ),
        const SizedBox(width: 10),
        WeatherInfoCard(
          icon: Icons.speed,
          value: '${w.pressure}',
          label: 'Pressure',
        ),
      ],
    );
  }

  Widget _buildForecastSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '5-DAY FORECAST',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (int i = 0; i < _weather!.forecast.length; i++) ...[
              ForecastItem(forecast: _weather!.forecast[i]),
              if (i < _weather!.forecast.length - 1) const SizedBox(width: 6),
            ],
          ],
        ),
      ],
    );
  }
}
