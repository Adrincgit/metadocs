import 'package:flutter/material.dart';
import 'package:nethive_neo/data/metadocs_mock_data.dart';
import 'package:nethive_neo/models/models.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:pluto_grid/pluto_grid.dart';

class BibliotecaPage extends StatefulWidget {
  const BibliotecaPage({super.key});

  @override
  State<BibliotecaPage> createState() => _BibliotecaPageState();
}

class _BibliotecaPageState extends State<BibliotecaPage> {
  PlutoGridStateManager? _stateManager;

  String _filterTipo = 'Todos';
  String _filterEstatus = 'Todos';
  String _filterOrigen = 'Todos';
  String _search = '';

  final _tipoOpciones = ['Todos', 'Contrato', 'Factura', 'Expediente Clínico',
      'Oficio', 'Acta Constitutiva', 'Informe Técnico', 'Solicitud', 'Dictamen'];
  final _estatusOpciones = ['Todos', 'revisado', 'extraido', 'pendiente',
      'procesando', 'rechazado', 'archivado'];
  final _origenOpciones = ['Todos', 'email', 'carga_manual', 'escaner',
      'api', 'integracion'];

  late List<Documento> _filteredDocs;

  @override
  void initState() {
    super.initState();
    _applyFilters();
  }

  void _applyFilters() {
    _filteredDocs = MetaDocsMockData.documentos.where((d) {
      if (_filterTipo != 'Todos' && d.tipoDocumental != _filterTipo) {
        return false;
      }
      if (_filterEstatus != 'Todos' && d.estatus != _filterEstatus) {
        return false;
      }
      if (_filterOrigen != 'Todos' && d.origen != _filterOrigen) return false;
      if (_search.isNotEmpty &&
          !d.nombre.toLowerCase().contains(_search.toLowerCase()) &&
          !d.id.toLowerCase().contains(_search.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
  }

  List<PlutoColumn> _buildColumns(AppThemeData t) {
    final headerStyle = AppTheme.tableHeader(t);
    final cellStyle = AppTheme.tableData(t);

    return [
      PlutoColumn(
        title: 'ID',
        field: 'id',
        type: PlutoColumnType.text(),
        width: 90,
        titleTextAlign: PlutoColumnTextAlign.left,
        titlePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        cellPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        renderer: (ctx) => Text(ctx.cell.value as String,
            style: cellStyle.copyWith(color: t.primary)),
      ),
      PlutoColumn(
        title: 'Nombre',
        field: 'nombre',
        type: PlutoColumnType.text(),
        width: 280,
        titlePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        cellPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        renderer: (ctx) => Text(ctx.cell.value as String,
            style: cellStyle, overflow: TextOverflow.ellipsis),
      ),
      PlutoColumn(
        title: 'Tipo',
        field: 'tipo',
        type: PlutoColumnType.text(),
        width: 140,
        titlePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        cellPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        renderer: (ctx) => Text(ctx.cell.value as String, style: cellStyle),
      ),
      PlutoColumn(
        title: 'Origen',
        field: 'origen',
        type: PlutoColumnType.text(),
        width: 110,
        titlePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        cellPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        renderer: (ctx) => Text(ctx.cell.value as String, style: cellStyle),
      ),
      PlutoColumn(
        title: 'Fecha',
        field: 'fecha',
        type: PlutoColumnType.text(),
        width: 110,
        titlePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        cellPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        renderer: (ctx) => Text(ctx.cell.value as String, style: cellStyle),
      ),
      PlutoColumn(
        title: 'Estatus',
        field: 'estatus',
        type: PlutoColumnType.text(),
        width: 110,
        titlePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        cellPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        renderer: (ctx) => _statusBadge(ctx.cell.value as String, t),
      ),
      PlutoColumn(
        title: 'Confianza IA',
        field: 'confianza',
        type: PlutoColumnType.text(),
        width: 120,
        titlePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        cellPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        renderer: (ctx) {
          final val = ctx.cell.value as double;
          if (val == 0.0) return Text('—', style: cellStyle);
          final pct = val * 100;
          final color = pct >= 90
              ? t.success
              : pct >= 70
                  ? t.warning
                  : t.error;
          return Row(children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: val,
                  backgroundColor: t.border,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 5,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text('${pct.toStringAsFixed(0)} %',
                style: cellStyle.copyWith(color: color, fontSize: 11)),
          ]);
        },
      ),
      PlutoColumn(
        title: 'Páginas',
        field: 'paginas',
        type: PlutoColumnType.number(),
        width: 80,
        titlePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        cellPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        renderer: (ctx) => Text(
            '${ctx.cell.value}', style: cellStyle,
            textAlign: TextAlign.center),
      ),
      PlutoColumn(
        title: 'Acciones',
        field: 'acciones',
        type: PlutoColumnType.text(),
        enableSorting: false,
        enableFilterMenuItem: false,
        width: 130,
        titlePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        cellPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        renderer: (ctx) => Row(children: [
          _actionBtn(Icons.visibility_outlined, t.info, () =>
              _showSnack('Ver metadatos del documento')),
          _actionBtn(Icons.psychology_outlined, t.indigo, () =>
              _showSnack('Analizando con IA…')),
          _actionBtn(Icons.archive_outlined, t.neutral, () =>
              _showSnack('Documento archivado')),
        ]),
      ),
    ];
  }

  List<PlutoRow> _buildRows(List<Documento> docs, AppThemeData t) {
    return docs.map((d) {
      final fecha =
          '${d.fechaIngesta.day.toString().padLeft(2, '0')}/${d.fechaIngesta.month.toString().padLeft(2, '0')}/${d.fechaIngesta.year}';
      return PlutoRow(cells: {
        'id': PlutoCell(value: d.id),
        'nombre': PlutoCell(value: d.nombre),
        'tipo': PlutoCell(value: d.tipoDocumental),
        'origen': PlutoCell(value: d.origen),
        'fecha': PlutoCell(value: fecha),
        'estatus': PlutoCell(value: d.estatus),
        'confianza': PlutoCell(value: d.confianzaIA),
        'paginas': PlutoCell(value: d.paginas),
        'acciones': PlutoCell(value: ''),
      });
    }).toList();
  }

  Widget _actionBtn(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(5),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppTheme.of(context);
    final rows = _buildRows(_filteredDocs, t);

    return ColoredBox(
      color: t.background,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Biblioteca de Documentos', style: AppTheme.h1(t)),
                  const SizedBox(height: 4),
                  Text('${MetaDocsMockData.documentos.length} documentos · ${_filteredDocs.length} visibles',
                      style: AppTheme.bodySmall(t)),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: () => _showSnack('Subir nuevo documento…'),
              icon: const Icon(Icons.upload_file_outlined, size: 16),
              label: const Text('Subir Documento'),
              style: FilledButton.styleFrom(
                backgroundColor: t.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ]),
          const SizedBox(height: 20),

          // Filters
          Wrap(spacing: 12, runSpacing: 10, children: [
            SizedBox(
              width: 220,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre o ID…',
                  prefixIcon: Icon(Icons.search, size: 18, color: t.textDisabled),
                  hintStyle: AppTheme.bodySmall(t),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: t.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: t.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: t.primary),
                  ),
                  filled: true,
                  fillColor: t.surface,
                ),
                style: AppTheme.body(t),
                onChanged: (v) =>
                    setState(() { _search = v; _applyFilters(); }),
              ),
            ),
            _dropdown('Tipo', _filterTipo, _tipoOpciones, t, (v) =>
                setState(() { _filterTipo = v!; _applyFilters(); })),
            _dropdown('Estatus', _filterEstatus, _estatusOpciones, t, (v) =>
                setState(() { _filterEstatus = v!; _applyFilters(); })),
            _dropdown('Origen', _filterOrigen, _origenOpciones, t, (v) =>
                setState(() { _filterOrigen = v!; _applyFilters(); })),
            if (_filterTipo != 'Todos' ||
                _filterEstatus != 'Todos' ||
                _filterOrigen != 'Todos' ||
                _search.isNotEmpty)
              TextButton.icon(
                onPressed: () => setState(() {
                  _filterTipo = 'Todos';
                  _filterEstatus = 'Todos';
                  _filterOrigen = 'Todos';
                  _search = '';
                  _applyFilters();
                }),
                icon: const Icon(Icons.clear, size: 14),
                label: const Text('Limpiar'),
              ),
          ]),
          const SizedBox(height: 16),

