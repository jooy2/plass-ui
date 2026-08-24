import { PlSelect } from 'plass-ui';

function GlobeIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" stroke="currentColor" strokeWidth="1.5" aria-hidden="true">
      <circle cx="8" cy="8" r="6" />
      <path d="M2 8h12M8 2c1.8 2 1.8 10 0 12M8 2C6.2 4 6.2 12 8 14" />
    </svg>
  );
}

const locales = [
  { value: 'en', label: 'English' },
  { value: 'ko', label: '한국어' },
  { value: 'pt-BR', label: 'Português (Brasil)' }
];

export default function SelectIcons() {
  return <PlSelect label="Language" startIcon={<GlobeIcon />} items={locales} defaultValue="en" />;
}
