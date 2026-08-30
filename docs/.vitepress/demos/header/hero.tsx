import { PlButton, PlHeader, PlTextLink } from 'plass-ui';

export default function HeaderHero() {
  return (
    <PlHeader
      className="w-full"
      position="static"
      brand={
        <>
          <span className="grid size-7 place-items-center rounded-(--plass-radius-sm) [background-image:var(--plass-primary-fill)] text-xs font-bold text-(--plass-primary-on-solid)">
            A
          </span>
          <span className="font-semibold">Acme</span>
        </>
      }
      actions={
        <>
          <PlButton size="sm" variant="ghost" color="secondary">
            Log in
          </PlButton>
          <PlButton size="sm">Sign up</PlButton>
        </>
      }
    >
      {['Product', 'Pricing', 'Docs'].map((item) => (
        <PlTextLink key={item} href="#" underline="hover" className="text-sm">
          {item}
        </PlTextLink>
      ))}
    </PlHeader>
  );
}
