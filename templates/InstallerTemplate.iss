#define MyAppName "GAME Legacy Modpack"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "Gxbbykko"
#define MyOutputName "GameLegacyMP"

#define GameExe "game.exe"
#define ArchiveName "GAME.arc"
#define TempExtractFolder "GameLegacy_Extract"

; Template notes:
; - Replace game validation sizes.
; - Replace wizard/header/icon paths.
; - Replace archive path.
; - Keep manifest uninstall architecture.
; - Keep MakeWritable overwrite logic.
; - Keep Backup restoration order:
;   1. DeleteFilesFromManifest
;   2. RestoreBackupFiles
;   3. RemoveEmptyDirectories