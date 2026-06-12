# NFS Legacy Modpacks

Modern installer framework and restoration-focused modpacks for classic Need for Speed titles.

This repository provides Inno Setup installer scripts, rollback validation documentation, and a unified installer architecture for legacy Need for Speed modpacks.

---

## Supported Titles

* Need for Speed Underground
* Need for Speed Underground 2
* Need for Speed Most Wanted
* Need for Speed Carbon
* Need for Speed ProStreet
* Need for Speed Undercover

---

## Features

### Installer Features

* FreeArc-based archive extraction
* Splash screen support
* Game folder validation
* Large Address Aware (4GB Patch) executable verification
* Manifest-based installed file tracking
* Backup restoration during uninstall
* Clean rollback system using `_LegacyInstaller`
* SHA256 rollback verification workflow

### Validation Features

* File hash comparison before install
* File hash comparison after uninstall
* Rollback integrity verification
* Deterministic uninstall validation

---

## Rollback System

Each installer tracks installed files through:

```txt
_LegacyInstaller/install_manifest.txt
```

During uninstall, the installer:

1. Deletes files listed in the install manifest
2. Restores original files from the `Backup` folder
3. Removes empty leftover directories
4. Returns the game folder to the original pre-install state

Rollback validation documentation:

```txt
docs/rollback-validation.md
docs/hashing-commands.md
```

A successful rollback validation produces:

```powershell
Compare-Object `
-ReferenceObject $baseline `
-DifferenceObject $after `
-Property Path, Hash
```

With **no output**, confirming a clean uninstall and restoration.

---

## Repository Structure

```txt
NFS-Legacy-Modpacks/
├── docs/
├── releases/
├── screenshots/
├── source/
│   ├── ArcRunner/
│   ├── Inno/
│   └── Splash/
├── templates/
├── .gitignore
├── LICENSE
└── README.md
```

### Folder Overview

| Folder         | Purpose                                      |
| -------------- | -------------------------------------------- |
| `docs/`        | Validation, hashing, and build documentation |
| `source/`      | Inno Setup scripts and source files          |
| `templates/`   | Shared reusable installer template           |
| `screenshots/` | Installer and project screenshots            |
| `releases/`    | Release placeholders and builds              |

---

## Installer Philosophy

The goal of this project is to modernize installation for legacy Need for Speed games while preserving reliability and reversibility.

Every modpack installer is designed to:

* Validate game installation state
* Detect unsupported or improperly patched copies
* Install safely
* Support rollback
* Restore the game cleanly

The uninstall process is treated as equally important as installation.

---

## Important Notice

This repository **does not include**:

* Commercial game files
* EA copyrighted assets
* Modpack archive payloads
* Redistributed game executables

You must legally own the original games and provide your own game installation.

---

## Roadmap

* [x] Underground installer architecture
* [x] Underground 2 installer architecture
* [x] Most Wanted installer architecture
* [x] Carbon installer architecture
* [x] ProStreet installer architecture
* [x] Undercover installer architecture
* [ ] Shared reusable installer template
* [ ] Public release packaging
* [ ] Documentation expansion
* [ ] Screenshot gallery

---

## License

Licensed under the MIT License.
