import 'package:flutter/widgets.dart';
import 'package:plass_ui/plass_ui.dart';

/// Six plates at four proportions, so a masonry has something to arrange.
final List<PlGalleryItem> photos = <PlGalleryItem>[
  PlGalleryItem(
    id: 'alpine-lake',
    image: const NetworkImage('/samples/photos/alpine-lake-dawn.webp'),
    semanticLabel: 'A still mountain lake at first light',
    title: 'Alpine lake',
    description: 'Dawn',
    ratio: 4 / 3,
  ),
  PlGalleryItem(
    id: 'coast-road',
    image: const NetworkImage('/samples/photos/bicycle-coastal-path.webp'),
    semanticLabel: 'A bicycle parked on a path above the sea',
    title: 'Coast road',
    description: 'Late summer',
    ratio: 3 / 2,
  ),
  PlGalleryItem(
    id: 'lighthouse',
    image: const NetworkImage('/samples/photos/lighthouse-cliff-wildflowers.webp'),
    semanticLabel: 'A lighthouse on a clifftop above wildflowers',
    title: 'Lighthouse',
    description: 'Wildflowers',
    ratio: 3 / 4,
  ),
  PlGalleryItem(
    id: 'citrus',
    image: const NetworkImage('/samples/photos/ceramic-bowl-citrus.webp'),
    semanticLabel: 'Oranges and lemons in a ceramic bowl',
    title: 'Citrus',
    description: 'Still life',
    ratio: 1,
  ),
  PlGalleryItem(
    id: 'tea-terraces',
    image: const NetworkImage('/samples/photos/misty-tea-terraces-sunrise.webp'),
    semanticLabel: 'Terraced tea fields under morning mist',
    title: 'Tea terraces',
    description: 'Sunrise',
    ratio: 2,
  ),
  PlGalleryItem(
    id: 'greenhouse',
    image: const NetworkImage('/samples/photos/greenhouse-fern-shadows.webp'),
    semanticLabel: 'Ferns throwing shadows across a greenhouse wall',
    title: 'Greenhouse',
    description: 'Ferns',
    ratio: 2 / 3,
  ),
];
