import 'package:flutter/material.dart';
import 'package:nethive_neo/theme/theme.dart';

class UsuariosPage extends StatelessWidget {
  const UsuariosPage({super.key});
  @override
  Widget build(BuildContext context) {
    final t = AppTheme.of(context);
    return ColoredBox(
      color: t.background,
      child: Center(child: Text('Usuarios y Roles', style: AppTheme.h2(t))),
    );
  }
}