import { TextField } from 'plass-ui';

function SearchIcon() {
  return (
    <svg viewBox="0 0 16 16" fill="none" stroke="currentColor" strokeWidth="1.6" aria-hidden="true">
      <circle cx="7" cy="7" r="4.5" />
      <path d="m10.5 10.5 3 3" strokeLinecap="round" />
    </svg>
  );
}

export default function TextFieldIcons() {
  return (
    <div className="grid w-full max-w-sm gap-4">
      <TextField startIcon={<SearchIcon />} placeholder="Search projects" />
      <TextField label="Domain" defaultValue="acme" endIcon={<span>.plass.dev</span>} />
      <TextField label="Checking availability" defaultValue="acme" loading />
    </div>
  );
}
