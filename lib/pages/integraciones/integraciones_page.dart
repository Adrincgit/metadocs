import 'package:flutter/material.dart';
import 'package:nethive_neo/data/metadocs_mock_data.dart';
import 'package:nethive_neo/models/models.dart';
import 'package:nethive_neo/theme/theme.dart';

class IntegracionesPage extends StatefulWidget {
  const IntegracionesPage({super.key});

  @override
  State<IntegracionesPage> createState() => _IntegracionesPageState();
}

class _IntegracionesPageState extends State<IntegracionesPage> {
  Integracion? _selected;

  void _showSnack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));

  IconData _iconForTipo(String tipo) => switch (tipo) {
        'ia_generativa' => Icons.psychology_outlined,
        'ocr' => Icons.document_scanner_outlined,
        'storage' => Icons.cloud_outlined,
        'email' => Icons.email_outlined,
        'api' => Icons.api_outlined,
        'escaner' => Icons.scanner_outlined,
        _ => Icons.extension_outlined,
      };

  Color _colorForEstatus(String estatus, AppThemeData t) => switch (estatus) {
        'activa' => t.success,
        'revision' => t.warning,
        'inactiva' => t.neutral,
        'error' => t.error,
        _ => t.neutral,
      };

  @override
  Widget build(BuildContext context) {
    final t = AppTheme.of(context);
    final integraciones = MetaDocsMockData.integraciones;

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
                  Text('Integraciones', style: AppTheme.h1(t)),
                  const SizedBox(height: 4),
                  Text('${integraciones.where((i) => i.estatus == "activa").length} activas · ${integraciones.length} configuradas',
                      style: AppTheme.bodySmall(t)),
                ],
              )),
              FilledButton.icon(
                onPressed: () => _showSnack('Agregar nueva integración (demo)'),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Nueva integración'),
                style: FilledButton.styleFrom(
                  backgroundColor: t.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ]),
            const SizedBox(height: 20),

            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Grid de tarjetas
                  Expanded(
                    flex: 3,
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.4,
                      children: integraciones.map((integ) {
                        final color = _colorForEstatus(integ.estatus, t);
                        final icon = _iconForTipo(integ.tipo);
                        final isSelected = _selected?.id == integ.id;
                        return GestureDetector(
                          onTap: () => setState(() => _selected = integ),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: t.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? t.primary : t.border,
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(icon, color: color, size: 22),
                                  ),
                                  const Spacer(),
                                  _estatusBadge(integ.estatus, color),
                                ]),
                                const Spacer(),
                                Text(integ.nombre,
                                    style: AppTheme.h3(t),
                                    overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Text(integ.version,
                                    style: AppTheme.caption(t)),
                                const SizedBox(height: 6),
                                if (integ.ultimaSincronizacion != null)
                                  Text(
                                    'Última sync: ${integ.ultimaSincronizacion!.day.toString().padLeft(2,"0")}/${integ.ultimaSincronizacion!.month.toString().padLeft(2,"0")}/${integ.ultimaSincronizacion!.year}',
                                    style: AppTheme.caption(t),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // Panel detalle
                  if (_selected != null) ...[
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 320,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: AppTheme.cardDecoration(t),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: _colorForEstatus(_selected!.estatus, t).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _iconForTipo(_selected!.tipo),
                                  color: _colorForEstatus(_selected!.estatus, t),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_selected!.nombre,
                                      style: AppTheme.h2(t),
                                      overflow: TextOverflow.ellipsis),
                                  Text(_selected!.version,
                                      style: AppTheme.caption(t)),
                                ],
                              )),
                              IconButton(
                                onPressed: () => setState(() => _selected = null),
                                icon: Icon(Icons.close, size: 18, color: t.textDisabled),
                              ),
                            ]),
                            const SizedBox(height: 16),
                            _estatusBadge(_selected!.estatus,
                                _colorForEstatus(_selected!.estatus, t)),
                            const SizedBox(height: 16),
                            Text(_selected!.descripcion,
                                style: AppTheme.body(t)),
                            const SizedBox(height: 16),
                            _detRow('Tipo', _selected!.tipo, t),
                            _detRow('Estatus', _selected!.estatus, t),
                            _detRow('Versión', _selected!.version, t),
                            if (_selected!.ultimaSincronizacion != null)
                              _detRow(
                                'Última sync',
                                '${_selected!.ultimaSincronizacion!.day.toString().padLeft(2,"0")}/${_selected!.ultimaSincronizacion!.month.toString().padLeft(2,"0")}/${_selected!.ultimaSincronizacion!.year} ${_selected!.ultimaSincronizacion!.hour.toString().padLeft(2,"0")}:${_selected!.ultimaSincronizacion!.minute.toString().padLeft(2,"0")}',
                                t,
                              ),
                            const SizedBox(height: 20),
                            Wrap(spacing: 8, runSpacing: 8, children: [
                              _actionBtn('Sincronizar', Icons.sync, t.primary, t),
                              _actionBtn('Configurar', Icons.settings_outlined, t.info, t),
                              if (_selected!.estatus == 'activa')
                                _actionBtn('Pausar', Icons.pause_outlined, t.warning, t)
                              else
                                _actionBtn('Activar', Icons.play_arrow_outlined, t.success, t),
                            ]),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 320,
                      child: Container(
                        decoration: AppTheme.cardDecoration(t),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.touch_app_outlined, size: 36, color: t.textDisabled),
                              const SizedBox(height: 12),
                              Text('Selecciona una integración',
                                  style: AppTheme.body(t).copyWith(color: t.textSecondary)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _estatusBadge(String estatus, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(estatus.toUpperCase(),
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }

  Widget _detRow(String label, String value, AppThemeData t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        SizedBox(
          width: 100,
          child: Text(label,
              style: AppTheme.bodySmall(t).copyWith(color: t.textSecondary)),
        ),
        Expanded(
          child: Text(value,
              style: AppTheme.body(t).copyWith(fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis),
        ),
      ]),
    );
  }

  Widget _actionBtn(String label, IconData icon, Color color, AppThemeData t) {
    return OutlinedButton.icon(
      onPressed: () => _showSnack('$label: ${_selected?.nombre}'),
      icon: Icon(icon, size: 14, color: color),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withOpacity(0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: AppTheme.bodySmall(t),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}