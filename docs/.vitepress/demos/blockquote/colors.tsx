import { PlBlockquote } from 'plass-ui';

export default function BlockquoteColors() {
  return (
    <div className="flex w-full max-w-lg flex-col gap-4">
      {(['primary', 'success', 'warning', 'danger'] as const).map((color) => (
        <PlBlockquote key={color} color={color} icon={false}>
          The family reaches the rule and stops there.
        </PlBlockquote>
      ))}
    </div>
  );
}
