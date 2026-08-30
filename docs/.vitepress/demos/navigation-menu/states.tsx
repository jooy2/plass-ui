import { PlNavigationMenu, PlNavigationMenuItem, PlNavigationMenuLink } from 'plass-ui';

export default function NavigationMenuStates() {
  return (
    <PlNavigationMenu>
      <PlNavigationMenuItem label="A destination" href="#" />
      <PlNavigationMenuItem label="A panel">
        <PlNavigationMenuLink href="#" title="Somewhere" />
      </PlNavigationMenuItem>
      <PlNavigationMenuItem label="Unavailable" disabled>
        <PlNavigationMenuLink href="#" title="Nowhere" />
      </PlNavigationMenuItem>
      <PlNavigationMenuItem label="Status page" href="https://example.com" target="_blank" />
    </PlNavigationMenu>
  );
}
