// ============================================================================
// MODELOS DE DATOS — MetaDocs · AI Document Intelligence Demo
// Todos los datos viven en memoria (sin backend, sin persistencia)
// ============================================================================
library;

// ─── Documento ───────────────────────────────────────────────────────────────
/// Entidad central del sistema.
/// estatus: 'pendiente' | 'procesando' | 'extraido' | 'revisado' | 'rechazado' | 'archivado'
/// origen:  'carga_manual' | 'email' | 'api' | 'escaner' | 'integracion'
class Documento {
  const Documento({
    required this.id,
    required this.nombre,
    required this.tipoDocumental,
    required this.origen,
    required this.fechaIngesta,
    this.fechaDocumento,
    required this.estatus,
    required this.confianzaIA,
    required this.etiquetas,
    required this.tamanoKb,
    required this.paginas,
    required this.metadatos,
  });

  final String id;
  final String nombre;
  final String tipoDocumental;
  final String origen;
  final DateTime fechaIngesta;
  final DateTime? fechaDocumento;
  final String estatus;
  final double confianzaIA;
  final List<String> etiquetas;
  final int tamanoKb;
  final int paginas;
  final Map<String, String> metadatos;
}

// ─── CampoMetadato ───────────────────────────────────────────────────────────
class CampoMetadato {
  const CampoMetadato({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.obligatorio,
    this.valorExtraido,
    required this.confianza,
  });

  final String id;
  final String nombre;

  /// 'texto' | 'fecha' | 'monto' | 'rfc' | 'entidad'
  final String tipo;
  final bool obligatorio;
  final String? valorExtraido;
  final double confianza;
}

// ─── ResultadoProcesamiento ───────────────────────────────────────────────────
class ResultadoProcesamiento {
  const ResultadoProcesamiento({
    required this.id,
    required this.documentoId,
    required this.estatus,
    required this.motorOCR,
    required this.tiempoMs,
    required this.errores,
    required this.camposExtraidos,
    required this.fecha,
  });

  final String id;
  final String documentoId;

  /// 'exitoso' | 'error' | 'parcial' | 'reintentando'
  final String estatus;

  /// 'google_vision' | 'tesseract' | 'azure_read' | 'aws_textract'
  final String motorOCR;
  final int tiempoMs;
  final List<String> errores;
  final int camposExtraidos;
  final DateTime fecha;
}

// ─── Integracion ─────────────────────────────────────────────────────────────
class Integracion {
  const Integracion({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.estatus,
    required this.version,
    this.ultimaSincronizacion,
    required this.descripcion,
  });

  final String id;
  final String nombre;

  /// 'ocr' | 'ia' | 'storage' | 'email' | 'api'
  final String tipo;

  /// 'activa' | 'revision' | 'inactiva' | 'error'
  final String estatus;
  final String version;
  final DateTime? ultimaSincronizacion;
  final String descripcion;
}

// ─── EventoAuditoria ─────────────────────────────────────────────────────────
class EventoAuditoria {
  const EventoAuditoria({
    required this.id,
    required this.timestamp,
    required this.usuario,
    required this.modulo,
    required this.accion,
    this.documentoId,
    required this.descripcion,
    required this.resultado,
    this.ip,
  });

  final String id;
  final DateTime timestamp;
  final String usuario;
  final String modulo;

  /// 'subir' | 'extraer' | 'editar' | 'rechazar' | 'archivar' | 'revisar' | 'configurar' | 'login'
  final String accion;
  final String? documentoId;
  final String descripcion;

  /// 'exitoso' | 'fallido' | 'advertencia'
  final String resultado;
  final String? ip;
}

// ─── TipoDocumental (segunda vuelta) ─────────────────────────────────────────
class TipoDocumental {
  const TipoDocumental({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.campos,
  });

  final String id;
  final String nombre;
  final String descripcion;
  final List<CampoMetadato> campos;
}

// ─── EntidadDetectada (segunda vuelta) ───────────────────────────────────────
class EntidadDetectada {
  const EntidadDetectada({
    required this.id,
    required this.documentoId,
    required this.tipo,
    required this.valor,
    required this.confianzaIA,
  });

  final String id;
  final String documentoId;

  /// 'persona' | 'empresa' | 'fecha' | 'monto' | 'lugar'
  final String tipo;
  final String valor;
  final double confianzaIA;
}

// ─── UsuarioSistema (segunda vuelta) ─────────────────────────────────────────
class UsuarioSistema {
  const UsuarioSistema({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
    required this.estatus,
    required this.ultimoAcceso,
    required this.permisos,
  });

