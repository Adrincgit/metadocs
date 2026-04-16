import 'package:flutter/material.dart';
import 'package:metadocs/data/metadocs_mock_data.dart';
import 'package:metadocs/helpers/constants.dart';
import 'package:metadocs/models/models.dart';
import 'package:metadocs/theme/theme.dart';

class IntegracionesPage extends StatefulWidget {
  const IntegracionesPage({super.key});

  @override
  State<IntegracionesPage> createState() => _IntegracionesPageState();
}

class _IntegracionesPageState extends State<IntegracionesPage> {
  late Integracion _selected;

  // Simulated per-module form state
  final Map<String, _ModuleState> _states = {};

  @override
  void initState() {
    super.initState();
    final ints = MetaDocsMockData.integraciones;
    _selected = ints.first;
    for (final i in ints) {
      _states[i.id] = _ModuleState.forTipo(i.tipo);
    }
  }

  @override
  void dispose() {
    for (final s in _states.values) s.dispose();
    super.dispose();
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));

  IconData _tipoIcon(String tipo) => switch (tipo) {
        'ia' => Icons.psychology_outlined,
        'ocr' => Icons.document_scanner_outlined,
        'storage' => Icons.cloud_outlined,
        'email' => Icons.email_outlined,
        'api' => Icons.api_outlined,
        'scanner' => Icons.scanner_outlined,
        _ => Icons.extension_outlined,
      };

  Color _tipoColor(String tipo, AppThemeData t) => switch (tipo) {
        'ia' => t.indigo,
        'ocr' => t.info,
        'storage' => t.success,
        'email' => t.warning,
        'api' => t.primary,
        'scanner' => t.neutral,
        _ => t.neutral,
      };

  Color _estatusColor(String estatus, AppThemeData t) => switch (estatus) {
        'activa' => t.success,
        'revision' => t.warning,
        'inactiva' => t.neutral,
        'error' => t.error,
        _ => t.neutral,
      };

  @override
  Widget build(BuildContext context) {
    final t = AppTheme.of(context);
    final ints = MetaDocsMockData.integraciones;
    final isMobile = MediaQuery.sizeOf(context).width < mobileSize;

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
                  Text('Integraciones y Conectores', style: AppTheme.h1(t)),
                  const SizedBox(height: 4),
                  Text(
                    '${ints.where((i) => i.estatus == "activa").length} activas · ${ints.length} configuradas',
                    style: AppTheme.bodySmall(t),
                  ),
                ],
              )),
              FilledButton.icon(
                onPressed: () => _snack('Nueva integración (demo)'),
                icon: const Icon(Icons.add, size: 15),
                label: const Text('Nueva integración'),
                style: FilledButton.styleFrom(
                  backgroundColor: t.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ]),
            const SizedBox(height: 20),

            // Panel dual
            Expanded(
              child: isMobile
                  ? _mobileList(ints, t)
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // LEFT: módulos
                        SizedBox(
                          width: 280,
                          child: Container(
                            decoration: AppTheme.cardDecoration(t),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Text('Módulos', style: AppTheme.h3(t)),
                                ),
                                Divider(color: t.border, height: 1),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: ints.length,
                                    itemBuilder: (_, i) {
                                      final intg = ints[i];
                                      final isSel = _selected.id == intg.id;
                                      final tColor = _tipoColor(intg.tipo, t);
                                      final eColor = _estatusColor(intg.estatus, t);
                                      return InkWell(
                                        onTap: () => setState(() => _selected = intg),
                                        child: Container(
                                          color: isSel
                                              ? t.primary.withOpacity(0.08)
                                              : Colors.transparent,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 13),
                                          child: Row(children: [
                                            Container(
                                              width: 36,
                                              height: 36,
                                              decoration: BoxDecoration(
                                                color: tColor.withOpacity(
                                                    isSel ? 0.18 : 0.10),
                                                borderRadius: BorderRadius.circular(9),
                                              ),
                                              child: Icon(_tipoIcon(intg.tipo),
                                                  color: tColor, size: 18),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(intg.nombre,
                                                    style: AppTheme.body(t).copyWith(
                                                      fontWeight: isSel
                                                          ? FontWeight.w600
                                                          : FontWeight.normal,
                                                      color: isSel
                                                          ? t.primary
                                                          : t.textPrimary,
                                                    ),
                                                    overflow: TextOverflow.ellipsis),
                                                Row(children: [
                                                  Text(intg.version,
                                                      style: AppTheme.caption(t)),
                                                  const SizedBox(width: 6),
                                                  Container(
                                                    width: 6,
                                                    height: 6,
                                                    decoration: BoxDecoration(
                                                      color: eColor,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                ]),
                                              ],
                                            )),
                                            if (isSel)
                                              Icon(Icons.chevron_right,
                                                  size: 16, color: t.primary),
                                          ]),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // RIGHT: configuración
                        Expanded(child: _configPanel(_selected, t)),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mobileList(List<Integracion> ints, AppThemeData t) {
    return ListView.separated(
      itemCount: ints.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final intg = ints[i];
        final tColor = _tipoColor(intg.tipo, t);
        final eColor = _estatusColor(intg.estatus, t);
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: t.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: t.border),
          ),
          child: Row(children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: tColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_tipoIcon(intg.tipo), color: tColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(intg.nombre, style: AppTheme.body(t).copyWith(fontWeight: FontWeight.w600)),
                Text('${intg.tipo} · ${intg.version}', style: AppTheme.caption(t)),
              ],
            )),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: eColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: eColor.withOpacity(0.35)),
              ),
              child: Text(intg.estatus.toUpperCase(),
                  style: TextStyle(color: eColor, fontSize: 9, fontWeight: FontWeight.w700)),
            ),
          ]),
        );
      },
    );
  }

  // -- CONFIG PANEL ------------------------------------------
  Widget _configPanel(Integracion intg, AppThemeData t) {
    final state = _states[intg.id]!;
    final tColor = _tipoColor(intg.tipo, t);
    final eColor = _estatusColor(intg.estatus, t);
    final syncStr = intg.ultimaSincronizacion == null
        ? '—'
        : '${intg.ultimaSincronizacion!.day.toString().padLeft(2, "0")}/${intg.ultimaSincronizacion!.month.toString().padLeft(2, "0")}/${intg.ultimaSincronizacion!.year} ${intg.ultimaSincronizacion!.hour.toString().padLeft(2, "0")}:${intg.ultimaSincronizacion!.minute.toString().padLeft(2, "0")}';

    return Container(
      decoration: AppTheme.cardDecoration(t),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Módulo header
            Row(children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: tColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(_tipoIcon(intg.tipo), color: tColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(intg.nombre, style: AppTheme.h2(t)),
                  Text(intg.descripcion,
                      style: AppTheme.body(t).copyWith(color: t.textSecondary)),
                ],
              )),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: eColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: eColor.withOpacity(0.35)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: eColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(intg.estatus.toUpperCase(),
                      style: TextStyle(
                          color: eColor, fontSize: 10, fontWeight: FontWeight.w700)),
                ]),
              ),
            ]),
            const SizedBox(height: 8),

            // Metadata row
            Row(children: [
              _metaItem('Tipo', intg.tipo, t),
              const SizedBox(width: 32),
              _metaItem('Versión', intg.version, t),
              const SizedBox(width: 32),
              _metaItem('Última sync', syncStr, t),
            ]),
            const SizedBox(height: 24),
            Divider(color: t.border),
            const SizedBox(height: 20),

            // Dynamic config based on tipo
            ..._buildConfig(intg, state, t),

            const SizedBox(height: 28),
            Divider(color: t.border),
            const SizedBox(height: 16),

            // Action row
            Row(children: [
              OutlinedButton.icon(
                onPressed: () => _snack('Módulo ${intg.estatus == "activa" ? "pausado" : "activado"}: ${intg.nombre}'),
                icon: Icon(
                    intg.estatus == 'activa'
                        ? Icons.pause_outlined
                        : Icons.play_arrow_outlined,
                    size: 15,
                    color: intg.estatus == 'activa' ? t.warning : t.success),
                label: Text(
                    intg.estatus == 'activa' ? 'Pausar módulo' : 'Activar módulo',
                    style: AppTheme.button(t).copyWith(
                        color: intg.estatus == 'activa' ? t.warning : t.success)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                      color: (intg.estatus == 'activa' ? t.warning : t.success)
                          .withOpacity(0.4)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: () => _snack('Sincronizando: ${intg.nombre}…'),
                icon: Icon(Icons.sync, size: 15, color: t.info),
                label: Text('Sincronizar',
                    style: AppTheme.button(t).copyWith(color: t.info)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: t.info.withOpacity(0.4)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => _snack('Configuración guardada: ${intg.nombre}'),
                icon: const Icon(Icons.save_outlined, size: 15),
                label: const Text('Guardar cambios'),
                style: FilledButton.styleFrom(
                  backgroundColor: t.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildConfig(Integracion intg, _ModuleState s, AppThemeData t) {
    return switch (intg.tipo) {
      'ia' => _iaConfig(s, t),
      'ocr' => _ocrConfig(s, t),
      'storage' => _storageConfig(s, t),
      'email' => _emailConfig(s, t),
      'api' => _apiConfig(s, t),
      'scanner' => _scannerConfig(s, t),
      _ => [Text('Sin configuración disponible.', style: AppTheme.body(t))],
    };
  }

  // -- CONFIG SECTIONS ---------------------------------------

  List<Widget> _iaConfig(_ModuleState s, AppThemeData t) => [
        _sectionTitle('Motor IA', Icons.psychology_outlined, t),
        const SizedBox(height: 14),
        _providerSelector(s, t),
        const SizedBox(height: 16),
        _twoCol(
          _field('Nombre del módulo', s.moduleName, t),
          _dropdown('Modelo', s.model,
              ['gemini-2.5-flash', 'gemini-2.0-pro', 'claude-3-5-sonnet', 'gpt-4o', 'text-embedding-004'],
              (v) => setState(() => s.model = v!), t),
        ),
        const SizedBox(height: 16),
        _apiKeyField(s, t),
        const SizedBox(height: 20),
        _sectionTitle('Reglas del módulo', Icons.rule_outlined, t),
        const SizedBox(height: 12),
        _twoCol(
          _toggle('Indexar automáticamente', s.autoIndex, (v) => setState(() => s.autoIndex = v), t),
          _toggle('Modo avanzado (API)', s.advancedMode, (v) => setState(() => s.advancedMode = v), t),
        ),
        const SizedBox(height: 12),
        _labeledSlider('Umbral de similitud', s.threshold, 0.5, 1.0,
            (v) => setState(() => s.threshold = v), t),
        const SizedBox(height: 16),
        _sectionTitle('Prompt del sistema', Icons.chat_outlined, t),
        const SizedBox(height: 10),
        _textArea('Instrucciones del sistema para este módulo…', s.promptCtrl, t),
      ];

  List<Widget> _ocrConfig(_ModuleState s, AppThemeData t) => [
        _sectionTitle('Motor OCR', Icons.document_scanner_outlined, t),
        const SizedBox(height: 14),
        Text('PROVEEDOR', style: AppTheme.label(t).copyWith(fontSize: 10, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Row(children: [
          for (final p in ['Azure Cognitive', 'Google Vision', 'Tesseract'])
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _providerBtn(p, s.provider == p, () => setState(() => s.provider = p), t),
            ),
        ]),
        const SizedBox(height: 16),
        _twoCol(
          _field('Versión API', s.moduleName, t),
          _dropdown('Idioma principal', s.model,
              ['es', 'en', 'es+en', 'pt', 'fr'], (v) => setState(() => s.model = v!), t),
        ),
        const SizedBox(height: 16),
        _labeledSlider('Umbral mínimo de confianza', s.threshold, 0.5, 1.0,
            (v) => setState(() => s.threshold = v), t),
        const SizedBox(height: 20),
        _sectionTitle('Reglas del módulo', Icons.rule_outlined, t),
        const SizedBox(height: 12),
        _twoCol(
          _toggle('Procesar al ingestar', s.autoIndex, (v) => setState(() => s.autoIndex = v), t),
          _toggle('Reintentar en error', s.advancedMode, (v) => setState(() => s.advancedMode = v), t),
        ),
        const SizedBox(height: 12),
        _twoCol(
          _field('Max reintentos', TextEditingController(text: '3'), t),
          _field('Timeout (segundos)', TextEditingController(text: '30'), t),
        ),
      ];

  List<Widget> _storageConfig(_ModuleState s, AppThemeData t) => [
        _sectionTitle('Almacenamiento', Icons.cloud_outlined, t),
        const SizedBox(height: 14),
        Text('PROVEEDOR', style: AppTheme.label(t).copyWith(fontSize: 10, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Row(children: [
          for (final p in ['Google Cloud', 'AWS S3', 'Azure Blob'])
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _providerBtn(p, s.provider == p, () => setState(() => s.provider = p), t),
            ),
        ]),
        const SizedBox(height: 16),
        _twoCol(
          _field('Bucket / Container', s.moduleName, t),
          _dropdown('Región', s.model,
              ['us-central1', 'us-east1', 'europe-west1', 'southamerica-east1'],
              (v) => setState(() => s.model = v!), t),
        ),
        const SizedBox(height: 16),
        _field('Ruta base', TextEditingController(text: '/metadocs/documents/'), t),
        const SizedBox(height: 20),
        _sectionTitle('Reglas', Icons.rule_outlined, t),
        const SizedBox(height: 12),
        _twoCol(
          _toggle('Cifrado en reposo', s.autoIndex, (v) => setState(() => s.autoIndex = v), t),
          _toggle('Versionado de archivos', s.advancedMode, (v) => setState(() => s.advancedMode = v), t),
        ),
        const SizedBox(height: 12),
        _field('Retención (días)', TextEditingController(text: '365'), t),
      ];

  List<Widget> _emailConfig(_ModuleState s, AppThemeData t) => [
        _sectionTitle('Configuración IMAP', Icons.email_outlined, t),
        const SizedBox(height: 14),
        _twoCol(
          _field('Servidor IMAP', s.moduleName, t),
          _field('Puerto', TextEditingController(text: '993'), t),
        ),
        const SizedBox(height: 16),
        _twoCol(
          _field('Usuario / Email', s.promptCtrl, t),
          _apiKeyField(s, t, label: 'Contraseña'),
        ),
        const SizedBox(height: 16),
        _field('Carpeta', TextEditingController(text: 'INBOX'), t),
        const SizedBox(height: 20),
        _sectionTitle('Reglas', Icons.rule_outlined, t),
        const SizedBox(height: 12),
        _twoCol(
          _toggle('Ingesta activa', s.autoIndex, (v) => setState(() => s.autoIndex = v), t),
          _toggle('Eliminar tras procesar', s.advancedMode, (v) => setState(() => s.advancedMode = v), t),
        ),
        const SizedBox(height: 12),
        _dropdown('Frecuencia de revisión', s.model,
            ['Cada 5 minutos', 'Cada 15 minutos', 'Cada 30 minutos', 'Cada hora'],
            (v) => setState(() => s.model = v!), t),
      ];

  List<Widget> _apiConfig(_ModuleState s, AppThemeData t) => [
        _sectionTitle('REST API Endpoint', Icons.api_outlined, t),
        const SizedBox(height: 14),
        _field('URL base', s.moduleName, t),
        const SizedBox(height: 16),
        _apiKeyField(s, t, label: 'Token de autenticación'),
        const SizedBox(height: 16),
        _field('Webhook URL', TextEditingController(text: 'https://'), t),
        const SizedBox(height: 20),
        _sectionTitle('Reglas', Icons.rule_outlined, t),
        const SizedBox(height: 12),
        _twoCol(
          _toggle('Validar SSL', s.autoIndex, (v) => setState(() => s.autoIndex = v), t),
          _toggle('Notificar webhook', s.advancedMode, (v) => setState(() => s.advancedMode = v), t),
        ),
        const SizedBox(height: 12),
        _twoCol(
          _field('Rate limit (req/min)', TextEditingController(text: '60'), t),
          _field('Timeout (ms)', TextEditingController(text: '5000'), t),
        ),
      ];

  List<Widget> _scannerConfig(_ModuleState s, AppThemeData t) => [
        _sectionTitle('Conector de Escáner', Icons.scanner_outlined, t),
        const SizedBox(height: 14),
        _twoCol(
          _dropdown('Driver', s.provider,
              ['TWAIN', 'WIA', 'eSCL', 'ICA'],
              (v) => setState(() => s.provider = v!), t),
          _dropdown('Formato de salida', s.model,
              ['PDF', 'TIFF', 'JPEG', 'PNG'],
              (v) => setState(() => s.model = v!), t),
        ),
        const SizedBox(height: 16),
        _twoCol(
          _dropdown('Resolución DPI', '300',
              ['150', '200', '300', '600'],
              (v) => setState(() => s.provider = v!), t),
          _dropdown('Color', 'Escala de grises',
              ['Color', 'Escala de grises', 'Blanco y Negro'],
              (v) => setState(() => s.model = v!), t),
        ),
        const SizedBox(height: 20),
        _sectionTitle('Reglas', Icons.rule_outlined, t),
        const SizedBox(height: 12),
        _twoCol(
          _toggle('Auto-procesar tras escanear', s.autoIndex, (v) => setState(() => s.autoIndex = v), t),
          _toggle('Dúplex automático', s.advancedMode, (v) => setState(() => s.advancedMode = v), t),
        ),
      ];

  // -- BUILDER HELPERS ---------------------------------------

  Widget _sectionTitle(String title, IconData icon, AppThemeData t) {
    return Row(children: [
      Icon(icon, size: 16, color: t.primary),
      const SizedBox(width: 7),
      Text(title, style: AppTheme.h3(t)),
    ]);
  }

  Widget _metaItem(String label, String value, AppThemeData t) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppTheme.caption(t)),
      const SizedBox(height: 2),
      Text(value, style: AppTheme.body(t).copyWith(fontWeight: FontWeight.w500)),
    ]);
  }

  Widget _twoCol(Widget a, Widget b) {
    return Row(children: [
      Expanded(child: a),
      const SizedBox(width: 14),
      Expanded(child: b),
    ]);
  }

  Widget _field(String label, TextEditingController ctrl, AppThemeData t) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppTheme.label(t).copyWith(fontSize: 11)),
      const SizedBox(height: 5),
      TextField(
        controller: ctrl,
        style: AppTheme.body(t).copyWith(fontSize: 13),
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
          filled: true,
          fillColor: t.background,
        ),
      ),
    ]);
  }

  Widget _apiKeyField(_ModuleState s, AppThemeData t, {String label = 'Clave API'}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppTheme.label(t).copyWith(fontSize: 11)),
      const SizedBox(height: 5),
      TextField(
        controller: s.apiKeyCtrl,
        obscureText: !s.showKey,
        style: AppTheme.body(t).copyWith(fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Dejar vacío para mantener la actual',
          hintStyle: AppTheme.body(t).copyWith(color: t.textDisabled, fontSize: 12),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          suffixIcon: IconButton(
            icon: Icon(s.showKey ? Icons.visibility_off : Icons.visibility,
                size: 16, color: t.textDisabled),
            onPressed: () => setState(() => s.showKey = !s.showKey),
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: t.border)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: t.border)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: t.primary)),
          filled: true,
          fillColor: t.background,
        ),
      ),
      const SizedBox(height: 4),
      Row(children: [
        Icon(Icons.check_circle_outline, size: 12, color: t.success),
        const SizedBox(width: 4),
        Text('Clave registrada (****Vh0)', style: AppTheme.caption(t).copyWith(color: t.success)),
      ]),
    ]);
  }

  Widget _dropdown(String label, String value, List<String> items,
      void Function(String?) onChanged, AppThemeData t) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppTheme.label(t).copyWith(fontSize: 11)),
      const SizedBox(height: 5),
      Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: t.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: t.border),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: items.contains(value) ? value : items.first,
            dropdownColor: t.surface,
            style: AppTheme.body(t).copyWith(fontSize: 13),
            icon: Icon(Icons.expand_more, size: 16, color: t.textDisabled),
            isExpanded: true,
            onChanged: onChanged,
            items: items.map((e) => DropdownMenuItem(
              value: e,
              child: Text(e, style: AppTheme.body(t).copyWith(fontSize: 13)),
            )).toList(),
          ),
        ),
      ),
    ]);
  }

  Widget _toggle(String label, bool value, void Function(bool) onChanged, AppThemeData t) {
    return Row(children: [
      Switch(
        value: value,
        onChanged: onChanged,
        activeColor: t.primary,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      const SizedBox(width: 8),
      Expanded(child: Text(label, style: AppTheme.bodySmall(t))),
    ]);
  }

  Widget _labeledSlider(String label, double value, double min, double max,
      void Function(double) onChanged, AppThemeData t) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(label, style: AppTheme.label(t).copyWith(fontSize: 11)),
        const Spacer(),
        Text('${(value * 100).toStringAsFixed(0)} %',
            style: AppTheme.body(t).copyWith(color: t.primary, fontWeight: FontWeight.w600, fontSize: 12)),
      ]),
      Slider(
        value: value,
        min: min,
        max: max,
        onChanged: onChanged,
        activeColor: t.primary,
        inactiveColor: t.border,
      ),
    ]);
  }

  Widget _textArea(String hint, TextEditingController ctrl, AppThemeData t) {
    return TextField(
      controller: ctrl,
      maxLines: 4,
      style: AppTheme.body(t).copyWith(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTheme.body(t).copyWith(color: t.textDisabled, fontSize: 12),
        contentPadding: const EdgeInsets.all(14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: t.border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: t.border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: t.primary)),
        filled: true,
        fillColor: t.background,
      ),
    );
  }

  Widget _providerSelector(_ModuleState s, AppThemeData t) {
    final providers = ['Anthropic', 'Google Gemini', 'Azure OpenAI'];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('PROVEEDOR', style: AppTheme.label(t).copyWith(fontSize: 10, letterSpacing: 0.5)),
      const SizedBox(height: 8),
      Row(children: providers.map((p) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: _providerBtn(p, s.provider == p, () => setState(() => s.provider = p), t),
      )).toList()),
    ]);
  }

  Widget _providerBtn(String label, bool selected, VoidCallback onTap, AppThemeData t) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? t.primary.withOpacity(0.10) : t.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: selected ? t.primary : t.border, width: selected ? 1.5 : 1),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(
            label == 'Anthropic'
                ? Icons.auto_awesome_outlined
                : label == 'Google Gemini'
                    ? Icons.star_outlined
                    : Icons.cloud_queue_outlined,
            size: 13,
            color: selected ? t.primary : t.textSecondary,
          ),
          const SizedBox(width: 5),
          Text(label,
              style: AppTheme.bodySmall(t).copyWith(
                  color: selected ? t.primary : t.textSecondary,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 12)),
        ]),
      ),
    );
  }
}

