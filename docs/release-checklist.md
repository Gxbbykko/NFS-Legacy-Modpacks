# Release Checklist

Comprehensive validation checklist for every **NFS Legacy Modpack** release.

A release should never be published without passing every section below.

---

# 1. Installer Compilation Validation

Before testing anything, confirm the installer compiles correctly in **Inno Setup Compiler**.

## Required checks

* [ ] Script compiles successfully
* [ ] No compiler errors
* [ ] No unexpected warnings
* [ ] Output installer generated correctly
* [ ] Correct installer filename/version

## Verify

Confirm:

* Correct `.arc` archive is referenced
* Correct splash image is referenced
* Correct icon file is referenced
* Correct game executable name is configured
* Correct version number is set

Example:

```ini
#define MyAppVersion "1.4.0"
```

---

# 2. Installation Validation

Perform a complete installation test on a **clean patched vanilla game**.

## Required checks

* [ ] Installer launches
* [ ] Splash screen works
* [ ] Game path auto-detection works
* [ ] Patch validation warning behaves correctly
* [ ] Archive extraction completes
* [ ] Progress bar works
* [ ] Installation completes successfully
* [ ] No unexpected installer errors

## Verify

Confirm:

* `_LegacyInstaller` folder is created
* `install_manifest.txt` is generated
* `unins000.exe` exists
* `unins000.dat` exists

Example expected structure:

```txt
_LegacyInstaller/
├── install_manifest.txt
├── unins000.exe
└── unins000.dat
```

---

# 3. Manifest Validation

The manifest is the source of truth for uninstall cleanup.

## Required checks

* [ ] `install_manifest.txt` exists
* [ ] Manifest contains installed files
* [ ] Paths are relative
* [ ] No duplicate entries
* [ ] Manifest excludes protected folders

## Must NOT include

```txt
Backup\
_LegacyInstaller\
```

## Verify manually

Example command:

```powershell
Get-Content ".\_LegacyInstaller\install_manifest.txt" | Select-Object -First 20
```

Expected result:

```txt
CARS\350Z\GEOMETRY.BIN
CARS\350Z\TEXTURES.BIN
GLOBAL\GlobalB.lzc
...
```

---

# 4. Rollback Validation (Critical)

Every release **must pass rollback validation**.

This confirms the game returns to the exact vanilla patched state after uninstall.

## Validation flow

### Step 1 — Generate baseline hash

Run on a **clean patched vanilla game**:

```powershell
Remove-Item ".\baseline_vanilla.csv" -Force -ErrorAction SilentlyContinue
Remove-Item ".\after_install.csv" -Force -ErrorAction SilentlyContinue
Remove-Item ".\after_uninstall.csv" -Force -ErrorAction SilentlyContinue
```

Generate baseline:

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

### Step 2 — Install modpack

Run installer normally.

Complete installation.

---

### Step 3 — Generate post-install hash

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

### Step 4 — Run uninstaller

```powershell
Start-Process ".\_LegacyInstaller\unins000.exe" -Wait
```

---

### Step 5 — Generate post-uninstall hash

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

### Step 6 — Compare hashes

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

Correct rollback:

```txt
(no output)
```

This means:

* All modded files removed
* All original files restored
* No leftovers remain
* Game matches vanilla patched state

---

## Failure Conditions

If output appears:

```txt
Path                           Hash
----                           ----
nextgenfx_settings.ini         XXXXX
```

The rollback **failed**.

Required action:

1. Identify leftover file
2. Add cleanup logic to uninstaller
3. Rebuild installer
4. Re-test
5. Repeat until comparison returns **no output**

A release is **invalid** until rollback passes.

---

# 5. Backup Restoration Validation

The backup system must fully restore overwritten vanilla files.

## Required checks

* [ ] Backup folder exists
* [ ] Original files restored
* [ ] Existing files overwritten safely
* [ ] Read-only files handled correctly
* [ ] Protected files restored successfully

## Verify

Confirm:

* No missing game assets
* Game launches after uninstall
* Vanilla files restored correctly

---

# 6. Uninstall Validation

Confirm uninstall process behaves correctly.

## Required checks

* [ ] Manifest deletion runs
* [ ] Backup restoration runs
* [ ] Empty directories removed
* [ ] Installer leftovers preserved correctly
* [ ] No unexpected files remain

## Correct uninstall order

```txt
1. DeleteFilesFromManifest
2. RestoreBackupFiles
3. Special cleanup (if required)
4. RemoveEmptyDirectories
```

Example special cleanup:

```txt
nextgenfx_settings.ini
```

---

# 7. Git Validation

Before publishing:

Check repository state:

```powershell
git status
```

Expected:

```txt
working tree clean
```

Verify latest commits:

```powershell
git log --oneline -5
```

Push latest changes:

```powershell
git add .
git commit -m "Describe change"
git push
```

---

# 8. GitHub Release Preparation

Before release:

* [ ] README updated
* [ ] CHANGELOG updated
* [ ] Screenshots updated
* [ ] Documentation updated
* [ ] Version number updated
* [ ] Installer filename correct
* [ ] Repository synced

---

# 9. Release Criteria

A release is considered **valid** only if all conditions below are true:

* Installer compiles
* Installation succeeds
* Uninstall succeeds
* Manifest generated correctly
* Backup restoration works
* Rollback validation passes
* SHA256 comparison returns **no output**
* Repository is synced
* Documentation updated

If any requirement fails:

**DO NOT RELEASE**
