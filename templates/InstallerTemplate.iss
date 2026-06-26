```iss
; =========================================================
; NFS Legacy Modpacks - Release 2.0 Installer Template
; =========================================================
;
; This template is the shared baseline architecture for future
; NFS Legacy Modpacks installers.
;
; It is based on the validated Release 2.0 architecture used
; across all supported titles:
;
;   SetupLauncher
;       -> LegacyUI
;       -> Inno Setup Backend
;       -> ArcRunner
;       -> FreeArc
;       -> RestoreData Rollback
;
; This file is intentionally written as a template.
; It is not expected to compile until all placeholders are replaced.
;
; ---------------------------------------------------------
; Main systems included
; ---------------------------------------------------------
;
; - Hidden Inno Setup backend
; - LegacyUI frontend bridge
; - SetupLauncher directory parameter support
; - Splash startup
; - Game folder auto-detection
; - Mandatory validation hooks
; - Large Address Aware validation
; - FreeArc extraction through ArcRunner
; - Optional 7-Zip external package support
; - Optional MOVIES package workflow
; - RestoreData rollback architecture
; - Changed-file backup system
; - install_manifest.txt tracking
; - new_files_manifest.txt tracking
; - Deterministic uninstall restoration
; - Title-specific cleanup hooks
;
; ---------------------------------------------------------
; Required customization before use
; ---------------------------------------------------------
;
; Replace every GAME_* / TODO_* / PLACEHOLDER value.
;
; Required per-title values:
;
; - MyAppName
; - MyAppVersion
; - MyOutputName
; - GameId
; - GameExe
; - ArchiveName
; - TempExtractFolder
; - AppId
; - ProjectRoot
; - icon/image filenames
; - GetDefaultDir paths
; - IsGameInstallReady validation checks
; - progress divisor in ExtractArchiveToTemp
; - title-specific messages
; - optional package configuration
;
; IMPORTANT:
; Do not change rollback order unless rollback validation is repeated.
;
; =========================================================


; =========================================================
; Application metadata
; =========================================================

#define MyAppName "GAME_NAME Legacy Modpack"
#define MyAppVersion "2.0.0"
#define MyAppPublisher "Gxbbykko"
#define MyOutputName "GAME_OUTPUT_NAME"

; Internal game identifier used by LegacyUI.
;
; Examples:
; nfsu
; nfsu2
; nfsmw
; nfsc
; nfsps
; nfsuc

#define GameId "game_id"

; Main executable used for detection and validation.

#define GameExe "GAME_EXE.exe"

; Main FreeArc payload archive.

#define ArchiveName "GAME_ARCHIVE.arc"

; Temporary extraction folder under {tmp}.

#define TempExtractFolder "GAME_Extract"


; =========================================================
; Optional external MOVIES / package configuration
; =========================================================
;
; Set EnableMoviesPackage to 1 only for installers that must
; download/extract/install an external package.
;
; Examples:
;
; Underground 2:
;   Standard HD/updated MOVIES package.
;
; Most Wanted / Carbon:
;   Standard HD/updated MOVIES package if used.
;
; Undercover:
;   Optional Unpissed Movies / filter-off package should use
;   title-specific LegacyUI option handling.
;
; For titles without external package support, keep this disabled.

#define EnableMoviesPackage 0

#if EnableMoviesPackage
#define MoviesUrl "TODO_MOVIES_DOWNLOAD_URL"
#define MoviesArchiveName "TODO_MOVIES_ARCHIVE.7z"
#define MoviesExtractFolder "TODO_MOVIES_EXTRACT_FOLDER"
#define MoviesSourceSubDir "TODO_SOURCE_ROOT\MOVIES"
#define MoviesExpectedMinSize 900000000
#endif


; =========================================================
; Local project structure
; =========================================================
;
; These paths are local build paths used by the developer.
; Public builds should be generated from the prepared local
; InstallerProject folder.
;
; Expected local layout:
;
; ProjectRoot/
; └── InstallerProject/
;     ├── Images/
;     ├── Tools/
;     │   ├── arc.exe
;     │   ├── ArcRunner.exe
;     │   ├── Splash.exe
;     │   ├── LegacyUI/
;     │   └── optional 7z.exe / 7z.dll
;     ├── GAME_ARCHIVE.arc
;     └── GAME.iss

#define ProjectRoot "C:\Users\Gabriel\Desktop\GAME_Modpack"
#define InstallerProject AddBackslash(ProjectRoot) + "InstallerProject"
#define ToolsDir AddBackslash(InstallerProject) + "Tools"
#define ImagesDir AddBackslash(InstallerProject) + "Images"


; =========================================================
; Setup configuration
; =========================================================

[Setup]

; Generate a unique GUID per title.
; Do not reuse AppIds between games.

AppId={{TODO-GENERATE-NEW-GUID-HERE}

AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}

; The backend receives the target directory either from SetupLauncher
; through /DIR or from GetDefaultDir fallback.

DefaultDirName={code:GetDefaultDir}
UsePreviousAppDir=no

OutputDir={#ProjectRoot}
OutputBaseFilename={#MyOutputName}

; FreeArc handles compression.
; Inno only wraps the backend payload.

Compression=none
SolidCompression=no

WizardStyle=modern

; The visible UI is LegacyUI.
; The Inno wizard is hidden and acts as backend.

DisableWelcomePage=yes
DisableDirPage=yes
DisableReadyPage=yes
DisableReadyMemo=no
DisableFinishedPage=yes
DisableProgramGroupPage=yes
AlwaysShowComponentsList=no

WizardImageFile={#ImagesDir}\wizard.bmp
WizardSmallImageFile={#ImagesDir}\header.bmp
SetupIconFile={#ImagesDir}\GAME_icon.ico

; Uninstaller is stored locally in the game folder.

Uninstallable=yes
CreateUninstallRegKey=yes
UninstallFilesDir={app}\_LegacyInstaller
UninstallDisplayName={#MyAppName} Restore Tool


; =========================================================
; Runtime files
; =========================================================

[Files]

; Core extraction tools.

Source: "{#ToolsDir}\arc.exe"; Flags: dontcopy
Source: "{#ToolsDir}\ArcRunner.exe"; Flags: dontcopy

; Optional 7-Zip files for external packages.

#if EnableMoviesPackage
Source: "{#ToolsDir}\7z.exe"; Flags: dontcopy
Source: "{#ToolsDir}\7z.dll"; Flags: dontcopy
#endif

; Splash.

Source: "{#ToolsDir}\Splash.exe"; Flags: dontcopy
Source: "{#ImagesDir}\splash.png"; Flags: dontcopy

; Main modpack archive.

Source: "{#InstallerProject}\{#ArchiveName}"; Flags: dontcopy

; LegacyUI runtime.
;
; First entry is extracted to {tmp} for install mode.
; Second entry is installed into _LegacyInstaller for uninstall mode.

Source: "{#ToolsDir}\LegacyUI\*"; DestDir: "{tmp}\LegacyUI"; Flags: dontcopy recursesubdirs createallsubdirs noencryption
Source: "{#ToolsDir}\LegacyUI\*"; DestDir: "{app}\_LegacyInstaller\LegacyUI"; Flags: ignoreversion recursesubdirs createallsubdirs


; =========================================================
; Restore Tool shortcut
; =========================================================

[Icons]

Name: "{app}\_LegacyInstaller\Restore GAME_NAME Legacy Modpack"; \
Filename: "{app}\_LegacyInstaller\LegacyUI\LegacyUI.exe"; \
Parameters: "--target ""{app}"" --mode uninstall --game {#GameId}"; \
WorkingDir: "{app}\_LegacyInstaller\LegacyUI"; \
IconFilename: "{app}\_LegacyInstaller\LegacyUI\LegacyUI.exe"


; =========================================================
; Pascal Script
; =========================================================

[Code]

var
  ExtractLogMemo: TNewMemo;

  LegacyUIResultCode: Integer;
  LegacyUIStatePath: String;
  LegacyUICommandPath: String;
  LegacyUITargetPath: String;

  InstallAbortRequested: Boolean;


; =========================================================
; Default game path detection
; =========================================================
;
; Replace these paths per title.
;
; This function only provides a suggested fallback path.
; SetupLauncher may pass the real selected folder through /DIR.

function GetDefaultDir(Param: String): String;
begin
  if FileExists('C:\Games\GAME_FOLDER\{#GameExe}') then
    Result := 'C:\Games\GAME_FOLDER'

  else if FileExists(ExpandConstant('{pf}\EA GAMES\GAME_FOLDER\{#GameExe}')) then
    Result := ExpandConstant('{pf}\EA GAMES\GAME_FOLDER')

  else if FileExists(ExpandConstant('{pf32}\EA GAMES\GAME_FOLDER\{#GameExe}')) then
    Result := ExpandConstant('{pf32}\EA GAMES\GAME_FOLDER')

  else
    Result := 'C:\Games\GAME_FOLDER';
end;


; =========================================================
; SetupLauncher /DIR bridge
; =========================================================

function GetLauncherDirParam(): String;
begin
  Result := ExpandConstant('{param:DIR|}');

  if Result <> '' then
  begin
    StringChangeEx(Result, '"', '', True);
    Result := RemoveBackslashUnlessRoot(Result);
  end;
end;


; =========================================================
; Active target folder
; =========================================================

function GetActiveInstallDir(): String;
begin
  if LegacyUITargetPath <> '' then
  begin
    Result := LegacyUITargetPath;
    Exit;
  end;

  try
    Result := WizardDirValue();
  except
    Result := GetDefaultDir('');
  end;
end;


; =========================================================
; Error reporting
; =========================================================
;
; Error reports are written beside the backend installer,
; not inside the game folder.

function GetInstallerErrorFolder(): String;
begin
  Result := AddBackslash(ExpandConstant('{src}')) + '_GAME_Legacy_Error_Backup';
end;

procedure CreateErrorReport(ErrorText: String);
var
  ErrorDir: String;
  LogFile: String;
begin
  ErrorDir := GetInstallerErrorFolder();
  ForceDirectories(ErrorDir);

  LogFile := AddBackslash(ErrorDir) + 'install_error.txt';

  SaveStringToFile(
    LogFile,
    MyAppName + ' installation error'#13#10 +
    'Timestamp: ' + GetDateTimeString('yyyy-mm-dd hh:nn:ss', '-', ':') + #13#10 +
    'Selected game folder: ' + GetActiveInstallDir() + #13#10 +
    'Error: ' + ErrorText + #13#10,
    False
  );
end;
```

