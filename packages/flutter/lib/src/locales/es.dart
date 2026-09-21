/// Spanish.
library;

import 'package:plass_ui/src/internal/date.dart';

/// The library's own vocabulary in Spanish.
const PlassLabels es = PlassLabels(
  close: 'Cerrar',
  cancel: 'Cancelar',
  confirm: 'Confirmar',
  acknowledge: 'Aceptar',
  search: 'Buscar',
  selectAll: 'Seleccionar todo',
  selectRow: 'Seleccionar fila',
  sortedAscending: 'Ordenado, menor primero',
  sortedDescending: 'Ordenado, mayor primero',
  remove: 'Quitar',
  dismiss: 'Descartar',
  open: 'Abrir',
  previous: 'Anterior',
  next: 'Siguiente',
  reveal: 'Mostrar',
  hide: 'Ocultar',
  increase: 'Aumentar',
  decrease: 'Disminuir',
  preview: 'Vista previa',
  empty: 'No hay nada aquí',
  optional: 'Opcional',
  breadcrumb: 'Ruta de navegación',
  breadcrumbExpand: 'Mostrar los pasos ocultos',
  carousel: 'Carrusel',
  carouselPrevious: 'Diapositiva anterior',
  carouselNext: 'Diapositiva siguiente',
  commandPalette: 'Paleta de comandos',
  commandPalettePlaceholder: 'Buscar comandos',
  gallery: 'Galería',
  chart: 'Gráfico',
  chartOther: 'Otros',
  chartMore: _chartMore,
  chartFewer: 'Mostrar menos',
  minimize: 'Minimizar',
  maximize: 'Maximizar',
  restore: 'Restaurar',
  resizeWindow: 'Redimensionar la ventana',
  overlay: 'Capa',
  pagination: 'Paginación',
  paginationPrevious: 'Página anterior',
  paginationNext: 'Página siguiente',
  paginationFirst: 'Primera página',
  paginationLast: 'Última página',
  rating: 'Valoración',
  sidebar: 'Barra lateral',
  sidebarOpen: 'Abrir la barra lateral',
  sidebarClose: 'Cerrar la barra lateral',
  sidebarResize: 'Redimensionar la barra lateral',
  skipToContent: 'Saltar al contenido',
  backToTop: 'Volver arriba',
  onThisPage: 'En esta página',
  typing: 'Escribiendo…',
  messageSending: 'Enviando',
  messageSent: 'Enviado',
  messageDelivered: 'Entregado',
  messageRead: 'Leído',
  messageFailed: 'No entregado',
  spoilerWarning: 'Puede contener spoilers',
  filePickerTitle: 'Elegir archivos',
  newTab: '(se abre en otro sitio)',
  transferAvailable: 'Disponibles',
  transferSelected: 'Seleccionados',
  transferToSelected: 'Mover a seleccionados',
  transferToAvailable: 'Mover a disponibles',
  copy: 'Copiar',
  copied: 'Copiado',
  copyFailed: 'No se pudo copiar',
  raw: 'Sin formato',
  code: 'Código',
  previousMonth: 'Mes anterior',
  nextMonth: 'Mes siguiente',
  previousYear: 'Año anterior',
  nextYear: 'Año siguiente',
  previousYears: 'Años anteriores',
  nextYears: 'Años siguientes',
  chooseMonth: 'Elegir un mes',
  chooseYear: 'Elegir un año',
  today: 'Hoy',
  thisMonth: 'Este mes',
  thisYear: 'Este año',
  now: 'Ahora',
  clear: 'Borrar',
  done: 'Hecho',
  skip: 'Omitir',
  hour: 'Hora',
  minute: 'Minuto',
  second: 'Segundo',
  meridiem: 'a. m./p. m.',
  start: 'Inicio',
  end: 'Fin',
  paginationPage: _paginationPage,
  ratingValue: _ratingValue,
  ratingNone: 'Sin valoración',
  carouselSlide: _carouselSlide,
  galleryItem: _galleryItem,
  removeItem: _removeItem,
  addCustom: _addCustom,
  howToStep: _howToStep,
  transferMoved: _transferMoved,
  filesRejectedType: _filesRejectedType,
  filesRejectedSize: _filesRejectedSize,
  filesRejectedCount: _filesRejectedCount,
);

String _paginationPage(int page) => 'Página $page';

String _ratingValue(num value, int count) => '${plassDecimal(value, ',')} de $count';

String _carouselSlide(int index, int count) => 'Diapositiva $index de $count';

String _galleryItem(int index, int total) => '$index de $total';

String _removeItem(String name) => 'Quitar $name';

String _addCustom(String query) => 'Añadir «$query»';

String _howToStep(int step, int total) => 'Paso $step de $total';

String _transferMoved(int count, String list) {
  return '$count ${count == 1 ? 'elemento movido' : 'elementos movidos'} a «$list»';
}

String _filesRejectedType(int count) {
  return '$count ${count == 1 ? 'archivo no tiene' : 'archivos no tienen'} un tipo admitido';
}

String _filesRejectedSize(int count) {
  return count == 1 ? '1 archivo es demasiado grande' : '$count archivos son demasiado grandes';
}

String _filesRejectedCount(int count) {
  return 'No había sitio para $count ${count == 1 ? 'archivo' : 'archivos'}';
}

String _chartMore(int count) => '$count más';
