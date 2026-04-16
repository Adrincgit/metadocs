# Plan de Acción — MetaDocs · AI Document Intelligence Demo
**Producto**: Plataforma de gestión, clasificación, extracción y análisis de documentos mediante metadatos e inteligencia artificial.  
**Stack**: Flutter Web · Provider · GoRouter · PlutoGrid · fl_chart  
**Datos**: 100% hardcodeados en memoria (sin backend, sin auth, sin persistencia)  
**Branding**: MetaDocs — AI Document Intelligence Demo  
**Avatar simulado**: Valeria Ríos · Document Analyst  
**Workspace**: Repositorio Principal · Demo 2026  
**Botón salida**: ❌ No existe por ahora. Se reintroducirá como "Volver al portafolio" cuando exista el portal personal.

---

## Rutas del Sistema

| Ruta | Página | Grupo | Fase |
|------|--------|-------|------|
| `/` | Dashboard | OVERVIEW | 1ª |
| `/biblioteca` | Biblioteca de Documentos | DOCUMENTS | 1ª |
| `/ingesta` | Ingesta / Carga | DOCUMENTS | 1ª |
| `/procesamiento` | Procesamiento | DOCUMENTS | 2ª |
| `/explorador` | Explorador de Metadatos | DATA | 1ª |
| `/esquemas` | Esquemas y Taxonomía | DATA | 2ª |
| `/analisis-ia` | Análisis con IA | AI | 1ª |
| `/consultas` | Consultas Inteligentes | AI | 2ª |
| `/reportes` | Reportes e Insights | INSIGHTS | 1ª |
| `/integraciones` | Integraciones | ADMIN | 1ª |
| `/configuracion` | Configuración | ADMIN | 1ª |
| `/usuarios` | Usuarios y Roles | ADMIN | 1ª |
| `/auditoria` | Auditoría | ADMIN | 1ª |

---

## FASE 0 — Limpieza de la base ERP anterior
> Eliminar todo rastro del ERP comercial antes de construir MetaDocs.

- [ ] Vaciar `lib/data/mock_data.dart` (eliminar clientes, vendedores, facturas, órdenes)
- [ ] Limpiar `lib/models/models.dart` (eliminar todos los modelos ERP)
- [ ] Limpiar `lib/providers/visual_state_provider.dart` (conservar solo lógica de tema + navegación)
- [ ] Limpiar `lib/pages/pages.dart` (barrel vacío listo para nuevas páginas)
- [ ] Limpiar `lib/router/router.dart` (placeholder temporal en `/`)
- [ ] Limpiar `lib/widgets/sidebar/` (eliminar grupos y ítems del ERP)
- [ ] Limpiar `lib/widgets/header/` (eliminar referencias ERP)
- [ ] Verificar que `flutter run -d chrome` compila sin errores tras la limpieza

---

## FASE 1 — Cimientos del sistema

### 1.1 · Theme Enterprise (MetaDocs)
- [ ] Reescribir `lib/theme/theme.dart` conservando la paleta dark blue corporativa
- [ ] Colores modo claro: `primary`, `success`, `warning`, `error`, `info`, `indigo`, `neutral`, `background`, `surface`, `border`, texto
- [ ] Colores modo oscuro: equivalentes dark de toda la paleta
- [ ] Tipografía con Google Fonts Inter
- [ ] Método `AppTheme.of(context)` que retorna el tema activo
- [ ] Verificar toggle claro/oscuro funcional

### 1.2 · Modelos de Datos

> **Estrategia**: implementar primero los 5 modelos núcleo para avanzar rápido a pantallas. Los 3 modelos secundarios se agregan en segunda vuelta cuando ya haya pantallas mostrando datos.

**Documento (entidad central):**
- [ ] `Documento`: id, nombre, tipoDocumental, origen, fechaIngesta, fechaDocumento, estatus, confianzaIA, etiquetas, tamanoKb, paginas, metadatos

**Estatus de documento:** `pendiente` | `procesando` | `extraido` | `revisado` | `rechazado` | `archivado`

