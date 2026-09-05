import { PlCarousel } from 'plass-ui';

const slides = [
  {
    name: 'Alpine lake',
    src: '/samples/photos/alpine-lake-dawn.webp',
    alt: 'A still mountain lake at first light'
  },
  {
    name: 'Tea terraces',
    src: '/samples/photos/misty-tea-terraces-sunrise.webp',
    alt: 'Terraced tea fields under morning mist'
  },
  {
    name: 'Forest trail',
    src: '/samples/photos/forest-trail-sunbeams.webp',
    alt: 'Sunbeams across a forest trail'
  }
];

export default function CarouselHero() {
  return (
    <PlCarousel className="w-full max-w-md" label="Places">
      {slides.map((slide) => (
        <figure key={slide.name} className="relative m-0 h-40">
          <img src={slide.src} alt={slide.alt} className="size-full object-cover" />
          <figcaption className="absolute inset-x-0 bottom-0 bg-linear-to-t from-black/60 to-transparent p-4 text-sm font-semibold text-white">
            {slide.name}
          </figcaption>
        </figure>
      ))}
    </PlCarousel>
  );
}
