/// French.
library;

import 'package:plass_ui/src/internal/date.dart';

/// The library's own vocabulary in French.
const PlassLabels fr = PlassLabels(
  close: 'Fermer',
  cancel: 'Annuler',
  confirm: 'Confirmer',
  acknowledge: 'OK',
  search: 'Rechercher',
  selectAll: 'Tout sélectionner',
  selectRow: 'Sélectionner la ligne',
  sortedAscending: 'Trié, du plus petit au plus grand',
  sortedDescending: 'Trié, du plus grand au plus petit',
  remove: 'Retirer',
  dismiss: 'Masquer',
  open: 'Ouvrir',
  previous: 'Précédent',
  next: 'Suivant',
  reveal: 'Afficher',
  hide: 'Masquer',
  increase: 'Augmenter',
  decrease: 'Diminuer',
  preview: 'Aperçu',
  empty: 'Rien ici',
  optional: 'Facultatif',
  breadcrumb: 'Fil d’Ariane',
  breadcrumbExpand: 'Afficher les étapes masquées',
  carousel: 'Carrousel',
  carouselPrevious: 'Diapositive précédente',
  carouselNext: 'Diapositive suivante',
  commandPalette: 'Palette de commandes',
  commandPalettePlaceholder: 'Rechercher une commande',
  gallery: 'Galerie',
  chart: 'Graphique',
  minimize: 'Réduire',
  maximize: 'Agrandir',
  restore: 'Restaurer',
  resizeWindow: 'Redimensionner la fenêtre',
  overlay: 'Voile',
  pagination: 'Pagination',
  paginationPrevious: 'Page précédente',
  paginationNext: 'Page suivante',
  paginationFirst: 'Première page',
  paginationLast: 'Dernière page',
  rating: 'Note',
  sidebar: 'Barre latérale',
  sidebarOpen: 'Ouvrir la barre latérale',
  sidebarClose: 'Fermer la barre latérale',
  sidebarResize: 'Redimensionner la barre latérale',
  skipToContent: 'Aller au contenu',
  backToTop: 'Revenir en haut',
  onThisPage: 'Sur cette page',
  typing: 'Écrit…',
  messageSending: 'Envoi en cours',
  messageSent: 'Envoyé',
  messageDelivered: 'Distribué',
  messageRead: 'Lu',
  messageFailed: 'Non distribué',
  spoilerWarning: 'Peut contenir des spoilers',
  filePickerTitle: 'Choisir des fichiers',
  newTab: '(s’ouvre ailleurs)',
  transferAvailable: 'Disponibles',
  transferSelected: 'Sélectionnés',
  transferToSelected: 'Déplacer vers les sélectionnés',
  transferToAvailable: 'Déplacer vers les disponibles',
  copy: 'Copier',
  copied: 'Copié',
  copyFailed: 'Copie impossible',
  raw: 'Brut',
  code: 'Code',
  previousMonth: 'Mois précédent',
  nextMonth: 'Mois suivant',
  previousYear: 'Année précédente',
  nextYear: 'Année suivante',
  previousYears: 'Années précédentes',
  nextYears: 'Années suivantes',
  chooseMonth: 'Choisir un mois',
  chooseYear: 'Choisir une année',
  today: 'Aujourd’hui',
  thisMonth: 'Ce mois-ci',
  thisYear: 'Cette année',
  now: 'Maintenant',
  clear: 'Effacer',
  done: 'Terminé',
  skip: 'Ignorer',
  hour: 'Heure',
  minute: 'Minute',
  second: 'Seconde',
  meridiem: 'AM/PM',
  start: 'Début',
  end: 'Fin',
  paginationPage: _paginationPage,
  ratingValue: _ratingValue,
  ratingNone: 'Aucune note',
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

String _paginationPage(int page) => 'Page $page';

String _ratingValue(num value, int count) => '${plassDecimal(value, ',')} sur $count';

String _carouselSlide(int index, int count) => 'Diapositive $index sur $count';

String _galleryItem(int index, int total) => '$index sur $total';

String _removeItem(String name) => 'Retirer $name';

String _addCustom(String query) => 'Ajouter « $query »';

String _howToStep(int step, int total) => 'Étape $step sur $total';

String _transferMoved(int count, String list) {
  return '$count ${count == 1 ? 'élément déplacé' : 'éléments déplacés'} vers « $list »';
}

String _filesRejectedType(int count) {
  return count == 1
      ? "1 fichier n'a pas un type accepté"
      : "$count fichiers n'ont pas un type accepté";
}

String _filesRejectedSize(int count) {
  return count == 1 ? '1 fichier est trop volumineux' : '$count fichiers sont trop volumineux';
}

String _filesRejectedCount(int count) {
  return "Il n'y avait plus de place pour $count ${count == 1 ? 'fichier' : 'fichiers'}";
}
