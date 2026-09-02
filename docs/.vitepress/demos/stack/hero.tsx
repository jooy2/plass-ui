import { PlAvatar, PlStack } from 'plass-ui';

export default function StackHero() {
  return (
    <PlStack ring max={4} total={11} overflow={(hidden) => <PlAvatar initials={`+${hidden}`} />}>
      <PlAvatar size="lg" name="Ada Lovelace" src="/portrait-1.svg" />
      <PlAvatar size="lg" name="Grace Hopper" src="/portrait-2.svg" />
      <PlAvatar size="lg" name="Katherine Johnson" />
      <PlAvatar size="lg" name="홍길동" />
      <PlAvatar size="lg" name="Alan Turing" />
    </PlStack>
  );
}
