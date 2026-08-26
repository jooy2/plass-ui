import { useState } from 'react';
import { PlBottomNavigation, PlBottomNavigationItem } from 'plass-ui';
import { AccountGlyph, HomeGlyph, SavedGlyph, SearchGlyph } from './glyphs';

export default function BottomNavigationHero() {
  const [where, setWhere] = useState<string | number>('home');

  return (
    <div className="w-full max-w-sm overflow-hidden rounded-(--plass-radius-lg) bg-(--plass-glass-press)">
      <div className="p-6 text-sm text-(--plass-muted-fg)">The page the bar is over.</div>
      <PlBottomNavigation position="static" value={where} onValueChange={setWhere} label="Main">
        <PlBottomNavigationItem value="home" icon={<HomeGlyph />}>
          Home
        </PlBottomNavigationItem>
        <PlBottomNavigationItem value="search" icon={<SearchGlyph />}>
          Search
        </PlBottomNavigationItem>
        <PlBottomNavigationItem value="saved" icon={<SavedGlyph />}>
          Saved
        </PlBottomNavigationItem>
        <PlBottomNavigationItem value="account" icon={<AccountGlyph />}>
          Account
        </PlBottomNavigationItem>
      </PlBottomNavigation>
    </div>
  );
}
