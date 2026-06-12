# Undercover Legacy Releases

This folder contains compiled release installers for **Need for Speed: Undercover (2008)**.

## Contents

Release builds only.

Example:

```txt
UndercoverLegacy_v1.0.0.1.exe
```

## Notes

* Installers are built using Inno Setup.
* Releases include rollback-safe uninstall support.
* Original game files are restored through backup restoration.
* Every release must pass rollback validation before publication.

## Validation Status

Before publishing:

* Installer compiled successfully
* Installation completed successfully
* Uninstall completed successfully
* SHA256 rollback validation passed
* No leftover files after uninstall
