import { PlNavigationMenu, PlNavigationMenuItem, PlNavigationMenuLink } from 'plass-ui';

export default function NavigationMenuHero() {
  return (
    <PlNavigationMenu>
      <PlNavigationMenuItem label="Product" columns={2}>
        <PlNavigationMenuLink href="#" title="Analytics" description="Numbers over time" />
        <PlNavigationMenuLink href="#" title="Billing" description="Invoices and plans" />
        <PlNavigationMenuLink href="#" title="Audit log" description="Who did what, when" />
        <PlNavigationMenuLink href="#" title="Integrations" description="Everything else" />
      </PlNavigationMenuItem>

      <PlNavigationMenuItem label="Developers">
        <PlNavigationMenuLink href="#" title="Documentation" description="Guides and reference" />
        <PlNavigationMenuLink href="#" title="API" description="The REST surface" />
      </PlNavigationMenuItem>

      <PlNavigationMenuItem label="Pricing" href="#" />
    </PlNavigationMenu>
  );
}
