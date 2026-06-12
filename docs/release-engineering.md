# Release Engineering

This document defines the release standards, versioning rules, packaging structure, checksum policy, and publishing workflow for **NFS Legacy Modpacks**.

The goal of this process is to ensure every public release is:

* Reproducible
* Versioned consistently
* Rollback-safe
* Verifiable
* Properly documented

---

## Versioning Strategy

Releases follow a structured semantic-style versioning format:

```txt
Major.Minor.Patch
```

Example:

```txt
1.0.0
1.1.0
1.2.1
2.0.0
```

### Version Meaning

| Version Part | Meaning                                                                |
| ------------ | ---------------------------------------------------------------------- |
| **Major**    | Large architectural changes, installer rewrites, major feature changes |
| **Minor**    | New features, validation improvements, compatibility updates           |
| **Patch**    | Bug fixes, rollback fixes, script cleanup, installer fixes             |

### Examples

```txt
1.0.0
```

Initial public release.

```txt
1.1.0
```

Added validation improvements or installer features.

```txt
1.1.1
```

Bugfix release for installer issues.

```txt
2.0.0
```

Major installer architecture rewrite.

---

## Release Naming Convention

Installer filenames must follow a standardized naming structure.

Format:

```txt
<Game>-Legacy-Modpack-v<version>.exe
```

Examples:

```txt
NFSU-Legacy-Modpack-v1.0.0.exe
NFSU2-Legacy-Modpack-v1.0.0.exe
NFSMW-Legacy-Modpack-v1.0.0.exe
NFSC-Legacy-Modpack-v1.0.0.exe
NFSPS-Legacy-Modpack-v1.0.0.exe
NFSUC-Legacy-Modpack-v1.0.0.exe
```

Avoid filenames such as:

```txt
modpack_final.exe
newinstaller.exe
installerfixed2.exe
latestbuild.exe
```

Release files must always be deterministic and versioned.

---

## Git Tag Format

Git tags must follow:

```txt
v<version>
```

Examples:

```txt
v1.0.0
v1.1.0
v1.2.3
```

Create a tag:

```powershell
git tag v1.0.0
git push origin v1.0.0
```

Tags represent immutable public release states.

Do not reuse or modify released tags.

---

## GitHub Release Format

GitHub release titles must follow:

```txt
<Game Name> Legacy Modpack v<version>
```

Examples:

```txt
Need for Speed Underground Legacy Modpack v1.0.0
Need for Speed Most Wanted Legacy Modpack v1.2.0
Need for Speed Carbon Legacy Modpack v2.0.0
```

Release descriptions should include:

* Version number
* Major changes
* Validation changes
* Rollback changes
* Known issues
* SHA256 checksum

---

## Release Notes Template

Example release format:

```md
## Changes

### Installer
- Improved validation workflow
- Updated rollback handling
- Improved archive extraction

### Fixes
- Fixed uninstall edge case
- Fixed manifest cleanup issue

### Validation
- Updated rollback verification
- Added additional install checks

### SHA256

NFSU-Legacy-Modpack-v1.0.0.exe

SHA256:
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

---

## SHA256 Verification Policy

Every public installer release must include a SHA256 checksum.

Generate checksum:

```powershell
Get-FileHash ".\NFSU-Legacy-Modpack-v1.0.0.exe" -Algorithm SHA256
```

Example output:

```txt
Algorithm : SHA256
Hash      : A1B2C3D4E5F67890...
Path      : NFSU-Legacy-Modpack-v1.0.0.exe
```

Checksums must be included in:

* GitHub Releases
* Release notes
* Optional checksum text files

Purpose:

* Integrity verification
* Corruption detection
* Trust verification
* Reproducible releases

---

## Allowed Release Files

Public releases may include:

```txt
.exe installer
release notes
checksum file
optional changelog
```

Examples:

```txt
NFSU-Legacy-Modpack-v1.0.0.exe
SHA256.txt
CHANGELOG.md
```

---

## Forbidden Release Files

Public releases must **not** include:

```txt
raw source archives
temporary extraction folders
debug files
backup files
private tools
working project folders
test screenshots
```

Examples:

```txt
arc.exe
tmp/
Build/
Backup/
installer_test.exe
debug.log
```

---

## Release Packaging Checklist

Before every release:

* [ ] Installer compiles successfully
* [ ] Game validation tested
* [ ] Install process tested
* [ ] Uninstall process tested
* [ ] Rollback validation confirmed
* [ ] Manifest cleanup verified
* [ ] Screenshots updated if required
* [ ] SHA256 generated
* [ ] CHANGELOG updated
* [ ] Git tag created
* [ ] GitHub release published

---

## Release Philosophy

A release is considered complete only when:

1. Installation succeeds
2. Uninstallation succeeds
3. Rollback validation passes
4. Original game state is restored
5. Public artifacts are reproducible

Installer reliability is prioritized over release speed.

No release should be published without rollback verification.
