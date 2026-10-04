export function componentSources(files: Record<string, string>): Record<string, string[]>;

export function scanManifests(
  files: Record<string, string>,
  folders?: string[]
): Record<string, string>;
