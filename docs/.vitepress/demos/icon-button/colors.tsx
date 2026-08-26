import { PlIconButton } from 'plass-ui';

const Star = () => (
  <svg viewBox="0 0 24 24" fill="currentColor">
    <path d="m12 3 2.6 5.6 6 .8-4.4 4.2 1.1 6.1L12 16.8 6.7 19.7l1.1-6.1L3.4 9.4l6-.8z" />
  </svg>
);

export default function IconButtonColors() {
  return (
    <div className="flex flex-wrap items-center gap-3">
      {(['primary', 'secondary', 'success', 'warning', 'danger', 'info'] as const).map((color) => (
        <PlIconButton key={color} color={color} icon={<Star />} label={color} />
      ))}
    </div>
  );
}
