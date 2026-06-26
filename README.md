# NFS Legacy Modpacks

> **A preservation-focused installer framework for the classic PC Need for Speed titles (2003–2008).**

NFS Legacy Modpacks is an open-source project dedicated to preserving and modernizing the installation experience of the classic **Need for Speed** games while respecting their original gameplay, art direction, and identity.

Rather than recreating or remastering the games, this project provides a standardized installer framework that integrates carefully selected community-made improvements into a safe, reproducible, and fully reversible installation process.

Every installer is built around a shared **Release 2.0 architecture**, combining a modern user interface, deterministic rollback, comprehensive validation, and standardized deployment across every supported title.

The project emphasizes installation reliability, restoration safety, and long-term maintainability above feature count, ensuring that users can always return their game to its original patched state.

---

# Project Philosophy

The primary objective of NFS Legacy Modpacks is **preservation rather than replacement**.

The project does not attempt to redesign the games or replace their original artistic direction. Instead, it focuses on restoring and enhancing the original experience using community-created improvements that remain faithful to the vanilla games.

Every design decision follows the same principles:

* Preserve the original game identity.
* Improve compatibility and usability.
* Keep the installation process simple.
* Guarantee deterministic rollback.
* Never permanently modify the user's installation.
* Maintain a unified architecture across every supported title.

Installation success is only one part of the engineering process.

A release is considered complete only when the installer is capable of restoring the original patched installation without leaving residual files or modifying the user's game beyond the intended installation.

---

# Supported Games

Release 2.0 currently supports every classic Black Box Need for Speed title released for PC between 2003 and 2008.

| Game                         | Release Year |          Required Version         |    Status   |
| ---------------------------- | :----------: | :-------------------------------: | :---------: |
| Need for Speed Underground   |     2003     |              **1.4**              | ✅ Supported |
| Need for Speed Underground 2 |     2004     |              **1.2**              | ✅ Supported |
| Need for Speed Most Wanted   |     2005     | **1.3 (Black Edition supported)** | ✅ Supported |
| Need for Speed Carbon        |     2006     |    **Collector's Edition 1.4**    | ✅ Supported |
| Need for Speed ProStreet     |     2007     |              **1.1**              | ✅ Supported |
| Need for Speed Undercover    |     2008     |            **1.0.0.1**            | ✅ Supported |

Every supported title shares the same Release 2.0 installer framework, rollback engine, deployment workflow, and validation methodology.

---

# Mandatory Requirements

> **MANDATORY**
>
> Every installer validates these requirements before installation. Unsupported game installations are intentionally rejected to prevent broken installs and unreliable rollback behavior.

Before installing any NFS Legacy Modpack, ensure that:

* The game is updated to the latest officially supported version.
* The game is installed on a clean, unmodified installation.
* The executable has the **Large Address Aware (4GB Patch)** applied where required.
* The installation directory has not been modified by incompatible tools or unofficial patches.
* You legally own the original game.

These requirements are enforced because the Release 2.0 installer architecture relies on deterministic validation before deploying any files.

---

# Release 2.0 Highlights

Release 2.0 represents the largest architectural milestone of the project.

Major improvements include:

### Unified Installer Framework

* Shared installer architecture across all supported games.
* Modern SetupLauncher bootstrapper.
* LegacyUI installation interface.
* Hidden Inno Setup backend.
* ArcRunner extraction controller.
* FreeArc payload extraction.

---

### Deterministic Rollback

Every installer includes the standardized **RestoreData** rollback architecture.

Features include:

* Automatic backup of overwritten files.
* Tracking of newly installed files.
* Manifest-driven uninstall.
* Automatic restoration of original game files.
* Automatic cleanup of empty directories.
* Deterministic rollback validation using SHA-256 comparison.

---

### Validation-First Installation

Before installation begins, every installer validates:

* Supported game executable.
* Required game version.
* Large Address Aware (4GB Patch) status.
* Required game folders.
* Critical file integrity.
* Installer configuration.

Unsupported installations are rejected before any files are modified.

---

### Standardized Deployment

Every supported title follows the same engineering workflow:

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

This architecture is shared across every Release 2.0 installer and serves as the foundation for future development.

---

# Features

The Release 2.0 installer framework provides:

## Installation

* Automatic game detection.
* Installation validation.
* Live installation progress.
* Optional component support.
* Standardized deployment workflow.
* Unified installation experience across all supported titles.

## Rollback

* RestoreData rollback architecture.
* Automatic backup restoration.
* Manifest-driven uninstall.
* Removal of newly installed files.
* Empty directory cleanup.
* Deterministic restoration.

