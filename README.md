# NFS Legacy Modpacks

![License](https://img.shields.io/badge/license-MIT-blue)
![Platform](https://img.shields.io/badge/platform-Windows-lightgrey)
![Architecture](https://img.shields.io/badge/architecture-Release%202.0-success)
![Rollback](https://img.shields.io/badge/rollback-100%25%20validated-brightgreen)
![Games](https://img.shields.io/badge/supported%20titles-6-orange)

Modern installer framework and preservation-focused modpacks for the classic **Need for Speed** PC titles.

NFS Legacy Modpacks is a unified installer framework and restoration-focused preservation project covering all six classic Need for Speed titles released between 2003 and 2008.

Rather than simply packaging modifications, the project focuses on providing a modern installation experience while preserving the original games through deterministic installation, validated rollback, and clean restoration.

The installer framework combines a custom launcher, a modern installation interface, a hidden installer backend, optimized archive extraction, and a fully validated rollback architecture into a standardized deployment system shared across every supported title.

---

# Supported Titles

* Need for Speed Underground
* Need for Speed Underground 2
* Need for Speed Most Wanted
* Need for Speed Carbon
* Need for Speed ProStreet
* Need for Speed Undercover

---

# Installer Architecture

Every title now uses the same validated installer architecture.

```text
SetupLauncher
        │
        ▼
LegacyUI
        │
        ▼
Inno Setup Backend
        │
        ▼
ArcRunner
        │
        ▼
FreeArc
        │
        ▼
Game Installation
        │
        ▼
RestoreData Rollback System
```

Each layer has a dedicated responsibility.

| Component     | Responsibility                                        |
| ------------- | ----------------------------------------------------- |
| SetupLauncher | Secure launcher, game selection, installer validation |
| LegacyUI      | Modern installation interface and frontend controller |
| Inno Setup    | Installation backend and rollback engine              |
| ArcRunner     | Archive extraction controller                         |
| FreeArc       | High-compression payload extraction                   |
| Splash        | Startup branding before installer initialization      |

---

# Features

## Installer Architecture

* Unified installer architecture shared across all six titles
* SetupLauncher frontend launcher
* LegacyUI installation interface
* Hidden Inno Setup backend
* ArcRunner extraction controller
* FreeArc compressed payload system
* Splash startup framework
* Standardized deployment pipeline

---

## Installation Features

* Automatic game folder detection
* Installation validation
* Large Address Aware (4GB Patch) verification
* Optional component support
* External MOVIES package handling
* Manifest generation
* Installation progress logging
* Deterministic installation workflow

---

## Rollback Features

* RestoreData rollback architecture
* Changed-file backup system
* SHA-256 file comparison
* install_manifest.txt tracking
* new_files_manifest.txt tracking
* Manifest-driven uninstall
* Automatic restoration of overwritten files
* Automatic removal of newly installed files
* Automatic empty folder cleanup
* Hidden RestoreData protection
* Deterministic restoration

---

## Validation Features

* File hash comparison before installation
* File hash comparison after uninstall
* Rollback integrity verification
* Deterministic uninstall validation
* Vanilla patched installation comparison
* Compare-Object verification workflow
* Six-title validation

---

# Screenshots

The installer framework includes rollback-safe workflows designed to restore the original game state after uninstall.

## Underground Installer

Installer startup and welcome screen.

![Underground Installer Welcome](screenshots/installers/nfsu-installer-welcome.png)

## Installation Validation Warning

Example warning shown when the selected game installation does not meet validation requirements.

![Underground Installer Validation](screenshots/installers/nfsu-installer-validation-warning.png)

## Installation Ready State

Installer configured and ready to begin installation.

![Underground Installer Ready](screenshots/installers/nfsu-installer-ready.png)

## Installation Progress

Archive extraction and installation progress with live logging enabled.

![Underground Installer Progress](screenshots/installers/nfsu-installer-progress-96.png)

## Installation Complete

Successful installation state.

![Underground Installer Complete](screenshots/installers/nfsu-installer-complete.png)

## Uninstall Completion

Successful uninstall and restoration state.

![Underground Uninstall Complete](screenshots/installers/nfsu-uninstaller-complete.png)

## Rollback Validation

Successful rollback verification after uninstall.

A clean comparison result (**no output**) confirms that the post-uninstall installation matches the original vanilla patched reference.

![NFSU Rollback Success](screenshots/rollback/nfsu-rollback-success.png)

## Manifest Tracking

Example of generated installation manifest tracking installed files for safe removal during uninstall.

![NFSU Manifest Example](screenshots/rollback/nfsu-manifest-example.png)

## Legacy Installer Structure

Generated rollback infrastructure.

![Legacy Installer Folder](screenshots/rollback/nfsu-legacyinstaller-folder.png)

## Rollback Confirmation

Example of rollback confirmation during uninstall.

![Rollback Confirmed](screenshots/rollback/nfsu-uninstaller-rollback-confirmed.png)

---

# Rollback System

Each installer generates a protected rollback structure inside the game directory.

```text
_LegacyInstaller
│
├── install_manifest.txt
├── new_files_manifest.txt
└── RestoreData
    └── Backup
```

The rollback process performs the following sequence:

1. Unlock RestoreData
2. Remove files recorded in `new_files_manifest.txt`
3. Restore original files from `RestoreData\Backup`
4. Remove empty directories
5. Verify restoration
6. Remove rollback infrastructure

Only original files that are actually overwritten are backed up, reducing required disk usage while preserving deterministic restoration.

Rollback documentation is available in:

```text
docs/rollback-validation.md
docs/hashing-commands.md
```

A successful validation produces:

```powershell
Compare-Object `
-ReferenceObject $baseline `
-DifferenceObject $after `
-Property Path, Hash
```

with **no output**, confirming that the restored installation matches the original vanilla patched reference.

---

# Validation Status

The installer architecture has been validated across every supported title.

| Title                        | Installation | Rollback |
| ---------------------------- | ------------ | -------- |
| Need for Speed Underground   | ✅            | ✅        |
| Need for Speed Underground 2 | ✅            | ✅        |
| Need for Speed Most Wanted   | ✅            | ✅        |
| Need for Speed Carbon        | ✅            | ✅        |
| Need for Speed ProStreet     | ✅            | ✅        |
| Need for Speed Undercover    | ✅            | ✅        |

All installers successfully:

* Install the complete modpack
* Restore overwritten files
* Remove newly installed files
* Clean empty directories
* Match the original vanilla patched reference after uninstall

---

# Repository Structure

```text
NFS-Legacy-Modpacks/
├── docs/
├── releases/
├── screenshots/
│   ├── installers/
│   └── rollback/
├── source/
│   ├── ArcRunner/
│   ├── Inno/
│   ├── LegacyUI/
│   ├── SetupLauncher/
│   └── Splash/
├── templates/
├── .gitignore
├── CHANGELOG.md
├── LICENSE
└── README.md
```

## Folder Overview

| Folder               | Purpose                                               |
| -------------------- | ----------------------------------------------------- |
| docs/                | Validation, rollback, release and build documentation |
| releases/            | Release notes and packaged release information        |
| screenshots/         | Installer and rollback screenshots                    |
| source/ArcRunner     | Archive extraction controller                         |
| source/Inno          | Installer backend and rollback engine                 |
| source/LegacyUI      | Modern installation frontend                          |
| source/SetupLauncher | Secure launcher and installer bootstrap               |
| source/Splash        | Startup splash application                            |
| templates/           | Shared reusable installer resources                   |

---

# Installer Philosophy

Every installer is designed around the following principles:

* Preserve the original games.
* Never distribute copyrighted game assets.
* Validate the target installation before modifying it.
* Install deterministically.
* Roll back deterministically.
* Restore the original patched installation.
* Share one unified architecture across every supported title.
* Keep the installer maintainable through standardized components.

Installation and uninstallation are treated as equally important parts of the user experience.

---

# Important Notice

This repository **does not include**:

* Commercial game files
* EA copyrighted assets
* Modpack archive payloads
* Redistributed game executables

Users must legally own the original games and provide their own installations.

---

# Roadmap

* [x] Underground installer architecture
* [x] Underground 2 installer architecture
* [x] Most Wanted installer architecture
* [x] Carbon installer architecture
* [x] ProStreet installer architecture
* [x] Undercover installer architecture
* [x] SetupLauncher framework
* [x] LegacyUI framework
* [x] ArcRunner extraction controller
* [x] RestoreData rollback architecture
* [x] Manifest-based rollback system
* [x] Six-title validation
* [x] Screenshot documentation
* [ ] Public Release 2.0 packaging
* [ ] Expanded architecture documentation
* [ ] Complete installer gallery
* [ ] Future installer enhancements

---

# License

Licensed under the **MIT License**.