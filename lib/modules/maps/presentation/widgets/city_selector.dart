import 'package:flutter/material.dart';

import '../../core/config/map_config.dart';

class CitySelector extends StatelessWidget {
  final String? selectedCity;
  final Function(String) onCityChanged;

  const CitySelector({
    super.key,
    this.selectedCity,
    required this.onCityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        initialValue: selectedCity,
        decoration: const InputDecoration(
          labelText: 'Ciudad',
          border: OutlineInputBorder(),
          isDense: true,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          prefixIcon: Icon(Icons.location_city, size: 20),
        ),
        items: MapConfig.colombianCities.map((city) {
          return DropdownMenuItem(
            value: city['nombre'],
            child: Text(
              city['nombre']!,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14),
            ),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) onCityChanged(value);
        },
      ),
    );
  }
}
