import { PlAppLogo, PlButton, PlHeader, PlTextLink } from 'plass-ui';

export default function HeaderHero() {
  return (
    <PlHeader
      className="w-full"
      position="static"
      brand={
        <PlAppLogo
          size="sm"
          name="Acme"
          src="/samples/marks/lantern.webp"
          render={<a href="#" />}
        />
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
