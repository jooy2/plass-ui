import { PlAlert } from 'plass-ui';

export default function AlertShapes() {
  return (
    <div className="flex w-full max-w-lg flex-col gap-3">
      <PlAlert icon={false}>A bare line, for a note among form fields.</PlAlert>
      <PlAlert>A line with the severity glyph — the default.</PlAlert>
      <PlAlert title="A headline">And the detail under it, in the muted ink.</PlAlert>
    </div>
  );
}
