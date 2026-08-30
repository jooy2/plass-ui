import { PlDivider, PlFooter, PlTextLink } from 'plass-ui';

const columns = {
  Product: ['Overview', 'Pricing', 'Changelog'],
  Company: ['About', 'Careers', 'Contact'],
  Legal: ['Privacy', 'Terms']
};

export default function FooterHero() {
  return (
    <PlFooter className="w-full">
      <div className="flex flex-col gap-6">
        <div className="grid gap-6 sm:grid-cols-3">
          {Object.entries(columns).map(([heading, links]) => (
            <div key={heading} className="flex flex-col gap-2">
              <span className="text-xs font-semibold tracking-wide text-(--plass-muted-fg) uppercase">
                {heading}
              </span>
              {links.map((link) => (
                <PlTextLink key={link} href="#" underline="hover" className="text-sm">
                  {link}
                </PlTextLink>
              ))}
            </div>
          ))}
        </div>
        <PlDivider />
        <span className="text-xs text-(--plass-muted-fg)">© 2026 Acme. All rights reserved.</span>
      </div>
    </PlFooter>
  );
}
