import { useState } from 'react';
import { PlChip } from 'plass-ui';

export default function ChipHero() {
  const [tags, setTags] = useState(['design', 'research', 'infra']);
  const [filter, setFilter] = useState('open');

  return (
    <div className="flex w-full max-w-lg flex-col gap-4">
      <div className="flex flex-wrap items-center gap-2">
        {(['open', 'closed'] as const).map((value) => (
          <PlChip
            key={value}
            selected={filter === value}
            onClick={() => setFilter(value)}
            count={value === 'open' ? 12 : 148}
          >
            {value}
          </PlChip>
        ))}
      </div>

      <div className="flex flex-wrap items-center gap-2">
        {tags.map((tag) => (
          <PlChip
            key={tag}
            variant="ghost"
            color="secondary"
            onDelete={() => setTags(tags.filter((one) => one !== tag))}
          >
            {tag}
          </PlChip>
        ))}
      </div>
    </div>
  );
}
