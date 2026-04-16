import 'package:flutter/material.dart';
import 'package:metadocs/theme/theme.dart';

class ConfiguracionPage extends StatefulWidget {
  const ConfiguracionPage({super.key});

  @override
  State<ConfiguracionPage> createState() => _ConfiguracionPageState();
}

class _ConfiguracionPageState extends State<ConfiguracionPage> {
  // Section 1: Workspace
  final _empresaCtrl = TextEditingController(text: 'Distribuidora Nexo S.A. de C.V.');
  final _nitCtrl = TextEditingController(text: 'NDX-8301-MX');

  // Section 2: OCR/IA
  String _motorOCR = 'Gemini Vision Pro';
  double _umbralConfianza = 0.75;
  String _idioma = 'Español';

  // Section 3: Retención
  int _diasRetencion = 365;
  bool _autoArchivado = true;

  // Section 4: Formatos
  bool _pdf = true, _xml = true, _docx = true, _jpg = true;

  // Section 5: Indexado
  bool _autoIndice = true;
  String _idiomaIndice = 'Español';

  // Section 6: Notificaciones
  bool _emailNotif = true;
  final _destinatarioCtrl = TextEditingController(text: 'alertas@nexo.mx');
  double _umbralAlertas = 0.60;

  void _showSnack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));

  @override
  void dispose() {
    _empresaCtrl.dispose();
    _nitCtrl.dispose();
    _destinatarioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppTheme.of(context);
    return ColoredBox(
      color: t.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Configuración', style: AppTheme.h1(t)),
                  const SizedBox(height: 4),
                  Text('Parámetros del sistema de gestión documental',
                      style: AppTheme.bodySmall(t)),
                ],
              )),
              FilledButton.icon(
                onPressed: () => _showSnack('Cambios guardados correctamente'),
                icon: const Icon(Icons.save_outlined, size: 16),
                label: const Text('Guardar cambios'),
                style: FilledButton.styleFrom(
                  backgroundColor: t.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ]),
            const SizedBox(height: 24),

            // 2-column grid
            _twoColGrid([
              // Section 1: Workspace
              _card(
                icon: Icons.business_outlined,
                title: 'Espacio de trabajo',
                iconColor: t.primary,
                t: t,
                children: [
                  _field('Nombre de empresa', _empresaCtrl, t),
                  const SizedBox(height: 12),
                  _field('NIT / Identificador', _nitCtrl, t),
                ],
              ),

              // Section 2: OCR/IA
              _card(
                icon: Icons.psychology_outlined,
                title: 'Motor OCR / IA',
                iconColor: t.indigo,
                t: t,
                children: [
                  _dropdownRow(
                    label: 'Motor OCR',
                    value: _motorOCR,
                    items: ['Gemini Vision Pro', 'Tesseract OCR', 'Azure Form Recognizer'],
                    onChanged: (v) => setState(() => _motorOCR = v!),
                    t: t,
                  ),
                  const SizedBox(height: 14),
                  _sliderRow(
                    label: 'Umbral de confianza',
                    value: _umbralConfianza,
                    display: '${(_umbralConfianza * 100).toStringAsFixed(0)} %',
                    color: t.info,
                    onChanged: (v) => setState(() => _umbralConfianza = v),
                    t: t,
                  ),
                  const SizedBox(height: 8),
                  _dropdownRow(
                    label: 'Idioma principal',
                    value: _idioma,
                    items: ['Español', 'Inglés', 'Portugués', 'Francés'],
                    onChanged: (v) => setState(() => _idioma = v!),
                    t: t,
                  ),
                ],
              ),

              // Section 3: Retención
              _card(
                icon: Icons.history_outlined,
                title: 'Retención y archivo',
                iconColor: t.warning,
                t: t,
                children: [
                  Row(children: [
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Días de retención', style: AppTheme.bodySmall(t)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<int>(
                          value: _diasRetencion,
                          dropdownColor: t.surface,
                          style: AppTheme.body(t),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: t.border)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: t.border)),
                          ),
                          items: [90, 180, 365, 730, 1825]
                              .map((v) => DropdownMenuItem(
                                    value: v,
                                    child: Text('$v días'),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(() => _diasRetencion = v!),
                        ),
                      ],
                    )),
                  ]),
                  const SizedBox(height: 14),
                  _switchRow('Auto-archivado al vencer', _autoArchivado,
                      (v) => setState(() => _autoArchivado = v), t),
                ],
              ),

              // Section 4: Formatos
              _card(
                icon: Icons.file_present_outlined,
                title: 'Formatos aceptados',
                iconColor: t.success,
                t: t,
                children: [
                  _switchRow('PDF', _pdf, (v) => setState(() => _pdf = v), t),
                  _switchRow('XML / CFDI', _xml, (v) => setState(() => _xml = v), t),
                  _switchRow('Word (DOCX)', _docx, (v) => setState(() => _docx = v), t),
                  _switchRow('Imagen (JPG / PNG)', _jpg,
                      (v) => setState(() => _jpg = v), t),
                ],
              ),

              // Section 5: Indexado
              _card(
                icon: Icons.search_outlined,
                title: 'Motor de indexado',
                iconColor: t.info,
                t: t,
                children: [
                  _switchRow('Indexado automático', _autoIndice,
                      (v) => setState(() => _autoIndice = v), t),
                  const SizedBox(height: 12),
                  _dropdownRow(
                    label: 'Idioma de índice',
                    value: _idiomaIndice,
                    items: ['Español', 'Inglés', 'Multilenguaje'],
                    onChanged: (v) => setState(() => _idiomaIndice = v!),
                    t: t,
                  ),
                ],
              ),

              // Section 6: Notificaciones
              _card(
                icon: Icons.notifications_outlined,
                title: 'Notificaciones',
                iconColor: t.error,
                t: t,
                children: [
                  _switchRow('Alertas por email', _emailNotif,
                      (v) => setState(() => _emailNotif = v), t),
                  const SizedBox(height: 12),
                  _field('Destinatario de alertas', _destinatarioCtrl, t),
                  const SizedBox(height: 14),
                  _sliderRow(
                    label: 'Umbral de alertas (confianza)',
                    value: _umbralAlertas,
                    display: '${(_umbralAlertas * 100).toStringAsFixed(0)} %',
                    color: t.error,
                    onChanged: (v) => setState(() => _umbralAlertas = v),
                    t: t,
                  ),
                ],
              ),
            ]),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _twoColGrid(List<Widget> children) {
    return LayoutBuilder(builder: (_, c) {
      final cols = c.maxWidth > 700 ? 2 : 1;
      if (cols == 1) {
        return Column(
          children: children
              .map((w) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: w,
                  ))
              .toList(),
        );
      }
      final rows = <Widget>[];
      for (var i = 0; i < children.length; i += 2) {
        final right = i + 1 < children.length ? children[i + 1] : const SizedBox.shrink();
        rows.add(Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: children[i]),
              const SizedBox(width: 16),
              Expanded(child: right),
            ],
          ),
        ));
      }
      return Column(children: rows);
    });
  }

  Widget _card({
    required IconData icon,
    required String title,
    required Color iconColor,
    required AppThemeData t,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration(t),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 10),
            Text(title, style: AppTheme.h3(t)),
          ]),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, AppThemeData t) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppTheme.bodySmall(t)),
      const SizedBox(height: 6),
      TextField(
        controller: ctrl,
        style: AppTheme.body(t),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: t.border)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: t.border)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: t.primary)),
          fillColor: t.surface,
          filled: true,
        ),
      ),
    ]);
  }

  Widget _dropdownRow({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
    required AppThemeData t,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppTheme.bodySmall(t)),
      const SizedBox(height: 6),
      DropdownButtonFormField<String>(
        value: value,
        dropdownColor: t.surface,
        style: AppTheme.body(t),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: t.border)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: t.border)),
        ),
        items: items
            .map((v) => DropdownMenuItem(value: v, child: Text(v)))
            .toList(),
        onChanged: onChanged,
      ),
    ]);
  }

  Widget _sliderRow({
    required String label,
    required double value,
    required String display,
    required Color color,
    required void Function(double) onChanged,
    required AppThemeData t,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Text(label, style: AppTheme.bodySmall(t))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(display,
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.w700)),
        ),
      ]),
      Slider(
        value: value,
        onChanged: onChanged,
        activeColor: color,
        inactiveColor: t.border,
        min: 0.3,
        max: 1.0,
      ),
    ]);
  }

  Widget _switchRow(String label, bool value, void Function(bool) onChanged,
      AppThemeData t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        Expanded(child: Text(label, style: AppTheme.body(t))),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: t.primary,
        ),
      ]),
    );
  }
}