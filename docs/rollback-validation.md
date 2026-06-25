# Rollback Validation

This document defines the official rollback validation methodology used by **NFS Legacy Modpacks Release 2.0**.

The rollback system has been designed to guarantee deterministic restoration of supported Need for Speed installations after uninstalling a modpack.

Rollback validation confirms that every installer restores the original patched game installation without leaving any residual modpack files.

---

# Purpose

Every installer included in NFS Legacy Modpacks implements the same rollback architecture.

The objectives are:

* Restore every overwritten original file.
* Remove every file introduced by the modpack.
* Remove empty directories created during installation.
* Restore the original patched installation.
* Produce deterministic and reproducible rollback behavior.

---

# Rollback Architecture

Each installer creates the following rollback structure inside the game directory.

```text id="z1g9fe"
_LegacyInstaller
│
├── install_manifest.txt
├── new_files_manifest.txt
└── RestoreData
    └── Backup
```

## Component Overview

| Component              | Purpose                                |
| ---------------------- | -------------------------------------- |
| install_manifest.txt   | Tracks installed files and directories |
| new_files_manifest.txt | Tracks newly created files for removal |
| RestoreData/Backup     | Stores overwritten original files      |

Only files that are actually overwritten are backed up.

This minimizes storage requirements while preserving deterministic restoration.

---

# Validation Workflow

Rollback validation is performed using a clean patched game installation.

Validation consists of the following sequence.

```text id="32v5tu"
Clean Patched Game
        │
        ▼
Generate Baseline
        │
        ▼
Install Modpack
        │
        ▼
Verify Modpack
        │
        ▼
Run Restore Tool
        │
        ▼
Generate Final Snapshot
        │
        ▼
Compare Results
```

---

# SHA-256 Validation

Three snapshots are generated during validation.

## Step 1 — Baseline

Generate a SHA-256 snapshot of the clean patched installation.

```powershell id="t42vh4"
Get-ChildItem -Recurse -File |
Where-Object {
    $_.FullName -notmatch '\\RestoreData\\|\\_LegacyInstaller\\|baseline_vanilla\.csv|after_install\.csv|after_uninstall\.csv'
} |
Get-FileHash -Algorithm SHA256 |
Select-Object Path, Hash |
Export-Csv ".\baseline_vanilla.csv" -NoTypeInformation
```

---

## Step 2 — After Installation

Generate a snapshot immediately after installation.

```powershell id="9k8rjc"
Get-ChildItem -Recurse -File |
Where-Object {
    $_.FullName -notmatch '\\RestoreData\\|\\_LegacyInstaller\\|baseline_vanilla\.csv|after_install\.csv|after_uninstall\.csv'
} |
Get-FileHash -Algorithm SHA256 |
Select-Object Path, Hash |
Export-Csv ".\after_install.csv" -NoTypeInformation
```

---

## Step 3 — After Rollback

Run the Restore Tool.

Generate the final snapshot.

```powershell id="a5fov4"
Get-ChildItem -Recurse -File |
Where-Object {
    $_.FullName -notmatch '\\RestoreData\\|\\_LegacyInstaller\\|baseline_vanilla\.csv|after_install\.csv|after_uninstall\.csv'
} |
Get-FileHash -Algorithm SHA256 |
Select-Object Path, Hash |
Export-Csv ".\after_uninstall.csv" -NoTypeInformation
```

---

# Verification

Compare the baseline against the restored installation.

```powershell id="xxtkdh"
$baseline = Import-Csv ".\baseline_vanilla.csv"
$after = Import-Csv ".\after_uninstall.csv"

Compare-Object `
-ReferenceObject $baseline `
-DifferenceObject $after `
-Property Path, Hash
```

---

# Expected Result

A successful validation produces:

```text id="5cbdn5"
(no output)
```

This confirms:

* Original files restored.
* Modded files removed.
* No remaining installer artifacts.
* No remaining modpack files.
* Restored installation matches the original patched reference.

---

# Rollback Order

The Release 2.0 rollback engine performs restoration in the following order.

```text id="oqlf9w"
Delete new files
        │
        ▼
Restore overwritten originals
        │
        ▼
Title-specific cleanup
        │
        ▼
Remove empty directories
        │
        ▼
Verification
```

This sequence is shared across every supported title.

---

# Title-Specific Notes

Some games require title-specific cleanup during rollback.

Examples include:

* MOVIES package handling
* Optional component cleanup
* Runtime-generated configuration files

These exceptions are handled before the final cleanup phase while preserving the deterministic rollback workflow.

---

# Validation Status

Rollback validation has successfully completed for every supported installer.

| Game                         | Validation |
| ---------------------------- | ---------- |
| Need for Speed Underground   | ✅ PASS     |
| Need for Speed Underground 2 | ✅ PASS     |
| Need for Speed Most Wanted   | ✅ PASS     |
| Need for Speed Carbon        | ✅ PASS     |
| Need for Speed ProStreet     | ✅ PASS     |
| Need for Speed Undercover    | ✅ PASS     |

Validation included:

* Installation
* Gameplay verification
* Rollback
* Compare-Object verification
* Restoration against the clean patched reference

---

# Validation Philosophy

Rollback is considered successful only when the restored installation is functionally and structurally identical to the original patched installation.

A release is never considered complete until every supported title passes the complete rollback validation workflow.
