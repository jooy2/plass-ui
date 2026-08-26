import { PlRating } from 'plass-ui';

const HeartFilled = () => (
  <svg viewBox="0 0 16 16" fill="currentColor">
    <path d="M8 13.7 1.9 8.1a3.4 3.4 0 0 1 4.8-4.8L8 4.6l1.3-1.3a3.4 3.4 0 1 1 4.8 4.8Z" />
  </svg>
);

const HeartOutline = () => (
  <svg viewBox="0 0 16 16" fill="none" stroke="currentColor" strokeWidth="1.3">
    <path d="M8 13.7 1.9 8.1a3.4 3.4 0 0 1 4.8-4.8L8 4.6l1.3-1.3a3.4 3.4 0 1 1 4.8 4.8Z" />
  </svg>
);

export default function RatingIcons() {
  return (
    <PlRating color="danger" defaultValue={3} icon={<HeartFilled />} emptyIcon={<HeartOutline />} />
  );
}
