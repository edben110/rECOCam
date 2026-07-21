import 'dart:convert';

import 'package:flutter/services.dart';

import '../../core/exceptions/app_exceptions.dart';
import '../../core/services/logger_service.dart';
import '../../domain/entities/recycle_rule.dart';
import '../../domain/repositories/recycle_rules.dart';

/// Fuente de datos local para la base de conocimiento de reciclaje.
/// Lee y parsea el archivo JSON con las reglas de reciclaje.
/// Implementa la interfaz RecycleRules.
class RecycleKnowledgeDatasource implements RecycleRules {
  List<RecycleRule> _knowledgeBase = [];

  @override
  List<RecycleRule> get allRules => List.unmodifiable(_knowledgeBase);

  /// Carga la base de conocimiento desde el asset JSON.
  @override
  Future<void> initialize() async {
    try {
      LoggerService.instance.info('Cargando base de conocimiento...');

      final jsonString = await rootBundle.loadString(
        'assets/json/recycle_rules.json',
      );

      final List<dynamic> jsonData = json.decode(jsonString);

      _knowledgeBase = jsonData
          .map((item) => _parseRule(item as Map<String, dynamic>))
          .toList();

      LoggerService.instance.info(
        '${_knowledgeBase.length} reglas de reciclaje cargadas',
      );
    } catch (e) {
      LoggerService.instance.error(
        'Error al cargar la base de conocimiento',
        e,
      );
      throw KnowledgeBaseException(originalError: e);
    }
  }

  /// Parsea un elemento del JSON a una entidad RecycleRule.
  RecycleRule _parseRule(Map<String, dynamic> json) {
    return RecycleRule(
      label: json['label'] as String? ?? '',
      material: json['material'] as String? ?? 'Desconocido',
      recyclable: json['recyclable'] as bool? ?? false,
      reusable: json['reusable'] as bool? ?? false,
      containerColor: json['container_color'] as String? ?? 'Gris',
      description: json['description'] as String? ?? '',
      recommendation: json['recommendation'] as String? ?? '',
      aliases: (json['aliases'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  /// Busca una regla por etiqueta exacta (incluyendo aliases).
  @override
  RecycleRule? findByLabel(String label) {
    final normalizedLabel = _normalizeText(label);

    // Búsqueda exacta por label
    for (final rule in _knowledgeBase) {
      if (_normalizeText(rule.label) == normalizedLabel) {
        return rule;
      }
    }

    // Búsqueda por aliases
    for (final rule in _knowledgeBase) {
      if (rule.aliases
          .any((alias) => _normalizeText(alias) == normalizedLabel)) {
        return rule;
      }
    }

    // Contención de texto
    for (final rule in _knowledgeBase) {
      if (_normalizeText(rule.label).contains(normalizedLabel) ||
          normalizedLabel.contains(_normalizeText(rule.label))) {
        return rule;
      }
    }

    return null;
  }

  /// Busca la mejor coincidencia para una etiqueta.
  @override
  RecycleRule findBestMatch(String label) {
    // Primero intenta búsqueda exacta
    final exactMatch = findByLabel(label);
    if (exactMatch != null) return exactMatch;

    // Búsqueda por palabras en común
    final normalizedInput = _normalizeText(label);

    for (final rule in _knowledgeBase) {
      final ruleWords = _normalizeText(rule.label).split(' ');
      final inputWords = normalizedInput.split(' ');

      final matchingWords =
          ruleWords.where((w) => inputWords.contains(w)).length;

      if (matchingWords > 0 && matchingWords >= ruleWords.length * 0.5) {
        return rule;
      }
    }

    // Si no hay coincidencia, retorna regla desconocida
    return RecycleRule.unknown(label);
  }

  String _normalizeText(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\sáéíóúñü]'), '')
        .trim();
  }
}
