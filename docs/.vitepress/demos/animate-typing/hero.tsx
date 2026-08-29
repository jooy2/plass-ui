import { PlAnimateTyping, PlTypography } from 'plass-ui';

export default function AnimateTypingHero() {
  return (
    <div className="flex flex-col items-center gap-2 text-center">
      <PlTypography level="overline">Terminal</PlTypography>

      <PlAnimateTyping
        className="font-mono text-base text-(--plass-primary-accent)"
        text="npm install plass-ui"
        speed={14}
        hold={1600}
        erase
        repeat="infinite"
      />
    </div>
  );
}
