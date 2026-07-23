import 'package:flutter/material.dart';

class MapSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final Function(String?) onFilterChanged;
  final String? currentFilter;

  const MapSearchBar({
    super.key,
    required this.onSearch,
    required this.onFilterChanged,
    this.currentFilter,
  });

  @override
  State<MapSearchBar> createState() => _MapSearchBarState();
}

class _MapSearchBarState extends State<MapSearchBar> {
  final TextEditingController _controller = TextEditingController();
  bool _showFilters = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre o dirección...',
                    border: const OutlineInputBorder(),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _controller.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _controller.clear();
                              widget.onSearch('');
                            },
                          )
                        : null,
                  ),
                  onChanged: widget.onSearch,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  _showFilters ? Icons.filter_list_off : Icons.filter_list,
                  color: widget.currentFilter != null
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                onPressed: () {
                  setState(() => _showFilters = !_showFilters);
                },
              ),
            ],
          ),
        ),
        if (_showFilters)
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildFilterChip('Todos', null),
                _buildFilterChip('Centro de reciclaje', 'Centro de reciclaje'),
                _buildFilterChip('Centro de acopio', 'Centro de acopio'),
                _buildFilterChip('Contenedor', 'Contenedor de reciclaje'),
                _buildFilterChip('Disposición', 'Punto de disposición'),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String? value) {
    final isSelected = widget.currentFilter == value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: isSelected,
        onSelected: (_) => widget.onFilterChanged(value),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
