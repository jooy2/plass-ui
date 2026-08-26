import { PlBottomNavigation, PlBottomNavigationItem, PlTypography } from 'plass-ui';
import { AccountGlyph, HomeGlyph, SearchGlyph } from './glyphs';

export default function BottomNavigationLabels() {
  return (
    <div className="flex w-full max-w-sm flex-col gap-4">
      {(['all', 'selected', 'none'] as const).map((labels) => (
        <div key={labels} className="flex flex-col gap-1">
          <PlTypography level="caption">labels={labels}</PlTypography>
          <PlBottomNavigation
            position="static"
            labels={labels}
            defaultValue="search"
            safeArea={false}
          >
            <PlBottomNavigationItem value="home" icon={<HomeGlyph />}>
              Home
            </PlBottomNavigationItem>
            <PlBottomNavigationItem value="search" icon={<SearchGlyph />}>
              Search
            </PlBottomNavigationItem>
            <PlBottomNavigationItem value="account" icon={<AccountGlyph />}>
              Account
            </PlBottomNavigationItem>
          </PlBottomNavigation>
        </div>
      ))}
    </div>
  );
}
