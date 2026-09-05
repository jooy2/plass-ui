import { PlAnimateMarquee, PlAppLogo } from 'plass-ui';

/** The row of customer logos a marquee is nearly always asked for. */
const brands = [
  { name: 'Lanterna', mark: '/samples/marks/lantern.webp' },
  { name: 'Northpin', mark: '/samples/marks/compass.webp' },
  { name: 'Kitewind', mark: '/samples/marks/kite.webp' },
  { name: 'Layerloom', mark: '/samples/marks/layers.webp' },
  { name: 'Sunmeadow', mark: '/samples/marks/solar.webp' },
  { name: 'Farglass', mark: '/samples/marks/telescope.webp' }
];

export default function AnimateMarqueeHero() {
  return (
    <PlAnimateMarquee className="w-full max-w-lg" gap="2.5rem" speed={45}>
      {brands.map((brand) => (
        <PlAppLogo key={brand.name} size="sm" name={brand.name} src={brand.mark} />
      ))}
    </PlAnimateMarquee>
  );
}
