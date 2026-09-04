import { PlAnimateScramble } from 'plass-ui';

export default function AnimateScrambleHero() {
  return (
    <div className="flex w-full max-w-md flex-col gap-3">
      <PlAnimateScramble className="text-2xl font-semibold" trigger="mount">
        Ship it on Friday
      </PlAnimateScramble>

      <PlAnimateScramble className="text-lg text-(--plass-muted-fg)" trigger="mount">
        금요일에 배포합니다
      </PlAnimateScramble>
    </div>
  );
}
