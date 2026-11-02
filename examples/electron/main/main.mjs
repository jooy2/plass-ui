import {
  app,
  BrowserWindow,
  ipcMain,
  Menu,
  nativeTheme,
  net,
  protocol,
  session,
  shell
} from 'electron';
import { dirname, join, normalize, sep } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
const dist = join(here, '..', 'dist');
const devServer = process.env.VITE_DEV_SERVER_URL;
const testUserData = process.env.PLASS_USER_DATA;

if (testUserData) {
  app.setPath('userData', testUserData);
}

// A scheme of its own rather than `file://`, as Electron's security guide asks:
// a page served this way has an origin, and `/samples/...` means what it means
// on a website.
protocol.registerSchemesAsPrivileged([
  { scheme: 'plass', privileges: { standard: true, secure: true, supportFetchAPI: true } }
]);

function serveBuild() {
  protocol.handle('plass', (request) => {
    const { pathname } = new URL(request.url);
    const file = normalize(join(dist, decodeURIComponent(pathname)));

    if (file !== dist && !file.startsWith(dist + sep)) {
      return new Response('Not found', { status: 404 });
    }

    return net.fetch(pathToFileURL(pathname === '/' ? join(dist, 'index.html') : file).toString());
  });
}

function denyPermissions() {
  // The page asks for nothing but the clipboard write the copy buttons need.
  session.defaultSession.setPermissionRequestHandler((_webContents, permission, callback) => {
    callback(permission === 'clipboard-sanitized-write');
  });
}

function createWindow() {
  const window = new BrowserWindow({
    width: 1180,
    height: 800,
    minWidth: 520,
    minHeight: 480,
    titleBarStyle: process.platform === 'darwin' ? 'hiddenInset' : 'default',
    backgroundColor: nativeTheme.shouldUseDarkColors ? '#0f1221' : '#eef2fb',
    show: false,
    webPreferences: {
      preload: join(here, 'preload.cjs'),
      contextIsolation: true,
      nodeIntegration: false,
      sandbox: true
    }
  });

  window.once('ready-to-show', () => window.show());

  // A link leaves for the browser rather than opening a second window here.
  window.webContents.setWindowOpenHandler(({ url }) => {
    if (url.startsWith('https://')) {
      shell.openExternal(url);
    }

    return { action: 'deny' };
  });

  window.webContents.on('will-navigate', (event, url) => {
    if (!url.startsWith('plass://') && !(devServer && url.startsWith(devServer))) {
      event.preventDefault();
    }
  });

  window.loadURL(devServer ?? 'plass://app/');
}

app.whenReady().then(() => {
  serveBuild();
  denyPermissions();

  ipcMain.handle('theme:set', (_event, source) => {
    nativeTheme.themeSource = source;
  });

  // The standard menu, which is also what puts copy and paste on their keys.
  Menu.setApplicationMenu(Menu.buildFromTemplate([{ role: 'appMenu' }, { role: 'editMenu' }]));

  createWindow();

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createWindow();
    }
  });
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});
