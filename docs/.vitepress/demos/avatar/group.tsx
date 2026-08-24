import { PlAvatar } from 'plass-ui';

/** A stack is a layout, not a component — a negative margin and a ring. */
export default function AvatarGroup() {
  const people = ['Ada Lovelace', 'Grace Hopper', 'Alan Turing', 'Jane Doe'];

  return (
    <div className="flex items-center">
      {people.map((name, index) => (
        <PlAvatar
          key={name}
          name={name}
          variant="glass"
          className={index === 0 ? '' : '-ms-3 ring-2 ring-(--plass-surface)'}
        />
      ))}
      <PlAvatar
        variant="ghost"
        color="secondary"
        initials="+7"
        className="-ms-3 ring-2 ring-(--plass-surface)"
      />
    </div>
  );
}
