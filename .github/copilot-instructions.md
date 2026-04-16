# Copilot Instructions — Demo ERP Gestión Comercial Empresarial

## ⚠️ REGLA CRÍTICA — NUNCA EJECUTAR EN WINDOWS
**NUNCA ejecutar la aplicación en Windows con `flutter run -d windows`.**
**Esta es una aplicación WEB. Siempre usar Chrome: `flutter run -d chrome`**
**NO usar: `flutter run -d windows`, `flutter run -d macos`, `flutter run -d linux`**

---

## Descripción General del Proyecto

**Demo ERP Gestión Comercial Empresarial** es una aplicación Flutter Web que simula un sistema profesional de gestión del ciclo completo de ventas **(Order-to-Cash)**: desde la cotización hasta la cobranza y el análisis financiero.

**Este proyecto NO es un sistema POS (Punto de Venta).**

### ❌ NO incluye:
- Escaneo de códigos de barras / QR
- Carrito de compra tipo retail
- Caja registradora
- Ticket de venta
- Flujo rápido tipo mostrador / tienda

### ✅ SÍ es:
- Sistema ERP comercial / backoffice empresarial
- Gestión documental y financiera
- Proceso corporativo estructurado
- Orientado a analistas, gerentes y directivos

**Propósito**: Demostrar las capacidades de CBLuna en la creación de sistemas ERP comerciales para empresas medianas/grandes que gestionan ventas formales, cobranza, inventario administrativo y análisis financiero.

**Demo Context**: Empresa comercial con 20-40 vendedores, catálogo de 200-500 productos, y ciclo de venta B2B (cotización → orden → factura → cobro).

---

## Arquitectura del Proyecto

### App Name & Package
- **Package name**: `nethive_neo` (nombre técnico existente, no cambiar)
- **App title display**: `Gestión Comercial — CBLuna Demo`

### Estructura de Páginas

```
lib/
├── main.dart
├── data/
│   └── mock_data.dart               ← Hub central de datos simulados
├── functions/                       ← Utilidades puras (formateo, validación)
├── helpers/
│   ├── constants.dart               ← Breakpoints, rutas, constantes
│   ├── globals.dart                 ← GlobalKeys, SharedPreferences
│   ├── color_extension.dart
│   └── scroll_behavior.dart
├── internationalization/
│   └── internationalization.dart
├── models/
│   └── models.dart                  ← Barrel file de modelos
├── pages/
│   ├── page_not_found.dart
│   ├── pages.dart                   ← Barrel file
│   │
│   ├── main_container/              ← Layout principal (sidebar + header)
│   │   └── main_container_page.dart
│   │
│   ── MÓDULO COMERCIAL ──────────────────────────────
│   ├── dashboard/
│   │   ├── dashboard_page.dart
│   │   └── widgets/
│   ├── cotizaciones/
│   │   ├── cotizaciones_page.dart
│   │   └── widgets/
│   ├── ordenes_venta/
│   │   ├── ordenes_venta_page.dart
│   │   └── widgets/
│   ├── clientes/
│   │   ├── clientes_page.dart
│   │   └── widgets/
│   ├── vendedores/
│   │   ├── vendedores_page.dart
│   │   └── widgets/
│   │
│   ── MÓDULO FINANCIERO ─────────────────────────────
│   ├── facturas/
│   │   ├── facturas_page.dart
│   │   └── widgets/
│   ├── cuentas_por_cobrar/
│   │   ├── cuentas_por_cobrar_page.dart
│   │   └── widgets/
│   ├── pagos/
│   │   ├── pagos_page.dart
│   │   └── widgets/
│   ├── notas_credito/
│   │   ├── notas_credito_page.dart
│   │   └── widgets/
│   │
│   ── MÓDULO OPERATIVO ──────────────────────────────
│   ├── inventario/
│   │   ├── inventario_page.dart
│   │   └── widgets/
│   ├── envios/
│   │   ├── envios_page.dart
│   │   └── widgets/
│   │
│   ── MÓDULO ANALÍTICO ──────────────────────────────
│   ├── reportes/
│   │   ├── reportes_page.dart
│   │   └── widgets/
│   ├── margenes/
│   │   ├── margenes_page.dart
│   │   └── widgets/
│   │
│   ── MÓDULO ADMINISTRATIVO ─────────────────────────
│   ├── configuracion/
│   │   ├── configuracion_page.dart
│   │   └── widgets/
│   ├── usuarios/
│   │   ├── usuarios_page.dart
│   │   └── widgets/
│   └── auditoria/
│       ├── auditoria_page.dart
│       └── widgets/
│
├── providers/
│   ├── visual_state_provider.dart   ← Navegación + tema (existente)
│   ├── cotizacion_provider.dart
│   ├── orden_venta_provider.dart
│   ├── cliente_provider.dart
│   ├── vendedor_provider.dart
│   ├── factura_provider.dart
│   ├── cobro_provider.dart
│   ├── inventario_provider.dart
│   └── pago_provider.dart
│
├── router/
│   └── router.dart
├── theme/
│   └── theme.dart                   ← AppTheme enterprise
└── widgets/                         ← Componentes globales compartidos
    ├── sidebar/
    ├── header/
    ├── navbar/
    └── charts/
```