## Validation

* Mandatory requirement verification.
* SHA-256 rollback validation.
* Gameplay verification.
* Installation verification.
* Repository-wide engineering standards.
* Reproducible release methodology.

# Gallery

The repository includes an extensive collection of screenshots documenting the Release 2.0 installer framework.

The gallery serves both as visual documentation and as engineering evidence demonstrating installation behavior, validation workflows, rollback verification, and gameplay preservation.

Screenshots are organized by supported title and validation category to ensure every public release remains transparent and reproducible.

---

## Gallery Categories

Each supported title contains its own gallery documenting the complete installation lifecycle.

Typical gallery contents include:

### Mandatory Requirements

Documentation proving the required game version and Large Address Aware (4GB Patch) implementation.

Examples include:

* Executable version information
* Large Address Aware verification
* Supported game executable
* Required patch verification

---

### Installer Workflow

Visual documentation of the Release 2.0 installer experience.

Typical screenshots include:

* SetupLauncher
* Splash screen
* LegacyUI
* Game detection
* Installation progress
* Successful installation
* Restore Tool

---

### Rollback Validation

Engineering proof demonstrating deterministic restoration.

Typical screenshots include:

* RestoreData structure
* install_manifest.txt
* new_files_manifest.txt
* Backup directory
* Compare-Object verification
* Successful rollback

---

### Gameplay Comparison

Each release also documents the installed modpack through gameplay comparisons.

Typical captures include:

* Main Menu
* Frontend improvements
* Visual enhancements
* Gameplay screenshots

Where appropriate, before and after comparisons are included to demonstrate the changes introduced by the modpack while preserving the original artistic style of the game.

---

# Installer Architecture

Every supported title shares the same Release 2.0 architecture.

Unlike traditional game mod installers, NFS Legacy Modpacks separates the installation process into dedicated components responsible for launching, user interaction, deployment, extraction, validation, and rollback.

This layered architecture improves maintainability, simplifies debugging, and guarantees identical behavior across all supported titles.

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

Every layer performs a dedicated responsibility before handing control to the next stage.

---

## SetupLauncher

SetupLauncher is the public entry point for every Release 2.0 installer.

Responsibilities include:

* Launcher bootstrap
* Backend discovery
* AppId verification
* Launcher configuration
* Installer initialization

---

## LegacyUI

LegacyUI provides the modern installation interface presented to the user.

Responsibilities include:

* Installation interface
* Progress reporting
* Status updates
* Optional component selection
* Communication with the backend installer

LegacyUI intentionally separates presentation from deployment logic, allowing the installer backend to remain stable while the user experience continues to evolve.

---

## Inno Setup Backend

The backend installer performs all installation logic.

Responsibilities include:

* Installation validation
* File deployment
* Manifest generation
* RestoreData creation
* Uninstaller generation
* Rollback orchestration

The backend remains hidden from the user while LegacyUI provides the complete installation experience.

---

## ArcRunner

ArcRunner acts as the extraction controller between the installer backend and FreeArc.

Responsibilities include:

* Launching archive extraction
* Monitoring extraction progress
* Reporting extraction status
* Generating extraction logs
* Communicating progress back to LegacyUI

---

## FreeArc

FreeArc is used as the payload extraction engine.

Responsibilities include:

* High-compression archive support
* Fast extraction
* Deterministic archive deployment
* Reduced download size

Every title uses standardized archive packaging to maintain consistent installer behavior.

---

## RestoreData

RestoreData is the foundation of the rollback system.

Unlike traditional uninstallers, RestoreData focuses on deterministic restoration rather than simple file removal.

Responsibilities include:

* Backing up overwritten original files
* Tracking newly installed files
* Restoring original content
* Removing newly created files
* Cleaning empty directories
* Returning the installation to its original patched state

RestoreData guarantees that uninstalling a supported modpack leaves the game functionally identical to its validated pre-installation state.

---

# Installation Workflow

Every Release 2.0 installer follows the same standardized workflow.

```text
Launcher
        │
        ▼
Mandatory Validation
        │
        ▼
Game Detection
        │
        ▼
Installation Configuration
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
RestoreData Creation
        │
        ▼
Installation Complete
```

This workflow is identical across every supported title, ensuring a predictable installation experience regardless of the selected game.

---

# Rollback Architecture

Rollback is considered a primary feature of the project rather than an optional convenience.

Every installer generates rollback metadata inside the game directory.

