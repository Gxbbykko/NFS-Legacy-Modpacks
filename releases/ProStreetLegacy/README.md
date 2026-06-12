# ProStreet Legacy Releases

This folder contains compiled release installers for **Need for Speed: ProStreet (2007)**.

## Contents

Release builds only.

Example:

```txt
ProStreetLegacy_v1.1.0.exe
```

## Notes

* Installers are built using Inno Setup.
* Releases include rollback-safe uninstall support.
* Original game files are restored through backup restoration.
* Includes cleanup for generated configuration leftovers when required.
* Every release must pass rollback validation before publication.

## Validation Status

Before publishing:

* Installer compiled successfully
* Installation completed successfully
* Uninstall completed successfully
* SHA256 rollback validation passed
* No leftover files after uninstall
