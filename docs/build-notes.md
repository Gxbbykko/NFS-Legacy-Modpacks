# Build Notes

This document describes the internal build process, repository workflow, validation standards, and installer architecture used for the **NFS Legacy Modpacks** project.

The goal of this documentation is to ensure reproducible builds, safe installation, deterministic rollback, and long-term maintainability across all supported Need for Speed titles.

---

# Project Philosophy

The NFS Legacy Modpacks project focuses on:

* Reliable installation
* Clean rollback
* Validation-first deployment
* Preservation of original game installations
* Reproducible builds
* Long-term maintainability

Unlike traditional mod installers, uninstall integrity is treated as equally important as installation success.

Every release should be capable of returning the game to its exact pre-install state.

---

# Supported Games

Current installer architecture supports:

| Game                         | Status   |
| ---------------------------- | -------- |
| Need for Speed Underground   | Complete |
| Need for Speed Underground 2 | Complete |
| Need for Speed Most Wanted   | Complete |
| Need for Speed Carbon        | Complete |
| Need for Speed ProStreet     | Complete |
| Need for Speed Undercover    | Complete |

All supported installers share the same rollback and validation architecture.

---

# Required Software

The following tools are required for local builds.

## Required Applications

### Inno Setup

Used to compile installer scripts.

Purpose:

* Installer generation
* Wizard interface
* File deployment
* Uninstall integration
* Rollback orchestration

---

### FreeArc (`arc.exe`)

Used to compress and extract modpack archives.

Purpose:

* Payload compression
* Reduced installer size
* Archive extraction

Expected archive format:

```txt
*.arc
```

---

### ArcRunner.exe

Wrapper process used to execute FreeArc silently while exposing extraction progress to the installer.

Purpose:

* Silent extraction
* Installer progress tracking
* Log generation
* Stable extraction handling

---

### Splash.exe

Displays splash screen before installer initialization.

Purpose:

* Branding
* User presentation
* Installer identity

---

# Local Build Structure

Each local installer project should follow the same structure.

Expected layout:

```txt
InstallerProject/
├── Images/
│   ├── wizard.bmp
│   ├── header.bmp
│   ├── splash.png
│   └── game_icon.ico
│
├── Tools/
│   ├── arc.exe
│   ├── ArcRunner.exe
│   └── Splash.exe
│
├── GameArchive.arc
│
└── GAME.iss
```

Example:

```txt
NFSMW_Modpack/
├── InstallerProject/
│   ├── Images/
│   ├── Tools/
│   ├── NFSMW.arc
│   └── NFSMW.iss
```

---

# Installer Architecture

All installers use the same internal workflow.

## Installation Flow

### 1. Game Validation

Installer validates:

* Correct executable exists
* Expected executable size
* Large Address Aware (4GB Patch) enabled
* Required folders exist
* Critical files match expected sizes

Purpose:

* Prevent unsupported installs
* Avoid broken mod states
* Reduce user errors

---

### 2. Temporary Extraction

Modpack payload is extracted into:

```txt
%TEMP%
```

Example:

```txt
MostWantedLegacy_Extract
CarbonLegacy_Extract
```

Extraction uses:

```txt
arc.exe
```

through:

```txt
ArcRunner.exe
```

This allows:

* Silent extraction
* Progress reporting
* Log capture

---

### 3. File Deployment

Files are copied from temporary extraction folders into the game installation directory.

Installer preserves structure recursively.

Example:

```txt
CARS\
GLOBAL\
FRONTEND\
LANGUAGES\
TRACKS\
```

---

### 4. Manifest Generation

Every installed file is written into:

```txt
_LegacyInstaller/install_manifest.txt
```

Purpose:

* Exact uninstall tracking
* File removal accuracy
* Deterministic rollback

Only modpack-installed files are recorded.

Excluded:

```txt
Backup\
_LegacyInstaller\
```

---

### 5. Backup Restoration

During uninstall:

1. Manifest files are removed
2. Original files are restored from:

```txt
Backup\
```

3. Empty folders are removed

Result:

Game returns to its original patched state.

---

# Rollback Order

The uninstall order is extremely important.

Correct order:

```txt
1. Delete manifest files
2. Restore Backup files
3. Remove empty directories
4. Final cleanup
```

Changing this order can break rollback validation.

---

# Validation Workflow

No build is considered complete without rollback validation.

Each release must pass SHA256 integrity testing.

Validation consists of:

## Step 1 — Baseline Snapshot

Generate hash list before installation.

Output:

```txt
baseline_vanilla.csv
```

---

## Step 2 — Install Snapshot

Generate hash list after installation.

Output:

```txt
after_install.csv
```

---

## Step 3 — Uninstall Snapshot

Generate hash list after uninstall.

Output:

```txt
after_uninstall.csv
```

---

## Step 4 — Compare Results

Example:

```powershell
$baseline = Import-Csv ".\baseline_vanilla.csv"
$after = Import-Csv ".\after_uninstall.csv"

Compare-Object `
-ReferenceObject $baseline `
-DifferenceObject $after `
-Property Path, Hash
```

---

## Expected Result

Successful rollback validation returns:

```txt
(no output)
```

This confirms:

* No missing files
* No leftover files
* No modified hashes
* Successful restoration

---

# Repository Rules

The repository intentionally excludes:

## Forbidden Files

Do **not** commit:

```txt
*.arc
*.exe
*.dll
*.zip
*.rar
*.7z
```

---

## Temporary Files

Do **not** commit:

```txt
Backup/
_LegacyInstaller/
*_Extract/
arc_progress.log
install_error.txt
```

---

## Validation Files

Do **not** commit:

```txt
baseline_vanilla.csv
after_install.csv
after_uninstall.csv
```

---

## Game Files

Never commit:

* EA game assets
* Original game binaries
* Copyrighted content
* Redistributed game data

---

# Release Standard

Before release, every installer must satisfy:

* Successful compilation
* Successful installation
* Successful uninstall
* Manifest generation
* Backup restoration
* SHA256 rollback verification
* No `Compare-Object` differences

Only then is a build considered release-ready.

---

# Future Improvements

Planned improvements include:

* Shared installer template system
* Automatic manifest filtering
* Unified build workflow
* CI-style validation tooling
* Expanded installer diagnostics
* Screenshot documentation
