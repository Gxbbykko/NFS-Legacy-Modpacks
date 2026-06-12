# Hashing Commands

Run inside the selected game test folder.

## Clean Previous Test Files

```powershell
Remove-Item ".\baseline_vanilla.csv" -Force -ErrorAction SilentlyContinue
Remove-Item ".\after_install.csv" -Force -ErrorAction SilentlyContinue
Remove-Item ".\after_uninstall.csv" -Force -ErrorAction SilentlyContinue
```

## Create Vanilla Baseline

```powershell
Get-ChildItem -Recurse -File |
Where-Object {
    $_.FullName -notmatch '\\Backup\\|\\_LegacyInstaller\\|baseline_vanilla\.csv|after_install\.csv|after_uninstall\.csv'
} |
Get-FileHash -Algorithm SHA256 |
Select-Object Path, Hash |
Export-Csv ".\baseline_vanilla.csv" -NoTypeInformation
```

## Verify Installer Output

```powershell
Get-ChildItem ".\_LegacyInstaller" -Force
Get-Content ".\_LegacyInstaller\install_manifest.txt" | Select-Object -First 20
```

## Scan After Install

```powershell
Get-ChildItem -Recurse -File |
Where-Object {
    $_.FullName -notmatch '\\Backup\\|\\_LegacyInstaller\\|baseline_vanilla\.csv|after_install\.csv|after_uninstall\.csv'
} |
Get-FileHash -Algorithm SHA256 |
Select-Object Path, Hash |
Export-Csv ".\after_install.csv" -NoTypeInformation
```

## Run Uninstaller

```powershell
Start-Process ".\_LegacyInstaller\unins000.exe" -Wait
```

## Scan After Uninstall

```powershell
Get-ChildItem -Recurse -File |
Where-Object {
    $_.FullName -notmatch '\\Backup\\|\\_LegacyInstaller\\|baseline_vanilla\.csv|after_install\.csv|after_uninstall\.csv'
} |
Get-FileHash -Algorithm SHA256 |
Select-Object Path, Hash |
Export-Csv ".\after_uninstall.csv" -NoTypeInformation
```

## Compare

```powershell
$baseline = Import-Csv ".\baseline_vanilla.csv"
$after = Import-Csv ".\after_uninstall.csv"

Compare-Object `
-ReferenceObject $baseline `
-DifferenceObject $after `
-Property Path, Hash
```

Success means no output.