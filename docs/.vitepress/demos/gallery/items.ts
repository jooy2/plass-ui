import type { PlGalleryItem } from 'plass-ui';

/** Six plates at four proportions, so a masonry has something to arrange. */
export const photos: PlGalleryItem[] = [
  {
    src: '/samples/photos/alpine-lake-dawn.webp',
    alt: 'A still mountain lake at first light',
    title: 'Alpine lake',
    description: 'Dawn',
    ratio: 4 / 3
  },
  {
    src: '/samples/photos/bicycle-coastal-path.webp',
    alt: 'A bicycle parked on a path above the sea',
    title: 'Coast road',
    description: 'Late summer',
    ratio: 3 / 2
  },
  {
    src: '/samples/photos/lighthouse-cliff-wildflowers.webp',
    alt: 'A lighthouse on a clifftop above wildflowers',
    title: 'Lighthouse',
    description: 'Wildflowers',
    ratio: 3 / 4
  },
  {
    src: '/samples/photos/ceramic-bowl-citrus.webp',
    alt: 'Oranges and lemons in a ceramic bowl',
    title: 'Citrus',
    description: 'Still life',
    ratio: 1
  },
  {
    src: '/samples/photos/misty-tea-terraces-sunrise.webp',
    alt: 'Terraced tea fields under morning mist',
    title: 'Tea terraces',
    description: 'Sunrise',
    ratio: 2
  },
  {
    src: '/samples/photos/greenhouse-fern-shadows.webp',
    alt: 'Ferns throwing shadows across a greenhouse wall',
    title: 'Greenhouse',
    description: 'Ferns',
    ratio: 2 / 3
  }
];
