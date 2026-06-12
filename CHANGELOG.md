# Changelog

All notable changes to **NFS Legacy Modpacks** will be documented in this file.

The format follows a structured release-based changelog designed for reproducible installer development and rollback validation.

---

## [Unreleased]

### Added

* Release engineering documentation
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

### Changed

* Standardized installer architecture across supported titles
* Improved repository structure and documentation layout
* Improved README formatting and GitHub presentation
* Added rollback-safe installer philosophy documentation
* Improved screenshot organization and naming consistency

### Installer Support

* Need for Speed Underground
* Need for Speed Underground 2
* Need for Speed Most Wanted
* Need for Speed Carbon
* Need for Speed ProStreet
* Need for Speed Undercover

### Validation

* Rollback validation workflow documented
* SHA256 comparison workflow documented
* Manifest-based uninstall verification documented
* Deterministic rollback methodology documented

---

## [1.0.0] - Planned

### Planned Release Scope

Initial public release of the **NFS Legacy Modpacks installer framework**.

Expected contents:

* Standardized installer architecture
* Rollback-safe uninstall workflow
* Manifest tracking system
* Validation system
* Documentation package
* Release engineering workflow

### Release Goals

* Deterministic installation
* Deterministic rollback
* Clean uninstall validation
* Reliable installer behavior
* Consistent release packaging

---

## Versioning Policy

This project follows:

```txt
Major.Minor.Patch
```

Examples:

```txt
1.0.0
1.1.0
1.1.1
2.0.0
```

### Meaning

| Version Type | Purpose                                |
| ------------ | -------------------------------------- |
| **Major**    | Large architectural changes            |
| **Minor**    | New installer features or improvements |
| **Patch**    | Bug fixes and validation fixes         |

---

## Release Philosophy

A release is only considered complete when:

1. Installation succeeds
2. Uninstallation succeeds
3. Rollback validation passes
4. Original game state is restored
5. SHA256 verification is generated

No public release should be published without rollback validation.
