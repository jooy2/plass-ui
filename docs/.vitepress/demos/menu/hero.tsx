import { PlButton, PlMenu, PlMenuItem, PlMenuSeparator } from 'plass-ui';

export default function MenuHero() {
  return (
    <PlMenu trigger={<PlButton variant="glass">Actions</PlButton>}>
      <PlMenuItem shortcut="⌘X">Cut</PlMenuItem>
      <PlMenuItem shortcut="⌘C">Copy</PlMenuItem>
      <PlMenuItem shortcut="⌘V">Paste</PlMenuItem>
      <PlMenuSeparator />
      <PlMenuItem color="danger" shortcut="⌫">
        Delete
      </PlMenuItem>
    </PlMenu>
  );
}
