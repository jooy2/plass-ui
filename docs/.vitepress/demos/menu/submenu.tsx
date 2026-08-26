import { PlButton, PlMenu, PlMenuItem, PlMenuSeparator, PlMenuSubmenu } from 'plass-ui';

export default function MenuSubmenus() {
  return (
    <PlMenu trigger={<PlButton variant="glass">Share</PlButton>}>
      <PlMenuItem>Copy link</PlMenuItem>
      <PlMenuSeparator />
      <PlMenuSubmenu label="Send to">
        <PlMenuItem>Email</PlMenuItem>
        <PlMenuItem>Message</PlMenuItem>
        <PlMenuSubmenu label="More">
          <PlMenuItem>Print</PlMenuItem>
          <PlMenuItem>Fax, apparently</PlMenuItem>
        </PlMenuSubmenu>
      </PlMenuSubmenu>
      <PlMenuSubmenu label="Export as">
        <PlMenuItem>PDF</PlMenuItem>
        <PlMenuItem>Markdown</PlMenuItem>
      </PlMenuSubmenu>
    </PlMenu>
  );
}
