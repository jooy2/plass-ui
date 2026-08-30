import { PlNavigationMenu, PlNavigationMenuItem, PlNavigationMenuLink } from 'plass-ui';

export default function NavigationMenuOrientation() {
  return (
    <div className="w-48">
      <PlNavigationMenu orientation="vertical" size="sm">
        <PlNavigationMenuItem label="Overview" href="#" />
        <PlNavigationMenuItem label="Reports">
          <PlNavigationMenuLink href="#" title="Usage" />
          <PlNavigationMenuLink href="#" title="Revenue" />
        </PlNavigationMenuItem>
        <PlNavigationMenuItem label="Settings" href="#" />
      </PlNavigationMenu>
    </div>
  );
}
