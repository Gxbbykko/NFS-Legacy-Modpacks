# Build Notes

## Requirements
- Windows
- Inno Setup
- FreeArc `arc.exe`
- `ArcRunner.exe`
- `Splash.exe`
- game-specific `.arc` archive
- game-specific wizard/header/icon/splash images

## Build Flow
1. Place the `.iss` script in `source/Inno/`.
2. Place required tools in each local InstallerProject folder.
3. Place the game archive beside the script/tool references.
4. Compile with Inno Setup.
5. Test install.
6. Test rollback with SHA256 validation.

## Important
The repository does not include game assets, commercial files, or compiled modpack archives.

Do not commit:
- `.arc` archives
- compiled installers
- game files
- backup folders
- test folders
- hash CSV files

## Installer System
Each installer uses:
- FreeArc extraction through `ArcRunner.exe`
- temporary extraction folder
- manifest-based installed file tracking
- `_LegacyInstaller` uninstall location
- Backup restoration during uninstall