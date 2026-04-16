import 'package:flutter/material.dart';
import 'package:nethive_neo/theme/theme.dart';

class ConfiguracionPage extends StatelessWidget {
  const ConfiguracionPage({super.key});
  @override
  Widget build(BuildContext context) {
    final t = AppTheme.of(context);
    return ColoredBox(
      color: t.background,
      child: Center(child: Text('Configuracion', style: AppTheme.h2(t))),
    );
  }
}