**Origen:** `carga_manual` | `email` | `api` | `escaner` | `integracion`

**Modelos núcleo (implementar primero):**
- [ ] `Documento` — entidad central del sistema
- [ ] `CampoMetadato`: id, nombre, tipo (texto/fecha/monto/rfc/entidad), obligatorio, valorExtraido, confianza
- [ ] `ResultadoProcesamiento`: id, documentoId, estatus, motorOCR, tiempoMs, errores, camposExtraidos, fecha
- [ ] `Integracion`: id, nombre, tipo (ocr/ia/storage/email/api), estatus, version, ultimaSincronizacion, descripcion
- [ ] `EventoAuditoria`: id, timestamp, usuario, modulo, accion, documentoId, descripcion, resultado, ip

**Modelos secundarios (agregar en segunda vuelta):**
- [ ] `TipoDocumental`: id, nombre, descripcion, campos (lista de `CampoMetadato`)
- [ ] `EntidadDetectada`: id, documentoId, tipo (persona/empresa/fecha/monto/lugar), valor, confianzaIA
- [ ] `UsuarioSistema`: id, nombre, email, rol, estatus, ultimoAcceso, permisos

- [ ] Exportar todo desde `lib/models/models.dart`

**Roles de usuario:** `admin` | `analyst` | `reviewer` | `compliance` | `operations`

### 1.3 · Mock Data
- [ ] 8 tipos documentales: Contrato, Factura, Expediente, Oficio, Acta, Informe, Solicitud, Dictamen
- [ ] 150 documentos con datos realistas (nombre, tipo, origen, metadatos extraídos, confianza IA entre 70-99%)
- [ ] 150 resultados de procesamiento vinculados a documentos (con tiempos OCR, errores simulados)
- [ ] 300 entidades detectadas distribuidas entre documentos (personas, empresas, fechas, montos)
- [ ] 6 integraciones simuladas: Gemini Embedding 2, OCR Engine, Cloud Storage, Email Ingestion, API Endpoint, Scanner Connector
- [ ] 180 eventos de auditoría con timestamps variados
- [ ] 10 usuarios del sistema con distintos roles
- [ ] Series temporales (12 meses): documentos procesados por mes, tasa de éxito, tiempo promedio
- [ ] Conjunto de preguntas sugeridas para la pantalla de Consultas Inteligentes (min. 12)

### 1.4 · Router
- [ ] Definir 13 rutas en `lib/router/router.dart`
- [ ] Todas dentro de `ShellRoute` (MainContainer como shell)
- [ ] Sin animaciones de transición (`NoTransitionPage`)
- [ ] Sin autenticación (acceso directo)
- [ ] Ruta de error → `PageNotFoundPage`

### 1.5 · VisualStateProvider
- [ ] Gestionar ruta/página activa del sidebar
- [ ] Toggle tema claro/oscuro
- [ ] Estado sidebar expandido/colapsado (desktop)
- [ ] Estado drawer mobile

---

## FASE 2 — Layout Principal (Shell)

### 2.1 · MainContainer
- [ ] Crear `lib/pages/main_container/main_container_page.dart`
- [ ] Estructura: `Row(Sidebar, Expanded(Column(Header, PageContent)))`
- [ ] Responsive: sidebar fijo en desktop, drawer en mobile
- [ ] Fondo con color `background` del tema activo

### 2.2 · Sidebar (Desktop)
- [ ] Crear/reescribir `lib/widgets/sidebar/sidebar_widget.dart`
- [ ] Cabecera: logo "MetaDocs" + subtítulo "AI Document Intelligence"
- [ ] 6 grupos con acento de color por grupo:
  - OVERVIEW (azul primario)
  - DOCUMENTS (índigo)
  - DATA (info azul)
  - AI (indigo saturado)
  - INSIGHTS (success verde)
  - ADMIN (neutral gris)