```text
_LegacyInstaller
│
├── install_manifest.txt
├── new_files_manifest.txt
└── RestoreData
    └── Backup
```

During uninstall, the Release 2.0 rollback engine performs the following sequence:

```text
Delete New Files
        │
        ▼
Restore Original Files
        │
        ▼
Title-Specific Cleanup
        │
        ▼
Remove Empty Directories
        │
        ▼
Rollback Verification
```

The same rollback methodology is shared across every supported Need for Speed title, providing a consistent and reproducible restoration workflow.

# Validation Methodology

Every Release 2.0 installer is validated using the same engineering methodology before it is considered ready for public release.

Validation extends beyond verifying that an installer completes successfully. Every release must demonstrate that installation, gameplay, rollback, and restoration all function correctly without compromising the original game installation.

The validation workflow is identical across every supported title.

```text id="7jykmu"
Clean Patched Game
        │
        ▼
Mandatory Requirements Verified
        │
        ▼
Installation
        │
        ▼
Gameplay Verification
        │
        ▼
Rollback
        │
        ▼
Compare-Object
        │
        ▼
Release Validation
```

A release is considered valid only when every stage completes successfully.

---

## Mandatory Requirements Validation

Before installation begins, every installer verifies that the selected game installation satisfies the required conditions.

Validation includes:

* Correct game executable.
* Required official game version.
* Large Address Aware (4GB Patch).
* Required folder structure.
* Critical game files.
* Installer compatibility.

This validation prevents unsupported installations from being modified.

---

## Installation Validation

During installation, the following components are verified:

* SetupLauncher
* LegacyUI
* Backend installer
* ArcRunner
* FreeArc extraction
* File deployment
* Manifest generation
* RestoreData generation

Installation must complete without errors before gameplay verification begins.

---

## Gameplay Verification

Every supported title is tested after installation.

Gameplay verification confirms:

* Successful game launch.
* Correct frontend behavior.
* Required assets loaded.
* No missing files.
* No unexpected crashes.
* Expected modpack functionality.

Gameplay screenshots are included within the repository gallery to document each validated release.

---

## Rollback Validation

Rollback validation is mandatory for every public release.

The Restore Tool must successfully:

* Remove newly installed files.
* Restore overwritten originals.
* Remove empty directories.
* Preserve the original patched installation.

The rollback workflow is identical across every supported title.

---

## SHA-256 Verification

Rollback integrity is verified using SHA-256 file comparison.

Three filesystem snapshots are generated:

* Baseline installation
* Post-installation
* Post-rollback

The restored installation is compared against the original clean patched reference using PowerShell.

Expected result:

```text id="bd5cm0"
(no output)
```

No output confirms that the restored installation matches the original reference exactly.

---

# Repository Structure

The repository has been organized around the standardized Release 2.0 architecture.

```text id="cmymmh"
NFS-Legacy-Modpacks/
│
├── docs/
├── releases/
├── screenshots/
├── source/
├── LICENSE
├── CHANGELOG.md
└── README.md
```

Each directory has a dedicated responsibility within the project.

---

## docs/

Contains the engineering documentation used during development, validation, and release preparation.

Documentation includes:

* Build Notes
* Release Engineering
* Rollback Validation
* Hashing Commands
* Release Checklist
* GitHub Release Template

---

## releases/

Contains release-specific documentation for every supported title.

Each release directory includes:

* Release README
* Gallery
* Release assets (when published)

This directory serves as the public-facing documentation accompanying every installer release.

---

## screenshots/

Stores repository-wide screenshots documenting:

* Installer workflow
* Rollback validation
* Compare-Object verification
* Mandatory requirements
* Gallery examples

---

## source/

Contains the complete Release 2.0 installer source code.

Major components include:

* SetupLauncher
* LegacyUI
* Inno Setup scripts
* ArcRunner
* Splash
* Shared utilities

Every supported installer is built from this source tree.

---

# Documentation

The repository includes extensive engineering documentation describing every aspect of the Release 2.0 installer framework.

| Document                            | Description                             |
| ----------------------------------- | --------------------------------------- |
| **README.md**                       | Project overview and architecture       |
| **CHANGELOG.md**                    | Project development history             |
| **docs/build-notes.md**             | Internal build workflow                 |
| **docs/release-engineering.md**     | Release engineering process             |
| **docs/release-checklist.md**       | Final validation checklist              |
| **docs/rollback-validation.md**     | Rollback methodology                    |
| **docs/hashing-commands.md**        | Official PowerShell validation commands |
| **docs/github-release-template.md** | GitHub Release template                 |

