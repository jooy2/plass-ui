import { PlAnimateMarquee, PlChip } from 'plass-ui';

const names = [
  'Northwind',
  'Contoso',
  'Fabrikam',
  'Tailspin',
  'Adventure Works',
  'Wide World',
  'Proseware'
];

export default function AnimateMarqueeHero() {
  return (
    <PlAnimateMarquee className="w-full max-w-lg" gap="1.5rem" speed={45}>
      {names.map((name) => (
        <PlChip key={name} variant="glass" color="secondary">
          {name}
        </PlChip>
      ))}
    </PlAnimateMarquee>
  );
}
