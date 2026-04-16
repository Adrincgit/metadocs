import 'package:flutter/material.dart';
import 'package:nethive_neo/data/metadocs_mock_data.dart';
import 'package:nethive_neo/helpers/constants.dart';
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

    final modulos = ['todos', ...MetaDocsMockData.auditoriaEventos.map((e) => e.modulo).toSet().toList()..sort()];
    final acciones = ['todos', 'subir', 'extraer', 'revisar', 'rechazar', 'archivar', 'configurar', 'editar', 'login'];
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
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Auditoría', style: AppTheme.h1(t)),
                      const SizedBox(height: 4),
                      Text('${MetaDocsMockData.auditoriaEventos.length} eventos registrados — Log de actividad del sistema',
                          style: AppTheme.bodySmall(t)),
                    ],
                  )),
                  if (!isMobile)
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
                if (isMobile) ...[
                  TextField(
                    controller: _searchCtrl,
                    onChanged: (_) => setState(() {}),
                    style: AppTheme.body(t),
                    decoration: _inputDeco('Buscar usuario, descripción…', t),
                  ),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: _filterDrop('Módulo', _filterModulo, modulos,
                        (v) => setState(() => _filterModulo = v!), t)),
                    const SizedBox(width: 8),
                    Expanded(child: _filterDrop('Resultado', _filterResultado, resultados,
                        (v) => setState(() => _filterResultado = v!), t)),
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
                        style: AppTheme.caption(t).copyWith(color: t.textSecondary)),
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

  // ── MOBILE CARDS ──────────────────────────────────────────
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
                Icon(_resultIcon(ev.resultado as String), size: 14, color: resColor),
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
                  style: AppTheme.body(t), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(ev.usuario as String,
                  style: AppTheme.caption(t).copyWith(color: t.textSecondary)),
            ],
          ),
        );
      },
    );
  }

  // ── DESKTOP TABLE ─────────────────────────────────────────
  Widget _desktopTable(List eventos, AppThemeData t) {
    return Container(
      decoration: AppTheme.tableDecoration(t),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          children: [
            Container(
              color: t.isDark ? const Color(0xFF0D1628) : const Color(0xFFF1F5FF),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(children: [
                SizedBox(width: 128, child: Text('Timestamp', style: AppTheme.tableHeader(t))),
                SizedBox(width: 145, child: Text('Usuario', style: AppTheme.tableHeader(t))),
                SizedBox(width: 115, child: Text('Módulo', style: AppTheme.tableHeader(t))),
                SizedBox(width: 95, child: Text('Acción', style: AppTheme.tableHeader(t))),
                Expanded(child: Text('Descripción', style: AppTheme.tableHeader(t))),
                SizedBox(width: 105, child: Text('Resultado', style: AppTheme.tableHeader(t))),
                SizedBox(width: 100, child: Text('IP', style: AppTheme.tableHeader(t))),
              ]),
            ),
            Divider(color: t.border, height: 1),
            Expanded(
              child: ListView.separated(
                itemCount: eventos.length,
                separatorBuilder: (_, __) => Divider(color: t.border, height: 1),
                itemBuilder: (_, i) {
                  final ev = eventos[i];
                  final isOdd = i.isOdd;
                  final acColor = _accionColor(ev.accion as String, t);
                  final resColor = _resultColor(ev.resultado as String, t);
                  final ts = ev.timestamp as DateTime;
                  final tsStr =
                      '${ts.day.toString().padLeft(2, "0")}/${ts.month.toString().padLeft(2, "0")}/${ts.year} ${ts.hour.toString().padLeft(2, "0")}:${ts.minute.toString().padLeft(2, "0")}';
                  return Container(
                    color: isOdd
                        ? (t.isDark ? const Color(0xFF0D1628) : const Color(0xFFF8FAFC))
                        : t.surface,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(children: [
                      SizedBox(
                        width: 128,
                        child: Text(tsStr,
                            style: AppTheme.tableData(t).copyWith(
                                fontSize: 11, color: t.textSecondary)),
                      ),
                      SizedBox(
                        width: 145,
                        child: Text(ev.usuario as String,
                            style: AppTheme.tableData(t).copyWith(fontSize: 12),
                            overflow: TextOverflow.ellipsis),
                      ),
                      SizedBox(
                        width: 115,
                        child: _chip(ev.modulo as String, t.primary, t),
                      ),
                      SizedBox(
                        width: 95,
                        child: _chip(ev.accion as String, acColor, t),
                      ),
                      Expanded(
                        child: Text(ev.descripcion as String,
                            style: AppTheme.tableData(t).copyWith(fontSize: 12),
                            overflow: TextOverflow.ellipsis),
                      ),
                      SizedBox(
                        width: 105,
                        child: Row(children: [
                          Icon(_resultIcon(ev.resultado as String), size: 14, color: resColor),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(ev.resultado as String,
                                style: AppTheme.tableData(t).copyWith(
                                    color: resColor, fontSize: 12)),
                          ),
                        ]),
                      ),
                      SizedBox(
                        width: 100,
                        child: Text(
                          (ev.ip as String?) ?? '—',
                          style: AppTheme.tableData(t).copyWith(
                              fontSize: 11, color: t.textSecondary,
                              fontFamily: 'monospace'),
                        ),
                      ),
                    ]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── HELPERS ───────────────────────────────────────────────
  Widget _chip(String label, Color color, AppThemeData t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(label,
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700),
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
          items: items.map((e) => DropdownMenuItem(
            value: e,
            child: Text(e == 'todos' ? label : e, style: AppTheme.bodySmall(t)),
          )).toList(),
        ),
      ),
    );
  }
}