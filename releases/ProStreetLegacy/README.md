# ProStreet Legacy Releases

This folder contains release builds and supporting documentation for **Need for Speed: ProStreet (2007)** as part of the **NFS Legacy Modpacks** project.

Each release is built on the validated Release 2.0 installer architecture, providing standardized installation, deterministic rollback, and restoration-safe uninstallation.

---

## Mandatory Requirements

Before initializing the installer, your game installation **must** satisfy the following requirements:

| Requirement                     | Status   |
| ------------------------------- | -------- |
| Game Version                    | **1.1**  |
| Clean Patched Installation      | Required |
| Large Address Aware (4GB Patch) | Required |

The installer validates these requirements before installation begins.

---

## Contents

This folder contains release-related assets such as:

```txt
ProStreetLegacy_v<version>.exe
Gallery/
README.md
```

The `Gallery` folder documents the complete installer workflow and visual proof of the release.

---

## Gallery

The gallery includes documentation for:

* Mandatory Requirements proof
* Installer startup
* Game validation
* Installation workflow
* Installation completion
* Rollback workflow
* Before / After comparisons
* Vanilla gameplay
* Legacy Modpack gameplay

These screenshots document the validated Release 2.0 architecture used by the installer.

---

## Installer Features

Every ProStreet Legacy release includes:

* SetupLauncher frontend
* LegacyUI interface
* Inno Setup backend
* FreeArc archive extraction
* ArcRunner extraction bridge
* Automatic game folder detection
* Game installation validation
* Manifest-based installation tracking
* RestoreData backup architecture
* Deterministic rollback
* Cleanup of generated configuration files when required
* Clean uninstall support

---

## Validation Status

Every public release must successfully pass:

* Installer compilation
* Mandatory requirement validation
* Installation validation
* Manifest generation
* RestoreData backup creation
* Rollback restoration
* Compare-Object rollback verification
* Before / After gameplay verification

Only validated releases are published.

---

## Rollback Verification

Rollback integrity is verified by comparing the restored installation against a clean patched baseline using SHA256 hashes.

A successful verification produces:

```txt
Compare-Object

(no output)
```

indicating that the restored installation matches the original vanilla patched game.

---

## Notes

* Original game files are **not** distributed.
* Commercial EA assets are **not** included.
* You must legally own **Need for Speed: ProStreet**.
* Community mods remain the property of their respective authors.
* NFS Legacy Modpacks provides an integrated installation, validation, and rollback framework.
