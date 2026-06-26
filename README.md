# NFS Legacy Modpacks

> **A preservation-focused installer framework for the classic PC Need for Speed titles (2003–2008).**

<!-- Optional GitHub badges (replace URLs after first public release) -->

```text
[MIT License] [Release 2.0] [Windows] [C#] [Inno Setup] [PowerShell]
```

NFS Legacy Modpacks is an open-source preservation project dedicated to modernizing the installation experience of the classic PC **Need for Speed** titles while respecting their original gameplay, artistic direction, and identity.

Rather than recreating or remastering the games, the project provides a standardized installer framework that integrates carefully selected community-created improvements into a safe, reproducible, and fully reversible installation process.

Every supported title is built upon the shared **Release 2.0** installer architecture, combining a modern launcher, a dedicated installation interface, deterministic rollback, comprehensive validation, and a standardized deployment workflow.

The project's highest priorities are installer reliability, restoration safety, and long-term maintainability, ensuring users can always return their installation to its original patched state.

---

# Contents

* Project Philosophy
* Supported Games
* Quick Start
* Mandatory Requirements
* Release 2.0 Highlights
* Features
* Gallery
* Installer Architecture
* Installation Workflow
* Rollback Architecture
* Validation Methodology
* Repository Structure
* Documentation
* Current Project Status
* Roadmap
* Contributing
* Project Principles
* License
* Legal Notice
* Acknowledgements
* Final Statement

---

# Project Philosophy

The primary objective of NFS Legacy Modpacks is **preservation rather than replacement**.

The project does not attempt to redesign the original games or replace their artistic direction. Instead, it focuses on restoring and enhancing the original experience through carefully selected community-developed improvements that remain faithful to the vanilla games.

Every engineering decision follows the same guiding principles:

* Preserve the original game identity.
* Improve compatibility and usability.
* Keep installation predictable and reproducible.
* Guarantee deterministic rollback.
* Never permanently modify a user's installation.
* Maintain a unified installer architecture across every supported title.

Installation success represents only one half of the engineering process.

A release is considered complete only when uninstalling the modpack restores the original patched installation without leaving residual files or altering the game's validated baseline.

---

# Supported Games

Release 2.0 supports every classic Black Box Need for Speed title released for PC between 2003 and 2008.

| Game                         | Release Year |          Required Version         |    Status   |
| ---------------------------- | :----------: | :-------------------------------: | :---------: |
| Need for Speed Underground   |     2003     |              **1.4**              | ✅ Supported |
| Need for Speed Underground 2 |     2004     |              **1.2**              | ✅ Supported |
| Need for Speed Most Wanted   |     2005     | **1.3 (Black Edition supported)** | ✅ Supported |
| Need for Speed Carbon        |     2006     |    **Collector's Edition 1.4**    | ✅ Supported |
| Need for Speed ProStreet     |     2007     |              **1.1**              | ✅ Supported |
| Need for Speed Undercover    |     2008     |            **1.0.0.1**            | ✅ Supported |

Every supported title shares the same installer framework, rollback engine, validation methodology, and deployment workflow.

---

# Quick Start

Before installing any NFS Legacy Modpack:

1. Install the original PC version of the game.
2. Update the game to the latest officially supported version.
3. Apply the **Large Address Aware (4GB Patch)** where required.
4. Launch the installer.
5. Select the correct game directory.
6. Allow validation to complete.
7. Install the modpack.
8. Launch and enjoy the game.

To remove the modpack, run the included **Restore Tool**, which restores the original patched installation using the Release 2.0 rollback system.

---

# Mandatory Requirements

> **MANDATORY**
>
> Every installer validates these requirements before installation. Unsupported installations are intentionally rejected to prevent unreliable installs and incomplete rollback.

Before installing any NFS Legacy Modpack, ensure that:

* The game has been updated to the latest officially supported version.
* The installation is clean and unmodified.
* The executable has the **Large Address Aware (4GB Patch)** applied where required.
* The installation directory has not been modified by incompatible patches or unsupported tools.
* You legally own the original game.

These requirements are enforced because the Release 2.0 installer architecture performs mandatory validation before any files are deployed.

Failure to satisfy these requirements may prevent installation from continuing.

