# Rollback Validation

This document explains how rollback validation is performed for NFS Legacy Modpacks.

## Purpose

Every installer in this project is designed to support deterministic rollback.

The goal is to ensure that uninstalling a modpack restores the game to its original state before installation.

Rollback validation verifies that:

* Modpack-added files are removed
* Original files are restored from backup
* No leftover files remain
* File hashes match the original installation

---

## Validation Method

Rollback integrity is verified using SHA256 hashing.

Three snapshots are created:

### 1. Baseline (Vanilla Patched Game)

A SHA256 hash list is generated before installation.

This acts as the reference state.

Example:

```powershell
Get-ChildItem -Recurse -File |
Where-Object {
    $_.FullName -notmatch '\\Backup\\|\\_LegacyInstaller\\|baseline_vanilla\.csv|after_install\.csv|after_uninstall\.csv'
} |
Get-FileHash -Algorithm SHA256 |
Select-Object Path, Hash |
Export-Csv ".\baseline_vanilla.csv" -NoTypeInformation
```

---

### 2. After Installation

A second hash snapshot is generated after modpack installation.

This confirms installation changes.

Example:

```powershell
Get-ChildItem -Recurse -File |
Where-Object {
    $_.FullName -notmatch '\\Backup\\|\\_LegacyInstaller\\|baseline_vanilla\.csv|after_install\.csv|after_uninstall\.csv'
} |
Get-FileHash -Algorithm SHA256 |
Select-Object Path, Hash |
Export-Csv ".\after_install.csv" -NoTypeInformation
```

---

### 3. After Uninstall

After uninstalling the modpack, a final hash snapshot is generated.

Example:

```powershell
Get-ChildItem -Recurse -File |
Where-Object {
    $_.FullName -notmatch '\\Backup\\|\\_LegacyInstaller\\|baseline_vanilla\.csv|after_install\.csv|after_uninstall\.csv'
} |
Get-FileHash -Algorithm SHA256 |
Select-Object Path, Hash |
Export-Csv ".\after_uninstall.csv" -NoTypeInformation
```

---

## Verification

The baseline snapshot is compared with the post-uninstall snapshot.

Example:

```powershell
$baseline = Import-Csv ".\baseline_vanilla.csv"
$after = Import-Csv ".\after_uninstall.csv"

Compare-Object `
-ReferenceObject $baseline `
-DifferenceObject $after `
-Property Path, Hash
```

---

## Expected Result

A successful rollback validation produces:

```txt
(no output)
```

No output means:

* File paths match
* File hashes match
* No leftover modpack files remain
* The game was restored successfully

---

## Exceptions

Some third-party middleware or runtime-generated files may require explicit cleanup.

Example:

```txt
nextgenfx_settings.ini
```

These files may be manually removed during uninstall if generated dynamically.

---

## Status

Rollback validation has been successfully verified for:

* Underground
* Underground 2
* Most Wanted
* Carbon
* ProStreet
* Undercover
