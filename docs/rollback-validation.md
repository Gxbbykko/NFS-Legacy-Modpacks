# Rollback Validation

## Goal
Verify that installing and uninstalling a Legacy Modpack restores the game folder to the exact pre-install state.

## Validation Method
1. Start from a clean vanilla-patched game folder.
2. Create SHA256 baseline of all game files.
3. Install the modpack.
4. Verify `_LegacyInstaller` and `install_manifest.txt`.
5. Run the generated uninstaller.
6. Create SHA256 post-uninstall scan.
7. Compare baseline vs post-uninstall.

## Success Condition
`Compare-Object` returns no output.

## Verified Titles
- Need for Speed Underground
- Need for Speed Underground 2
- Need for Speed Most Wanted
- Need for Speed Carbon
- Need for Speed ProStreet
- Need for Speed Undercover

## Notes
The rollback system uses:
- install manifest deletion
- Backup folder restoration
- empty directory cleanup
- hash-based validation