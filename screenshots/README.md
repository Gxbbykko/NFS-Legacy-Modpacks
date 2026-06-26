# Screenshots

This folder stores screenshots used throughout the **NFS Legacy Modpacks** repository for documentation, validation, release galleries, and project presentation.

The screenshots document the complete Release 2.0 installer architecture, mandatory requirements, rollback validation, and visual before/after comparisons for all supported titles.

---

# Purpose

The screenshot collection serves four primary purposes:

* Document the installer workflow
* Demonstrate rollback validation
* Showcase the visual improvements of each Legacy Modpack
* Provide reproducible proof of the validated Release 2.0 architecture

---

# Folder Structure

```txt
screenshots/
├── installer/
├── rollback/
├── mandatory/
├── games/
│   ├── nfsu/
│   ├── nfsu2/
│   ├── nfsmw/
│   ├── nfsc/
│   ├── nfsps/
│   └── nfsuc/
└── README.md
```

---

# Installer Screenshots

The `installer/` folder documents the standardized installer workflow.

Recommended captures include:

* Validation warning
* Welcome screen
* Game directory selection
* Validation successful
* Installation progress
* Installation completed

These screenshots demonstrate the Release 2.0 installation workflow shared by all supported titles.

---

# Rollback Screenshots

The `rollback/` folder documents the deterministic rollback architecture.

Recommended captures include:

* Restore Tool
* `_LegacyInstaller`
* `RestoreData`
* `install_manifest.txt`
* `new_files_manifest.txt`
* Compare-Object verification

Successful rollback verification should produce:

```txt
Compare-Object

(no output)
```

indicating that the restored installation matches the original patched game.

---

# Mandatory Requirements

The `mandatory/` folder documents the requirements validated by the installer before installation.

Each supported title includes proof of:

* Required game version
* Executable information
* File size
* Large Address Aware (4GB Patch)
* Successful validation

These screenshots demonstrate the exact requirements enforced by the installer.

---

# Game Galleries

Each supported title includes a dedicated gallery documenting:

* Vanilla main menu
* Legacy Modpack main menu
* Vanilla gameplay
* Legacy Modpack gameplay

Additional title-specific screenshots are included where applicable, such as optional installation components.

---

# Release Galleries

Every release folder contains its own `Gallery` directory documenting the complete workflow for that title.

Typical gallery contents include:

* Mandatory Requirements proof
* Installer startup
* Validation workflow
* Installation progress
* Installation completion
* Rollback workflow
* Before / After comparison
* Gameplay comparison

These galleries provide complete visual documentation for each public release.

---

# Screenshot Guidelines

All screenshots should:

* Be clear and readable
* Capture complete application windows where practical
* Use PNG format
* Maintain consistent naming
* Avoid unnecessary cropping
* Accurately represent the current Release 2.0 architecture

---

# Privacy Guidelines

Before publishing, ensure screenshots do not expose:

* Personal information
* Email addresses
* Sensitive system details
* Unrelated browser tabs
* Private file paths where avoidable

Crop or edit screenshots where necessary.

---

# Repository Philosophy

Screenshots are treated as engineering documentation rather than promotional material.

Their purpose is to provide transparent visual evidence of:

* Installer behavior
* Validation workflow
* Rollback integrity
* Mandatory requirements
* Gameplay transformation

This allows users and contributors to understand the project architecture and verify expected behavior before using a release.