  final String id;
  final String nombre;
  final String email;

  /// 'admin' | 'analyst' | 'reviewer' | 'compliance' | 'operations'
  final String rol;

  /// 'activo' | 'inactivo' | 'bloqueado'
  final String estatus;
  final DateTime ultimoAcceso;
  final List<String> permisos;
}

// ─── Modelos auxiliares de UI ────────────────────────────────────────────────
/// Series temporales mensuales para gráficas del dashboard y reportes
class PuntoSerie {
  const PuntoSerie({required this.mes, required this.valor});
  final String mes;
  final double valor;
}

// ─── LEGACY — clase descontinuada, solo para que no explote si algo la importa
class Cliente {
  const Cliente({
    required this.id,
    required this.razonSocial,
    required this.rfc,
    required this.contactoPrincipal,
    required this.email,
    required this.telefono,
    required this.ciudad,
    required this.estado,
    required this.segmento,
    required this.estatus,
    required this.fechaAlta,
    required this.limiteCredito,
    required this.diasCredito,
    this.vendedorId,
  });

  final String id;
  final String razonSocial;
  final String rfc;
  final String contactoPrincipal;
  final String email;
  final String telefono;
  final String ciudad;
  final String estado;

  /// 'A' | 'B' | 'C' (por volumen)
  final String segmento;

  /// 'activo' | 'inactivo' | 'suspendido'
  final String estatus;
  final DateTime fechaAlta;
  final double limiteCredito;

  /// 30 | 60 | 90 días
  final int diasCredito;
  final String? vendedorId;
}

// ─── Vendedor ─────────────────────────────────────────────────────────────────
class Vendedor {
  const Vendedor({
    required this.id,
    required this.nombre,
    required this.email,
    required this.telefono,
    required this.zona,
    required this.estatus,
    required this.comisionPct,
    required this.metaMensual,
    required this.fechaIngreso,
  });

  final String id;
  final String nombre;
  final String email;
  final String telefono;
  final String zona;

  /// 'activo' | 'inactivo'
  final String estatus;

  /// Porcentaje de comisión (e.g. 3.5)
  final double comisionPct;

  /// Meta de ventas mensual en MXN
  final double metaMensual;
  final DateTime fechaIngreso;
}

// ─── Producto ─────────────────────────────────────────────────────────────────
class Producto {
  const Producto({
    required this.id,
    required this.clave,
    required this.descripcion,
    required this.categoria,
    required this.unidad,
    required this.precioLista,
    required this.costo,
    required this.stockDisponible,
    required this.stockReservado,
    required this.estatus,
  });

  final String id;

  /// SKU interno
  final String clave;
  final String descripcion;
  final String categoria;

  /// 'PZA' | 'KIT' | 'MTO' | 'CJA' | 'RLL'
  final String unidad;
  final double precioLista;
  final double costo;
  final int stockDisponible;
  final int stockReservado;

  /// 'activo' | 'descontinuado' | 'agotado'
  final String estatus;

  double get margenPct =>
      precioLista > 0 ? ((precioLista - costo) / precioLista) * 100 : 0;

  double get margenMonto => precioLista - costo;

  int get stockReal => stockDisponible - stockReservado;
}

// ─── Línea de Documento (compartida: Cotización / Orden de Venta) ─────────────
class LineaDocumento {
  const LineaDocumento({
    required this.productoId,
    required this.descripcion,
    required this.unidad,
    required this.cantidad,
    required this.precioUnitario,
    required this.descuentoPct,
  });

  final String productoId;
  final String descripcion;
  final String unidad;
  final double cantidad;
  final double precioUnitario;

  /// Porcentaje de descuento 0-100
  final double descuentoPct;

  double get subtotal => cantidad * precioUnitario * (1 - descuentoPct / 100);
}

// ─── Cotización ───────────────────────────────────────────────────────────────
class Cotizacion {
  const Cotizacion({
    required this.id,
    required this.clienteId,
    required this.vendedorId,
    required this.fecha,
    required this.fechaVigencia,
    required this.estatus,
    required this.lineas,
    required this.subtotal,
    required this.descuentoTotal,
    required this.iva,
    required this.total,
    this.notas,
    this.condicionesPago,
  });

  /// COT-2026-XXXX
  final String id;
  final String clienteId;
  final String vendedorId;
  final DateTime fecha;
  final DateTime fechaVigencia;

