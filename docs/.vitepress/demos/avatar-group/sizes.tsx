import { PlAvatar, PlAvatarGroup, type PlassSize } from 'plass-ui';

const people = ['Ada Lovelace', 'Grace Hopper', 'Katherine Johnson'];

export default function AvatarGroupSizes() {
  return (
    <div className="flex flex-col gap-4">
      {(['xs', 'sm', 'md', 'lg', 'xl'] as PlassSize[]).map((size) => (
        <PlAvatarGroup key={size} size={size}>
          {people.map((name) => (
            <PlAvatar key={name} name={name} />
          ))}
        </PlAvatarGroup>
      ))}
    </div>
  );
}
