import 'package:flutter/material.dart';
import 'package:metadocs/data/metadocs_mock_data.dart';
import 'package:metadocs/helpers/constants.dart';
import 'package:metadocs/theme/theme.dart';
import 'package:pluto_grid/pluto_grid.dart';

class AuditoriaPage extends StatefulWidget {
  const AuditoriaPage({super.key});

  @override
  State<AuditoriaPage> createState() => _AuditoriaPageState();
}

class _AuditoriaPageState extends State<AuditoriaPage> {
  PlutoGridStateManager? _sm;
  String _filterModulo = 'todos';
  String _filterAccion = 'todos';
  String _filterResultado = 'todos';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Color _accionColor(String accion, AppThemeData t) => switch (accion) {
        'subir' => t.success,
        'extraer' => t.info,
        'revisar' => t.primary,
        'rechazar' => t.error,
        'archivar' => t.neutral,
        'configurar' => t.warning,
        'editar' => t.indigo,
        'login' => t.textSecondary,
        _ => t.neutral,
      };

  Color _resultColor(String res, AppThemeData t) => switch (res) {
        'exitoso' => t.success,
        'fallido' => t.error,
        'advertencia' => t.warning,
        _ => t.neutral,
      };

  IconData _resultIcon(String res) => switch (res) {
        'exitoso' => Icons.check_circle_outline,
        'fallido' => Icons.cancel_outlined,
        'advertencia' => Icons.warning_amber_outlined,
        _ => Icons.info_outline,
      };

