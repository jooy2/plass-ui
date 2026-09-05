import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

/// Six plates at four proportions, so a masonry has something to arrange.
final List<PlGalleryItem> photos = <PlGalleryItem>[
  PlGalleryItem(
    id: 'harbour',
    image: const NetworkImage('/gallery-1.svg'),
    semanticLabel: 'A harbour at dusk',
    title: 'Harbour',
    description: 'Busan',
    ratio: 4 / 3,
  ),
  PlGalleryItem(
    id: 'bridge',
    image: const NetworkImage('/gallery-2.svg'),
    semanticLabel: 'A bridge over a river',
    title: 'Bridge',
    description: 'Porto',
    ratio: 3 / 2,
  ),
  PlGalleryItem(
    id: 'hillside',
    image: const NetworkImage('/gallery-3.svg'),
    semanticLabel: 'A terraced hillside',
    title: 'Hillside',
    description: 'Banaue',
    ratio: 3 / 4,
  ),
  PlGalleryItem(
    id: 'market',
    image: const NetworkImage('/gallery-4.svg'),
    semanticLabel: 'A covered market',
    title: 'Market',
    description: 'Marrakesh',
    ratio: 1,
  ),
  PlGalleryItem(
    id: 'dunes',
    image: const NetworkImage('/gallery-5.svg'),
    semanticLabel: 'Dunes at first light',
    title: 'Dunes',
    description: 'Huacachina',
    ratio: 2,
  ),
  PlGalleryItem(
    id: 'terrace',
    image: const NetworkImage('/gallery-6.svg'),
    semanticLabel: 'A stepped terrace',
    title: 'Terrace',
    description: 'Lisbon',
    ratio: 2 / 3,
  ),
];