---

# Release 2.0 Highlights

Release 2.0 represents the completion of the standardized installer framework shared across every supported title.

Major milestones include:

## Unified Installer Architecture

Every supported game now shares a common installer platform consisting of:

* SetupLauncher
* LegacyUI
* Inno Setup Backend
* ArcRunner
* FreeArc
* RestoreData Rollback

This architecture provides a consistent installation experience while allowing title-specific validation and optional component handling.

---

## Deterministic Rollback

Release 2.0 introduces a standardized rollback engine capable of restoring the original patched game installation after uninstall.

The rollback system includes:

* Changed-file backup
* Manifest-driven uninstall
* Automatic restoration of overwritten files
* Automatic removal of newly installed files
* Empty directory cleanup
* SHA-256 validation support

---

## Shared Validation Framework

Every supported title now follows the same validation methodology.

Validation includes:

* Game executable verification
* Latest official patch verification
* Large Address Aware verification
* Required directory validation
* Critical file validation
* Installation integrity verification

---

## Repository Standardization

The repository has been reorganized into a consistent structure including:

* Shared installer templates
* Source code for all installer components
* Engineering documentation
* Release documentation
* Screenshot galleries
* Validation methodology
* Release engineering standards

---

# Features

Release 2.0 provides a consistent feature set across every supported installer.

## Installer

* Modern SetupLauncher bootstrap
* LegacyUI installation interface
* Automatic game detection
* Mandatory installation validation
* Live installation progress
* Optional component support
* External package framework
* Silent backend execution

---

## Installation

* Standardized deployment workflow
* FreeArc extraction pipeline
* ArcRunner extraction controller
* Automatic file deployment
* Installation logging
* Manifest generation
* Restore metadata generation

---

## Rollback

* RestoreData architecture
* Backup of overwritten files only
* install_manifest.txt tracking
* new_files_manifest.txt tracking
* Automatic restoration
* Automatic cleanup
* Deterministic uninstall workflow

---

## Validation

* SHA-256 comparison workflow
* Compare-Object verification
* Clean rollback validation
* Gameplay verification
* Installation verification
* Release reproducibility

---

# Gallery

Every supported title contains a dedicated release gallery documenting the installer and validation workflow.

Gallery documentation includes:

* Mandatory installation requirements
* Installer workflow
* Installation progress
* Main menu comparisons
* Gameplay comparisons
* Rollback validation
* Restore Tool workflow
* SHA-256 verification
* Version validation
* Large Address Aware verification

Release galleries are located under:

```text
releases/
├── Underground/
├── Underground2/
├── MostWanted/
├── Carbon/
├── ProStreet/
└── Undercover/
```

These galleries serve as visual documentation for both users and contributors while demonstrating the Release 2.0 validation methodology.

---

# Installer Architecture

Every installer included in NFS Legacy Modpacks follows the same engineering architecture.

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

Each component has a dedicated responsibility.

| Component          | Purpose                                       |
| ------------------ | --------------------------------------------- |
| SetupLauncher      | Bootstrap launcher and backend initialization |
| LegacyUI           | Modern installation interface                 |
| Inno Setup Backend | Core installation engine                      |
| ArcRunner          | Extraction controller                         |
| FreeArc            | Payload extraction                            |
| RestoreData        | Rollback infrastructure                       |

This modular architecture simplifies maintenance while ensuring identical behavior across every supported title.

---

# Installation Workflow

Every installer follows the same validated workflow.

```text
Launch Installer
        │
        ▼
Game Detection
        │
        ▼
Mandatory Validation
        │
        ▼
Archive Extraction
        │
        ▼
File Deployment
        │
        ▼
Manifest Generation
        │
        ▼
Installation Complete
```

Rollback metadata is generated automatically during installation.

The installer records every required file to guarantee deterministic restoration during uninstall.

---

# Rollback Architecture

Rollback safety is a core design principle of Release 2.0.

Each installation creates the following structure:

```text
_LegacyInstaller
│
├── install_manifest.txt
├── new_files_manifest.txt
└── RestoreData
    └── Backup
```

The rollback engine performs restoration in the following order:

```text
Delete Newly Installed Files
        │
        ▼
Restore Overwritten Originals
        │
        ▼
Title-Specific Cleanup
        │
        ▼
Remove Empty Directories
        │
        ▼
Rollback Complete
```

Only files that are actually overwritten are backed up, minimizing storage requirements while preserving complete restoration capability.

---

# Validation Methodology

Every public release follows the same validation process before publication.

Validation is performed against a **clean, fully patched reference installation** and consists of installation verification, gameplay verification, rollback verification, and SHA-256 filesystem comparison.

Validation workflow:

```text
Clean Patched Installation
        │
        ▼
Baseline Snapshot
        │
        ▼
Install Modpack
        │
        ▼
Gameplay Verification
        │
        ▼
Run Restore Tool
        │
        ▼
Rollback Verification
        │
        ▼
SHA-256 Compare-Object Validation
```

A successful validation confirms:

* Installation completed successfully.
* Gameplay functions correctly.
* Rollback restored every overwritten file.
* Newly installed files were removed.
* No empty directories remain.
* The restored installation matches the original patched reference.

---

# Repository Structure

The repository is organized into independent components that separate source code, documentation, release assets, and validation resources.

```text
NFS-Legacy-Modpacks/
│
├── docs/
├── releases/
├── screenshots/
├── source/
├── templates/
├── LICENSE
├── CHANGELOG.md
├── README.md
└── .gitignore
```

Each directory has a dedicated purpose.

| Directory    | Purpose                                      |
| ------------ | -------------------------------------------- |
| docs/        | Engineering and release documentation        |
| releases/    | Per-title release information and galleries  |
| screenshots/ | Repository screenshots and validation assets |
| source/      | Source code for all installer components     |
| templates/   | Shared installer templates                   |
| README.md    | Project overview                             |
| CHANGELOG.md | Project history                              |
| LICENSE      | Project license                              |

---

# Documentation

The repository documentation is organized into dedicated engineering references.

| Document                                                   | Description                         |
| ---------------------------------------------------------- | ----------------------------------- |
| [README.md](README.md)                                     | Project overview                    |
| [CHANGELOG.md](CHANGELOG.md)                               | Release history                     |
| [Build Notes](docs/build-notes.md)                         | Internal build workflow             |
| [Release Checklist](docs/release-checklist.md)             | Release validation checklist        |
| [Release Engineering](docs/release-engineering.md)         | Engineering and publishing workflow |
| [Rollback Validation](docs/rollback-validation.md)         | Rollback methodology                |
| [Hashing Commands](docs/hashing-commands.md)               | SHA-256 validation commands         |
| [GitHub Release Template](docs/github-release-template.md) | Standardized release notes template |

These documents collectively describe the engineering practices, validation methodology, release process, and repository standards used throughout the project.

---

# Release Galleries

Each supported title includes its own release documentation and validation gallery.

```text
releases/
├── Underground/
├── Underground2/
├── MostWanted/
├── Carbon/
├── ProStreet/
└── Undercover/
```

Each release directory contains:

* Release README
* Validation screenshots
* Gameplay comparisons
* Installer workflow
* Mandatory requirements
* Rollback proof
* Version verification
* Large Address Aware verification

These galleries provide visual documentation of the Release 2.0 installer framework without distributing copyrighted game assets.

---

# Current Project Status

## Repository

| Component               |   Status   |
| ----------------------- | :--------: |
| Documentation           | ✅ Complete |
| Installer Framework     | ✅ Complete |
| Rollback Architecture   | ✅ Complete |
| Validation Workflow     | ✅ Complete |
| Release Engineering     | ✅ Complete |
| Repository Organization | ✅ Complete |

---

## Supported Titles

| Game                         | Installer | Rollback | Validation |
| ---------------------------- | :-------: | :------: | :--------: |
| Need for Speed Underground   |     ✅     |     ✅    |      ✅     |
| Need for Speed Underground 2 |     ✅     |     ✅    |      ✅     |
| Need for Speed Most Wanted   |     ✅     |     ✅    |      ✅     |
| Need for Speed Carbon        |     ✅     |     ✅    |      ✅     |
| Need for Speed ProStreet     |     ✅     |     ✅    |      ✅     |
| Need for Speed Undercover    |     ✅     |     ✅    |      ✅     |

