import { PlDivider } from 'plass-ui';

export default function DividerColors() {
  return (
    <div className="flex w-full max-w-md flex-col gap-5">
      <PlDivider>neutral</PlDivider>
      {(['primary', 'success', 'warning', 'danger'] as const).map((color) => (
        <PlDivider key={color} color={color}>
          {color}
        </PlDivider>
      ))}
    </div>
  );
}
