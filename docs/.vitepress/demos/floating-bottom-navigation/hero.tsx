import { useState } from 'react';
import { PlFloatingBottomNavigation, PlFloatingBottomNavigationItem } from 'plass-ui';
import { AccountGlyph, HomeGlyph, SavedGlyph, SearchGlyph } from '../bottom-navigation/glyphs';

export default function FloatingBottomNavigationHero() {
  const [where, setWhere] = useState<string | number>('home');

  return (
    <div className="w-full max-w-sm overflow-hidden rounded-(--plass-radius-lg) bg-(--plass-glass-press)">
      <div className="p-6 text-sm text-(--plass-muted-fg)">The page the bar is floating over.</div>
      <PlFloatingBottomNavigation
        position="static"
        safeArea={false}
        value={where}
        onValueChange={setWhere}
        label="Main"
      >
        <PlFloatingBottomNavigationItem value="home" icon={<HomeGlyph />}>
          Home
        </PlFloatingBottomNavigationItem>
        <PlFloatingBottomNavigationItem value="search" icon={<SearchGlyph />}>
          Search
        </PlFloatingBottomNavigationItem>
        <PlFloatingBottomNavigationItem value="saved" icon={<SavedGlyph />}>
          Saved
        </PlFloatingBottomNavigationItem>
        <PlFloatingBottomNavigationItem value="account" icon={<AccountGlyph />}>
          Account
        </PlFloatingBottomNavigationItem>
      </PlFloatingBottomNavigation>
    </div>
  );
}
