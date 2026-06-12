# Hashing Commands

This document contains reusable PowerShell commands for validating installer rollback integrity.

These commands are used to compare a clean vanilla installation with the post-uninstall state.

---

## Step 1 — Remove Old Validation Files

Run before creating a new validation session.

```powershell
Remove-Item ".\baseline_vanilla.csv" -Force -ErrorAction SilentlyContinue
Remove-Item ".\after_install.csv" -Force -ErrorAction SilentlyContinue
Remove-Item ".\after_uninstall.csv" -Force -ErrorAction SilentlyContinue
```

---

## Step 2 — Generate Baseline Hashes

Run this on a clean, patched vanilla game before installing the modpack.

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

## Step 3 — Verify Install Manifest Exists

Confirm installer tracking was created.

```powershell
Get-ChildItem ".\_LegacyInstaller" -Force
```

Preview first entries:

```powershell
Get-Content ".\_LegacyInstaller\install_manifest.txt" | Select-Object -First 20
```

---

## Step 4 — Generate Post-Install Hashes

Run after installation.

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

## Step 5 — Run Uninstaller

Wait for completion.

```powershell
Start-Process ".\_LegacyInstaller\unins000.exe" -Wait
```

---

## Step 6 — Generate Post-Uninstall Hashes

Run after uninstall finishes.

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

## Step 7 — Compare Results

Compare vanilla state with the restored state.

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

Successful rollback validation returns:

```txt
(no output)
```

No output means:

* No missing files
* No leftover modded files
* No changed file hashes
* Complete restoration

---

## Notes

The following folders/files are excluded intentionally:

```txt
Backup/
_LegacyInstaller/
baseline_vanilla.csv
after_install.csv
after_uninstall.csv
```

These are installer-generated validation files and should not be included in rollback comparison.
