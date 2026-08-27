import { PlButton, PlPopover } from 'plass-ui';

export default function PopoverSides() {
  return (
    <div className="grid grid-cols-2 gap-3">
      {(['top', 'right', 'bottom', 'left'] as const).map((side) => (
        <PlPopover
          key={side}
          side={side}
          arrow
          trigger={<PlButton variant="glass">{side}</PlButton>}
          title={`side="${side}"`}
        >
          It flips to the opposite side when there is no room.
        </PlPopover>
      ))}
    </div>
  );
}
