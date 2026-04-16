// lib/functions/asset_helper.dart
// Utilidades para asignación determinista de imágenes de empresa y avatares
// de persona (con detección de género por nombre).

import 'package:flutter/material.dart';

// ─── Imágenes de empresa ─────────────────────────────────────────────────────

const _empresaImages = [
  'apex',
  'atlas',
  'horizon',
  'meridian',
  'nexus',
  'nova',
  'pinnacle',
  'quantum',
  'sterling',
  'summit',
  'vanguard',
  'vertex',
];

/// Devuelve la ruta del isotipo de empresa de forma determinista por nombre.
String companyImagePath(String nombre) {
  final idx = nombre.hashCode.abs() % _empresaImages.length;
  return 'assets/images/empresas/${_empresaImages[idx]}.png';
}

// ─── Avatares de persona ─────────────────────────────────────────────────────

const _avataresFemeninos = ['Laura', 'Maria', 'Marta'];
const _avataresMasculinos = ['Carlos', 'Eduardo', 'Juan'];

const _nombresFemeninos = {
  'maria',
  'laura',
  'marta',
  'ana',
  'carmen',
  'elena',
  'rosa',
  'patricia',
  'claudia',
  'sofia',
  'isabel',
  'lucia',
  'andrea',
  'beatriz',
  'diana',
  'fernanda',
  'gabriela',
  'ingrid',
  'jessica',
  'karen',
  'linda',
  'monica',
  'natalia',
  'olga',
  'paula',
  'rebeca',
  'sandra',
  'teresa',
  'valentina',
  'ximena',
  'yolanda',
  'adriana',
  'alicia',
  'blanca',
  'cecilia',
  'dolores',
  'esther',
  'fabiola',
  'graciela',
  'gloria',
  'hilda',
  'irene',
  'julia',
  'lorena',
  'mariana',
  'norma',
  'ofelia',
  'pilar',
  'raquel',
  'silvia',
  'veronica',
  'guadalupe',
  'lupe',
  'lourdes',
  'rocio',
  'alma',
  'miriam',
  'perla',
  'brenda',
  'nadia',
  'wendy',
  'abigail',
  'ariadna',
  'consuelo',
  'esperanza',
  'florencia',
  'griselda',
  'hortensia',
};

/// Elimina tildes y diéresis para comparación case-insensitive.
String _sinTilde(String s) => s
    .replaceAll('á', 'a')
    .replaceAll('é', 'e')
    .replaceAll('í', 'i')
    .replaceAll('ó', 'o')
    .replaceAll('ú', 'u')
    .replaceAll('ü', 'u')
    .replaceAll('à', 'a')
    .replaceAll('è', 'e')
    .replaceAll('ì', 'i')
    .replaceAll('ò', 'o')
    .replaceAll('ù', 'u');

/// `true` si el nombre parece femenino (heurística por cualquier palabra, sin tildes).
bool esFemenino(String nombre) {
  // titulos que se deben ignorar
  const titulos = {
    'lic',
    'dr',
    'dra',
    'ing',
    'arq',
    'mtro',
    'mtra',
    'cp',
    'sr',
    'sra'
  };
  final palabras = nombre.toLowerCase().split(RegExp(r'[\s,\.]+'));
  return palabras.any((p) {
    final norm = _sinTilde(p);
    return norm.isNotEmpty &&
        !titulos.contains(norm) &&
        _nombresFemeninos.contains(norm);
  });
}

/// Devuelve la ruta del avatar de persona según género detectado.
String avatarPath(String nombre) {
  if (esFemenino(nombre)) {
    final idx = nombre.hashCode.abs() % _avataresFemeninos.length;
    return 'assets/images/avatares/${_avataresFemeninos[idx]}.png';
  } else {
    final idx = nombre.hashCode.abs() % _avataresMasculinos.length;
    return 'assets/images/avatares/${_avataresMasculinos[idx]}.png';
  }
}

// ─── Formato de fecha descriptivo ────────────────────────────────────────────

const _meses = [
  'enero',
  'febrero',
  'marzo',
  'abril',
  'mayo',
  'junio',
  'julio',
  'agosto',
  'septiembre',
  'octubre',
  'noviembre',
  'diciembre',
];

/// Formatea una fecha como "21 de enero de 2026".
String fechaDescriptiva(DateTime d) =>
    '${d.day} de ${_meses[d.month - 1]} de ${d.year}';

// ─── Widgets ─────────────────────────────────────────────────────────────────

/// Contenedor circular para isotipo de empresa.
Widget companyCircle({
  required String nombre,
  double size = 36,
  double borderWidth = 1.5,
  Color? borderColor,
}) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white,
      border: Border.all(
        color: borderColor ?? const Color(0xFFE3E8EF),
        width: borderWidth,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ],
    ),
    child: ClipOval(
      child: Image.asset(
        companyImagePath(nombre),
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Icon(
          Icons.business_outlined,
          size: size * 0.55,
          color: const Color(0xFF94A3B8),
        ),
      ),
    ),
  );
}

/// Contenedor circular para avatar de persona.
Widget avatarCircle({
  required String nombre,
  double size = 36,
  double borderWidth = 1.5,
  Color? borderColor,
}) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: borderColor ?? const Color(0xFFE3E8EF),
        width: borderWidth,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ],
    ),
    child: ClipOval(
      child: Image.asset(
        avatarPath(nombre),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => CircleAvatar(
          radius: size / 2,
          backgroundColor: const Color(0xFFE3E8EF),
          child: Icon(
            Icons.person_outline,
            size: size * 0.55,
            color: const Color(0xFF94A3B8),
          ),
        ),
      ),
    ),
  );
}
