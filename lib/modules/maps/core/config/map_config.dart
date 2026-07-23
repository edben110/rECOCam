class MapConfig {
  MapConfig._();

  static const double defaultZoom = 13.0;
  static const double selectedZoom = 16.0;
  static const double minZoom = 5.0;
  static const double maxZoom = 18.0;

  static const double defaultLatitude = 4.7110;
  static const double defaultLongitude = -74.0721;

  static const Duration cacheExpiration = Duration(hours: 1);
  static const Duration animationDuration = Duration(milliseconds: 500);

  static const List<Map<String, String>> colombianCities = [
    {'nombre': 'Bogotá', 'lat': '4.7110', 'lng': '-74.0721'},
    {'nombre': 'Medellín', 'lat': '6.2442', 'lng': '-75.5812'},
    {'nombre': 'Cali', 'lat': '3.4516', 'lng': '-76.5320'},
    {'nombre': 'Barranquilla', 'lat': '10.9685', 'lng': '-74.7813'},
    {'nombre': 'Cartagena', 'lat': '10.3910', 'lng': '-75.5144'},
    {'nombre': 'Cúcuta', 'lat': '7.8891', 'lng': '-72.4967'},
    {'nombre': 'Bucaramanga', 'lat': '7.1254', 'lng': '-73.1198'},
    {'nombre': 'Pereira', 'lat': '4.8056', 'lng': '-75.6959'},
    {'nombre': 'Santa Marta', 'lat': '11.2408', 'lng': '-74.1990'},
    {'nombre': 'Ibagué', 'lat': '4.4389', 'lng': '-75.2322'},
    {'nombre': 'Pasto', 'lat': '1.2136', 'lng': '-77.2811'},
    {'nombre': 'Neiva', 'lat': '2.9279', 'lng': '-75.2819'},
    {'nombre': 'Villavicencio', 'lat': '4.1420', 'lng': '-73.6266'},
    {'nombre': 'Armenia', 'lat': '4.5339', 'lng': '-75.6814'},
    {'nombre': 'Popayán', 'lat': '2.4448', 'lng': '-76.6147'},
    {'nombre': 'Valledupar', 'lat': '10.4631', 'lng': '-73.2532'},
    {'nombre': 'Montería', 'lat': '8.7480', 'lng': '-75.8808'},
    {'nombre': 'Sincelejo', 'lat': '9.3047', 'lng': '-75.3958'},
    {'nombre': 'Manizales', 'lat': '5.0689', 'lng': '-75.5174'},
    {'nombre': 'Quibdó', 'lat': '5.6918', 'lng': '-76.6584'},
    {'nombre': 'Riohacha', 'lat': '11.5444', 'lng': '-72.9072'},
    {'nombre': 'Tunja', 'lat': '5.5353', 'lng': '-73.3678'},
    {'nombre': 'Apartadó', 'lat': '7.8824', 'lng': '-76.6256'},
    {'nombre': 'Floridablanca', 'lat': '7.0640', 'lng': '-73.0945'},
    {'nombre': 'Palmira', 'lat': '3.5329', 'lng': '-76.3039'},
    {'nombre': 'Buenaventura', 'lat': '3.8801', 'lng': '-77.0310'},
  ];
}
