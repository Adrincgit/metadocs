import 'package:flutter/material.dart';
import 'package:nethive_neo/theme/theme.dart';

class IngestaPage extends StatelessWidget {
  const IngestaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppTheme.of(context);
    return ColoredBox(
      color: t.background,
      child: Center(
        child: Text(
          'Ingesta / Carga de Documentos',
          style: AppTheme.h2(t),
        ),
      ),
    );
  }
}
