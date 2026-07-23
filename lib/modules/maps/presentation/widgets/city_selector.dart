import 'package:flutter/material.dart';

import '../../core/config/map_config.dart';

class CitySelector extends StatelessWidget {
  final String? selectedCity;
  final String? selectedLocality;
  final List<String> availableLocalities;
  final Function(String) onCityChanged;
  final Function(String?) onLocalityChanged;

  const CitySelector({
    super.key,
    this.selectedCity,
    this.selectedLocality,
    this.availableLocalities = const [],
    required this.onCityChanged,
    required this.onLocalityChanged,
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
      child: Row(
        children: [
          Expanded(
            flex: 3,
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
          ),
          if (availableLocalities.isNotEmpty) ...[
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<String>(
                initialValue: selectedLocality,
                decoration: const InputDecoration(
                  labelText: 'Localidad',
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  prefixIcon: Icon(Icons.map, size: 20),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Todas', style: TextStyle(fontSize: 14)),
                  ),
                  ...availableLocalities.map((locality) {
                    return DropdownMenuItem(
                      value: locality,
                      child: Text(
                        locality,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }),
                ],
                onChanged: onLocalityChanged,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
