import { PlBottomNavigation, PlBottomNavigationItem } from 'plass-ui';
import { HomeGlyph, SavedGlyph, SearchGlyph } from './glyphs';

export default function BottomNavigationVariants() {
  return (
    <div className="flex w-full max-w-sm flex-col gap-4">
      {(['glass', 'solid', 'ghost'] as const).map((variant) => (
        <PlBottomNavigation
          key={variant}
          variant={variant}
          position="static"
          defaultValue="home"
          safeArea={false}
        >
          <PlBottomNavigationItem value="home" icon={<HomeGlyph />}>
            Home
          </PlBottomNavigationItem>
          <PlBottomNavigationItem value="search" icon={<SearchGlyph />}>
            Search
          </PlBottomNavigationItem>
          <PlBottomNavigationItem value="saved" icon={<SavedGlyph />}>
            Saved
          </PlBottomNavigationItem>
        </PlBottomNavigation>
      ))}
    </div>
  );
}
