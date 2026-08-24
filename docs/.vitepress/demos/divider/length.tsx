import { PlDivider } from 'plass-ui';

export default function DividerLength() {
  return (
    <div className="flex w-full max-w-md flex-col gap-6">
      <PlDivider />
      <PlDivider length={160} />
      <PlDivider length="50%" thickness={2} />
      <PlDivider thickness="0.25rem" />
    </div>
  );
}
