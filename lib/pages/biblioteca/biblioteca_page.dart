import 'package:flutter/material.dart';
import 'package:nethive_neo/theme/theme.dart';

class BibliotecaPage extends StatelessWidget {
  const BibliotecaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppTheme.of(context);
    return ColoredBox(
      color: t.background,
      child: Center(
        child: Text(
          'Biblioteca de Documentos',
          style: AppTheme.h2(t),
        ),
      ),
    );
  }
}
