# Build Notes

This document describes the internal build workflow, project structure, validation methodology, and release standards used by **NFS Legacy Modpacks Release 2.0**.

The objective is to guarantee reproducible builds, deterministic installation, deterministic rollback, and long-term maintainability across every supported Need for Speed title.

---

# Project Philosophy

NFS Legacy Modpacks is built around the following engineering principles:

* Reliable installation
* Deterministic rollback
* Validation-first deployment
* Preservation of original game installations
* Reproducible builds
* Shared installer architecture
* Long-term maintainability

Unlike traditional game mod installers, installation and uninstallation are treated as equally important.

Every build must be capable of restoring the original patched game installation.

---

# Supported Games

The Release 2.0 architecture supports every classic PC Need for Speed title.

| Game                         | Status     |
| ---------------------------- | ---------- |
| Need for Speed Underground   | ✅ Complete |
| Need for Speed Underground 2 | ✅ Complete |
| Need for Speed Most Wanted   | ✅ Complete |
| Need for Speed Carbon        | ✅ Complete |
| Need for Speed ProStreet     | ✅ Complete |
| Need for Speed Undercover    | ✅ Complete |

Every title shares the same installer architecture, rollback engine, and validation methodology.

---

# Required Software

The following components are required to build a release.

## SetupLauncher

Purpose:

* Launcher
* Game selection
* Installer bootstrap
* Backend validation
* AppId verification

---

## LegacyUI

Purpose:

* Modern installer frontend
* Installation interface
* Progress reporting
* Optional component handling
* Backend communication

Published as a self-contained Release executable.

---

## Inno Setup

Purpose:

* Backend installer
* File deployment
* Rollback engine
* RestoreData generation
* Uninstaller generation

---

## FreeArc

Purpose:

* High-compression archive format
* Payload extraction

Supported archive format:

```text id="n20x5u"
*.arc
```

---

## ArcRunner

Purpose:

* Silent extraction
* Progress monitoring
* Log generation
* Extraction controller

---

## Splash

Purpose:

* Startup splash
* Branding
* Installer presentation

---

# Build Pipeline

Every supported title follows the same build workflow.

```text id="xg9mzf"
SetupLauncher
        │
        ▼
LegacyUI
        │
        ▼
Backend (Inno Setup)
        │
        ▼
ArcRunner
        │
        ▼
FreeArc
        │
        ▼
Installer
```

---

# Local Project Structure

Each installer project follows the same layout.

```text id="5azdc0"
InstallerProject/
│
├── Images/
├── Tools/
│   ├── ArcRunner.exe
│   ├── Splash.exe
│   └── arc.exe
│
├── GameArchive.arc
└── GAME.iss
```

The launcher is deployed alongside the installer while the backend executable is placed inside `_backend`.

---

# Installer Workflow

Every installer performs the following sequence.

## 1. Launcher

* SetupLauncher starts.
* AppId verified.
* Launcher configuration verified.
* Backend validated.

---

## 2. LegacyUI

* Installer interface displayed.
* Game selected.
* Installation configured.

---

## 3. Backend Validation

The backend verifies:

* Game executable
* Expected executable size
* Latest official patch
* Large Address Aware support
* Required folders
* Critical file sizes

Unsupported installations are rejected before extraction begins.

---

## 4. Archive Extraction

ArcRunner launches FreeArc.

Extraction occurs inside the temporary directory while providing progress information to LegacyUI.

---

## 5. File Deployment

Extracted files are copied into the selected game installation.

The installer preserves directory structure and records installation metadata.

---

## 6. Rollback Metadata

The installer generates:

```text id="3xg1lw"
_LegacyInstaller
│
├── install_manifest.txt
├── new_files_manifest.txt
└── RestoreData
    └── Backup
```

Only overwritten original files are backed up.

---

## 7. Uninstall Workflow

Rollback follows the Release 2.0 sequence.

```text id="i8g6qx"
Delete new files
        │
        ▼
Restore overwritten originals
        │
        ▼
Title-specific cleanup
        │
        ▼
Remove empty directories
        │
        ▼
Verification
```

---

# Validation Workflow

Every release must complete the following validation.

```text id="1dvs8o"
Clean Patched Game
        │
        ▼
Install
        │
        ▼
Verify Gameplay
        │
        ▼
Rollback
        │
        ▼
Compare-Object
```

Expected result:

```text id="pn9k9b"
(no output)
```

This confirms:

* Original files restored.
* Modded files removed.
* No remaining artifacts.
* Installation restored to the clean patched reference.

---

# Repository Rules

The repository intentionally excludes build artifacts and copyrighted content.

## Never Commit

```text id="x6lybx"
*.arc
*.exe
*.dll
*.zip
*.rar
*.7z
```

---

## Temporary Files

```text id="my2fdw"
RestoreData/
_LegacyInstaller/
*_Extract/
arc_progress.log
install_error.txt
```

---

## Validation Files

```text id="1e30c6"
baseline_vanilla.csv
after_install.csv
after_uninstall.csv
```

---

## Game Files

Never commit:

* EA game assets
* Original executables
* Copyrighted game data
* Commercial content

---

# Release Standard

A build is considered release-ready only when all of the following have passed.

* Successful compilation
* Successful launcher validation
* Successful installation
* Successful gameplay verification
* Successful rollback
* RestoreData validation
* Compare-Object returns no differences
* Documentation synchronized
* Repository synchronized

---

# Future Improvements

Planned future work includes:

* Expanded installer diagnostics
* Automated release packaging
* Automated validation tooling
* Expanded documentation
* Additional installer screenshots
* Future quality-of-life improvements
