import { PlCarousel } from 'plass-ui';

const slides = [
  { name: 'Harbour', from: 'oklch(0.72 0.13 250)', to: 'oklch(0.78 0.11 200)' },
  { name: 'Dunes', from: 'oklch(0.80 0.12 75)', to: 'oklch(0.85 0.09 40)' },
  { name: 'Pines', from: 'oklch(0.68 0.12 155)', to: 'oklch(0.75 0.10 190)' }
];

export default function CarouselHero() {
  return (
    <PlCarousel className="w-full max-w-md" label="Places">
      {slides.map((slide) => (
        <div
          key={slide.name}
          className="flex h-40 items-end p-4 text-sm font-semibold text-white"
          style={{ backgroundImage: `linear-gradient(135deg, ${slide.from}, ${slide.to})` }}
        >
          {slide.name}
        </div>
      ))}
    </PlCarousel>
  );
}
