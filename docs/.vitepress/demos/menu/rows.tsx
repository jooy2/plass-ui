import { PlButton, PlMenu, PlMenuItem, PlMenuSeparator } from 'plass-ui';

const Star = () => (
  <svg viewBox="0 0 16 16" fill="currentColor">
    <path d="m8 1.6 1.86 3.9 4.14.56-3.02 2.9.76 4.24L8 11.16 4.26 13.2l.76-4.24L2 6.06l4.14-.56z" />
  </svg>
);

export default function MenuRows() {
  return (
    <PlMenu trigger={<PlButton variant="glass">Rows</PlButton>}>
      <PlMenuItem startIcon={<Star />} shortcut="⌘D">
        With an icon
      </PlMenuItem>
      <PlMenuItem description="A second line, one step down and muted">
        With a description
      </PlMenuItem>
      <PlMenuItem href="https://plass.cdget.com" target="_blank">
        A real link
      </PlMenuItem>
      <PlMenuItem disabled>Unavailable</PlMenuItem>
      <PlMenuSeparator />
      <PlMenuItem color="danger">Delete everything</PlMenuItem>
    </PlMenu>
  );
}
