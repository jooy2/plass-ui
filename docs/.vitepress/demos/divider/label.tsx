import { PlDivider } from 'plass-ui';

export default function DividerLabel() {
  return (
    <div className="flex w-full max-w-md flex-col gap-6">
      {(['start', 'center', 'end'] as const).map((textAlign) => (
        <PlDivider key={textAlign} textAlign={textAlign}>
          {textAlign}
        </PlDivider>
      ))}
    </div>
  );
}
