import { PlCarousel } from 'plass-ui';

const notices = ['Free delivery over $40', 'Returns within 30 days', 'Members get early access'];

export default function CarouselAutoPlay() {
  return (
    <PlCarousel className="w-full max-w-md" label="Notices" autoPlay interval={2500} arrows={false}>
      {notices.map((notice) => (
        <div
          key={notice}
          className="flex h-16 items-center justify-center bg-(--plass-info-soft) text-sm"
        >
          {notice}
        </div>
      ))}
    </PlCarousel>
  );
}
