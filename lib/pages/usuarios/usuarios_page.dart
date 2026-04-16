import 'package:flutter/material.dart';
import 'package:nethive_neo/data/metadocs_mock_data.dart';
import 'package:nethive_neo/helpers/constants.dart';
import 'package:nethive_neo/models/models.dart';
import 'package:nethive_neo/theme/theme.dart';

class UsuariosPage extends StatefulWidget {
  const UsuariosPage({super.key});

  @override
  State<UsuariosPage> createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  String _filterRol = 'todos';
  String _filterEstatus = 'todos';

  void _showSnack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));

  Color _rolColor(String rol, AppThemeData t) => switch (rol) {
        'admin' => t.error,
        'analyst' => t.indigo,
        'reviewer' => t.info,
        'compliance' => t.warning,
        'operations' => t.neutral,
        _ => t.neutral,
      };

  String _rolLabel(String rol) => switch (rol) {
        'admin' => 'Admin',
        'analyst' => 'Analyst',
        'reviewer' => 'Reviewer',
        'compliance' => 'Compliance',
        'operations' => 'Operations',
        _ => rol,
      };

  Color _estatusColor(String estatus, AppThemeData t) => switch (estatus) {
        'activo' => t.success,
        'inactivo' => t.neutral,
        'bloqueado' => t.error,
        _ => t.neutral,
      };

  @override
  Widget build(BuildContext context) {
    final t = AppTheme.of(context);
    final isMobile = MediaQuery.sizeOf(context).width < mobileSize;
    var usuarios = MetaDocsMockData.usuarios;
    if (_filterRol != 'todos') {
      usuarios = usuarios.where((u) => u.rol == _filterRol).toList();
    }
    if (_filterEstatus != 'todos') {
      usuarios = usuarios.where((u) => u.estatus == _filterEstatus).toList();
    }

    return ColoredBox(
      color: t.background,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(children: [
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Usuarios y Roles', style: AppTheme.h1(t)),
                  const SizedBox(height: 4),
                  Text('${MetaDocsMockData.usuarios.where((u) => u.estatus == "activo").length} activos · ${MetaDocsMockData.usuarios.length} usuarios registrados',
                      style: AppTheme.bodySmall(t)),
                ],
              )),
              FilledButton.icon(
                onPressed: () => _showSnack('Nuevo usuario (demo)'),
                icon: const Icon(Icons.person_add_outlined, size: 16),
                label: const Text('Nuevo usuario'),
                style: FilledButton.styleFrom(
                  backgroundColor: t.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ]),
            const SizedBox(height: 16),

            // Filtros
            Row(children: [
              _filterDropdown('Rol', _filterRol, ['todos', 'admin', 'analyst', 'reviewer', 'compliance', 'operations'],
                  (v) => setState(() => _filterRol = v!), t),
              const SizedBox(width: 10),
              _filterDropdown('Estatus', _filterEstatus, ['todos', 'activo', 'inactivo', 'bloqueado'],
                  (v) => setState(() => _filterEstatus = v!), t),
            ]),
            const SizedBox(height: 16),

            // Tabla manual scroll
            Expanded(
              child: isMobile
                  ? _buildMobileCards(usuarios, t)
                  : Container(
                      decoration: AppTheme.tableDecoration(t),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Column(
                    children: [
                      // Header row
                      Container(
                        color: t.isDark ? const Color(0xFF0D1628) : const Color(0xFFF1F5FF),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(children: [
                          SizedBox(width: 200, child: Text('Usuario', style: AppTheme.tableHeader(t))),
                          SizedBox(width: 220, child: Text('Email', style: AppTheme.tableHeader(t))),
                          SizedBox(width: 110, child: Text('Rol', style: AppTheme.tableHeader(t))),
                          SizedBox(width: 110, child: Text('Estatus', style: AppTheme.tableHeader(t))),
                          SizedBox(width: 120, child: Text('Último acceso', style: AppTheme.tableHeader(t))),
                          SizedBox(width: 80, child: Text('Permisos', style: AppTheme.tableHeader(t))),
                          const Spacer(),
                          SizedBox(width: 120, child: Text('Acciones', style: AppTheme.tableHeader(t))),
                        ]),
                      ),
                      Divider(color: t.border, height: 1),

                      // Data rows
                      Expanded(
                        child: ListView.separated(
                          itemCount: usuarios.length,
                          separatorBuilder: (_, __) => Divider(color: t.border, height: 1),
                          itemBuilder: (_, i) {
                            final u = usuarios[i];
                            final isOdd = i.isOdd;
                            final rolColor = _rolColor(u.rol, t);
                            final estColor = _estatusColor(u.estatus, t);
                            final ua = u.ultimoAcceso;
                            final dStr = '${ua.day.toString().padLeft(2,"0")}/${ua.month.toString().padLeft(2,"0")}/${ua.year}';
                            return Container(
                              color: isOdd
                                  ? (t.isDark ? const Color(0xFF0D1628) : const Color(0xFFF8FAFC))
                                  : t.surface,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(children: [
                                // Nombre con avatar
                                SizedBox(
                                  width: 200,
                                  child: Row(children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: rolColor.withOpacity(0.15),
                                      child: Text(
                                        u.nombre.split(' ').map((p) => p[0]).take(2).join(),
                                        style: TextStyle(
                                            color: rolColor,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(u.nombre, style: AppTheme.tableData(t),
                                        overflow: TextOverflow.ellipsis)),
                                  ]),
                                ),
                                // Email
                                SizedBox(
                                  width: 220,
                                  child: Text(u.email,
                                      style: AppTheme.tableData(t).copyWith(color: t.textSecondary),
                                      overflow: TextOverflow.ellipsis),
                                ),
                                // Rol badge
                                SizedBox(
                                  width: 110,
                                  child: _chip(_rolLabel(u.rol), rolColor),
                                ),
                                // Estatus badge
                                SizedBox(
                                  width: 110,
                                  child: _chip(u.estatus, estColor),
                                ),
                                // Último acceso
                                SizedBox(
                                  width: 120,
                                  child: Text(dStr,
                                      style: AppTheme.tableData(t).copyWith(color: t.textSecondary)),
                                ),
                                // Permisos count
                                SizedBox(
                                  width: 80,
                                  child: _chip('${u.permisos.length} perms', t.info),
                                ),
                                const Spacer(),
                                // Acciones
                                SizedBox(
                                  width: 120,
                                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                                    _iconBtn(Icons.edit_outlined, t.info,
                                        () => _showSnack('Editar: ${u.nombre}')),
                                    const SizedBox(width: 4),
                                    _iconBtn(
                                        u.estatus == 'bloqueado'
                                            ? Icons.lock_open_outlined
                                            : Icons.block_outlined,
                                        u.estatus == 'bloqueado' ? t.success : t.error,
                                        () => _showSnack(u.estatus == 'bloqueado'
                                            ? 'Desbloquear: ${u.nombre}'
                                            : 'Bloquear: ${u.nombre}')),
                                  ]),
                                ),
                              ]),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileCards(List<UsuarioSistema> usuarios, AppThemeData t) {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: usuarios.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final u = usuarios[i];
        final rolColor = _rolColor(u.rol, t);
        final estColor = _estatusColor(u.estatus, t);
        final ua = u.ultimoAcceso;
        final dStr =
            '${ua.day.toString().padLeft(2, "0")}/${ua.month.toString().padLeft(2, "0")}/${ua.year}';
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: AppTheme.cardDecoration(t),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: rolColor.withOpacity(0.15),
                child: Text(
                  u.nombre.split(' ').map((p) => p[0]).take(2).join(),
                  style: TextStyle(
                      color: rolColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(u.nombre,
                          style:
                              AppTheme.body(t).copyWith(fontWeight: FontWeight.w600)),
                      Text(u.email,
                          style: AppTheme.caption(t),
                          overflow: TextOverflow.ellipsis),
                    ]),
              ),
              _iconBtn(Icons.edit_outlined, t.info,
                  () => _showSnack('Editar: ${u.nombre}')),
              const SizedBox(width: 4),
              _iconBtn(
                u.estatus == 'bloqueado'
                    ? Icons.lock_open_outlined
                    : Icons.block_outlined,
                u.estatus == 'bloqueado' ? t.success : t.error,
                () => _showSnack(u.estatus == 'bloqueado'
                    ? 'Desbloquear: ${u.nombre}'
                    : 'Bloquear: ${u.nombre}'),
              ),
            ]),
            const SizedBox(height: 10),
            Wrap(spacing: 6, runSpacing: 6, children: [
              _chip(_rolLabel(u.rol), rolColor),
              _chip(u.estatus, estColor),
              _chip('${u.permisos.length} perms', t.info),
            ]),
            const SizedBox(height: 6),
            Text('Último acceso: $dStr', style: AppTheme.caption(t)),
          ]),
        );
      },
    );
  }

  Widget _filterDropdown(String label, String value, List<String> items,
      void Function(String?) onChanged, AppThemeData t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: t.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: t.surface,
          style: AppTheme.body(t),
          items: items
              .map((v) => DropdownMenuItem(
                    value: v,
                    child: Text(v == 'todos' ? 'Todos los $label' : v),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.w700),
          overflow: TextOverflow.ellipsis),
    );
  }

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) {
    return Tooltip(
      message: '',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }
}