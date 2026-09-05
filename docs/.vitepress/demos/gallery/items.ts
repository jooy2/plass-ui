import type { PlGalleryItem } from 'plass-ui';

/** Six plates at four proportions, so a masonry has something to arrange. */
export const photos: PlGalleryItem[] = [
  {
    src: '/gallery-1.svg',
    alt: 'A harbour at dusk',
    title: 'Harbour',
    description: 'Busan',
    ratio: 4 / 3
  },
  {
    src: '/gallery-2.svg',
    alt: 'A bridge over a river',
    title: 'Bridge',
    description: 'Porto',
    ratio: 3 / 2
  },
  {
    src: '/gallery-3.svg',
    alt: 'A terraced hillside',
    title: 'Hillside',
    description: 'Banaue',
    ratio: 3 / 4
  },
  {
    src: '/gallery-4.svg',
    alt: 'A covered market',
    title: 'Market',
    description: 'Marrakesh',
    ratio: 1
  },
  {
    src: '/gallery-5.svg',
    alt: 'Dunes at first light',
    title: 'Dunes',
    description: 'Huacachina',
    ratio: 2
  },
  {
    src: '/gallery-6.svg',
    alt: 'A stepped terrace',
    title: 'Terrace',
    description: 'Lisbon',
    ratio: 2 / 3
  }
];
