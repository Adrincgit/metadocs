import 'package:flutter/material.dart';
import 'package:nethive_neo/data/metadocs_mock_data.dart';
import 'package:nethive_neo/theme/theme.dart';

class AuditoriaPage extends StatefulWidget {
  const AuditoriaPage({super.key});

  @override
  State<AuditoriaPage> createState() => _AuditoriaPageState();
}

class _AuditoriaPageState extends State<AuditoriaPage> {
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
      eventos = eventos.where((e) =>
          e.usuario.toLowerCase().contains(q) ||
          e.descripcion.toLowerCase().contains(q) ||
          e.modulo.toLowerCase().contains(q)).toList();
    }

    final modulos = ['todos', ...MetaDocsMockData.auditoriaEventos.map((e) => e.modulo).toSet()];
    final acciones = ['todos', 'subir', 'extraer', 'revisar', 'rechazar', 'archivar', 'configurar', 'editar', 'login'];
    final resultados = ['todos', 'exitoso', 'fallido', 'advertencia'];

    return ColoredBox(
      color: t.background,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(children: [
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Auditoría', style: AppTheme.h1(t)),
                  const SizedBox(height: 4),
                  Text('${MetaDocsMockData.auditoriaEventos.length} eventos registrados — Log de actividad del sistema',
                      style: AppTheme.bodySmall(t)),
                ],
              )),
              OutlinedButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Exportando log de auditoría…'),
                        duration: Duration(seconds: 2))),
                icon: Icon(Icons.download_outlined, size: 15, color: t.info),
                label: Text('Exportar log',
                    style: AppTheme.button(t).copyWith(color: t.info)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: t.info.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ]),
            const SizedBox(height: 16),

            // Filtros
            Row(children: [
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => setState(() {}),
                  style: AppTheme.body(t),
                  decoration: InputDecoration(
                    hintText: 'Buscar…',
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
                  ),
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
                  style: AppTheme.caption(t).copyWith(color: t.textSecondary)),
            ]),
            const SizedBox(height: 16),

            // Tabla
            Expanded(
              child: Container(
                decoration: AppTheme.tableDecoration(t),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Column(
                    children: [
                      // Header
                      Container(
                        color: t.isDark
                            ? const Color(0xFF0D1628)
                            : const Color(0xFFF1F5FF),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(children: [
                          SizedBox(width: 140, child: Text('Timestamp', style: AppTheme.tableHeader(t))),
                          SizedBox(width: 130, child: Text('Usuario', style: AppTheme.tableHeader(t))),
                          SizedBox(width: 130, child: Text('Módulo', style: AppTheme.tableHeader(t))),
                          SizedBox(width: 100, child: Text('Acción', style: AppTheme.tableHeader(t))),
                          const Expanded(child: Text('')),
                          SizedBox(width: 110, child: Text('Resultado', style: AppTheme.tableHeader(t))),
                          SizedBox(width: 110, child: Text('IP', style: AppTheme.tableHeader(t))),
                        ]),
                      ),
                      Divider(color: t.border, height: 1),

                      // Rows
                      Expanded(
                        child: ListView.separated(
                          itemCount: eventos.length,
                          separatorBuilder: (_, __) => Divider(color: t.border, height: 1),
                          itemBuilder: (_, i) {
                            final ev = eventos[i];
                            final isOdd = i.isOdd;
                            final acColor = _accionColor(ev.accion, t);
                            final resColor = _resultColor(ev.resultado, t);
                            final ts = ev.timestamp;
                            final tsStr =
                                '${ts.day.toString().padLeft(2,"0")}/${ts.month.toString().padLeft(2,"0")}/${ts.year} ${ts.hour.toString().padLeft(2,"0")}:${ts.minute.toString().padLeft(2,"0")}';
                            return Container(
                              color: isOdd
                                  ? (t.isDark
                                      ? const Color(0xFF0D1628)
                                      : const Color(0xFFF8FAFC))
                                  : t.surface,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              child: Row(children: [
                                SizedBox(
                                  width: 140,
                                  child: Text(tsStr,
                                      style: AppTheme.tableData(t).copyWith(
                                          fontSize: 11,
                                          color: t.textSecondary)),
                                ),
                                SizedBox(
                                  width: 130,
                                  child: Text(ev.usuario,
                                      style: AppTheme.tableData(t),
                                      overflow: TextOverflow.ellipsis),
                                ),
                                SizedBox(
                                  width: 130,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: t.primary.withOpacity(0.10),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(ev.modulo,
                                        style: AppTheme.caption(t).copyWith(
                                            color: t.primary,
                                            fontWeight: FontWeight.w600),
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                ),
                                SizedBox(
                                  width: 100,
                                  child: _chip(ev.accion, acColor),
                                ),
                                Expanded(
                                  child: Text(ev.descripcion,
                                      style: AppTheme.tableData(t).copyWith(
                                          color: t.textSecondary, fontSize: 12),
                                      overflow: TextOverflow.ellipsis),
                                ),
                                SizedBox(
                                  width: 110,
                                  child: Row(children: [
                                    Icon(_resultIcon(ev.resultado),
                                        size: 14, color: resColor),
                                    const SizedBox(width: 4),
                                    Text(ev.resultado,
                                        style: AppTheme.tableData(t)
                                            .copyWith(color: resColor, fontSize: 11)),
                                  ]),
                                ),
                                SizedBox(
                                  width: 110,
                                  child: Text(ev.ip ?? '—',
                                      style: AppTheme.tableData(t).copyWith(
                                          color: t.textDisabled, fontSize: 11)),
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

  Widget _filterDrop(String label, String value, List<String> items,
      void Function(String?) onChanged, AppThemeData t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
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
                    child: Text(v == 'todos' ? 'Todos' : v),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
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
}