---

## Routing — GoRouter

**Router config**: `lib/router/router.dart`

| Ruta | Página | Módulo |
|------|--------|--------|
| `/` | Dashboard | Comercial |
| `/cotizaciones` | Cotizaciones | Comercial |
| `/ordenes-venta` | Órdenes de Venta | Comercial |
| `/clientes` | Clientes | Comercial |
| `/vendedores` | Vendedores / Comisiones | Comercial |
| `/facturas` | Facturas | Financiero |
| `/cuentas-por-cobrar` | Cuentas por Cobrar | Financiero |
| `/pagos` | Pagos Aplicados | Financiero |
| `/notas-credito` | Notas de Crédito | Financiero |
| `/inventario` | Inventario | Operativo |
| `/envios` | Envíos / Logística | Operativo |
| `/reportes` | Reportes | Analítico |
| `/margenes` | Márgenes | Analítico |
| `/configuracion` | Configuración | Administrativo |
| `/usuarios` | Usuarios y Roles | Administrativo |
| `/auditoria` | Auditoría | Administrativo |

- **Sin animaciones de transición**: usar `NoTransitionPage` o `pageBuilder` con `Duration.zero`
- **Sin autenticación**: acceso directo a todas las páginas
- **Exit button**: abre `https://cbluna.com/` en la misma ventana

---

## State Management — Provider

| Provider | Responsabilidad |
|----------|----------------|
| `VisualStateProvider` | Navegación, tema claro/oscuro (existente) |
| `ClienteProvider` | CRUD clientes |
| `VendedorProvider` | CRUD vendedores + comisiones |
| `CotizacionProvider` | CRUD cotizaciones + líneas |
| `OrdenVentaProvider` | CRUD órdenes de venta |
| `FacturaProvider` | CRUD facturas + estado |
| `CobroProvider` | Cuentas por cobrar + estado |
| `PagoProvider` | Pagos aplicados + nota de crédito |
| `InventarioProvider` | Disponibilidad de productos |

**Setup**: Todos registrados en `main()` vía `MultiProvider`.

---

## Sistema de Colores — Enterprise Dark Blue

### Filosofía de color
El sistema usa un esquema semántico claro:

| Color | Significado |
|-------|-------------|
| 🔴 Rojo | Error / Riesgo / Eliminación / Estado crítico |
| 🟢 Verde | Éxito / Confirmación / Activo / Ingreso |
| 🟡 Amarillo/Amber | Advertencia / Pendiente / Por revisar |
| 🔵 Azul | Información / Acción primaria / Margen |
| ⚪ Gris | Neutro / Inactivo / Cancelado |
| 🟣 Índigo | Crecimiento / Analítico / Tendencia |

### ❌ Prohibido
- Colores neón
- Rosas vibrantes
- Morados saturados
- Amarillos brillantes
- Gradientes llamativos
- Estética startup / retail / marketing

