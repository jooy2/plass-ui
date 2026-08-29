import { PlAnimateSlide, PlBox } from 'plass-ui';

export default function AnimateSlideDistance() {
  return (
    <div className="flex w-full max-w-sm flex-col gap-3 overflow-hidden">
      <PlAnimateSlide from="left" distance="100%" duration={1400} repeat="infinite" alternate>
        <PlBox size="sm">100% — its own width, so it starts out of frame</PlBox>
      </PlAnimateSlide>

      <PlAnimateSlide from="left" distance={16} duration={1400} repeat="infinite" alternate>
        <PlBox size="sm">16px — a nudge rather than an entrance</PlBox>
      </PlAnimateSlide>
    </div>
  );
}
