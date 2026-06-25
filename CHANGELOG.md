# Changelog

All notable changes to **NFS Legacy Modpacks** are documented in this file.

The project follows a structured, release-oriented changelog documenting architectural milestones, installer evolution, rollback validation, and repository development.

---

# [2.0.0] - Release 2.0 Architecture Milestone

**Status:** Framework Complete / Fully Validated

Release 2.0 represents the completion of the unified installer architecture shared across every supported Need for Speed title.

This milestone concludes the transition from a traditional Inno Setup installer into a modular installer platform featuring a dedicated launcher, modern installation interface, optimized extraction pipeline, deterministic rollback system, and standardized deployment architecture.

Every supported title now shares the same validated installation and restoration framework.

---

## Added

### Installer Framework

* SetupLauncher launcher framework
* LegacyUI modern installation interface
* ArcRunner extraction controller
* Splash startup framework
* Unified installer architecture
* Standardized deployment pipeline

### Installation System

* Automatic game detection
* Installation validation
* Latest official patch verification
* Large Address Aware verification
* Optional component framework
* External package support
* Live installation logging
* Standardized installer workflow

### Rollback System

* RestoreData rollback architecture
* Changed-file backup system
* install_manifest.txt tracking
* new_files_manifest.txt tracking
* Manifest-driven uninstall
* Automatic restoration of overwritten files
* Automatic removal of newly installed files
* Empty directory cleanup
* RestoreData protection attributes
* SHA-256 comparison support
* Deterministic rollback workflow

### Repository

* Complete installer source tree
* SetupLauncher source
* LegacyUI source
* ArcRunner source
* Splash source
* Updated Inno Setup scripts
* Expanded documentation
* Screenshot documentation
* Release engineering documentation

---

## Changed

### Installer Architecture

The installer framework has been redesigned into a layered architecture.

Previous architecture:

```text
Setup.exe
        │
        ▼
Inno Setup
```

Current Release 2.0 architecture:

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
RestoreData Rollback
```

### Standardization

* Unified installer architecture across all supported titles
* NFSU Gold Master architecture adopted as the reference implementation
* Shared rollback engine
* Shared validation workflow
* Shared deployment structure
* Shared installer philosophy

---

## Validation

The Release 2.0 installer framework has been validated across every supported title.

| Game                         | Installation | Rollback |
| ---------------------------- | ------------ | -------- |
| Need for Speed Underground   | ✅ PASS       | ✅ PASS   |
| Need for Speed Underground 2 | ✅ PASS       | ✅ PASS   |
| Need for Speed Most Wanted   | ✅ PASS       | ✅ PASS   |
| Need for Speed Carbon        | ✅ PASS       | ✅ PASS   |
| Need for Speed ProStreet     | ✅ PASS       | ✅ PASS   |
| Need for Speed Undercover    | ✅ PASS       | ✅ PASS   |

Validation confirms:

* Successful installation
* Successful extraction
* Successful rollback
* Restoration of overwritten files
* Removal of newly installed files
* Cleanup of empty directories
* Restoration to the original patched installation

Rollback verification was performed by comparing the restored installation against a clean vanilla patched reference.

---

## Supported Installer Frameworks

* Need for Speed Underground
* Need for Speed Underground 2
* Need for Speed Most Wanted
* Need for Speed Carbon
* Need for Speed ProStreet
* Need for Speed Undercover

---

## Required Game Versions

> **IMPORTANT**
>
> Every supported title must be updated to the latest official version before installing a modpack.

| Game                         | Required Version |
| ---------------------------- | ---------------- |
| Need for Speed Underground   | **1.4.0**        |
| Need for Speed Underground 2 | **1.2.0**        |
| Need for Speed Most Wanted   | **1.3.0**        |
| Need for Speed Carbon        | **1.4.0**        |
| Need for Speed ProStreet     | **1.1.0**        |
| Need for Speed Undercover    | **1.0.0.1**      |

---

## Release Notes

Release 2.0 represents the first fully validated version of the installer framework.

Major milestones completed:

* Unified installer architecture
* Shared rollback architecture
* SetupLauncher integration
* LegacyUI integration
* ArcRunner integration
* RestoreData implementation
* Six-title validation
* Repository modernization
* Documentation overhaul

This release establishes the foundation for future public modpack releases while maintaining deterministic installation, deterministic rollback, and reproducible restoration across every supported title.

---

# Development History

## Alpha 0.3b

Framework stabilization milestone.

Major work completed during this phase:

* Initial installer architecture
* Rollback proof of concept
* Manifest tracking
* Validation methodology
* Repository standardization
* Initial documentation

This phase served as the foundation for the Release 2.0 architecture.

---

# Future Development

Future updates will focus on:

* Public Release packaging
* Documentation expansion
* Additional installer polish
* Expanded screenshot gallery
* Future compatibility improvements

---

# Versioning Policy

The project follows semantic versioning.

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

| Version | Meaning                                            |
| ------- | -------------------------------------------------- |
| Major   | Architectural changes                              |
| Minor   | New installer functionality                        |
| Patch   | Bug fixes, validation improvements and maintenance |

---

# Release Philosophy

A release is only considered complete when:

1. Installation succeeds.
2. Installation validation succeeds.
3. Rollback succeeds.
4. Restored installation matches the original patched reference.
5. Rollback verification passes.
6. Installer behavior is reproducible across every supported title.

Installer reliability, deterministic restoration, and preservation of the original games remain the highest priorities of the project.