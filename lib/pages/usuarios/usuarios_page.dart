import 'package:flutter/material.dart';
import 'package:metadocs/data/metadocs_mock_data.dart';
import 'package:metadocs/helpers/constants.dart';
import 'package:metadocs/models/models.dart';
import 'package:metadocs/theme/theme.dart';
import 'package:pluto_grid/pluto_grid.dart';

class UsuariosPage extends StatefulWidget {
  const UsuariosPage({super.key});

  @override
  State<UsuariosPage> createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  PlutoGridStateManager? _sm;
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

  /// Maps user first name to a real avatar asset path.
  String _avatarPath(String nombre) {
    final first = nombre.split(' ').first.toLowerCase();
    const map = {
      'valeria': 'assets/images/avatares/valeria.png',
      'carlos': 'assets/images/avatares/Carlos.png',
      'patricia': 'assets/images/avatares/Marta.png',
      'rodrigo': 'assets/images/avatares/Fernando.png',
      'elena': 'assets/images/avatares/Laura.png',
      'miguel': 'assets/images/avatares/Eduardo.png',
      'sandra': 'assets/images/avatares/Maria.png',
      'jorge': 'assets/images/avatares/Juan.png',
      'laura': 'assets/images/avatares/Laura.png',
      'maria': 'assets/images/avatares/Maria.png',
      'marta': 'assets/images/avatares/Marta.png',
      'eduardo': 'assets/images/avatares/Eduardo.png',
      'fernando': 'assets/images/avatares/Fernando.png',
      'juan': 'assets/images/avatares/Juan.png',
      'yuna': 'assets/images/avatares/Yuna.png',
    };
    return map[first] ?? '';
  }

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
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Usuarios y Roles', style: AppTheme.h1(t)),
                  const SizedBox(height: 4),
                  Text(
                      '${MetaDocsMockData.usuarios.where((u) => u.estatus == "activo").length} activos · ${MetaDocsMockData.usuarios.length} usuarios registrados',
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
              _filterDropdown(
                  'Rol',
                  _filterRol,
                  [
                    'todos',
                    'admin',
                    'analyst',
                    'reviewer',
                    'compliance',
                    'operations'
                  ],
                  (v) => setState(() => _filterRol = v!),
                  t),
              const SizedBox(width: 10),
              _filterDropdown(
                  'Estatus',
                  _filterEstatus,
                  ['todos', 'activo', 'inactivo', 'bloqueado'],
                  (v) => setState(() => _filterEstatus = v!),
                  t),
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
                        child: PlutoGrid(
                          columns: _usuCols(t),
                          rows: _usuRows(usuarios, t),
                          onLoaded: (e) => _sm = e.stateManager,
                          configuration: _usuConfig(t),
                          createFooter: (sm) {
                            sm.setPageSize(25, notify: false);
                            return PlutoPagination(sm);
                          },
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // -- PLUTOGRID HELPERS -------------------------------------
  List<PlutoColumn> _usuCols(AppThemeData t) => [
        PlutoColumn(
          title: 'Usuario',
          field: 'nombre',
          type: PlutoColumnType.text(),
          width: 200,
          titlePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          cellPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          renderer: (ctx) {
            final nombre = ctx.cell.value as String;
            final rol = ctx.row.cells['rol']?.value as String? ?? '';
            final rolColor = _rolColor(rol, t);
            final path = _avatarPath(nombre);
            return Row(children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: rolColor.withOpacity(0.15),
                backgroundImage: path.isNotEmpty ? AssetImage(path) : null,
                child: path.isEmpty
                    ? Text(
                        nombre.split(' ').map((p) => p[0]).take(2).join(),
                        style: TextStyle(
                            color: rolColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w700),
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(nombre,
                      style: AppTheme.tableData(t),
                      overflow: TextOverflow.ellipsis)),
            ]);
          },
        ),
        PlutoColumn(
          title: 'Email',
          field: 'email',
          type: PlutoColumnType.text(),
          width: 220,
          titlePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          cellPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          renderer: (ctx) => Text(ctx.cell.value as String,
              style: AppTheme.tableData(t).copyWith(color: t.textSecondary),
              overflow: TextOverflow.ellipsis),
        ),
        PlutoColumn(
          title: 'Rol',
          field: 'rol',
          type: PlutoColumnType.text(),
          width: 110,
          titlePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          cellPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          renderer: (ctx) {
            final rol = ctx.cell.value as String;
            return _chip(_rolLabel(rol), _rolColor(rol, t));
          },
        ),
        PlutoColumn(
          title: 'Estatus',
          field: 'estatus',
          type: PlutoColumnType.text(),
          width: 95,
          titlePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          cellPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          renderer: (ctx) {
            final est = ctx.cell.value as String;
            return _chip(est, _estatusColor(est, t));
          },
        ),
        PlutoColumn(
          title: 'Último acceso',
          field: 'ultimoAcceso',
          type: PlutoColumnType.text(),
          width: 110,
          titlePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          cellPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          renderer: (ctx) => Text(ctx.cell.value as String,
              style: AppTheme.tableData(t).copyWith(color: t.textSecondary)),
        ),
        PlutoColumn(
          title: 'Perms.',
          field: 'permisos',
          type: PlutoColumnType.number(),
          width: 70,
          titlePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          cellPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          renderer: (ctx) => _chip('${ctx.cell.value}', t.info),
        ),
        PlutoColumn(
          title: 'Acciones',
          field: 'accNombre',
          type: PlutoColumnType.text(),
          width: 90,
          titlePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          cellPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          renderer: (ctx) {
            final nombre = ctx.cell.value as String;
            final est = ctx.row.cells['estatus']?.value as String? ?? '';
            return Row(mainAxisSize: MainAxisSize.min, children: [
              _iconBtn(Icons.edit_outlined, t.info,
                  () => _showSnack('Editar: $nombre')),
              const SizedBox(width: 4),
              _iconBtn(
                  est == 'bloqueado'
                      ? Icons.lock_open_outlined
                      : Icons.block_outlined,
                  est == 'bloqueado' ? t.success : t.error,
                  () => _showSnack(est == 'bloqueado'
                      ? 'Desbloquear: $nombre'
                      : 'Bloquear: $nombre')),
            ]);
          },
        ),
      ];

  List<PlutoRow> _usuRows(List<UsuarioSistema> usuarios, AppThemeData t) =>
      usuarios.map((u) {
        final ua = u.ultimoAcceso;
        final dStr =
            '${ua.day.toString().padLeft(2, "0")}/${ua.month.toString().padLeft(2, "0")}/${ua.year}';
        return PlutoRow(cells: {
          'nombre': PlutoCell(value: u.nombre),
          'email': PlutoCell(value: u.email),
          'rol': PlutoCell(value: u.rol),
          'estatus': PlutoCell(value: u.estatus),
          'ultimoAcceso': PlutoCell(value: dStr),
          'permisos': PlutoCell(value: u.permisos.length),
          'accNombre': PlutoCell(value: u.nombre),
        });
      }).toList();

  PlutoGridConfiguration _usuConfig(AppThemeData t) => PlutoGridConfiguration(
        style: PlutoGridStyleConfig(
          gridBackgroundColor: t.surface,
          rowColor: t.surface,
          oddRowColor:
              t.isDark ? const Color(0xFF0D1628) : const Color(0xFFF8FAFC),
          activatedColor: t.primary.withOpacity(0.10),
          gridBorderColor: Colors.transparent,
          borderColor: t.border,
          activatedBorderColor: t.primary,
          inactivatedBorderColor: Colors.transparent,
          columnTextStyle: AppTheme.tableHeader(t),
          cellTextStyle: AppTheme.tableData(t),
          iconColor: t.textDisabled,
          menuBackgroundColor: t.surface,
          columnHeight: 44,
          rowHeight: 50,
        ),
        columnSize: const PlutoGridColumnSizeConfig(
          autoSizeMode: PlutoAutoSizeMode.scale,
          resizeMode: PlutoResizeMode.normal,
        ),
      );

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
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              () {
                final path = _avatarPath(u.nombre);
                return CircleAvatar(
                  radius: 20,
                  backgroundColor: rolColor.withOpacity(0.15),
                  backgroundImage: path.isNotEmpty ? AssetImage(path) : null,
                  child: path.isEmpty
                      ? Text(
                          u.nombre.split(' ').map((p) => p[0]).take(2).join(),
                          style: TextStyle(
                              color: rolColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w700),
                        )
                      : null,
                );
              }(),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(u.nombre,
                          style: AppTheme.body(t)
                              .copyWith(fontWeight: FontWeight.w600)),
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
