import { PlAvatar, PlAvatarGroup } from 'plass-ui';

const people = ['Ada Lovelace', 'Grace Hopper', 'Katherine Johnson'];

export default function AvatarGroupOverlap() {
  return (
    <div className="flex flex-col gap-4">
      {[undefined, 0, '1.5rem'].map((overlap, index) => (
        <PlAvatarGroup key={index} overlap={overlap}>
          {people.map((name) => (
            <PlAvatar key={name} name={name} />
          ))}
        </PlAvatarGroup>
      ))}
    </div>
  );
}