  @override
  Widget build(BuildContext context) {
    final t = AppTheme.of(context);
    var eventos = MetaDocsMockData.auditoriaEventos;

    if (_filterModulo != 'todos') {
      eventos = eventos.where((e) => e.modulo == _filterModulo).toList();
    }
    if (_filterAccion != 'todos') {
      eventos = eventos.where((e) => e.accion == _filterAccion).toList();
    }
    if (_filterResultado != 'todos') {
      eventos = eventos.where((e) => e.resultado == _filterResultado).toList();
    }
    final q = _searchCtrl.text.toLowerCase();
    if (q.isNotEmpty) {
      eventos = eventos
          .where((e) =>
              e.usuario.toLowerCase().contains(q) ||
              e.descripcion.toLowerCase().contains(q) ||
              e.modulo.toLowerCase().contains(q))
          .toList();
    }

    final modulos = [
      'todos',
      ...MetaDocsMockData.auditoriaEventos.map((e) => e.modulo).toSet().toList()
        ..sort()
    ];
    final acciones = [
      'todos',
      'subir',
      'extraer',
      'revisar',
      'rechazar',
      'archivar',
      'configurar',
      'editar',
      'login'
    ];
    final resultados = ['todos', 'exitoso', 'fallido', 'advertencia'];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < mobileSize;
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
                      Text('Auditoría', style: AppTheme.h1(t)),
                      const SizedBox(height: 4),
                      Text(
                          '${MetaDocsMockData.auditoriaEventos.length} eventos registrados — Log de actividad del sistema',
                          style: AppTheme.bodySmall(t)),
                    ],
                  )),
                  if (!isMobile)
                    OutlinedButton.icon(
                      onPressed: () => ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(
                              content: Text('Exportando log de auditoría…'),
                              duration: Duration(seconds: 2))),
                      icon: Icon(Icons.download_outlined,
                          size: 15, color: t.info),
                      label: Text('Exportar log',
                          style: AppTheme.button(t).copyWith(color: t.info)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: t.info.withOpacity(0.5)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                ]),
                const SizedBox(height: 16),

                // Filtros
                if (isMobile) ...[
                  TextField(
                    controller: _searchCtrl,
                    onChanged: (_) => setState(() {}),
                    style: AppTheme.body(t),
                    decoration: _inputDeco('Buscar usuario, descripción…', t),
                  ),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(
                        child: _filterDrop('Módulo', _filterModulo, modulos,
                            (v) => setState(() => _filterModulo = v!), t)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _filterDrop(
                            'Resultado',
                            _filterResultado,
                            resultados,
                            (v) => setState(() => _filterResultado = v!),
                            t)),
                  ]),
                ] else
                  Row(children: [
                    SizedBox(
                      width: 200,
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: (_) => setState(() {}),
                        style: AppTheme.body(t),
                        decoration: _inputDeco('Buscar…', t),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _filterDrop('Módulo', _filterModulo, modulos,
                        (v) => setState(() => _filterModulo = v!), t),
                    const SizedBox(width: 8),
                    _filterDrop('Acción', _filterAccion, acciones,
                        (v) => setState(() => _filterAccion = v!), t),
                    const SizedBox(width: 8),
                    _filterDrop('Resultado', _filterResultado, resultados,
                        (v) => setState(() => _filterResultado = v!), t),
                    const SizedBox(width: 8),
                    Text('${eventos.length} resultados',
                        style: AppTheme.caption(t)
                            .copyWith(color: t.textSecondary)),
                  ]),
                const SizedBox(height: 16),

                // Contenido
                Expanded(
                  child: isMobile
                      ? _mobileCards(eventos, t)
                      : _desktopTable(eventos, t),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // -- MOBILE CARDS ------------------------------------------
  Widget _mobileCards(List eventos, AppThemeData t) {
    return ListView.separated(
      itemCount: eventos.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final ev = eventos[i];
        final ts = ev.timestamp as DateTime;
        final tsStr =
            '${ts.day.toString().padLeft(2, "0")}/${ts.month.toString().padLeft(2, "0")}/${ts.year} ${ts.hour.toString().padLeft(2, "0")}:${ts.minute.toString().padLeft(2, "0")}';
        final acColor = _accionColor(ev.accion as String, t);
        final resColor = _resultColor(ev.resultado as String, t);
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: t.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: t.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text(tsStr, style: AppTheme.caption(t)),
                const Spacer(),
                Icon(_resultIcon(ev.resultado as String),
                    size: 14, color: resColor),
                const SizedBox(width: 4),
                Text(ev.resultado as String,
                    style: AppTheme.caption(t).copyWith(color: resColor)),
              ]),
              const SizedBox(height: 6),
              Row(children: [
                _chip(ev.modulo as String, t.primary, t),
                const SizedBox(width: 6),
                _chip(ev.accion as String, acColor, t),
              ]),
              const SizedBox(height: 6),
              Text(ev.descripcion as String,
                  style: AppTheme.body(t),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(ev.usuario as String,
                  style: AppTheme.caption(t).copyWith(color: t.textSecondary)),
            ],
          ),
        );
      },
    );
  }

  // -- DESKTOP TABLE (PlutoGrid) -----------------------------
  List<PlutoColumn> _cols(AppThemeData t) => [
        PlutoColumn(
          title: 'Timestamp',
          field: 'timestamp',
          type: PlutoColumnType.text(),
          width: 130,
          titlePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          cellPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          renderer: (ctx) => Text(ctx.cell.value as String,
              style: AppTheme.tableData(t)
                  .copyWith(fontSize: 11, color: t.textSecondary)),
        ),
        PlutoColumn(
          title: 'Usuario',
          field: 'usuario',
          type: PlutoColumnType.text(),
          width: 145,
          titlePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          cellPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          renderer: (ctx) => Text(ctx.cell.value as String,
              style: AppTheme.tableData(t).copyWith(fontSize: 12),
              overflow: TextOverflow.ellipsis),
        ),
        PlutoColumn(
          title: 'Módulo',
          field: 'modulo',
          type: PlutoColumnType.text(),
          width: 110,
          titlePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          cellPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          renderer: (ctx) => _chip(ctx.cell.value as String, t.primary, t),
        ),
        PlutoColumn(
          title: 'Acción',
          field: 'accion',
          type: PlutoColumnType.text(),
          width: 95,
          titlePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          cellPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          renderer: (ctx) {
            final accion = ctx.cell.value as String;
            return _chip(accion, _accionColor(accion, t), t);
          },
        ),
        PlutoColumn(
          title: 'Descripción',
          field: 'descripcion',
          type: PlutoColumnType.text(),
          width: 280,
          titlePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          cellPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          renderer: (ctx) => Text(ctx.cell.value as String,
              style: AppTheme.tableData(t).copyWith(fontSize: 12),
              overflow: TextOverflow.ellipsis),
        ),
        PlutoColumn(
          title: 'Resultado',
          field: 'resultado',
          type: PlutoColumnType.text(),
          width: 105,
          titlePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          cellPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          renderer: (ctx) {
            final res = ctx.cell.value as String;
            final color = _resultColor(res, t);
            return Row(children: [
              Icon(_resultIcon(res), size: 14, color: color),
              const SizedBox(width: 5),
              Expanded(
                  child: Text(res,
                      style: AppTheme.tableData(t)
                          .copyWith(color: color, fontSize: 12))),
            ]);
          },
        ),
        PlutoColumn(
          title: 'IP',
          field: 'ip',
          type: PlutoColumnType.text(),
          width: 100,
          titlePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          cellPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          renderer: (ctx) => Text(ctx.cell.value as String,
              style: AppTheme.tableData(t).copyWith(
                  fontSize: 11,
                  color: t.textSecondary,
                  fontFamily: 'monospace')),
        ),
      ];

  List<PlutoRow> _buildRows(List eventos) => eventos.map((ev) {
        final ts = ev.timestamp as DateTime;
        final tsStr =
            '${ts.day.toString().padLeft(2, "0")}/${ts.month.toString().padLeft(2, "0")}/${ts.year} '
            '${ts.hour.toString().padLeft(2, "0")}:${ts.minute.toString().padLeft(2, "0")}';
        return PlutoRow(cells: {
          'timestamp': PlutoCell(value: tsStr),
          'usuario': PlutoCell(value: ev.usuario as String),
          'modulo': PlutoCell(value: ev.modulo as String),
          'accion': PlutoCell(value: ev.accion as String),
          'descripcion': PlutoCell(value: ev.descripcion as String),
          'resultado': PlutoCell(value: ev.resultado as String),
          'ip': PlutoCell(value: (ev.ip as String?) ?? '—'),
        });
      }).toList();

  PlutoGridConfiguration _config(AppThemeData t) => PlutoGridConfiguration(
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
          rowHeight: 44,
        ),
        columnSize: const PlutoGridColumnSizeConfig(
          autoSizeMode: PlutoAutoSizeMode.scale,
          resizeMode: PlutoResizeMode.normal,
        ),
      );

  Widget _desktopTable(List eventos, AppThemeData t) {
    return Container(
      decoration: AppTheme.tableDecoration(t),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: PlutoGrid(
          columns: _cols(t),
          rows: _buildRows(eventos),
          onLoaded: (e) => _sm = e.stateManager,
          configuration: _config(t),
          createFooter: (sm) {
            sm.setPageSize(25, notify: false);
            return PlutoPagination(sm);
          },
        ),
      ),
    );
  }

  // -- HELPERS -----------------------------------------------
  Widget _chip(String label, Color color, AppThemeData t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.w700),
          overflow: TextOverflow.ellipsis),
    );
  }

  InputDecoration _inputDeco(String hint, AppThemeData t) => InputDecoration(
        hintText: hint,
        hintStyle: AppTheme.body(t).copyWith(color: t.textDisabled),
        prefixIcon: Icon(Icons.search, size: 18, color: t.textDisabled),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: t.border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: t.border)),
        fillColor: t.surface,
        filled: true,
      );

  Widget _filterDrop(String label, String value, List<String> items,
      void Function(String?) onChanged, AppThemeData t) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: t.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: t.surface,
          style: AppTheme.bodySmall(t),
          icon: Icon(Icons.expand_more, size: 15, color: t.textDisabled),
          onChanged: onChanged,
          items: items
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e == 'todos' ? label : e,
                        style: AppTheme.bodySmall(t)),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