---

### Paleta — Modo Claro

```dart
// Identidad / Navegación / Acciones primarias
static const Color primary       = Color(0xFF1E3A5F); // Azul corporativo profundo
static const Color primaryHover  = Color(0xFF254A75);
static const Color primarySoft   = Color(0xFF2C5C8F);

// Semánticos
static const Color success       = Color(0xFF2D7A4F); // Verde empresa (ingresos, activo)
static const Color successSoft   = Color(0xFFE8F5EE);
static const Color warning       = Color(0xFFB45309); // Amber oscuro (pendiente)
static const Color warningSoft   = Color(0xFFFEF3C7);
static const Color error         = Color(0xFFB91C1C); // Rojo corporativo (riesgo, error)
static const Color errorSoft     = Color(0xFFFEE2E2);
static const Color info          = Color(0xFF1D4ED8); // Azul info (margen, analítico)
static const Color infoSoft      = Color(0xFFEFF6FF);
static const Color indigo        = Color(0xFF4338CA); // Crecimiento / analítico
static const Color indigoSoft    = Color(0xFFEEF2FF);
static const Color neutral       = Color(0xFF64748B); // Gris neutro (inactivo)

// Fondos y superficies
static const Color background    = Color(0xFFF4F6F9);
static const Color surface       = Color(0xFFFFFFFF);
static const Color border        = Color(0xFFE3E8EF);

// Texto
static const Color textPrimary   = Color(0xFF0F172A);
static const Color textSecondary = Color(0xFF475569);
static const Color textDisabled  = Color(0xFF94A3B8);
```

### Paleta — Modo Oscuro

```dart
// Identidad
static const Color primaryDark       = Color(0xFF2C5C8F);
static const Color primaryHoverDark  = Color(0xFF3A72AD);

// Semánticos dark
static const Color successDark       = Color(0xFF34D399);
static const Color warningDark       = Color(0xFFFBBF24);
static const Color errorDark         = Color(0xFFF87171);
static const Color infoDark          = Color(0xFF60A5FA);
static const Color indigoDark        = Color(0xFF818CF8);
static const Color neutralDark       = Color(0xFF94A3B8);

// Fondos y superficies dark
static const Color backgroundDark    = Color(0xFF0F1C2E);
static const Color surfaceDark       = Color(0xFF1B2B42);
static const Color borderDark        = Color(0xFF253B56);

// Texto dark
static const Color textPrimaryDark   = Color(0xFFF1F5F9);
static const Color textSecondaryDark = Color(0xFF94A3B8);
static const Color textDisabledDark  = Color(0xFF64748B);
```

### Uso de Colores en Dashboard Financiero

| Métrica | Color |
|---------|-------|
| Ingresos / Cobrado | Verde (`success`) |
| Egresos / Por pagar | Rojo (`error`) |
| Margen bruto | Azul (`info`) |
| Crecimiento / Tendencia | Índigo (`indigo`) |
| Pendiente / En proceso | Amber (`warning`) |
| Cancelado / Inactivo | Gris (`neutral`) |

---

## Datos Mock — Contexto de Negocio

**Empresa ficticia**: *Distribuidora Nexo S.A. de C.V.*
**Año fiscal**: 2026 (enero–diciembre)
**Giro**: Distribución B2B de material eléctrico / industrial
**Clientes**: 60–80 clientes empresariales
**Productos**: 150–200 SKUs en catálogo
**Vendedores**: 8–12 vendedores con zonas y comisiones
**Ciclo de venta**: Cotización → Orden de Venta → Factura → Pago

Todos los datos en `lib/data/mock_data.dart`.

---

## Modelos de Datos

