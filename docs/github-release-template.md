# GitHub Release Template

This document defines the official GitHub Release template used by **NFS Legacy Modpacks Release 2.0**.

Every public release should follow a standardized structure to ensure consistency, transparency, reproducibility, and clear communication with users.

---

# Release Title Format

Use:

```text
Need for Speed <Game Name> Legacy Modpack v<version>
```

Examples:

```text
Need for Speed Underground Legacy Modpack v2.0.0
Need for Speed Underground 2 Legacy Modpack v2.0.0
Need for Speed Most Wanted Legacy Modpack v2.0.0
Need for Speed Carbon Legacy Modpack v2.0.0
Need for Speed ProStreet Legacy Modpack v2.0.0
Need for Speed Undercover Legacy Modpack v2.0.0
```

---

# Release Description Template

````md
# Release Overview

**Version:** v<version>

This release delivers the latest version of the NFS Legacy Modpack installer for **<Game Name>**.

The Release 2.0 installer framework combines SetupLauncher, LegacyUI, a validated Inno Setup backend, ArcRunner, FreeArc extraction, and the RestoreData rollback system into a unified installation experience.

---

# What's New

## Installer

- Added:
- Improved:
- Updated:

## User Interface

- Added:
- Improved:
- Updated:

## Rollback

- Added:
- Improved:
- Updated:

## Validation

- Installation verified
- Gameplay verified
- Rollback verified
- Compare-Object verification passed
- RestoreData validated

---

# Installer Architecture

This release uses the standardized Release 2.0 installer architecture.

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
RestoreData Rollback
```

---

# Compatibility

Required game version:

| Game | Required Version |
|------|------------------|
| <Game Name> | <Required Version> |

Mandatory requirements:

- Latest official game patch
- Clean game installation
- Large Address Aware (4GB Patch)

The installer validates these requirements before installation.

---

# Rollback Support

This release includes:

- RestoreData rollback architecture
- install_manifest.txt tracking
- new_files_manifest.txt tracking
- Automatic restoration of overwritten files
- Automatic removal of newly installed files
- Automatic empty directory cleanup

Rollback validation methodology:

docs/rollback-validation.md

---

# Validation Summary

Release validation completed successfully.

✔ Mandatory requirements verified

✔ Installation

✔ Gameplay verification

✔ Rollback

✔ Compare-Object verification

✔ Restored installation matches clean patched reference

---

# Gallery

This release includes visual documentation covering:

- Mandatory Requirements
- Installer workflow
- Installation validation
- Rollback validation
- Before / After comparison
- Gameplay comparison

See the Gallery folder included with this release for complete documentation.

---

# SHA-256 Verification

Installer:

<Game>-Legacy-Modpack-v<version>.exe

SHA-256:

XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

Generate manually:

```powershell
Get-FileHash ".\<InstallerName>.exe" -Algorithm SHA256
```

---

# Installation Notes

1. Update the game to the latest official version.
2. Apply the Large Address Aware (4GB Patch).
3. Launch the installer.
4. Select the game installation directory.
5. Follow any validation messages.
6. Wait for extraction and installation to complete.
7. Launch the game.

To remove the modpack, use the included Restore Tool.

---

# Known Issues

- None currently reported.

---

# Important Notice

This repository does **not** include:

- Original EA game files
- Commercial assets
- Copyrighted game content
- Modpack archive payloads

Users must legally own the original game.
````

---

# Release Publishing Workflow

Before publishing:

* [ ] Release build compiled
* [ ] SetupLauncher verified
* [ ] LegacyUI verified
* [ ] Backend verified
* [ ] ArcRunner verified
* [ ] Installation tested
* [ ] Gameplay tested
* [ ] Rollback validated
* [ ] Compare-Object returned no differences
* [ ] Mandatory requirement proof captured
* [ ] Gallery screenshots prepared
* [ ] SHA-256 generated
* [ ] README updated
* [ ] CHANGELOG updated
* [ ] Documentation synchronized
* [ ] Git tag created
* [ ] GitHub Release drafted
* [ ] GitHub Release published

---

# Example Release

Release name:

```text
Need for Speed Underground Legacy Modpack v2.0.0
```

Installer:

```text
NFSU-Legacy-Modpack-v2.0.0.exe
```

Git tag:

```text
v2.0.0
```

Release assets:

```text
NFSU-Legacy-Modpack-v2.0.0.exe
SHA256.txt
CHANGELOG.md
Gallery/
```

---

# Release Philosophy

Every GitHub Release should represent a fully validated installer.

A release is considered complete only when:

1. Mandatory requirements are verified.
2. Installation succeeds.
3. Gameplay verification succeeds.
4. Rollback succeeds.
5. RestoreData restores the original patched installation.
6. Compare-Object returns no differences.
7. Gallery documentation is complete.
8. Documentation and repository are synchronized.

Release quality is prioritized over release frequency.