; =========================================================
; File validation helpers
; =========================================================

function FileSizeMatches(FileName: String; ExpectedSize: Int64): Boolean;
var
  Size: Int64;
begin
  Result := False;

  if not FileExists(FileName) then
    Exit;

  if GetFileSize(FileName, Size) then
    Result := (Size = ExpectedSize);
end;


function RequiredFolderExists(BaseDir, FolderName: String): Boolean;
begin
  Result := DirExists(AddBackslash(BaseDir) + FolderName);
end;


; =========================================================
; Large Address Aware verification
; =========================================================
;
; Release 2.0 requires the game executable to already have
; the 4GB Patch applied where applicable.
;
; Replace or extend this implementation if a future title
; requires a different validation mechanism.

function IsLargeAddressAware(ExePath: String): Boolean;
var
  ResultCode: Integer;
  OutputFile: String;
  Command: String;
begin
  OutputFile := ExpandConstant('{tmp}\laa_check.txt');

  DeleteFile(OutputFile);

  Command :=
    '-NoProfile -ExecutionPolicy Bypass -Command ' +
    '"$fs=[IO.File]::OpenRead(''' + ExePath + ''');' +
    '$fs.Seek(0x3C,''Begin'')>$null;' +
    '$br=New-Object IO.BinaryReader($fs);' +
    '$pe=$br.ReadInt32();' +
    '$fs.Seek($pe+0x16,''Begin'')>$null;' +
    '$chars=$br.ReadUInt16();' +
    '$fs.Close();' +
    'if(($chars -band 0x20)-ne 0){''1''}else{''0''} | Out-File ''' +
    OutputFile + ''' -Encoding ascii"';

  Exec(
    ExpandConstant('{sys}\WindowsPowerShell\v1.0\powershell.exe'),
    Command,
    '',
    SW_HIDE,
    ewWaitUntilTerminated,
    ResultCode
  );

  Result :=
    FileExists(OutputFile) and
    (Trim(LoadStringFromFile(OutputFile)) = '1');

  DeleteFile(OutputFile);
end;


; =========================================================
; Game validation
; =========================================================
;
; IMPORTANT
;
; Replace all placeholder values below for each title.
;
; Validation should verify:
;
; • Correct executable
; • Correct executable size
; • Latest official patch
; • LAA applied
; • Required folders
; • Critical files
;
; The NFSU implementation is considered the reference
; architecture for future titles.

function IsGameInstallReady(BaseDir: String): Boolean;
begin
  Result :=

    FileExists(AddBackslash(BaseDir) + '{#GameExe}')

    and FileSizeMatches(
      AddBackslash(BaseDir) + '{#GameExe}',
      TODO_EXE_SIZE)

    and IsLargeAddressAware(
      AddBackslash(BaseDir) + '{#GameExe}')

    and RequiredFolderExists(BaseDir, 'CARS')
    and RequiredFolderExists(BaseDir, 'GLOBAL')
    and RequiredFolderExists(BaseDir, 'FRONTEND')
    and RequiredFolderExists(BaseDir, 'LANGUAGES')

    and FileSizeMatches(
      AddBackslash(BaseDir) + 'GLOBAL\GlobalB.lzc',
      TODO_GLOBAL_SIZE)

    and FileSizeMatches(
      AddBackslash(BaseDir) + 'LANGUAGES\English.bin',
      TODO_LANGUAGE_SIZE);
end;


; =========================================================
; Unsafe install confirmation
; =========================================================

var
  UserAcceptedUnsafeInstall: Boolean;

function ConfirmUnsafeInstall(): Boolean;
begin
  Result :=
    MsgBox(
      'The selected directory does not appear to be a fully supported installation.' + #13#10#13#10 +
      'Continuing may result in installation failures or rollback problems.' + #13#10#13#10 +
      'Do you want to continue anyway?',
      mbCriticalError,
      MB_YESNO) = IDYES;

  UserAcceptedUnsafeInstall := Result;
end;