```dart
// Cliente
class Cliente {
  final String id;
  final String razonSocial;
  final String rfc;
  final String contactoPrincipal;
  final String email;
  final String telefono;
  final String ciudad;
  final String estadoGeografico;
  final String segmento;        // 'A' | 'B' | 'C' (por volumen)
  final String estatus;         // 'activo' | 'inactivo' | 'suspendido'
  final DateTime fechaAlta;
  final double limiteCredito;
  final int diasCredito;        // 30, 60, 90
  final String? vendedorId;
}

// Vendedor
class Vendedor {
  final String id;
  final String nombre;
  final String email;
  final String zona;
  final String estatus;         // 'activo' | 'inactivo'
  final double comisionPct;
  final double metaMensual;
  final DateTime fechaIngreso;
}

// Producto
class Producto {
  final String id;
  final String clave;           // SKU
  final String descripcion;
  final String categoria;
  final String unidad;          // 'PZA' | 'KIT' | 'MTO' | 'CJA'
  final double precioLista;
  final double costo;
  final int stockDisponible;
  final String estatus;         // 'activo' | 'descontinuado' | 'agotado'
}

// Cotización
class Cotizacion {
  final String id;              // COT-2026-0001
  final String clienteId;
  final String vendedorId;
  final DateTime fecha;
  final DateTime fechaVigencia;
  final String estatus;         // 'borrador' | 'enviada' | 'aprobada' | 'rechazada' | 'vencida' | 'convertida'
  final List<LineaDocumento> lineas;
  final double subtotal;
  final double descuentoTotal;
  final double iva;
  final double total;
  final String? notas;
  final String? condicionesPago;
}

// Orden de Venta
class OrdenVenta {
  final String id;              // OV-2026-0001
  final String? cotizacionId;
  final String clienteId;
  final String vendedorId;
  final DateTime fecha;
  final DateTime fechaEntregaCompromiso;
  final String estatus;         // 'pendiente' | 'en_proceso' | 'parcial' | 'completada' | 'cancelada'
  final String estatusEnvio;    // 'pendiente' | 'preparando' | 'enviado' | 'entregado'
  final List<LineaDocumento> lineas;
  final double subtotal;
  final double descuentoTotal;
  final double iva;
  final double total;
  final String? notas;
}

// Factura
class Factura {
  final String id;              // FAC-2026-0001
  final String ordenVentaId;
  final String clienteId;
  final DateTime fecha;
  final DateTime fechaVencimiento;
  final String estatus;         // 'emitida' | 'parcial' | 'pagada' | 'vencida' | 'cancelada'
  final double subtotal;
  final double iva;
  final double total;
  final double saldoPendiente;
  final String? uuid;           // UUID CFDI simulado
}

// Pago
class Pago {
  final String id;              // PAG-2026-0001
  final String facturaId;
  final String clienteId;
  final DateTime fecha;
  final double monto;
  final String formaPago;       // 'transferencia' | 'cheque' | 'efectivo' | 'tarjeta'
  final String referencia;
  final String? notas;
}

// Nota de Crédito
class NotaCredito {
  final String id;              // NC-2026-0001
  final String facturaId;
  final String clienteId;
  final DateTime fecha;
  final double monto;
  final String motivo;          // 'devolucion' | 'descuento' | 'error_factura' | 'otro'
  final String estatus;         // 'vigente' | 'aplicada' | 'cancelada'
}

// Línea de documento compartida
class LineaDocumento {
  final String productoId;
  final String descripcion;
  final String unidad;
  final double cantidad;
  final double precioUnitario;
  final double descuentoPct;
  final double subtotal;
}

// Envío
class Envio {
  final String id;              // ENV-2026-0001
  final String ordenVentaId;
  final DateTime fechaEnvio;
  final DateTime? fechaEntrega;
  final String transportista;   // 'propio' | 'fedex' | 'estafeta' | 'dhl'
  final String guia;
  final String estatus;         // 'preparando' | 'en_ruta' | 'entregado' | 'incidencia'
  final String destinatario;
  final String direccion;
}

// Evento de Auditoría
class EventoAuditoria {
  final String id;
  final DateTime timestamp;
  final String usuario;
  final String modulo;
  final String accion;          // 'crear' | 'editar' | 'eliminar' | 'aprobar' | 'cancelar'
  final String descripcion;
  final String? referencia;
  final String? ip;
}

// Usuario del sistema
class UsuarioSistema {
  final String id;
  final String nombre;
  final String email;
  final String rol;             // 'admin' | 'gerente' | 'vendedor' | 'finanzas' | 'operaciones'
  final String estatus;         // 'activo' | 'inactivo' | 'bloqueado'
  final DateTime ultimoAcceso;
  final List<String> permisos;
}
```