          // Grid
          Expanded(
            child: Container(
              decoration: AppTheme.tableDecoration(t),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: PlutoGrid(
                  columns: _buildColumns(t),
                  rows: rows,
                  onLoaded: (e) {
                    _stateManager = e.stateManager;
                  },
                  configuration: _gridConfig(t),
                  createFooter: (sm) {
                    sm.setPageSize(20, notify: false);
                    return PlutoPagination(sm);
                  },
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _dropdown(String label, String value, List<String> items,
      AppThemeData t, void Function(String?) onChanged) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: t.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(label, style: AppTheme.bodySmall(t)),
          dropdownColor: t.surface,
          style: AppTheme.body(t),
          icon: Icon(Icons.expand_more, size: 16, color: t.textDisabled),
          onChanged: onChanged,
          items: items
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e, style: AppTheme.body(t)),
                  ))
              .toList(),
        ),
      ),
    );
  }

  PlutoGridConfiguration _gridConfig(AppThemeData t) =>
      PlutoGridConfiguration(
        style: PlutoGridStyleConfig(
          gridBackgroundColor: t.surface,
          rowColor: t.surface,
          oddRowColor: t.isDark
              ? const Color(0xFF0D1628)
              : const Color(0xFFF8FAFC),
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
          rowHeight: 46,
        ),
        columnSize: const PlutoGridColumnSizeConfig(
          autoSizeMode: PlutoAutoSizeMode.none,
        ),
      );

  Widget _statusBadge(String estatus, AppThemeData t) {
    late Color color;
    switch (estatus) {
      case 'revisado':
        color = t.success;
        break;
      case 'extraido':
        color = t.info;
        break;
      case 'pendiente':
        color = t.warning;
        break;
      case 'procesando':
        color = t.indigo;
        break;
      case 'rechazado':
        color = t.error;
        break;
      case 'archivado':
        color = t.neutral;
        break;
      default:
        color = t.neutral;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        estatus.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

