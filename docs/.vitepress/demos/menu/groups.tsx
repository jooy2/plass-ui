import { PlButton, PlMenu, PlMenuGroup, PlMenuItem, PlMenuSeparator } from 'plass-ui';

export default function MenuGroups() {
  return (
    <PlMenu trigger={<PlButton variant="glass">Grouped</PlButton>}>
      <PlMenuGroup label="Edit">
        <PlMenuItem shortcut="⌘X">Cut</PlMenuItem>
        <PlMenuItem shortcut="⌘C">Copy</PlMenuItem>
      </PlMenuGroup>
      <PlMenuSeparator />
      <PlMenuGroup label="Document">
        <PlMenuItem shortcut="⌘S">Save</PlMenuItem>
        <PlMenuItem shortcut="⌘P">Print</PlMenuItem>
      </PlMenuGroup>
    </PlMenu>
  );
}
