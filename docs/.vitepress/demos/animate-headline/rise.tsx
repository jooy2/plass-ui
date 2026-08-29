import { PlAnimateHeadline, PlChip } from 'plass-ui';

const names = ['Northwind', 'Contoso', 'Fabrikam'];

export default function AnimateHeadlineRise() {
  return (
    <div className="flex flex-wrap items-center justify-center gap-10">
      {[
        { label: 'rise 100%', rise: '100%' },
        { label: 'rise 8px', rise: 8 }
      ].map((option) => (
        <PlAnimateHeadline key={option.label} rise={option.rise} interval={1600}>
          {names.map((name) => (
            <PlChip key={name}>{name}</PlChip>
          ))}
        </PlAnimateHeadline>
      ))}
    </div>
  );
}