- [ ] Cada grupo: label + ícono + ítems de menú
- [ ] Ítem activo: fondo con opacidad baja del color del grupo
- [ ] Hover sutil en ítems
- [ ] **Sin botón "Salir de la demo"** (se añadirá en el futuro como "Volver al portafolio")
- [ ] Ancho fijo: 240px

### 2.3 · Header (Desktop)
- [ ] Crear/reescribir `lib/widgets/header/header_widget.dart`
- [ ] **Izquierda**: título de la página activa + subtítulo contextual (diferente por ruta)
- [ ] **Centro**: campo de búsqueda global con placeholder "Buscar documentos, entidades o metadatos…"
- [ ] **Derecha** (de izquierda a derecha):
  - Selector de workspace (badge/dropdown simulado: "Repositorio Principal")
  - Badge de estado IA: `IA Activa` en verde
  - Badge de estado OCR: `OCR Online` en azul info
  - Fecha actual
  - Toggle claro/oscuro
  - Avatar: Valeria Ríos · Document Analyst

### 2.4 · Navbar Mobile
- [ ] Crear `lib/widgets/navbar/navbar_widget.dart`
- [ ] Botón hamburguesa → Drawer con el mismo sidebar
- [ ] Misma estructura de grupos y módulos

---

## FASE 3 — Pantallas Fase 1ª (10 pantallas)

### 3.1 · Dashboard (`/`)
- [ ] Crear `lib/pages/dashboard/dashboard_page.dart`
- [ ] 6 KPI cards:
  - Documentos procesados hoy (azul)
  - Documentos pendientes (amber)
  - Errores de extracción (rojo)
  - Campos extraídos hoy (info)
  - Confianza IA promedio (índigo)
  - Documentos en revisión (neutral)
- [ ] Gráfica de línea: volumen de documentos procesados (últimos 12 meses)
- [ ] Gráfica de barras: documentos por tipo documental (top 8)
- [ ] Gráfica donut: distribución de documentos por estatus
- [ ] Gráfica de barras horizontales: top orígenes de ingesta
- [ ] Sección actividad reciente: últimos 5 documentos procesados
- [ ] Sección alertas: documentos con error, documentos pendientes > 24h

### 3.2 · Biblioteca de Documentos (`/biblioteca`)
- [ ] Crear `lib/pages/biblioteca/biblioteca_page.dart`
- [ ] Crear `BibliotecaProvider`
- [ ] PlutoGrid columnas: ID, Nombre, Tipo Documental, Origen, Fecha, Estatus, Confianza IA, Etiquetas, Acciones
- [ ] Confianza IA: barra de progreso o número con color (≥90% verde, 70-89% amber, <70% rojo)
- [ ] Filtros rápidos: por tipo documental, estatus, origen, rango de fechas
- [ ] Barra de búsqueda
- [ ] Acciones por fila: Ver metadatos, Analizar con IA, Descargar (simulado), Archivar

### 3.3 · Ingesta / Carga (`/ingesta`)
- [ ] Crear `lib/pages/ingesta/ingesta_page.dart`
- [ ] Área visual drag & drop (decorativa, no funcional)
- [ ] Cola de archivos recientes: lista de últimos 10 documentos ingresados con estatus
- [ ] Panel de reglas aplicadas al cargar (tipo documental detectado, motor OCR usado, etiquetas automáticas)
- [ ] KPIs de sesión: archivos cargados hoy, tamaño total, tiempo promedio de procesamiento
- [ ] Tabla de orígenes activos: email, API, manual — con estatus y último evento

### 3.4 · Explorador de Metadatos (`/explorador`)
- [ ] Crear `lib/pages/explorador/explorador_page.dart`
- [ ] Crear `ExploradorProvider`
- [ ] PlutoGrid con todos los campos extraídos de los documentos
- [ ] Columnas dinámicas según tipo documental seleccionado
- [ ] Filtros avanzados combinables: tipo, entidad, fecha emisión, fecha vencimiento, monto, confianza, origen, presencia de campo
- [ ] Agrupación por tipo documental o por mes
- [ ] Exportar (SnackBar de confirmación)

