import { PlAvatar, PlStack } from 'plass-ui';

export default function StackHero() {
  return (
    <PlStack ring max={4} total={11} overflow={(hidden) => <PlAvatar initials={`+${hidden}`} />}>
      <PlAvatar size="lg" name="Nadia Rowan" src="/samples/avatars/nadia-rowan.webp" />
      <PlAvatar size="lg" name="Theo Quinn" src="/samples/avatars/theo-quinn.webp" />
      <PlAvatar size="lg" name="Victor Saye" src="/samples/avatars/victor-saye.webp" />
      <PlAvatar size="lg" name="Noa Marin" src="/samples/avatars/noa-marin.webp" />
      <PlAvatar size="lg" name="홍길동" />
    </PlStack>
  );
}
