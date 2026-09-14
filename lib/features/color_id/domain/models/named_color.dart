import 'package:flutter/material.dart';

class NamedColor {
  final String name;
  final Color referenceColor;
  final String category; // "Basic" or "Extended"
  final String? description;

  const NamedColor({
    required this.name,
    required this.referenceColor,
    required this.category,
    this.description,
  });
}

class ColorMatchResult {
  final Color sampledColor;
  final String basicName;
  final String extendedName;
  final double distance;
  final double luminance;
  final bool isPoorLighting;
  final String? lightingWarning;
  final String? confusionWarning;

  const ColorMatchResult({
    required this.sampledColor,
    required this.basicName,
    required this.extendedName,
    required this.distance,
    required this.luminance,
    required this.isPoorLighting,
    this.lightingWarning,
    this.confusionWarning,
  });

  String get hexCode =>
      '#${sampledColor.red.toRadixString(16).padLeft(2, '0').toUpperCase()}'
      '${sampledColor.green.toRadixString(16).padLeft(2, '0').toUpperCase()}'
      '${sampledColor.blue.toRadixString(16).padLeft(2, '0').toUpperCase()}';
}