// -- STATE PER MODULE ------------------------------------------
class _ModuleState {
  String provider;
  String model;
  bool autoIndex;
  bool advancedMode;
  bool showKey;
  double threshold;
  final TextEditingController moduleName;
  final TextEditingController apiKeyCtrl;
  final TextEditingController promptCtrl;

  _ModuleState({
    required this.provider,
    required this.model,
    this.autoIndex = true,
    this.advancedMode = false,
    this.showKey = false,
    this.threshold = 0.75,
    required String moduleNameVal,
    String apiKeyVal = '',
    String promptVal = '',
  })  : moduleName = TextEditingController(text: moduleNameVal),
        apiKeyCtrl = TextEditingController(text: apiKeyVal),
        promptCtrl = TextEditingController(text: promptVal);

  factory _ModuleState.forTipo(String tipo) => switch (tipo) {
        'ia' => _ModuleState(
            provider: 'Google Gemini',
            model: 'gemini-2.5-flash',
            moduleNameVal: 'Búsqueda semántica',
            promptVal:
                'Eres un motor de indexación semántica para documentos empresariales. Genera embeddings representativos del contenido documental.',
          ),
        'ocr' => _ModuleState(
            provider: 'Azure Cognitive',
            model: 'es+en',
            moduleNameVal: 'Análisis óptico v4.0',
            threshold: 0.80,
          ),
        'storage' => _ModuleState(
            provider: 'Google Cloud',
            model: 'us-central1',
            moduleNameVal: 'metadocs-storage-prod',
          ),
        'email' => _ModuleState(
            provider: 'IMAP',
            model: 'Cada 15 minutos',
            moduleNameVal: 'imap.nordika.mx',
          ),
        'api' => _ModuleState(
            provider: 'Bearer Token',
            model: 'REST v2',
            moduleNameVal: 'https://api.nordika.mx/v2/docs',
          ),
        'scanner' => _ModuleState(
            provider: 'TWAIN',
            model: 'PDF',
            moduleNameVal: 'Escáner Fujitsu fi-800R',
            autoIndex: false,
          ),
        _ => _ModuleState(
            provider: 'Genérico',
            model: 'default',
            moduleNameVal: 'Módulo',
          ),
      };

  void dispose() {
    moduleName.dispose();
    apiKeyCtrl.dispose();
    promptCtrl.dispose();
  }
}