import { PlAvatar, PlStack } from 'plass-ui';

const reviewers = [
  { name: 'Nadia Rowan', src: '/samples/avatars/nadia-rowan.webp' },
  { name: 'Theo Quinn', src: '/samples/avatars/theo-quinn.webp' },
  { name: 'Victor Saye', src: '/samples/avatars/victor-saye.webp' },
  { name: 'Anya Sol', src: '/samples/avatars/anya-sol.webp' },
  { name: 'Helen Voss', src: '/samples/avatars/helen-voss.webp' },
  { name: 'Noa Marin', src: '/samples/avatars/noa-marin.webp' }
];

export default function StackOverflow() {
  return (
    <div className="flex flex-col items-center gap-4">
      {[undefined, 3, 2].map((max, index) => (
        <PlStack
          key={index}
          ring
          max={max}
          total={9}
          overflow={(hidden) => <PlAvatar initials={`+${hidden}`} />}
        >
          {reviewers.map((reviewer) => (
            <PlAvatar key={reviewer.name} name={reviewer.name} src={reviewer.src} />
          ))}
        </PlStack>
      ))}
    </div>
  );
}
