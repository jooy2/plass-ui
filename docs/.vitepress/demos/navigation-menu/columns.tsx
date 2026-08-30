import { PlNavigationMenu, PlNavigationMenuItem, PlNavigationMenuLink } from 'plass-ui';

export default function NavigationMenuColumns() {
  return (
    <PlNavigationMenu>
      <PlNavigationMenuItem label="One column">
        <PlNavigationMenuLink href="#" title="Overview" />
        <PlNavigationMenuLink href="#" title="Changelog" />
      </PlNavigationMenuItem>

      <PlNavigationMenuItem label="Three columns" columns={3}>
        {['Analytics', 'Billing', 'Audit log', 'Integrations', 'Webhooks', 'Exports'].map(
          (title) => (
            <PlNavigationMenuLink key={title} href="#" title={title} />
          )
        )}
      </PlNavigationMenuItem>
    </PlNavigationMenu>
  );
}
