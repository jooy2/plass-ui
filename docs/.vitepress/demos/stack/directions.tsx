import { PlChip, PlStack } from 'plass-ui';

const directions = ['horizontal', 'vertical', 'diagonal'] as const;

export default function StackDirections() {
  return (
    <div className="flex flex-wrap items-start justify-center gap-10">
      {directions.map((direction) => (
        <PlStack key={direction} direction={direction} overlap={14}>
          {['One', 'Two', 'Three'].map((label) => (
            <PlChip key={label} variant="solid" color="secondary">
              {label}
            </PlChip>
          ))}
        </PlStack>
      ))}
    </div>
  );
}
