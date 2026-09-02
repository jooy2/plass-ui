import { PlAvatar, PlStack } from 'plass-ui';

const reviewers = ['Ada Lovelace', 'Grace Hopper', 'Katherine Johnson', 'Alan Turing'];

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
          {reviewers.map((name) => (
            <PlAvatar key={name} name={name} />
          ))}
        </PlStack>
      ))}
    </div>
  );
}