---

## Sidebar — Estructura Visual

```
┌─────────────────────────────┐
│  [Logo] Gestión Comercial   │
├─────────────────────────────┤
│  🟦 COMERCIAL               │
│      Dashboard              │
│      Cotizaciones           │
│      Órdenes de Venta       │
│      Clientes               │
│      Vendedores             │
├─────────────────────────────┤
│  🟩 FINANCIERO              │
│      Facturas               │
│      Cuentas por Cobrar     │
│      Pagos Aplicados        │
│      Notas de Crédito       │
├─────────────────────────────┤
│  🟨 OPERATIVO               │
│      Inventario             │
│      Envíos / Logística     │
├─────────────────────────────┤
│  🟪 ANALÍTICO               │
│      Reportes               │
│      Márgenes               │
├─────────────────────────────┤
│  🟥 ADMINISTRATIVO          │
│      Configuración          │
│      Usuarios y Roles       │
│      Auditoría              │
├─────────────────────────────┤
│  [Salir de la Demo]         │
└─────────────────────────────┘
```

Grupos con acento sutil: borde izquierdo de color o fondo muy tenue por grupo.

---

## Páginas — Descripción Funcional

### 1. Dashboard (`/`)
**KPIs principales:**
| KPI | Color | Ícono |
|-----|-------|-------|
| Ventas del mes (MXN) | Azul | `Icons.trending_up` |
| Cobrado del mes | Verde | `Icons.check_circle_outline` |
| Por cobrar (vencido) | Rojo | `Icons.warning_amber_outlined` |
| Cotizaciones activas | Amber | `Icons.description_outlined` |
| Órdenes en proceso | Azul info | `Icons.sync` |
| Margen bruto promedio | Índigo | `Icons.percent` |

**Gráficas (fl_chart):**
- Línea: Ventas vs Cobrado (últimos 6 meses)
- Barras: Ventas por vendedor (mes actual)
- Donut: Distribución de facturas por estatus
- Barras: Top 10 clientes por volumen

**Alertas:**
- Facturas vencidas (> días de crédito)
- Cotizaciones próximas a vencer
- Clientes cerca del límite de crédito

### 2. Cotizaciones (`/cotizaciones`)
PlutoGrid: Folio, Cliente, Vendedor, Fecha, Vigencia, Total, Estatus, Acciones
Filtros: Estatus, vendedor, cliente, rango de fechas
Acciones: Nueva cotización, Ver detalle, Convertir a OV, Duplicar, Cancelar

### 3. Órdenes de Venta (`/ordenes-venta`)
PlutoGrid: Folio OV, Folio COT origen, Cliente, Vendedor, Fecha, F.Entrega, Total, Estatus, Estatus Envío, Acciones
Flujo: Pendiente → En Proceso → Completada

### 4. Clientes (`/clientes`)
PlutoGrid: Razón Social, RFC, Segmento, Ciudad, Vendedor asignado, Límite crédito, Días crédito, Estatus, Acciones
Filtros: Segmento, estatus, vendedor, ciudad

### 5. Vendedores (`/vendedores`)
Vista tarjetas + tabla: Nombre, zona, meta mensual, ventas del mes, % cumplimiento, comisión generada
Gráfica de ranking por volumen

### 6. Facturas (`/facturas`)
PlutoGrid: Folio FAC, UUID, Cliente, OV origen, Fecha, Vencimiento, Total, Saldo, Estatus, Acciones
Estatus semántico: Azul(emitida), Amber(parcial), Verde(pagada), Rojo(vencida), Gris(cancelada)

