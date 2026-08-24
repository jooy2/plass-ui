import { PlButton, PlCard } from 'plass-ui';

export default function CardDividers() {
  return (
    <div className="grid w-full gap-4 sm:grid-cols-2">
      <PlCard size="sm" title="Spaced" footer={<PlButton size="xs">Save</PlButton>}>
        The sections are told apart by a gap.
      </PlCard>

      <PlCard size="sm" dividers title="Scored" footer={<PlButton size="xs">Save</PlButton>}>
        The rules run the full width of the sheet.
      </PlCard>
    </div>
  );
}
