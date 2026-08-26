import { useState } from 'react';
import { PlRating } from 'plass-ui';

export default function RatingHero() {
  const [score, setScore] = useState(4);

  return (
    <div className="flex flex-col items-center gap-3">
      <PlRating size="lg" value={score} onValueChange={setScore} />
      <span className="text-sm text-(--plass-muted-fg)">{score} out of 5</span>
    </div>
  );
}