### 7. Cuentas por Cobrar (`/cuentas-por-cobrar`)
Vista ejecutiva de cartera: Total, vencido <30d, 30–60d, 60–90d, >90d
Tabla por cliente: Saldo, vencido, próximo a vencer
Semáforo de riesgo por antigüedad

### 8. Pagos Aplicados (`/pagos`)
Tabla: Folio PAG, Cliente, Factura(s) aplicada(s), Fecha, Monto, Forma de pago, Referencia

### 9. Notas de Crédito (`/notas-credito`)
Tabla: Folio NC, Factura origen, Cliente, Fecha, Monto, Motivo, Estatus

### 10. Inventario (`/inventario`)
Tabla administrativa (NO POS): SKU, Descripción, Categoría, Unidad, Stock, Reservado, Disponible real, Precio lista, Costo, Margen%, Estatus
Sin escaneo. Solo consulta y ajuste administrativo.

### 11. Envíos (`/envios`)
Tabla: Folio ENV, OV, Cliente, Transportista, Guía, Fecha envío, Fecha entrega, Estatus

### 12. Reportes (`/reportes`)
- Ventas por mes (línea/área)
- Ventas por vendedor (barras)
- Ventas por categoría / canal
- Reporte de cobranza
- Export simulado: SnackBar de confirmación

### 13. Márgenes (`/margenes`)
- Margen bruto por producto (tabla + gráfica)
- Margen por categoría
- Margen por cliente
- Evolución del margen en el tiempo

### 14. Configuración (`/configuracion`)
Parámetros de empresa, condiciones de pago, categorías, zonas de vendedores, IVA

### 15. Usuarios y Roles (`/usuarios`)
Tabla: Nombre, Email, Rol, Último acceso, Estatus
Roles: admin, gerente, vendedor, finanzas, operaciones

### 16. Auditoría (`/auditoria`)
Log: Timestamp, Usuario, Módulo, Acción, Descripción, Referencia
Filtros: por fecha, usuario, módulo, acción

---

## PlutoGrid — Patrón Estándar (Datos Mock)

**NUNCA usar `PlutoLazyPagination` con datos hardcodeados.**

### Patrón correcto:

```dart
// 1. El Provider construye las rows
class CotizacionProvider extends ChangeNotifier {
  List<Cotizacion> _cotizaciones = [];
  List<PlutoRow> cotizacionesRows = [];

  void _buildRows() {
    cotizacionesRows = _cotizaciones.map((c) => PlutoRow(cells: {
      'folio':    PlutoCell(value: c.id),
      'cliente':  PlutoCell(value: c.clienteId),
      'total':    PlutoCell(value: c.total),
      'estatus':  PlutoCell(value: c.estatus),
      '_objeto':  PlutoCell(value: c), // objeto completo oculto
    })).toList();
  }

  Future<void> initialize() async {
    _cotizaciones = List.from(MockData.cotizaciones);
    _buildRows();
    notifyListeners();
  }
}

// 2. PlutoGrid con PlutoPagination simple
PlutoGrid(
  columns: _columns,
  rows: provider.cotizacionesRows,
  onLoaded: (e) => stateManager = e.stateManager,
  configuration: PlutoGridConfiguration(
    columnSize: const PlutoGridColumnSizeConfig(
      autoSizeMode: PlutoAutoSizeMode.scale,
      resizeMode: PlutoResizeMode.normal,
    ),
  ),
  createFooter: (stateManager) {
    stateManager.setPageSize(20, notify: false);
    return PlutoPagination(stateManager);
  },
)
```

### Container estándar para PlutoGrid:

```dart
Container(
  decoration: BoxDecoration(
    color: theme.surface,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: theme.border, width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  ),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: PlutoGrid(...),
  ),
)
```

---

## Badges de Estatus — Estilo Enterprise

