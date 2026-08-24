import { PlHighlight } from 'plass-ui';

export default function HighlightColors() {
  return (
    <div className="flex w-full max-w-lg flex-col gap-2 text-sm/7 text-(--plass-fg)">
      {(['warning', 'primary', 'success', 'danger', 'info'] as const).map((color) => (
        <p key={color}>
          <PlHighlight color={color} query={color}>
            The family is {color} here.
          </PlHighlight>
        </p>
      ))}
    </div>
  );
}
