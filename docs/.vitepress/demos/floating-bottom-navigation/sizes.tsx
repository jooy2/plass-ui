import { PlFloatingBottomNavigation, PlFloatingBottomNavigationItem } from 'plass-ui';
import { HomeGlyph, SavedGlyph, SearchGlyph } from '../bottom-navigation/glyphs';

export default function FloatingBottomNavigationSizes() {
  return (
    <div className="flex w-full max-w-sm flex-col gap-2">
      {(['sm', 'md', 'lg'] as const).map((size) => (
        <PlFloatingBottomNavigation
          key={size}
          size={size}
          position="static"
          safeArea={false}
          defaultValue="home"
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
        </PlFloatingBottomNavigation>
      ))}
    </div>
  );
}