```dart
Widget statusBadge(String estatus, AppThemeData theme) {
  late Color color;
  switch (estatus) {
    case 'activo': case 'pagada': case 'completada': case 'entregado':
      color = theme.success; break;
    case 'pendiente': case 'en_proceso': case 'parcial': case 'enviada': case 'borrador':
      color = theme.warning; break;
    case 'vencida': case 'rechazada': case 'incidencia': case 'suspendido':
      color = theme.error; break;
    case 'cancelada': case 'inactivo': case 'descontinuado': case 'bloqueado':
      color = theme.neutral; break;
    case 'aprobada': case 'emitida': case 'convertida': case 'en_ruta':
      color = theme.info; break;
    default: color = theme.neutral;
  }
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: color.withOpacity(0.4), width: 1),
    ),
    child: Text(
      estatus.toUpperCase().replaceAll('_', ' '),
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.w600,
        fontSize: 11,
        letterSpacing: 0.3,
      ),
    ),
  );
}
```

---

## Formato de Datos

| Tipo | Formato | Ejemplo |
|------|---------|---------|
| Dinero MXN | `$ 1,234,567.00 MXN` | `$ 45,800.00 MXN` |
| Fecha larga | `3 de enero de 2026` | `18 de febrero de 2026` |
| Fecha corta | `18/02/2026` | — |
| Fecha + hora | `18/02/2026 14:35` | — |
| Porcentaje | `16.00 %` | `23.50 %` |
| Folios | `COT-2026-0001` | `FAC-2026-0048` |

---

## Convenciones de Código

- **Archivos**: `snake_case.dart`
- **Clases**: `PascalCase`
- **Variables**: `camelCase`
- **Constantes**: `SCREAMING_SNAKE_CASE`
- **Imports**: (1) dart:, (2) package:flutter, (3) package:third_party, (4) relativos
- **Nunca mutar estado**: siempre nuevas instancias + `notifyListeners()`
- **Dispose**: limpiar controllers/listeners en `dispose()`
- **Feedback**: SnackBar para operaciones CRUD
- **Validación**: client-side (RFC, email, campos requeridos, numéricos)
- **Persistencia**: Solo en memoria durante la sesión. Sin backend. Sin base de datos.

---

## Dependencias Clave

| Paquete | Uso |
|---------|-----|
| `pluto_grid: ^8.0.0` | Tablas administrativas |
| `fl_chart: ^0.69.0` | Gráficas del dashboard y reportes |
| `provider: ^6.1.1` | State management |
| `go_router: ^14.6.2` | Navegación declarativa |
| `google_fonts: ^6.2.1` | Tipografía Inter |
| `shared_preferences: ^2.2.2` | Persistencia del tema |
| `url_launcher: ^6.2.0` | Botón "Salir" → cbluna.com |
| `url_strategy: ^0.2.0` | URLs sin `#` en web |
| `intl: ^0.19.0` | Formateo de fechas/números en español |
| `uuid: ^4.5.1` | IDs para CRUD en memoria |
| `flutter_animate: ^4.2.0` | Animaciones sutiles enterprise |
| `auto_size_text: ^3.0.0` | Texto responsivo en KPI cards |

---

## Diseño Responsivo

| Breakpoint | Comportamiento |
|------------|---------------|
| Desktop (> 768px) | Sidebar fijo + PlutoGrid + layout columnas |
| Mobile (≤ 768px) | Navbar hamburguesa + Cards apiladas |

Constante: `mobileSize = 768` en `lib/helpers/constants.dart`

---

## Comandos de Desarrollo

```bash
# Instalación
flutter pub get

# Ejecutar (SIEMPRE web - NUNCA windows)
flutter run -d chrome

# Build producción
flutter build web --release
```

---

## Quick Reference

| Item | Valor |
|------|-------|
| **Demo** | ERP Gestión Comercial (Order-to-Cash) |
| **Empresa ficticia** | Distribuidora Nexo S.A. de C.V. |
| **Año fiscal** | 2026 |
| **Paleta base** | Azul corporativo `#1E3A5F` |
| **Dark background** | `#0F1C2E` |
| **Light background** | `#F4F6F9` |
| **Fuente** | Inter (Google Fonts) |
| **Exit URL** | https://google.com/ |
| **Breakpoint móvil** | 768px |
| **Package name** | `nethive_neo` |
