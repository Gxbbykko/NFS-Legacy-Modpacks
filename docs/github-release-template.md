# GitHub Release Template

This document provides the standardized format for publishing GitHub Releases for **NFS Legacy Modpacks**.

Every public release should follow a consistent structure to improve readability, version tracking, rollback verification, and reproducibility.

---

# Release Title Format

Use:

```txt
<Game Name> Legacy Modpack v<version>
```

Examples:

```txt
Need for Speed Underground Legacy Modpack v1.0.0
Need for Speed Most Wanted Legacy Modpack v1.2.0
Need for Speed Carbon Legacy Modpack v2.0.0
```

---

# Release Description Template

```md
## Overview

Release version: **v<version>**

This update includes installer improvements, rollback validation, and packaging updates for the legacy modpack installer framework.

---

## Changes

### Installer
- Added:
- Improved:
- Updated:

### Fixes
- Fixed:
- Resolved:

### Validation
- Updated rollback validation
- Verified uninstall restoration
- Manifest cleanup confirmed

---

## Compatibility

Required:

- Correct game version
- Proper game installation
- Large Address Aware (4GB Patch) where applicable

---

## Rollback Support

This release supports:

- Manifest-based uninstall tracking
- Backup restoration
- Deterministic rollback validation
- Clean uninstall workflow

Rollback validation methodology:

docs/rollback-validation.md

---

## SHA256 Verification

File:

<Game>-Legacy-Modpack-v<version>.exe

SHA256:

XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

Generate checksum:

Get-FileHash ".\<InstallerName>.exe" -Algorithm SHA256

---

## Important Notice

This repository does **not** distribute:

- Game files
- EA copyrighted assets
- Commercial content

You must legally own the original game.

---

## Installation Notes

1. Select your game directory
2. Ensure required patches are installed
3. Follow installer validation warnings
4. Allow installer extraction to complete
5. Use uninstall for clean rollback

---

## Known Issues

- None currently reported.
```

---

# Release Publishing Workflow

Before publishing:

* [ ] Installer tested
* [ ] Install tested
* [ ] Uninstall tested
* [ ] Rollback validation passed
* [ ] SHA256 generated
* [ ] CHANGELOG updated
* [ ] Version incremented
* [ ] Git tag created
* [ ] GitHub Release drafted
* [ ] Release published

---

# Example Release Name

```txt
Need for Speed Underground Legacy Modpack v1.0.0
```

# Example Installer File

```txt
NFSU-Legacy-Modpack-v1.0.0.exe
```
