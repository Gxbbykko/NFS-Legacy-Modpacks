# Changelog

All notable changes to **NFS Legacy Modpacks** are documented in this file.

The project follows a structured, release-oriented changelog documenting architectural milestones, installer evolution, rollback validation, repository development, and release engineering.

---

# [2.0.0] - Release 2.0 Architecture Milestone

**Status:** Framework Complete / Fully Validated

Release 2.0 represents the completion of the unified installer architecture shared across every supported Need for Speed title.

This milestone concludes the transition from a traditional Inno Setup installer into a modular installer platform featuring a dedicated launcher, modern installation interface, optimized extraction pipeline, deterministic rollback system, standardized deployment architecture, and comprehensive release documentation.

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
* Mandatory game version verification
* Large Address Aware (4GB Patch) verification
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
* Automatic empty directory cleanup
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
* Release engineering documentation
* Release-specific documentation
* Gallery documentation
* Mandatory Requirements documentation
* Gameplay comparison documentation

---

## Changed

### Installer Architecture

The installer framework has been redesigned into a layered architecture.

Previous architecture:

```text id="r8yg8i"
Setup.exe
        │
        ▼
Inno Setup
```

Current Release 2.0 architecture:

```text id="jdjlwm"
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
* NFSU gold-master architecture adopted as the reference implementation
* Shared rollback engine
* Shared validation workflow
* Shared deployment structure
* Shared installer philosophy
* Standardized release documentation
* Standardized gallery structure

---

## Validation

The Release 2.0 installer framework has been validated across every supported title.

| Game                         | Installation | Rollback |
| ---------------------------- | :----------: | :------: |
| Need for Speed Underground   |    ✅ PASS    |  ✅ PASS  |
| Need for Speed Underground 2 |    ✅ PASS    |  ✅ PASS  |
| Need for Speed Most Wanted   |    ✅ PASS    |  ✅ PASS  |
| Need for Speed Carbon        |    ✅ PASS    |  ✅ PASS  |
| Need for Speed ProStreet     |    ✅ PASS    |  ✅ PASS  |
| Need for Speed Undercover    |    ✅ PASS    |  ✅ PASS  |

Validation confirms:

* Successful installation
* Mandatory requirement verification
* Successful extraction
* Successful rollback
* Restoration of overwritten files
* Removal of newly installed files
* Cleanup of empty directories
* Restoration to the original patched installation
* Gameplay verification
* Release gallery documentation

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

> **MANDATORY**
>
> Every supported title must be updated to the latest officially supported version and have the Large Address Aware (4GB Patch) applied before installation.

| Game                         | Required Version                  |
| ---------------------------- | --------------------------------- |
| Need for Speed Underground   | **1.4**                           |
| Need for Speed Underground 2 | **1.2**                           |
| Need for Speed Most Wanted   | **1.3 (Black Edition supported)** |
| Need for Speed Carbon        | **Collector's Edition 1.4**       |
| Need for Speed ProStreet     | **1.1**                           |
| Need for Speed Undercover    | **1.0.0.1**                       |

These requirements are validated automatically by the installer.

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
* Release gallery system
* Mandatory Requirements documentation
* Before / After gameplay documentation

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

* Public release packaging
* Expanded documentation
* Additional installer polish
* Extended gallery documentation
* Future compatibility improvements
* Continuous maintenance of the standardized Release 2.0 architecture

---

# Versioning Policy

The project follows semantic versioning.

```text id="7grqfm"
Major.Minor.Patch
```

Examples:

```text id="p8rj44"
2.0.0
2.1.0
2.1.1
3.0.0
```

| Version | Meaning                                             |
| ------- | --------------------------------------------------- |
| Major   | Architectural changes                               |
| Minor   | New installer functionality                         |
| Patch   | Bug fixes, validation improvements, and maintenance |

---

# Release Philosophy

A release is only considered complete when:

1. Mandatory requirements are verified.
2. Installation succeeds.
3. Installation validation succeeds.
4. Gameplay verification succeeds.
5. Rollback succeeds.
6. Restored installation matches the original patched reference.
7. Compare-Object returns no differences.
8. Documentation and release galleries are synchronized.

Installer reliability, deterministic restoration, comprehensive documentation, and preservation of the original games remain the highest priorities of the project.