All documentation is maintained together with the source code to ensure every release remains reproducible and fully documented.

---

# Current Project Status

Release 2.0 represents the completion of the unified installer framework.

Current project status:

| Component                      |   Status   |
| ------------------------------ | :--------: |
| Unified Installer Architecture | ✅ Complete |
| SetupLauncher                  | ✅ Complete |
| LegacyUI                       | ✅ Complete |
| Inno Setup Backend             | ✅ Complete |
| ArcRunner                      | ✅ Complete |
| RestoreData Rollback           | ✅ Complete |
| Six Supported Titles           | ✅ Complete |
| Validation Workflow            | ✅ Complete |
| Engineering Documentation      | ✅ Complete |
| Repository Standardization     | ✅ Complete |
| Gallery Documentation          | ✅ Complete |
| Release Framework              |   ✅ Ready  |

The remaining work primarily consists of publishing validated public releases as development of individual modpacks progresses.

# Roadmap

Release 2.0 establishes the long-term foundation for every future NFS Legacy Modpacks release.

Future development will continue building upon the standardized installer architecture while preserving full compatibility with the Release 2.0 engineering principles.

Planned future work includes:

* Continued maintenance of the installer framework.
* Compatibility updates where required.
* Additional installer polish.
* Expanded documentation.
* Additional gameplay galleries.
* Future quality-of-life improvements.
* Ongoing validation and testing.

Any future architectural changes will continue using the NFSU implementation as the reference architecture before being adopted by the remaining supported titles.

---

# Contributing

Contributions are welcome.

The project values improvements that preserve the existing engineering philosophy and maintain compatibility across every supported title.

Areas where contributions may be valuable include:

* Installer improvements.
* Documentation.
* Validation tooling.
* Bug fixes.
* Testing.
* User interface refinements.
* Translation improvements.
* Community feedback.

Before submitting significant architectural changes, contributors are encouraged to review the engineering documentation contained in the `docs/` directory to ensure compatibility with the Release 2.0 framework.

---

# Project Principles

Every contribution should follow the same guiding principles.

## Preservation First

The goal of NFS Legacy Modpacks is to preserve the original games rather than redesign them.

Community improvements should respect the original gameplay, atmosphere, and artistic direction.

---

## Reliability Before Features

Installer reliability always takes priority over introducing new functionality.

A feature that compromises installation safety or rollback integrity is considered unsuitable until it satisfies the project's validation requirements.

---

## Deterministic Rollback

Every supported installer must remain capable of restoring the game to its original patched state.

Rollback safety is considered a core feature of the project.

---

## Reproducible Releases

Every public release should be reproducible using the repository source, documented engineering workflow, and standardized validation process.

---

## Transparency

Engineering decisions, validation methodology, and release workflows are documented publicly whenever possible.

Repository documentation exists to make every release understandable, reproducible, and maintainable by future contributors.

---

# License

This project is licensed under the **MIT License**.

See the `LICENSE` file for the complete license text.

---

# Legal Notice

NFS Legacy Modpacks is an independent community project.

This repository is **not affiliated with, endorsed by, sponsored by, or associated with Electronic Arts Inc., EA Canada, Black Box Games, or any of their subsidiaries or licensors.**

Need for Speed and all associated trademarks, logos, and copyrighted materials remain the property of their respective owners.

This repository does **not** distribute:

* Original game files.
* Copyrighted EA assets.
* Commercial game content.
* Executable game binaries.
* Archive payloads containing copyrighted game data.

Users must legally own the original game before using any installer provided by this project.

---

# Acknowledgements

NFS Legacy Modpacks would not be possible without the work of the Need for Speed modding community.

The project builds upon years of community research, reverse engineering, compatibility improvements, and restoration work created by countless developers, artists, testers, and enthusiasts.

Individual mods remain the work of their respective authors and are credited accordingly within each release where applicable.

Special appreciation goes to the wider Need for Speed preservation community whose continued efforts have helped keep these classic titles playable on modern systems.

---

# Final Statement

NFS Legacy Modpacks is more than a collection of game modifications.

It is an engineering-focused preservation project designed to provide a consistent, reliable, and fully documented installation framework for the classic PC Need for Speed series.

By combining modern installer technology, deterministic rollback, comprehensive validation, and standardized engineering practices, Release 2.0 establishes a long-term foundation for future public releases while respecting the identity and legacy of the original games.

Every installer released under this framework is developed with the same objective:

**Preserve the originals. Improve the experience. Always provide a safe path back.**
