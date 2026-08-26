import { PlContainer, PlCard, PlTypography } from 'plass-ui';

export default function ContainerHero() {
  return (
    <div className="w-full rounded-(--plass-radius-lg) bg-(--plass-glass-press) py-4">
      <PlContainer maxWidth="sm">
        <PlCard title="Inside the measure">
          <PlTypography level="body">
            The container is the gutter down each side and the width the content stops at. It draws
            nothing itself — the sheet you can see is this card.
          </PlTypography>
        </PlCard>
      </PlContainer>
    </div>
  );
}
