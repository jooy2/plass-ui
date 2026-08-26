import { PlBottomNavigation, PlBottomNavigationItem } from 'plass-ui';
import { HomeGlyph, SavedGlyph, SearchGlyph } from './glyphs';

export default function BottomNavigationSizes() {
  return (
    <div className="flex w-full max-w-sm flex-col gap-4">
      {(['sm', 'md', 'lg'] as const).map((size) => (
        <PlBottomNavigation
          key={size}
          size={size}
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
