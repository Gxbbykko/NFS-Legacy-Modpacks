# Release Engineering

This document defines the release engineering standards, versioning rules, packaging workflow, validation requirements, checksum policy, documentation standards, and publishing process for **NFS Legacy Modpacks Release 2.0**.

The objective is to ensure every public release is:

* Reproducible
* Versioned consistently
* Deterministic
* Rollback-safe
* Fully validated
* Properly documented

Every release follows the same engineering workflow regardless of the supported Need for Speed title.

---

# Release Engineering Pipeline

Every release follows the standardized deployment pipeline.

```text
Developer
        │
        ▼
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
RestoreData Rollback
        │
        ▼
Validation
        │
        ▼
Documentation
        │
        ▼
Public Release
```

The same architecture is shared across all supported installers.

---

# Versioning Strategy

Releases follow semantic versioning.

```text
Major.Minor.Patch
```

Examples:

```text
2.0.0
2.1.0
2.1.1
3.0.0
```

## Version Meaning

| Version   | Meaning                                                                    |
| --------- | -------------------------------------------------------------------------- |
| **Major** | Architectural changes, installer redesigns, framework milestones           |
| **Minor** | New installer functionality, compatibility improvements, optional features |
| **Patch** | Bug fixes, rollback improvements, installer maintenance                    |

---

# Release Naming Convention

Installer filenames must remain deterministic.

Format:

```text
<Game>-Legacy-Modpack-v<version>.exe
```

Examples:

```text
NFSU-Legacy-Modpack-v2.0.0.exe
NFSU2-Legacy-Modpack-v2.0.0.exe
NFSMW-Legacy-Modpack-v2.0.0.exe
NFSC-Legacy-Modpack-v2.0.0.exe
NFSPS-Legacy-Modpack-v2.0.0.exe
NFSUC-Legacy-Modpack-v2.0.0.exe
```

Never publish installers with temporary names such as:

```text
installer_final.exe
latest.exe
fixed.exe
test.exe
```

---

# Release Components

Every public installer consists of the following components.

| Component            | Purpose                       |
| -------------------- | ----------------------------- |
| SetupLauncher        | Public launcher               |
| LegacyUI             | Installation interface        |
| Backend (Inno Setup) | Installer engine              |
| ArcRunner            | Archive extraction controller |
| FreeArc              | Payload extraction            |
| RestoreData          | Rollback system               |

These components form the validated Release 2.0 installer architecture.

---

# Validation Requirements

Every release must successfully complete:

* Mandatory requirement validation
* Game validation
* Installation
* Archive extraction
* File deployment
* Optional component installation
* Gameplay verification
* Rollback
* RestoreData verification
* Manifest verification
* Empty directory cleanup

A release is considered valid only after every supported title passes the complete validation workflow.

---

# Rollback Validation

Rollback validation is mandatory.

Validation consists of:

1. Clean patched reference installation.
2. Verify mandatory requirements.
3. Install modpack.
4. Verify installed modpack.
5. Uninstall using Restore Tool.
6. Compare restored installation against the original reference.

Verification is performed using PowerShell filesystem comparison.

A successful comparison produces no differences.

---

# Documentation Requirements

Every Release 2.0 publication includes standardized documentation.

Documentation consists of:

* Release README
* Gallery
* Mandatory Requirements proof
* Installer workflow
* Rollback validation
* Before / After comparison
* Gameplay comparison

Documentation is considered part of the release engineering process.

---

# SHA-256 Verification Policy

Every public release must include a SHA-256 checksum.

Example:

```powershell
Get-FileHash ".\NFSU-Legacy-Modpack-v2.0.0.exe" -Algorithm SHA256
```

Checksums should accompany:

* GitHub Releases
* Release notes
* Optional checksum files

---

# Git Tag Format

Git tags must follow:

```text
v<version>
```

Examples:

```text
v2.0.0
v2.1.0
v2.1.1
```

Example:

```powershell
git tag v2.0.0
git push origin v2.0.0
```

Tags represent immutable release states.

Released tags must never be modified.

---

# GitHub Release Format

GitHub release titles should follow:

```text
Need for Speed Underground Legacy Modpack v2.0.0
Need for Speed Underground 2 Legacy Modpack v2.0.0
Need for Speed Most Wanted Legacy Modpack v2.0.0
Need for Speed Carbon Legacy Modpack v2.0.0
Need for Speed ProStreet Legacy Modpack v2.0.0
Need for Speed Undercover Legacy Modpack v2.0.0
```

Release notes should contain:

* Installer improvements
* Rollback improvements
* Validation summary
* Compatibility
* Gallery overview
* Known issues
* SHA-256 checksum

---

# Allowed Release Files

Public releases may contain:

```text
Installer (.exe)
Gallery/
Release notes
CHANGELOG.md
SHA256.txt
README.md
```

---

# Forbidden Release Files

Public releases must never include:

```text
Game files
Commercial assets
Archive payloads
Temporary extraction folders
Debug logs
Private development tools
Build folders
Working directories
```

Examples:

```text
arc.exe
tmp/
obj/
bin/
debug.log
Backup/
```

---

# Release Checklist

Before publishing a public release, every supported title must successfully complete the following checklist.

## Source

* [x] SetupLauncher source updated
* [x] LegacyUI source updated
* [x] Inno Setup scripts updated
* [x] ArcRunner source updated
* [x] Splash source updated
* [x] Documentation reviewed

---

## Build

* [x] SetupLauncher published (Release)
* [x] LegacyUI published (Release)
* [x] Backend compiled successfully
* [x] Splash compiled
* [x] ArcRunner compiled

---

## Deployment

* [x] backend.exe copied to `_backend`
* [x] `setup_launcher.ini` generated
* [x] Launcher icons verified
* [x] AppId verified
* [x] Backend validation verified

---

## Installation

* [x] Mandatory requirements verified
* [x] Game detection verified
* [x] Installation validation verified
* [x] Archive extraction completed
* [x] Installation completed
* [x] Optional components verified
* [x] MOVIES package verified (where applicable)

---

## Rollback

* [x] RestoreData created
* [x] `install_manifest.txt` generated
* [x] `new_files_manifest.txt` generated
* [x] Changed files backed up
* [x] New files tracked
* [x] Restore completed successfully
* [x] Empty directories removed

---

## Validation

* [x] Gameplay verified
* [x] Rollback completed
* [x] Compare-Object verification passed
* [x] Restored installation matches vanilla patched reference

---

## Documentation

* [x] README updated
* [x] CHANGELOG updated
* [x] Release READMEs updated
* [x] Gallery synchronized
* [x] Release engineering documentation synchronized
* [x] Validation documentation synchronized

---

## Release

* [ ] SHA-256 generated
* [ ] Git tag created
* [ ] GitHub Release created
* [ ] Public installer uploaded

---

# Release Philosophy

A release is considered complete only when:

1. Mandatory requirements are verified.
2. Installation succeeds.
3. Installation validation succeeds.
4. Gameplay verification succeeds.
5. Rollback succeeds.
6. RestoreData successfully restores the original installation.
7. Verification confirms the restored installation matches the original patched reference.
8. Documentation and galleries are synchronized across the repository.

Installer reliability, deterministic restoration, comprehensive documentation, and preservation of the original games are prioritized over release speed.
