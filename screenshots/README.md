# Screenshots

This folder stores screenshots used for project documentation, release validation, and repository presentation.

Screenshots help demonstrate installer behavior, rollback validation, and expected workflows for contributors and users.

---

# Folder Structure

```txt
screenshots/
├── installers/
│   ├── underground-installer.png
│   ├── underground2-installer.png
│   ├── mw-installer.png
│   ├── carbon-installer.png
│   ├── prostreet-installer.png
│   └── undercover-installer.png
│
├── rollback/
│   ├── rollback-success.png
│   ├── manifest-example.png
│   └── uninstall-success.png
│
└── README.md
```

---

# Installer Screenshots

The `installers/` folder should contain screenshots of the installer workflow for every supported title.

Recommended captures:

## Welcome / splash

Capture the installer startup screen or splash screen.

Purpose:

* Shows branding consistency
* Documents installer presentation

Example:

```txt
underground-installer.png
```

---

## Game detection / path selection

Capture the installer detecting or selecting the game folder.

Purpose:

* Documents supported installation paths
* Demonstrates automatic game detection

---

## Extraction progress

Capture archive extraction in progress.

Purpose:

* Shows progress bar behavior
* Documents extraction logging
* Demonstrates FreeArc integration

Recommended capture:

* Progress gauge visible
* Extraction log visible
* Status text readable

---

## Installation complete

Capture successful installation screen.

Purpose:

* Documents expected successful completion state

---

# Rollback Validation Screenshots

The `rollback/` folder should contain screenshots proving rollback validation behavior.

These are especially useful for repository credibility and future debugging.

---

## `_LegacyInstaller` structure

Capture:

```txt
_LegacyInstaller/
├── install_manifest.txt
├── unins000.exe
└── unins000.dat
```

Purpose:

* Demonstrates uninstall infrastructure
* Shows manifest generation

Recommended filename:

```txt
legacyinstaller-folder.png
```

---

## Manifest preview

Capture:

```powershell
Get-Content ".\_LegacyInstaller\install_manifest.txt" | Select-Object -First 20
```

Purpose:

* Demonstrates tracked file removal system
* Documents manifest format

Recommended filename:

```txt
manifest-example.png
```

---

## Successful rollback validation

Capture:

```powershell
Compare-Object `
-ReferenceObject $baseline `
-DifferenceObject $after `
-Property Path, Hash
```

Expected result:

```txt
(no output)
```

Purpose:

* Proves rollback works correctly
* Demonstrates clean uninstall validation

Recommended filename:

```txt
rollback-success.png
```

---

## Successful uninstall

Capture uninstall completion dialog.

Purpose:

* Documents expected uninstall result
* Demonstrates backup restoration workflow

Recommended filename:

```txt
uninstall-success.png
```

---

# Screenshot Guidelines

Screenshots should:

* Be readable
* Use consistent resolution where possible
* Show complete windows when relevant
* Avoid cropped or unclear captures

Recommended:

* PNG format
* Dark mode terminal where possible
* Consistent naming

---

# Privacy Guidelines

Avoid including:

* Personal email addresses
* Private folders if avoidable
* Sensitive system information
* Browser tabs unrelated to the project

If necessary, crop screenshots before publishing.

---

# Purpose

The goal of screenshots is to make the repository:

* Easier to understand
* Easier to validate
* More professional
* More contributor-friendly
* More transparent about rollback safety
