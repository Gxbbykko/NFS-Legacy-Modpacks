# Changelog

All notable changes to **NFS Legacy Modpacks** will be documented in this file.

The format follows a structured release-based changelog designed for reproducible installer development, rollback validation, and restoration-safe deployment.

---

## [Unreleased]

### Coming Soon

Further improvements, polish, validation updates, and installer refinements are planned.

No release timeline is currently available.

---

## [Alpha 0.3b] - Current Pre-Release

**Status:** Pre-build / Pre-release

This version represents the current **architecture-finalized installer framework** for legacy Need for Speed modpacks.

The project is currently in a **pre-release stabilization phase**, focused on:

* Installer architecture finalization
* Rollback reliability
* Manifest tracking
* Validation workflows
* Documentation maturity
* Repository standardization

This release should be considered a **testing and framework milestone**, not a final public release.

### Added

* Release engineering documentation
* GitHub release template
* Screenshot system and repository visual documentation
* Rollback validation proof screenshots
* Installer workflow screenshots
* Release checklist documentation
* Build notes documentation
* Hashing command documentation
* Rollback validation documentation
* Shared installer template
* Standardized repository structure
* MIT License
* Project README
* Standardized changelog format

### Changed

* Standardized installer architecture across supported titles
* Improved repository structure and documentation layout
* Improved README formatting and GitHub presentation
* Added rollback-safe installer philosophy documentation
* Improved screenshot organization and naming consistency
* Standardized release engineering workflow
* Improved installer rollback validation methodology

### Installer Support

Current supported installer frameworks:

* Need for Speed Underground
* Need for Speed Underground 2
* Need for Speed Most Wanted
* Need for Speed Carbon
* Need for Speed ProStreet
* Need for Speed Undercover

### Required Game Versions

> **IMPORTANT**
>
> All supported titles **must be patched to the latest official version before installation**.
>
> Unsupported or unpatched game versions may result in:
>
> * Failed installation
> * Missing assets
> * Crashes
> * Incorrect rollback behavior
> * Mod incompatibility

| Game                         | Required Version |
| ---------------------------- | ---------------- |
| Need for Speed Underground   | **1.4.0**        |
| Need for Speed Underground 2 | **1.2.0**        |
| Need for Speed Most Wanted   | **1.3.0**        |
| Need for Speed Carbon        | **1.4.0**        |
| Need for Speed ProStreet     | **1.1.0**        |
| Need for Speed Undercover    | **1.0.0.1**      |

### Validation

* Rollback validation workflow documented
* SHA256 comparison workflow documented
* Manifest-based uninstall verification documented
* Deterministic rollback methodology documented
* Rollback-safe uninstall system verified

### Release Notes

This version is considered a **framework milestone release**.

Future updates, improvements, and additional polishing are planned.

**No ETA is currently available.**

---

## [1.0.0] - Planned Stable Release

### Planned Release Scope

Initial stable public release of the **NFS Legacy Modpacks installer framework**.

Expected contents:

* Standardized installer architecture
* Rollback-safe uninstall workflow
* Manifest tracking system
* Validation system
* Documentation package
* Release engineering workflow
* Stable installer packaging
* Expanded compatibility testing

### Release Goals

* Deterministic installation
* Deterministic rollback
* Clean uninstall validation
* Reliable installer behavior
* Consistent release packaging
* Stable public-ready experience

---

## Versioning Policy

This project follows:

```txt
Major.Minor.Patch
```

Examples:

```txt
0.3.0-alpha
0.5.0-beta
1.0.0
1.1.0
1.1.1
2.0.0
```

### Meaning

| Version Type    | Purpose                                |
| --------------- | -------------------------------------- |
| **Major**       | Large architectural changes            |
| **Minor**       | New installer features or improvements |
| **Patch**       | Bug fixes and validation fixes         |
| **Pre-release** | Framework testing and stabilization    |

---

## Release Philosophy

A release is only considered complete when:

1. Installation succeeds
2. Uninstallation succeeds
3. Rollback validation passes
4. Original game state is restored
5. SHA256 verification is generated

Installer reliability is prioritized over release speed.

No public release should be published without rollback validation.