### 3.5 · Análisis con IA (`/analisis-ia`)
- [ ] Crear `lib/pages/analisis_ia/analisis_ia_page.dart`
- [ ] Layout de dos paneles: lista de documentos (izquierda) + detalle IA (derecha)
- [ ] Panel de detalle al seleccionar un documento:
  - Resumen generado por IA (texto simulado)
  - Entidades detectadas (persona, empresa, fecha, monto, lugar) con badge por tipo
  - Campos extraídos con confianza individual
  - Inconsistencias detectadas (si las hay)
  - Sugerencias de acción
- [ ] Acciones simuladas (botones que muestran SnackBar):
  - "Resumir documento"
  - "Extraer datos clave"
  - "Detectar riesgos"
  - "Comparar con otro documento"

### 3.6 · Reportes e Insights (`/reportes`)
- [ ] Crear `lib/pages/reportes/reportes_page.dart`
- [ ] Selector de período: último mes / trimestre / año
- [ ] Gráfica de área: documentos procesados por período
- [ ] Gráfica de barras: documentos por tipo documental (período seleccionado)
- [ ] Gráfica de línea: tasa de éxito de extracción IA por mes
- [ ] Tabla: tiempo promedio de procesamiento por tipo documental
- [ ] KPI: porcentaje de documentos con extracción exitosa
- [ ] Botones "Exportar PDF" y "Exportar Excel" (solo SnackBar)

### 3.7 · Integraciones (`/integraciones`)
- [ ] Crear `lib/pages/integraciones/integraciones_page.dart`
- [ ] Grid de tarjetas de integración (mínimo 6):
  - Gemini Embedding 2 (IA/embeddings) — verde Activa
  - OCR Engine (motor OCR) — verde Activa
  - Cloud Storage (almacenamiento) — verde Activa
  - Email Ingestion (conectores email) — amber En revisión
  - API Endpoint (API REST) — verde Activa
  - Scanner Connector (escaneo físico) — gris Inactiva
- [ ] Cada tarjeta: ícono, nombre, tipo, versión, estatus badge, última sincronización, botón "Configurar" (simulado)
- [ ] Panel lateral al seleccionar integración: detalle de configuración simulada

### 3.8 · Configuración (`/configuracion`)
- [ ] Crear `lib/pages/configuracion/configuracion_page.dart`
- [ ] Sección branding del workspace (nombre, descripción, idioma)
- [ ] Sección parámetros de procesamiento (motor OCR por defecto, umbral mínimo de confianza IA)
- [ ] Sección retención documental (días de retención por tipo)
- [ ] Sección formato de fechas e idioma
- [ ] Sección indexado y búsqueda (campos indexados, frecuencia)
- [ ] Botón "Guardar cambios" (SnackBar de confirmación)

### 3.9 · Usuarios y Roles (`/usuarios`)
- [ ] Crear `lib/pages/usuarios/usuarios_page.dart`
- [ ] Tabla PlutoGrid: Nombre, Email, Rol, Último acceso, Estatus, Acciones
- [ ] Chips de rol con color por tipo:
  - Admin → rojo
  - Analyst → índigo
  - Reviewer → azul info
  - Compliance → amber
  - Operations → neutral
- [ ] Botón "Nuevo Usuario" con formulario simulado
- [ ] Acciones: Editar, Bloquear/Activar

### 3.10 · Auditoría (`/auditoria`)
- [ ] Crear `lib/pages/auditoria/auditoria_page.dart`
- [ ] Tabla: Timestamp, Usuario, Módulo, Acción, Documento, Descripción, Resultado
- [ ] Color por acción: subir(verde), extraer(azul), editar(info), rechazar(rojo), archivar(neutral), revisar(amber)
- [ ] Filtros: por fecha, usuario, módulo, tipo de acción
- [ ] 180 eventos pre-generados con datos realistas

---

## FASE 4 — Pantallas Fase 2ª (3 pantallas)
> Implementar solo si hay tiempo disponible después de completar Fase 3.

