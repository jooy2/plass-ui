import { PlIconButton } from 'plass-ui';

const Heart = () => (
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
    <path d="M12 20s-7-4.5-7-9a4 4 0 0 1 7-2.6A4 4 0 0 1 19 11c0 4.5-7 9-7 9Z" />
  </svg>
);

const Share = () => (
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
    <path d="M4 12v7a1 1 0 0 0 1 1h14a1 1 0 0 0 1-1v-7M12 3v13M8 7l4-4 4 4" />
  </svg>
);

const Trash = () => (
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
    <path d="M4 7h16M9 7V4h6v3M6 7l1 13h10l1-13M10 11v6M14 11v6" />
  </svg>
);

const More = () => (
  <svg viewBox="0 0 24 24" fill="currentColor">
    <circle cx="5" cy="12" r="1.6" />
    <circle cx="12" cy="12" r="1.6" />
    <circle cx="19" cy="12" r="1.6" />
  </svg>
);

export default function IconButtonHero() {
  return (
    <div className="flex flex-wrap items-center gap-3">
      <PlIconButton icon={<Heart />} label="Like" />
      <PlIconButton icon={<Share />} label="Share" variant="glass" />
      <PlIconButton icon={<More />} label="More" variant="ghost" color="secondary" />
      <PlIconButton icon={<Trash />} label="Delete" variant="glass" color="danger" />
    </div>
  );
}
