# NFS Legacy Modpacks

> **A preservation-focused installer framework for the classic PC Need for Speed titles (2003–2008).**

[![Release](https://img.shields.io/badge/Release-2.0.0-2ea44f?style=for-the-badge)](https://github.com/Gxbbykko/NFS-Legacy-Modpacks/releases)
[![License](https://img.shields.io/github/license/Gxbbykko/NFS-Legacy-Modpacks?style=for-the-badge)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Windows%2010%20%7C%2011-0078D6?style=for-the-badge)](#)
[![Games](https://img.shields.io/badge/Games-6%20Supported-ea4c89?style=for-the-badge)](#)

[![Installer](https://img.shields.io/badge/Installer-Inno%20Setup-ff9800?style=for-the-badge)](#)
[![Frontend](https://img.shields.io/badge/Frontend-LegacyUI-6f42c1?style=for-the-badge)](#)
[![Rollback](https://img.shields.io/badge/Rollback-Deterministic-28a745?style=for-the-badge)](#)
[![Validation](https://img.shields.io/badge/Validation-SHA--256%20Verified-1f6feb?style=for-the-badge)](#)

[![Framework](https://img.shields.io/badge/.NET-10.0-512BD4?style=for-the-badge)](#)
[![PowerShell](https://img.shields.io/badge/PowerShell-7+-5391FE?style=for-the-badge)](#)
[![FreeArc](https://img.shields.io/badge/Compression-FreeArc-7952B3?style=for-the-badge)](#)
[![Status](https://img.shields.io/badge/Project-Active-success?style=for-the-badge)](#)

NFS Legacy Modpacks is an open-source preservation project dedicated to modernizing the installation experience of the classic PC **Need for Speed** titles while respecting their original gameplay, artistic direction, and identity.

Rather than recreating or remastering the games, the project provides a standardized installer framework that integrates carefully selected community-created improvements into a safe, reproducible, and fully reversible installation process.

Every supported title is built upon the shared **Release 2.0** installer architecture, combining **SetupLauncher**, **LegacyUI**, a validated **Inno Setup** backend, **ArcRunner**, **FreeArc**, deterministic rollback, comprehensive validation, and a standardized deployment workflow.

The project's highest priorities are installer reliability, restoration safety, long-term maintainability, and preservation of the original games, ensuring users can always return their installation to its original patched state.

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
* Release Galleries
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

> **IMPORTANT**
>
> Every installer validates these requirements before installation. Unsupported installations are intentionally rejected to prevent unreliable installs, incomplete rollback, or compatibility issues.

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

## Unified Installer Architecture

Every supported game now shares a common installer platform consisting of:

* SetupLauncher
* LegacyUI
* Inno Setup Backend
* ArcRunner
* FreeArc
* RestoreData Rollback

This architecture provides a consistent installation experience while allowing title-specific validation, rollback, and optional component handling.

---

## Deterministic Rollback

Release 2.0 introduces a standardized rollback engine capable of restoring the original patched game installation after uninstall.

The rollback system includes:

* Backup of overwritten files only
* Manifest-driven uninstall
* Automatic restoration of overwritten files
* Automatic removal of newly installed files
* Empty directory cleanup
* SHA-256 validation support
* Compare-Object verification

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
* Rollback verification

---

## Repository Standardization

The repository has been reorganized into a unified engineering structure including:

* Shared installer templates
* Source code for all installer components
* Engineering documentation
* Release documentation
* Screenshot galleries
* Validation methodology
* Release engineering standards
* Credits and attribution

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
* RestoreData metadata generation

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
* Reproducible release methodology

---

# Gallery

Every supported title contains a dedicated release gallery documenting the installer and validation workflow.

Each gallery includes:

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

Each component has a dedicated responsibility within the Release 2.0 installer framework.

| Component          | Purpose                                       |
| ------------------ | --------------------------------------------- |
| SetupLauncher      | Bootstrap launcher and backend initialization |
| LegacyUI           | Modern installation interface                 |
| Inno Setup Backend | Core installation engine                      |
| ArcRunner          | FreeArc extraction controller                 |
| FreeArc            | High-compression payload extraction           |
| RestoreData        | Rollback infrastructure                       |

This modular architecture simplifies maintenance while ensuring identical installer behavior across every supported title.

---

# Installation Workflow

Every installer follows the same validated installation workflow.

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

The installer records every required file to guarantee deterministic restoration during uninstall while protecting the original patched installation.

---

# Rollback Architecture

Rollback safety is one of the core engineering principles of Release 2.0.

Each installation generates the following structure inside the game directory:

```text
_LegacyInstaller
│
├── install_manifest.txt
├── new_files_manifest.txt
└── RestoreData
    └── Backup
```

The rollback engine performs restoration using the following sequence:

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

Only files that are actually overwritten are backed up. Newly introduced files are tracked separately through `new_files_manifest.txt`, allowing the installer to restore the game efficiently while minimizing backup size.

---

# Validation Methodology

Every public release follows the same validation methodology before publication.

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
* Empty directories were cleaned up.
* The restored installation matches the original patched reference.

This deterministic validation process is mandatory for every supported title before a public release is published.

---

# Repository Structure

The repository is organized into independent components that separate source code, documentation, release assets, templates, and validation resources.

```text
NFS-Legacy-Modpacks/
│
├── docs/
├── releases/
├── screenshots/
├── source/
├── templates/
├── CREDITS.md
├── CHANGELOG.md
├── LICENSE
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
| CREDITS.md   | Community acknowledgements and attribution   |
| README.md    | Project overview                             |
| CHANGELOG.md | Release history                              |
| LICENSE      | Project license                              |

---

# Documentation

The repository documentation is organized into dedicated engineering references.

| Document                          | Description                            |
| --------------------------------- | -------------------------------------- |
| `README.md`                       | Project overview                       |
| `CREDITS.md`                      | Community contributors and attribution |
| `CHANGELOG.md`                    | Release history                        |
| `docs/build-notes.md`             | Internal build workflow                |
| `docs/release-checklist.md`       | Release validation checklist           |
| `docs/release-engineering.md`     | Engineering and publishing workflow    |
| `docs/rollback-validation.md`     | Rollback methodology                   |
| `docs/hashing-commands.md`        | SHA-256 validation commands            |
| `docs/github-release-template.md` | Standardized GitHub release template   |

Together, these documents describe the engineering practices, release workflow, validation methodology, attribution policy, and repository standards that define the Release 2.0 framework.

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

* Release-specific README
* Installation workflow screenshots
* Validation screenshots
* Gameplay comparisons
* Mandatory installation requirements
* Rollback verification
* Restore Tool demonstration
* Version verification
* Large Address Aware verification

The galleries provide visual documentation of the Release 2.0 installer framework while preserving the repository's focus on engineering transparency and reproducible validation.

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

Future development will continue building upon the Release 2.0 installer framework while maintaining compatibility with the existing architecture.

Planned future work includes:

* Installer maintenance
* Compatibility updates
* Community-requested improvements
* Documentation expansion
* Additional release galleries
* Performance optimizations
* Quality-of-life improvements
* Continued validation across supported titles

Future architectural work continues to use the **Need for Speed Underground** implementation as the reference baseline before being adopted by the remaining supported games.

---

# Contributing

Community contributions are welcome.

Areas where contributors can help include:

* Installer improvements
* Documentation
* Testing
* Bug fixes
* Validation tooling
* User interface improvements
* Translation updates
* Compatibility research

Before contributing significant architectural changes, please review the documentation inside the `docs/` directory to ensure compatibility with the Release 2.0 engineering framework.

---

# Project Principles

Every contribution should respect the engineering principles that define NFS Legacy Modpacks.

## Preservation First

Maintain the original gameplay experience while improving compatibility, stability, usability, and long-term preservation.

---

## Reliability Before Features

Installer reliability, validation, and rollback integrity always take priority over introducing additional functionality.

---

## Deterministic Rollback

Every supported installer must remain capable of restoring the original patched installation without leaving residual files.

---

## Reproducible Releases

Every public release should be reproducible using the documented engineering workflow, validation methodology, and release process.

---

## Transparency

Engineering decisions, release workflows, validation methodologies, and attribution are documented publicly to encourage long-term maintainability and community collaboration.

---

# License

This project is licensed under the **MIT License**.

The complete license text is available in the `LICENSE` file located in the root of this repository.

---

# Legal Notice

NFS Legacy Modpacks is an independent community preservation project.

This repository is **not affiliated with, endorsed by, sponsored by, or associated with Electronic Arts Inc., EA Canada, EA Black Box, or any of their subsidiaries, licensors, or trademark holders.**

Need for Speed and all associated trademarks, logos, artwork, and copyrighted materials remain the property of their respective owners.

This repository intentionally **does not distribute**:

* Original game files
* EA copyrighted assets
* Commercial game content
* Original game executables
* FreeArc payload archives containing copyrighted material
* Proprietary third-party assets

Every installer contained within this project has been designed to install community-created enhancements onto a legally owned copy of the original PC game.

Users are responsible for obtaining the original games through legitimate means and ensuring compliance with all applicable licenses and copyright laws.

---

# Acknowledgements

NFS Legacy Modpacks exists thanks to years of work contributed by the Need for Speed community.

The project builds upon the knowledge, research, reverse engineering, compatibility fixes, tooling, testing, preservation efforts, and creativity of countless developers, artists, reverse engineers, and enthusiasts.

Special thanks go to every contributor whose work has helped preserve the classic Need for Speed titles for modern hardware and operating systems.

Individual modifications remain the intellectual property of their respective authors and are credited according to their original licenses, permissions, and distribution terms.

Complete attribution for every evaluated and integrated community project can be found in **CREDITS.md**.

NFS Legacy Modpacks serves as a standardized installation and preservation framework that safely integrates compatible community-created enhancements while respecting and acknowledging their original authors.

---

# Final Statement

Release 2.0 represents the completion of the first fully standardized installer framework developed for NFS Legacy Modpacks.

Across all six supported Need for Speed titles, the project now provides:

* A unified installer architecture
* A consistent user experience
* Mandatory installation validation
* Deterministic rollback
* Manifest-driven restoration
* RestoreData backup architecture
* Standardized release engineering
* Comprehensive documentation
* Complete attribution
* Reproducible validation methodology

Rather than simply packaging community modifications together, Release 2.0 establishes a maintainable engineering platform that can continue evolving while preserving compatibility, reliability, transparency, and restoration safety.

Future releases will continue building upon this foundation without compromising the project's core principles of preservation, reproducibility, deterministic rollback, and respect for the original games and their community.

---

# Project Status

| Component                  |         Status         |
| -------------------------- | :--------------------: |
| Repository                 | ✅ Release 2.0 Complete |
| Installer Framework        |       ✅ Complete       |
| Rollback Architecture      |       ✅ Complete       |
| Validation Methodology     |       ✅ Complete       |
| Engineering Documentation  |       ✅ Complete       |
| Community Attribution      |       ✅ Complete       |
| Repository Standardization |       ✅ Complete       |

The repository is now prepared to support future public releases through **GitHub Releases** and **Nexus Mods**, while maintaining a unified engineering workflow across every supported Need for Speed title.

---

> **Preserve the originals. Enhance the experience. Always provide a safe path back.**