### 4.1 · Procesamiento (`/procesamiento`)
- [ ] Crear `lib/pages/procesamiento/procesamiento_page.dart`
- [ ] Cola de procesamiento: documentos en OCR, en extracción, fallidos, reintentando
- [ ] KPIs operativos: documentos en cola, tiempo promedio, tasa de error del día
- [ ] Tabla con estado en tiempo real simulado (con badges de estatus)
- [ ] Acción "Reintentar" por fila (SnackBar de confirmación)

### 4.2 · Consultas Inteligentes (`/consultas`)
- [ ] Crear `lib/pages/consultas/consultas_page.dart`
- [ ] Campo de búsqueda semántica grande (tipo chat input)
- [ ] Preguntas sugeridas en chips:
  - "Contratos con vencimiento en 30 días"
  - "¿Qué documentos mencionan penalización?"
  - "Facturas con monto mayor a $100,000"
  - "Documentos del mes con estatus rechazado"
  - "Expedientes por entidad Gobierno"
- [ ] Panel de resultados: fragmentos relevantes + referencia al documento fuente
- [ ] Cada resultado con badge de tipo documental y score de relevancia

### 4.3 · Esquemas y Taxonomía (`/esquemas`)
- [ ] Crear `lib/pages/esquemas/esquemas_page.dart`
- [ ] Lista de tipos documentales en sidebar izquierdo
- [ ] Panel derecho al seleccionar tipo: campos definidos, obligatorios/opcionales, tipo de dato
- [ ] Tabla de etiquetas disponibles (taxonomía)
- [ ] Botón "Agregar campo" / "Agregar tipo" (simulado con SnackBar)

---

## FASE 5 — Polish y Revisión Final

- [ ] Verificar subtítulos contextuales en el header por cada ruta (todos distintos)
- [ ] Confirmar que búsqueda global del header tiene placeholder correcto
- [ ] Revisar badges IA Activa / OCR Online en header
- [ ] Verificar responsividad mobile en todas las páginas (≤768px)
- [ ] Confirmar consistencia de colores modo claro y oscuro en todos los módulos
- [ ] Revisar que todos los PlutoGrid tengan bordes redondeados y sombra estándar
- [ ] Confirmar que todos los badges de estatus usan los colores semánticos correctos
- [ ] Verificar navegación completa: todas las rutas del sidebar funcionan
- [ ] Confirmar que **no existe ningún botón de salida** en el sidebar
- [ ] Animaciones sutiles con `flutter_animate` en KPI cards
- [ ] Revisar formato de datos: fechas en español, porcentajes con 2 decimales
- [ ] Verificar título del navegador: "MetaDocs — AI Document Intelligence Demo"
- [ ] Prueba de toggle tema claro ↔ oscuro en todas las páginas

---

## Resumen de Entregas

| Fase | Contenido | Estado |
|------|-----------|--------|
| 0 | Limpieza del ERP anterior | ⬜ |
| 1 | Cimientos: theme, modelos, mock data, router, provider | ⬜ |
| 2 | Shell: sidebar MetaDocs, header nuevo, navbar mobile | ⬜ |
| 3.1 | Dashboard documental | ⬜ |
| 3.2 | Biblioteca de Documentos | ⬜ |
| 3.3 | Ingesta / Carga | ⬜ |
| 3.4 | Explorador de Metadatos | ⬜ |
| 3.5 | Análisis con IA | ⬜ |
| 3.6 | Reportes e Insights | ⬜ |
| 3.7 | Integraciones | ⬜ |
| 3.8 | Configuración | ⬜ |
| 3.9 | Usuarios y Roles | ⬜ |
| 3.10 | Auditoría | ⬜ |
| 4.1 | Procesamiento (fase 2) | ⬜ |
| 4.2 | Consultas Inteligentes (fase 2) | ⬜ |
| 4.3 | Esquemas y Taxonomía (fase 2) | ⬜ |
| 5 | Polish y revisión final | ⬜ |

