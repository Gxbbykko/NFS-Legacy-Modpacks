```iss
; =========================================================
; NFS Legacy Modpack - Installer Template
; =========================================================
; This template is the shared base for future NFS Legacy installers.
; It is not meant to compile immediately without replacing placeholders.
;
; Main systems included:
; - Game folder detection
; - Game file validation
; - Large Address Aware check
; - FreeArc extraction through ArcRunner
; - Manifest-based install tracking
; - Backup restoration
; - Clean uninstall rollback
;
; Replace all TODO / PLACEHOLDER values before using.

#define MyAppName "GAME_NAME Legacy Modpack"          ; Public installer name
#define MyAppVersion "1.0.0"                          ; Installer/modpack version
#define MyAppPublisher "Gxbbykko"                     ; Publisher shown by installer
#define MyOutputName "GAME_NAME_MP"                   ; Compiled installer output name

#define GameExe "GAME_EXE.exe"                        ; Main game executable to detect
#define ArchiveName "GAME_ARCHIVE.arc"                ; FreeArc archive containing the modpack payload
#define TempExtractFolder "GAME_NAME_Extract"         ; Temporary extraction folder inside Windows temp

[Setup]
AppId={{GENERATE-NEW-GUID-HERE}                       ; Unique app ID. Generate a new GUID per game.
AppName={#MyAppName}                                  ; Uses MyAppName define
AppVersion={#MyAppVersion}                            ; Uses MyAppVersion define
AppPublisher={#MyAppPublisher}                        ; Uses publisher define
DefaultDirName={code:GetDefaultDir}                   ; Calls GetDefaultDir() to suggest game folder

DisableProgramGroupPage=yes                           ; No Start Menu group page
DisableReadyMemo=no                                   ; Show ready memo
DisableReadyPage=no                                   ; Show ready/install confirmation page

OutputDir=.                                           ; Output compiled installer beside script
OutputBaseFilename={#MyOutputName}                    ; Installer filename without extension

Compression=none                                      ; Archive is already compressed by FreeArc
SolidCompression=no                                   ; Not needed because Inno is only wrapping files
WizardStyle=modern                                    ; Modern Inno wizard UI

WizardImageFile=PATH_TO_WIZARD_IMAGE                  ; Left-side wizard bitmap
WizardSmallImageFile=PATH_TO_HEADER_IMAGE             ; Header bitmap
SetupIconFile=PATH_TO_ICON                            ; Installer icon

Uninstallable=yes                                     ; Enables generated uninstaller
CreateUninstallRegKey=no                              ; Avoids Windows Programs & Features registry entry
UninstallFilesDir={app}\_LegacyInstaller              ; Stores uninstaller inside game folder
UninstallDisplayName={#MyAppName} Restore Tool        ; Name shown by uninstaller

[Files]
Source: "Tools\arc.exe"; Flags: dontcopy              ; FreeArc extractor, copied to temp at runtime
Source: "{#ArchiveName}"; Flags: dontcopy             ; Modpack archive, copied to temp at runtime
Source: "Tools\Splash.exe"; Flags: dontcopy           ; Splash screen executable
Source: "Images\splash.png"; Flags: dontcopy          ; Splash image
Source: "Tools\ArcRunner.exe"; Flags: dontcopy        ; Wrapper that launches arc.exe and writes extraction log

[Code]

var
  UserAcceptedUnsafeInstall: Boolean;                 ; Tracks if user accepted unsafe install warning
  ExtractLogMemo: TNewMemo;                           ; Runtime log box shown during extraction

; =========================================================
; Default game path detection
; =========================================================

function GetDefaultDir(Param: String): String;
begin
  ; First check the preferred/manual install path.
  if FileExists('C:\Games\GAME_FOLDER\{#GameExe}') then
    Result := 'C:\Games\GAME_FOLDER'

  ; Add more else-if blocks here for retail/EA Games/Electronic Arts paths.
  ; Example:
  ; else if FileExists(ExpandConstant('{pf32}\EA GAMES\GAME_FOLDER\{#GameExe}')) then
  ;   Result := ExpandConstant('{pf32}\EA GAMES\GAME_FOLDER')

  ; Fallback folder shown when the game is not auto-detected.
  else
    Result := 'C:\Games\GAME_FOLDER';
end;

; =========================================================
; Basic file validation helpers
; =========================================================

function FileSizeMatches(FileName: String; ExpectedSize: Integer): Boolean;
var
  Size: Integer;
begin
  Result := False;                                    ; Default to failed validation

  if not FileExists(FileName) then                    ; Missing file = invalid
    Exit;

  if FileSize(FileName, Size) then                    ; Read file size
    Result := Size = ExpectedSize;                    ; Pass only if exact size matches
end;

function RequiredFolderExists(BaseDir, FolderName: String): Boolean;
begin
  Result := DirExists(AddBackslash(BaseDir) + FolderName); ; Checks required game folder
end;

function IsLargeAddressAware(ExePath: String): Boolean;
var
  ResultCode: Integer;
  PSCommand: String;
begin
  Result := False;                                    ; Default to not patched

  ; PowerShell reads the PE header and checks the Large Address Aware flag.
  PSCommand :=
    '-NoProfile -ExecutionPolicy Bypass -Command "' +
    '$bytes=[System.IO.File]::ReadAllBytes(''' + ExePath + ''');' +
    '$pe=[BitConverter]::ToInt32($bytes,0x3C);' +
    '$off=$pe+4+18;' +
    '$ch=[BitConverter]::ToUInt16($bytes,$off);' +
    'if(($ch -band 0x20) -ne 0){exit 0}else{exit 1}"';

  if Exec(
      ExpandConstant('{sys}\WindowsPowerShell\v1.0\powershell.exe'),
      PSCommand,
      '',
      SW_HIDE,
      ewWaitUntilTerminated,
      ResultCode
  ) then
    Result := (ResultCode = 0);                       ; Exit code 0 means LAA is enabled
end;

; =========================================================
; Game validation
; =========================================================

function IsGameInstallReady(BaseDir: String): Boolean;
var
  ExePath: String;
begin
  Result := False;                                    ; Default to invalid

  ExePath := AddBackslash(BaseDir) + '{#GameExe}';    ; Full executable path

  if not FileExists(ExePath) then Exit;               ; Game executable must exist

  ; TODO: Replace with the expected executable size.
  ; if not FileSizeMatches(ExePath, 1234567) then Exit;

  if not IsLargeAddressAware(ExePath) then Exit;      ; Require 4GB/LAA patch

  ; TODO: Add important file-size checks for this game.
  ; if not FileSizeMatches(AddBackslash(BaseDir) + 'GLOBAL\GlobalB.lzc', 1234567) then Exit;

  ; TODO: Add or remove required folders depending on the game.
  if not RequiredFolderExists(BaseDir, 'CARS') then Exit;
  if not RequiredFolderExists(BaseDir, 'FRONTEND') then Exit;
  if not RequiredFolderExists(BaseDir, 'GLOBAL') then Exit;

  Result := True;                                     ; All checks passed
end;

; =========================================================
; Error reporting
; =========================================================

function GetInstallerErrorFolder(): String;
begin
  ; Error logs are written beside the installer executable, not inside the game folder.
  Result := AddBackslash(ExpandConstant('{src}')) + '_GAME_Error_Backup';
end;

procedure CreateErrorReport(ErrorText: String);
var
  ErrorDir: String;
  LogFile: String;
begin
  ErrorDir := GetInstallerErrorFolder();              ; Error folder path
  ForceDirectories(ErrorDir);                         ; Create folder if missing

  LogFile := AddBackslash(ErrorDir) + 'install_error.txt';

  SaveStringToFile(
    LogFile,
    MyAppName + ' installation error'#13#10 +
    'Timestamp: ' + GetDateTimeString('yyyy-mm-dd hh:nn:ss', '-', ':') + #13#10 +
    'Selected game folder: ' + WizardDirValue() + #13#10 +
    'Error: ' + ErrorText + #13#10,
    False
  );
end;

; =========================================================
; Extraction log UI
; =========================================================

procedure CreateExtractLogBox;
begin
  ; Adds a read-only log box under the progress bar during extraction.
  ExtractLogMemo := TNewMemo.Create(WizardForm);
  ExtractLogMemo.Parent := WizardForm.InstallingPage;
  ExtractLogMemo.Left := WizardForm.ProgressGauge.Left;
  ExtractLogMemo.Top := WizardForm.ProgressGauge.Top + WizardForm.ProgressGauge.Height + 12;
  ExtractLogMemo.Width := WizardForm.ProgressGauge.Width;
  ExtractLogMemo.Height := 170;
  ExtractLogMemo.ScrollBars := ssVertical;
  ExtractLogMemo.ReadOnly := True;
  ExtractLogMemo.Visible := True;
end;

function CleanLogText(S: String): String;
var
  I: Integer;
begin
  Result := '';

  ; Removes backspace characters from FreeArc console-style output.
  for I := 1 to Length(S) do
  begin
    if S[I] <> #8 then
      Result := Result + S[I];
  end;
end;

; =========================================================
; Directory size helper
; =========================================================

function GetDirectorySize(Dir: String): Int64;
var
  FindRec: TFindRec;
  FilePath: String;
  Size: Integer;
begin
  Result := 0;
  Dir := RemoveBackslashUnlessRoot(Dir);

  ; Recursively calculates extracted file size for progress estimation.
  if FindFirst(Dir + '\*', FindRec) then
  begin
    try
      repeat
        if (FindRec.Name <> '.') and (FindRec.Name <> '..') then
        begin
          FilePath := Dir + '\' + FindRec.Name;

          if (FindRec.Attributes and FILE_ATTRIBUTE_DIRECTORY) <> 0 then
            Result := Result + GetDirectorySize(FilePath)
          else
          begin
            if FileSize(FilePath, Size) then
              Result := Result + Size;
          end;
        end;
      until not FindNext(FindRec);
    finally
      FindClose(FindRec);
    end;
  end;
end;

; =========================================================
; Writable-file helper
; =========================================================

procedure MakeWritable(FileName: String);
var
  ResultCode: Integer;
begin
  ; Removes read-only/system/hidden attributes before overwrite/delete.
  if FileExists(FileName) then
  begin
    Exec(
      ExpandConstant('{cmd}'),
      '/C attrib -R -S -H "' + FileName + '"',
      '',
      SW_HIDE,
      ewWaitUntilTerminated,
      ResultCode
    );
  end;
end;

; =========================================================
; Archive extraction
; =========================================================

function ExtractArchiveToTemp(): Boolean;
begin
  ; TODO:
  ; Paste the validated extraction logic from a working title.
  ;
  ; Required behavior:
  ; - Extract arc.exe, ArcRunner.exe, and archive into {tmp}
  ; - Delete old extraction folder if present
  ; - Launch ArcRunner.exe
  ; - Read arc_progress.log
  ; - Update wizard progress
  ; - Return True only when extraction succeeds
end;

; =========================================================
; Manifest generation
; =========================================================

function ShouldSkipManifest(RelPath: String): Boolean;
begin
  ; Prevents uninstall system from tracking its own support folders.
  Result :=
    (Pos('Backup\', RelPath) = 1) or
    (Pos('_LegacyInstaller\', RelPath) = 1);
end;

function CopyDirectoryRecursive(SourceDir, DestDir, BaseSourceDir, ManifestPath: String): Boolean;
begin
  ; TODO:
  ; Paste validated recursive copy logic here.
  ;
  ; Required behavior:
  ; - Recursively copy extracted files into game folder
  ; - Make destination files writable before deleting
  ; - Delete existing destination files before copy
  ; - Write copied relative paths to install_manifest.txt
  ; - Skip Backup and _LegacyInstaller paths
end;

function CopyExtractedFilesToGame(): Boolean;
begin
  ; TODO:
  ; Paste validated CopyExtractedFilesToGame logic here.
  ;
  ; Required behavior:
  ; - Set TempExtractPath
  ; - Create {app}\_LegacyInstaller
  ; - Create/clear install_manifest.txt
  ; - Call CopyDirectoryRecursive()
end;

; =========================================================
; Backup restoration and uninstall cleanup
; =========================================================

procedure RestoreBackupFiles(SourceDir, DestDir: String);
begin
  ; TODO:
  ; Paste validated backup restore logic here.
  ;
  ; Required behavior:
  ; - Recursively copy files from Backup into game folder
  ; - Make existing destination files writable
  ; - Delete destination before restoring original
end;

procedure DeleteFilesFromManifest(GameDir, ManifestPath: String);
begin
  ; TODO:
  ; Paste validated manifest deletion logic here.
  ;
  ; Required behavior:
  ; - Read install_manifest.txt
  ; - Delete every listed installed file
  ; - Make files writable before delete
end;

procedure RemoveEmptyDirectories(Dir: String);
begin
  ; TODO:
  ; Paste validated empty-folder cleanup logic here.
  ;
  ; Required behavior:
  ; - Recursively remove empty directories
  ; - Do not remove Backup
  ; - Do not remove _LegacyInstaller
end;

; =========================================================
; Uninstall flow
; =========================================================

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  ; TODO:
  ; Paste validated uninstall logic here.
  ;
  ; Required order:
  ; 1. DeleteFilesFromManifest(GameDir, ManifestPath)
  ; 2. RestoreBackupFiles(BackupDir, GameDir)
  ; 3. Optional special cleanup files
  ; 4. RemoveEmptyDirectories(GameDir)
  ;
  ; Important:
  ; Do not change this order unless rollback validation is repeated.
end;

; =========================================================
; Splash screen
; =========================================================

procedure RunSplash;
var
  ResultCode: Integer;
begin
  ; Extract splash executable and image to temp.
  ExtractTemporaryFile('Splash.exe');
  ExtractTemporaryFile('splash.png');

  ; Show splash before wizard initialization continues.
  Exec(
    ExpandConstant('{tmp}\Splash.exe'),
    '"' + ExpandConstant('{tmp}\splash.png') + '"',
    '',
    SW_SHOW,
    ewWaitUntilTerminated,
    ResultCode
  );
end;

procedure InitializeWizard;
begin
  UserAcceptedUnsafeInstall := False;                 ; Reset unsafe install flag
  RunSplash;                                          ; Show splash screen
end;

; =========================================================
; User validation warning
; =========================================================

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;

  ; TODO:
  ; Paste validated warning prompt here.
  ;
  ; Required behavior:
  ; - On wpSelectDir, run IsGameInstallReady(WizardDirValue())
  ; - If validation fails, warn user
  ; - YES continues anyway
  ; - NO returns to folder selection
end;

; =========================================================
; Install flow
; =========================================================

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssInstall then
  begin
    ; Extract archive first. Game folder remains untouched if this fails.
    if not ExtractArchiveToTemp() then
    begin
      MsgBox(
        'Archive extraction failed.'#13#10#13#10 +
        'The game folder was not modified.',
        mbError,
        MB_OK
      );
      RaiseException('Extraction failed.');
    end;

    ; Copy extracted files into game folder and generate manifest.
    if not CopyExtractedFilesToGame() then
    begin
      MsgBox(
        'File copy failed.'#13#10#13#10 +
        'Some files may not have been installed.',
        mbError,
        MB_OK
      );
      RaiseException('Copy failed.');
    end;
  end;
end;
```
