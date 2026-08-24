import { PlBlockquote } from 'plass-ui';

export default function BlockquoteAttribution() {
  return (
    <div className="flex w-full max-w-lg flex-col gap-5">
      <PlBlockquote>Nobody is credited, so this is a plain div.</PlBlockquote>

      <PlBlockquote author="Ada Lovelace">A person said it.</PlBlockquote>

      <PlBlockquote source="Notes on the Analytical Engine">A work it came from.</PlBlockquote>

      <PlBlockquote
        author="Ada Lovelace"
        source="Notes on the Analytical Engine"
        cite="https://example.com/notes"
      >
        Both, plus the machine-readable URL nobody sees.
      </PlBlockquote>
    </div>
  );
}
