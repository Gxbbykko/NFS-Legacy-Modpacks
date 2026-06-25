# Release Checklist

Comprehensive validation checklist for every **NFS Legacy Modpacks** release.

This checklist is the final quality gate before publishing any public release.

A release must successfully complete every applicable section before it is considered ready.

---

# 1. Source Validation

Confirm the repository reflects the intended release.

## Required checks

* [ ] README updated
* [ ] CHANGELOG updated
* [ ] Documentation reviewed
* [ ] Inno Setup scripts updated
* [ ] SetupLauncher source updated
* [ ] LegacyUI source updated
* [ ] ArcRunner source updated
* [ ] Splash source updated

---

# 2. Build Validation

Compile every required component.

## Required checks

* [ ] SetupLauncher published (Release)
* [ ] LegacyUI published (Release)
* [ ] Backend installer compiled
* [ ] ArcRunner compiled
* [ ] Splash compiled

## Verify

Confirm:

* Correct version numbers
* Correct icons
* Correct resources
* No compiler errors
* No unexpected warnings

---

# 3. Deployment Validation

Verify the deployment package.

## Required checks

* [ ] backend.exe copied to `_backend`
* [ ] setup_launcher.ini generated
* [ ] AppId verified
* [ ] Launcher icon verified
* [ ] Backend path verified
* [ ] Game identifier verified
* [ ] Silent arguments verified

---

# 4. Installation Validation

Perform a complete installation on a clean patched game.

## Required checks

* [ ] SetupLauncher launches
* [ ] Splash screen works
* [ ] LegacyUI starts correctly
* [ ] Backend launches
* [ ] Game detection works
* [ ] Installation validation succeeds
* [ ] Archive extraction completes
* [ ] Progress reporting works
* [ ] Installation completes successfully

## Verify

Confirm the installer generates:

```text
_LegacyInstaller
│
├── install_manifest.txt
├── new_files_manifest.txt
├── RestoreData
│   └── Backup
├── unins000.exe
└── unins000.dat
```

---

# 5. Manifest Validation

Verify rollback metadata.

## Required checks

* [ ] install_manifest.txt generated
* [ ] new_files_manifest.txt generated
* [ ] Relative paths only
* [ ] No duplicate entries
* [ ] Protected folders excluded

Protected folders:

```text
RestoreData
_LegacyInstaller
```

---

# 6. Optional Components

Verify optional installer content.

## Required checks

* [ ] Optional components install correctly
* [ ] Optional components uninstall correctly
* [ ] MOVIES package verified (where applicable)
* [ ] Title-specific options verified

---

# 7. Rollback Validation (Critical)

Rollback validation is mandatory.

Validation workflow:

* [ ] Install modpack
* [ ] Verify modpack functionality
* [ ] Run Restore Tool
* [ ] Restore original files
* [ ] Remove newly installed files
* [ ] Remove empty folders
* [ ] Compare against clean patched reference

PowerShell verification:

```powershell
Compare-Object `
-ReferenceObject $baseline `
-DifferenceObject $after `
-Property Path, Hash
```

Expected result:

```text
(no output)
```

This confirms:

* Original files restored
* Modded files removed
* No leftovers remain
* Installation matches the clean patched reference

---

# 8. Game Validation

Verify the installed modpack.

## Required checks

* [ ] Game launches
* [ ] Modpack functions correctly
* [ ] Required files installed
* [ ] No missing assets
* [ ] No installation corruption

---

# 9. Repository Validation

Before release:

```powershell
git status
```

Expected:

```text
working tree clean
```

Verify recent commits:

```powershell
git log --oneline -5
```

---

# 10. Release Preparation

Before publishing:

* [ ] Version number updated
* [ ] Installer filename verified
* [ ] SHA-256 generated
* [ ] Git tag created
* [ ] GitHub Release prepared
* [ ] Release notes updated
* [ ] Screenshots updated (if required)
* [ ] Repository synchronized

---

# Release Criteria

A release is considered valid only when all applicable requirements have passed.

## Engineering

* [ ] Components compile successfully
* [ ] Deployment package validated
* [ ] Installation completed
* [ ] Rollback completed
* [ ] RestoreData verified

## Validation

* [ ] Game functions correctly
* [ ] Compare-Object returns no differences
* [ ] Restored installation matches clean patched reference

## Documentation

* [ ] README updated
* [ ] CHANGELOG updated
* [ ] Documentation synchronized

## Release

* [ ] SHA-256 generated
* [ ] GitHub Release created
* [ ] Public installer uploaded

---

# Release Philosophy

No public release should be published until every applicable validation step has passed.

The primary objective of every release is to guarantee:

1. Deterministic installation.
2. Deterministic rollback.
3. Restoration to the original patched game state.
4. Reproducible release artifacts.
5. A consistent installer experience across all supported Need for Speed titles.
