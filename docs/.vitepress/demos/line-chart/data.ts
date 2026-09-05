import type { PlassChartSeries } from 'plass-ui';

/** Twelve months, so a stride on the category axis has something to do. */
export const months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec'
];

export const revenue: PlassChartSeries[] = [
  {
    name: 'Europe',
    data: [42, 45, 51, 49, 58, 63, 61, 68, 72, 70, 78, 84]
  },
  {
    name: 'Asia',
    data: [28, 31, 30, 36, 39, 42, 48, 47, 53, 58, 61, 66]
  },
  {
    name: 'Americas',
    data: [19, 22, 24, 23, 27, 26, 31, 34, 33, 38, 41, 44]
  }
];
