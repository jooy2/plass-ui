import { PlMenubar, PlMenubarMenu, PlMenuItem, type PlassSize } from 'plass-ui';

export default function MenubarSizes() {
  return (
    <div className="flex flex-col gap-4">
      {(['xs', 'sm', 'md', 'lg', 'xl'] as PlassSize[]).map((size) => (
        <PlMenubar key={size} size={size}>
          <PlMenubarMenu label={size}>
            <PlMenuItem>New</PlMenuItem>
          </PlMenubarMenu>
          <PlMenubarMenu label="Edit">
            <PlMenuItem>Copy</PlMenuItem>
          </PlMenubarMenu>
        </PlMenubar>
      ))}
    </div>
  );
}
