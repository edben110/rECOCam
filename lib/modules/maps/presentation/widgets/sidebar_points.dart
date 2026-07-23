import 'package:flutter/material.dart';

import '../../domain/entities/recycle_point.dart';

class SidebarPoints extends StatefulWidget {
  final List<RecyclePoint> points;
  final int allPointsCount;
  final String? selectedLocality;
  final List<String> availableLocalities;
  final String? tipoFilter;
  final String searchQuery;
  final Function(RecyclePoint) onPointSelected;
  final bool isVisible;
  final VoidCallback onToggle;
  final Function(String?) onLocalityChanged;
  final Function(String?) onTipoFilterChanged;
  final Function(String) onSearchChanged;

  const SidebarPoints({
    super.key,
    required this.points,
    required this.allPointsCount,
    this.selectedLocality,
    this.availableLocalities = const [],
    this.tipoFilter,
    this.searchQuery = '',
    required this.onPointSelected,
    required this.isVisible,
    required this.onToggle,
    required this.onLocalityChanged,
    required this.onTipoFilterChanged,
    required this.onSearchChanged,
  });

  @override
  State<SidebarPoints> createState() => _SidebarPointsState();
}

class _SidebarPointsState extends State<SidebarPoints> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void didUpdateWidget(SidebarPoints oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != oldWidget.searchQuery &&
        widget.searchQuery != _searchController.text) {
      _searchController.text = widget.searchQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final sidebarWidth = (screenWidth * 0.62).clamp(280.0, 440.0);

    return Stack(
      children: [
        if (widget.isVisible)
          GestureDetector(
            onTap: widget.onToggle,
            child: Container(color: Colors.black.withValues(alpha: 0.25)),
          ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          left: widget.isVisible ? 0 : -sidebarWidth - 8,
          top: 0,
          bottom: 0,
          width: sidebarWidth,
          child: GestureDetector(
            onTap: () {},
            child: Material(
              elevation: 8,
              color: Theme.of(context).colorScheme.surface,
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const Divider(height: 1),
                    _buildSearchBar(context),
                    _buildFilterSection(context),
                    const Divider(height: 1),
                    Expanded(
                      child: widget.points.isEmpty
                          ? _buildEmptyState(context)
                          : _buildPointsList(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Row(
        children: [
          Icon(
            Icons.recycling,
            color: Theme.of(context).colorScheme.primary,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Puntos de reciclaje',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${widget.points.length} de ${widget.allPointsCount} punto${widget.allPointsCount == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: widget.onToggle,
            tooltip: 'Cerrar',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar por nombre o dirección...',
          border: const OutlineInputBorder(),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          prefixIcon: const Icon(Icons.search, size: 18),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 16),
                  onPressed: () {
                    _searchController.clear();
                    widget.onSearchChanged('');
                  },
                )
              : null,
        ),
        onChanged: widget.onSearchChanged,
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLocalityDropdown(context),
        _buildTypeFilterChips(context),
      ],
    );
  }

  Widget _buildLocalityDropdown(BuildContext context) {
    if (widget.availableLocalities.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
        child: DropdownButtonFormField<String>(
        initialValue: widget.selectedLocality,
        isExpanded: true,
        isDense: true,
        decoration: const InputDecoration(
          labelText: 'Localidad',
          border: OutlineInputBorder(),
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          prefixIcon: Icon(Icons.map, size: 18),
        ),
        items: [
          const DropdownMenuItem(
            value: null,
            child: Text('Todas', style: TextStyle(fontSize: 13)),
          ),
          ...widget.availableLocalities.map((locality) {
            return DropdownMenuItem(
              value: locality,
              child: Text(
                locality,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13),
              ),
            );
          }),
        ],
        onChanged: widget.onLocalityChanged,
      ),
    );
  }

  Widget _buildTypeFilterChips(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        children: [
          _buildFilterChip(context, 'Todos', null),
          _buildFilterChip(context, 'Reciclaje', 'Centro de reciclaje'),
          _buildFilterChip(context, 'Contenedores y cestos', 'contenedor_cesta'),
          _buildFilterChip(context, 'Disposición', 'Punto de disposición'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, String? value) {
    final isSelected = widget.tipoFilter == value;
    final primary = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label, style: const TextStyle(fontSize: 11)),
        selected: isSelected,
        onSelected: (_) => widget.onTipoFilterChanged(value),
        visualDensity: VisualDensity.compact,
        selectedColor: primary.withValues(alpha: 0.15),
        checkmarkColor: primary,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              'Sin resultados',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'No se encontraron puntos\ncon los filtros actuales',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsList(BuildContext context) {
    return ListView.builder(
      itemCount: widget.points.length,
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemBuilder: (context, index) {
        final point = widget.points[index];
        return _buildPointItem(context, point);
      },
    );
  }

  Widget _buildPointItem(BuildContext context, RecyclePoint point) {
    final primary = Theme.of(context).colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.onPointSelected(point),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _getColorForType(point.tipo),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIcon(point.tipo),
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      point.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      point.direccion,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            point.tipo,
                            style: TextStyle(
                              fontSize: 10,
                              color: primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (point.distance != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            '${point.distance!.toStringAsFixed(1)} km',
                            style: TextStyle(
                              fontSize: 11,
                              color: primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorForType(String type) {
    if (type.contains('reciclaje')) return const Color(0xFF2E7D32);
    if (type.contains('acopio')) return const Color(0xFF1565C0);
    if (type.contains('Contenedor')) return const Color(0xFF6A1B9A);
    if (type.contains('disposición')) return const Color(0xFFE65100);
    if (type.contains('Cesta')) return const Color(0xFF757575);
    return const Color(0xFF424242);
  }

  IconData _getIcon(String type) {
    if (type.contains('reciclaje')) return Icons.recycling;
    if (type.contains('acopio')) return Icons.inventory_2;
    if (type.contains('Contenedor')) return Icons.delete_outline;
    if (type.contains('disposición')) return Icons.dangerous;
    if (type.contains('Cesta')) return Icons.delete;
    return Icons.place;
  }
}
