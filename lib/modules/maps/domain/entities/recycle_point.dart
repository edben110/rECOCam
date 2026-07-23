import 'package:equatable/equatable.dart';

class RecyclePoint extends Equatable {
  final String id;
  final String nombre;
  final String direccion;
  final double latitud;
  final double longitud;
  final String tipo;
  final String descripcion;
  final String ciudad;
  final String localidad;
  final String horario;
  final String telefono;
  final String website;
  final double? distance;

  const RecyclePoint({
    required this.id,
    required this.nombre,
    required this.direccion,
    required this.latitud,
    required this.longitud,
    required this.tipo,
    required this.descripcion,
    this.ciudad = '',
    this.localidad = '',
    this.horario = '',
    this.telefono = '',
    this.website = '',
    this.distance,
  });

  @override
  List<Object?> get props => [
    id, nombre, direccion, latitud, longitud,
    tipo, descripcion, ciudad, localidad,
    horario, telefono, website, distance,
  ];
}
