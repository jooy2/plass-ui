import { PlAvatar, PlAvatarGroup } from 'plass-ui';

const people = ['Ada Lovelace', 'Grace Hopper', 'Katherine Johnson', 'Alan Turing', 'Jane Doe'];

export default function AvatarGroupMax() {
  return (
    <div className="flex flex-col gap-4">
      <PlAvatarGroup>
        {people.map((name) => (
          <PlAvatar key={name} name={name} />
        ))}
      </PlAvatarGroup>

      <PlAvatarGroup max={3}>
        {people.map((name) => (
          <PlAvatar key={name} name={name} />
        ))}
      </PlAvatarGroup>

      <PlAvatarGroup max={3} total={128}>
        {people.slice(0, 3).map((name) => (
          <PlAvatar key={name} name={name} />
        ))}
      </PlAvatarGroup>
    </div>
  );
}