Release 2.0 establishes a unified engineering baseline shared across every supported title.

---

# Roadmap

Future development will continue building upon the Release 2.0 framework while preserving compatibility with the existing installer architecture.

Planned future work includes:

* Installer maintenance
* Compatibility updates
* Community-requested improvements
* Documentation expansion
* Additional release galleries
* Quality-of-life improvements
* Ongoing validation

Future architectural work will continue using the **Need for Speed Underground** implementation as the reference baseline before being adopted by the remaining supported titles.

---

# Contributing

Contributions are welcome.

Areas where contributors can help include:

* Installer improvements
* Documentation
* Testing
* Bug fixes
* Validation tooling
* User interface improvements
* Translation updates

Before contributing significant architectural changes, please review the documentation in the `docs/` directory to ensure compatibility with the Release 2.0 engineering framework.

---

# Project Principles

Every contribution should respect the principles that define NFS Legacy Modpacks.

## Preservation First

Maintain the original gameplay experience while improving compatibility, stability, and usability.

---

## Reliability Before Features

Installer reliability always takes priority over introducing additional functionality.

---

## Deterministic Rollback

Every supported installer must remain capable of restoring the original patched installation.

---

## Reproducible Releases

Every public release should be reproducible using the documented engineering workflow and validation methodology.

---

## Transparency

Engineering decisions, release workflows, and validation methodologies are documented publicly to ensure long-term maintainability and contributor accessibility.

---

# License

This project is licensed under the **MIT License**.

The full license text is available in the `LICENSE` file included with this repository.

---

# Legal Notice

NFS Legacy Modpacks is an independent community preservation project.

This repository is **not affiliated with, endorsed by, sponsored by, or associated with Electronic Arts Inc., EA Canada, EA Black Box, or any of their subsidiaries, licensors, or trademark holders.**

Need for Speed and all associated trademarks, logos, artwork, and copyrighted materials remain the property of their respective owners.

This repository intentionally **does not distribute**:

* Original game files.
* EA copyrighted assets.
* Commercial game content.
* Game executables.
* FreeArc payload archives containing copyrighted material.
* Proprietary third-party assets.

Every installer contained within this project has been designed to install community-created enhancements onto a legally owned copy of the original game.

Users are responsible for obtaining the original games through legitimate means and ensuring compliance with all applicable licenses and copyright laws.

---

# Acknowledgements

NFS Legacy Modpacks exists thanks to years of work contributed by the Need for Speed community.

The project builds upon the knowledge, research, reverse engineering, compatibility fixes, tooling, testing, and preservation efforts created by countless community developers, artists, and enthusiasts.

Special thanks go to every community member whose work has helped preserve the classic Need for Speed titles for modern hardware and operating systems.

Individual modifications remain the intellectual work of their respective authors and should always be credited according to their original licenses and distribution terms.

NFS Legacy Modpacks serves as a standardized installation and preservation framework that integrates compatible community projects while respecting their original authorship.

---

# Final Statement

Release 2.0 represents the completion of the first fully standardized installer framework developed for NFS Legacy Modpacks.

Across all six supported Need for Speed titles, the project now provides:

* A unified installer architecture.
* A consistent user experience.
* Mandatory installation validation.
* Deterministic rollback.
* Manifest-driven restoration.
* RestoreData backup architecture.
* Standardized release engineering.
* Comprehensive documentation.
* Reproducible validation methodology.

Rather than simply packaging modifications together, Release 2.0 establishes a maintainable engineering platform that can continue evolving while preserving compatibility, reliability, and restoration safety.

Future releases will continue building upon this foundation without compromising the project's core principles of preservation, reproducibility, and deterministic rollback.

---

# Project Status

**Repository Status:** ✅ Release 2.0 Complete

**Installer Framework:** ✅ Complete

**Rollback Architecture:** ✅ Complete

**Engineering Documentation:** ✅ Complete

**Validation Methodology:** ✅ Complete

**Repository Standardization:** ✅ Complete

The repository is now prepared to support future public releases through **GitHub Releases** and **Nexus Mods**, while maintaining a unified engineering workflow across every supported Need for Speed title.

---

> **Preserve the originals. Improve the experience. Always provide a safe path back.**