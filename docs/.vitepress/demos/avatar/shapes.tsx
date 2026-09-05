import { PlAvatar } from 'plass-ui';

export default function AvatarShapes() {
  return (
    <div className="flex flex-wrap items-center gap-4">
      <PlAvatar size="lg" name="Theo Quinn" src="/samples/avatars/theo-quinn.webp" />
      <PlAvatar size="lg" shape="square" name="Theo Quinn" src="/samples/avatars/theo-quinn.webp" />
    </div>
  );
}
