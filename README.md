# NFS Legacy Modpacks

Modern installer framework and restoration-focused modpacks for classic Need for Speed titles.

This project provides Inno Setup installer scripts, rollback validation documentation, and a shared installer architecture for legacy Need for Speed modpacks.

## Supported Titles

- Need for Speed Underground
- Need for Speed Underground 2
- Need for Speed Most Wanted
- Need for Speed Carbon
- Need for Speed ProStreet
- Need for Speed Undercover

## Installer Features

- FreeArc-based archive extraction
- Splash screen support
- Game folder validation
- Large Address Aware executable check
- Manifest-based installed file tracking
- Backup restoration during uninstall
- Clean rollback using `_LegacyInstaller`
- SHA256 rollback verification workflow

## Rollback System

Each installer tracks installed files using:

```txt
_LegacyInstaller/install_manifest.txt

During uninstall, the installer:

Deletes files listed in the install manifest.
Restores original files from the Backup folder.
Removes empty leftover directories.
Returns the game folder to the pre-install state.

Rollback validation is documented in:

docs/rollback-validation.md
docs/hashing-commands.md

Repository Contents

docs/       Documentation and validation notes
source/     Inno Setup installer scripts and source projects
templates/  Reusable installer template
screenshots/ Project screenshots
releases/   Release notes/placeholders

Important Notice

This repository does not include commercial game files, copyrighted game assets, or modpack archive payloads.

Users must own the original games and provide their own game installations.

License

This project is licensed under the MIT License.