  /// 'borrador' | 'enviada' | 'aprobada' | 'rechazada' | 'vencida' | 'convertida'
  final String estatus;
  final List<LineaDocumento> lineas;
  final double subtotal;
  final double descuentoTotal;
  final double iva;
  final double total;
  final String? notas;
  final String? condicionesPago;
}

// ─── Orden de Venta ───────────────────────────────────────────────────────────
class OrdenVenta {
  const OrdenVenta({
    required this.id,
    required this.clienteId,
    required this.vendedorId,
    required this.fecha,
    required this.fechaEntregaCompromiso,
    required this.estatus,
    required this.estatusEnvio,
    required this.lineas,
    required this.subtotal,
    required this.descuentoTotal,
    required this.iva,
    required this.total,
    this.cotizacionId,
    this.notas,
  });

  /// OV-2026-XXXX
  final String id;

  /// ID de cotización origen (null si es directa)
  final String? cotizacionId;
  final String clienteId;
  final String vendedorId;
  final DateTime fecha;
  final DateTime fechaEntregaCompromiso;

  /// 'pendiente' | 'en_proceso' | 'parcial' | 'completada' | 'cancelada'
  final String estatus;

  /// 'pendiente' | 'preparando' | 'enviado' | 'entregado'
  final String estatusEnvio;
  final List<LineaDocumento> lineas;
  final double subtotal;
  final double descuentoTotal;
  final double iva;
  final double total;
  final String? notas;
}

// ─── Factura ──────────────────────────────────────────────────────────────────
class Factura {
  const Factura({
    required this.id,
    required this.ordenVentaId,
    required this.clienteId,
    required this.fecha,
    required this.fechaVencimiento,
    required this.estatus,
    required this.subtotal,
    required this.iva,
    required this.total,
    required this.saldoPendiente,
    this.uuid,
  });

  /// FAC-2026-XXXX
  final String id;
  final String ordenVentaId;
  final String clienteId;
  final DateTime fecha;
  final DateTime fechaVencimiento;

  /// 'emitida' | 'parcial' | 'pagada' | 'vencida' | 'cancelada'
  final String estatus;
  final double subtotal;
  final double iva;
  final double total;
  final double saldoPendiente;

  /// UUID CFDI simulado
  final String? uuid;
}

// ─── Pago ─────────────────────────────────────────────────────────────────────
class Pago {
  const Pago({
    required this.id,
    required this.facturaId,
    required this.clienteId,
    required this.fecha,
    required this.monto,
    required this.formaPago,
    required this.referencia,
    this.notas,
  });

  /// PAG-2026-XXXX
  final String id;
  final String facturaId;
  final String clienteId;
  final DateTime fecha;
  final double monto;

  /// 'transferencia' | 'cheque' | 'efectivo' | 'tarjeta'
  final String formaPago;
  final String referencia;
  final String? notas;
}

// ─── Nota de Crédito ──────────────────────────────────────────────────────────
class NotaCredito {
  const NotaCredito({
    required this.id,
    required this.facturaId,
    required this.clienteId,
    required this.fecha,
    required this.monto,
    required this.motivo,
    required this.estatus,
  });

  /// NC-2026-XXXX
  final String id;
  final String facturaId;
  final String clienteId;
  final DateTime fecha;
  final double monto;

  /// 'devolucion' | 'descuento' | 'error_factura' | 'otro'
  final String motivo;

  /// 'vigente' | 'aplicada' | 'cancelada'
  final String estatus;
}

// ─── Envío ────────────────────────────────────────────────────────────────────
class Envio {
  const Envio({
    required this.id,
    required this.ordenVentaId,
    required this.clienteId,
    required this.fechaEnvio,
    required this.transportista,
    required this.guia,
    required this.estatus,
    required this.destinatario,
    required this.direccion,
    this.fechaEntrega,
  });

  /// ENV-2026-XXXX
  final String id;
  final String ordenVentaId;
  final String clienteId;
  final DateTime fechaEnvio;
  final DateTime? fechaEntrega;

  /// 'propio' | 'fedex' | 'estafeta' | 'dhl'
  final String transportista;
  final String guia;

  /// 'preparando' | 'en_ruta' | 'entregado' | 'incidencia'
  final String estatus;
  final String destinatario;
  final String direccion;
}

// ─── Serie mensual (para gráficas del dashboard) ──────────────────────────────
class PuntoMensual {
  const PuntoMensual({
    required this.mes,
    required this.anio,
    required this.ventas,
    required this.cobrado,
    required this.cotizaciones,
    required this.margenPct,
  });

  final String mes;
  final int anio;
  final double ventas;
  final double cobrado;
  final int cotizaciones;
  final double margenPct;
}
