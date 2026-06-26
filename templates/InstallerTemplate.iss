; =========================================================
; NFS Legacy Modpacks - Release 2.0 Installer Template
; =========================================================
;
; Shared Inno Setup backend template for NFS Legacy Modpacks.
;
; This template represents the validated Release 2.0 architecture:
;
;   SetupLauncher
;       -> LegacyUI
;       -> Inno Setup Backend
;       -> ArcRunner
;       -> FreeArc
;       -> RestoreData Rollback
;
; This file is intentionally a template. It is not meant to be used
; unchanged. Replace every TODO_* / GAME_* placeholder before compiling.
;
; Core systems included:
;
; - Hidden Inno Setup backend
; - LegacyUI frontend bridge
; - SetupLauncher /DIR target support
; - Splash startup
; - Mandatory game validation hooks
; - Large Address Aware validation
; - FreeArc extraction through ArcRunner
; - Optional 7-Zip external package workflow
; - RestoreData rollback architecture
; - Changed-file backup system
; - install_manifest.txt tracking
; - new_files_manifest.txt tracking
; - Deterministic uninstall restoration
; - Title-specific cleanup hook
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
; Valid project identifiers:
; nfsu, nfsu2, nfsmw, nfsc, nfsps, nfsuc

#define GameId "game_id"

; Main executable used for detection and validation.

#define GameExe "GAME_EXE.exe"

; Main FreeArc payload archive.

#define ArchiveName "GAME_ARCHIVE.arc"

; Temporary extraction folder under {tmp}.

#define TempExtractFolder "GAME_Legacy_Extract"

; Progress divisor used to estimate extraction percentage.
;
; Formula used by the backend:
;   ProgressPercent := Integer(ExtractedSize div ExtractProgressDivisor)
;
; Replace with a value appropriate for the unpacked archive size.

#define ExtractProgressDivisor 50000000


; =========================================================
; Optional external package configuration
; =========================================================
;
; Set EnableExternalPackage to 1 only for titles that install a
; separately downloaded 7-Zip package, such as HD MOVIES packages.
;
; For titles without external packages, keep it disabled.
;
; Undercover's optional MOVIES / Unpissed Movies workflow may require
; title-specific LegacyUI option handling in addition to this template.

#define EnableExternalPackage 0

#if EnableExternalPackage == 1
#define ExternalPackageUrl "TODO_EXTERNAL_PACKAGE_URL"
#define ExternalArchiveName "TODO_EXTERNAL_PACKAGE.7z"
#define ExternalExtractFolder "TODO_EXTERNAL_EXTRACT_FOLDER"
#define ExternalSourceSubDir "TODO_SOURCE_ROOT\MOVIES"
#define ExternalSourceBaseDir "TODO_SOURCE_ROOT"
#define ExternalDestSubDir "MOVIES"
#define ExternalExpectedMinSize 900000000
#define ExternalDisplayName "MOVIES package"
#endif


; =========================================================
; Local project structure
; =========================================================
;
; Expected local layout:
;
; ProjectRoot/
; └── InstallerProject/
;     ├── Images/
;     │   ├── wizard.bmp
;     │   ├── header.bmp
;     │   ├── splash.png
;     │   └── GAME_icon.ico
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

DefaultDirName={code:GetDefaultDir}
UsePreviousAppDir=no

OutputDir={#ProjectRoot}
OutputBaseFilename={#MyOutputName}

; FreeArc handles compression. Inno only wraps runtime files.

Compression=none
SolidCompression=no
WizardStyle=modern

; LegacyUI is the visible installer interface.
; The Inno wizard runs hidden as the backend.

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

; The Restore Tool lives inside the game folder.

Uninstallable=yes
CreateUninstallRegKey=yes
UninstallFilesDir={app}\_LegacyInstaller
UninstallDisplayName={#MyAppName} Restore Tool


; =========================================================
; Runtime files
; =========================================================

[Files]

Source: "{#ToolsDir}\arc.exe"; Flags: dontcopy
Source: "{#ToolsDir}\ArcRunner.exe"; Flags: dontcopy

#if EnableExternalPackage == 1
Source: "{#ToolsDir}\7z.exe"; Flags: dontcopy
Source: "{#ToolsDir}\7z.dll"; Flags: dontcopy
#endif

Source: "{#ToolsDir}\Splash.exe"; Flags: dontcopy
Source: "{#ImagesDir}\splash.png"; Flags: dontcopy

Source: "{#InstallerProject}\{#ArchiveName}"; Flags: dontcopy

; LegacyUI runtime.
; - Extracted to {tmp} for install mode.
; - Installed to _LegacyInstaller for uninstall mode.

Source: "{#ToolsDir}\LegacyUI\*"; DestDir: "{tmp}\LegacyUI"; Flags: dontcopy recursesubdirs createallsubdirs noencryption
Source: "{#ToolsDir}\LegacyUI\*"; DestDir: "{app}\_LegacyInstaller\LegacyUI"; Flags: ignoreversion recursesubdirs createallsubdirs


; =========================================================
; Restore Tool shortcut
; =========================================================

[Icons]

Name: "{app}\_LegacyInstaller\Restore GAME_NAME Legacy Modpack"; Filename: "{app}\_LegacyInstaller\LegacyUI\LegacyUI.exe"; Parameters: "--target ""{app}"" --mode uninstall --game {#GameId}"; WorkingDir: "{app}\_LegacyInstaller\LegacyUI"; IconFilename: "{app}\_LegacyInstaller\LegacyUI\LegacyUI.exe"


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
; Replace paths per title.
; SetupLauncher may pass the selected target through /DIR.

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


; =========================================================
; Process control
; =========================================================

procedure TerminateProcessByName(ProcessName: String);
var
  ResultCode: Integer;
begin
  Exec(
    ExpandConstant('{cmd}'),
    '/C taskkill /F /IM "' + ProcessName + '"',
    '',
    SW_HIDE,
    ewWaitUntilTerminated,
    ResultCode
  );
end;

procedure KillInstallerProcesses();
begin
  TerminateProcessByName('ArcRunner.exe');
  TerminateProcessByName('arc.exe');

#if EnableExternalPackage == 1
  TerminateProcessByName('7z.exe');
#endif
end;

procedure KillAllFrontendBackendProcesses();
begin
  KillInstallerProcesses();
  TerminateProcessByName('LegacyUI.exe');
end;


; =========================================================
; LegacyUI state bridge
; =========================================================

procedure WriteLegacyUIState(Phase, Progress, Message: String);
var
  StateText: String;
  StateDir: String;
begin
  if LegacyUIStatePath = '' then
  begin
    StateDir := AddBackslash(GetActiveInstallDir()) + '_LegacyInstaller';
    ForceDirectories(StateDir);
    LegacyUIStatePath := AddBackslash(StateDir) + 'legacyui_state.ini';
  end
  else
  begin
    StateDir := ExtractFileDir(LegacyUIStatePath);
    ForceDirectories(StateDir);
  end;

  StateText :=
    'phase=' + Phase + #13#10 +
    'progress=' + Progress + #13#10 +
    'message=' + Message + #13#10;

  if FileExists(LegacyUIStatePath) then
    DeleteFile(LegacyUIStatePath);

  if not SaveStringToFile(LegacyUIStatePath, StateText, False) then
    CreateErrorReport('Failed to write LegacyUI state file: ' + LegacyUIStatePath);
end;

function ReadCommandValue(CommandText, KeyName: String): String;
var
  Text: String;
  Line: String;
  Prefix: String;
  P: Integer;
begin
  Result := '';
  Prefix := KeyName + '=';

  Text := CommandText;
  StringChangeEx(Text, #13#10, #10, True);
  StringChangeEx(Text, #13, #10, True);

  while Length(Text) > 0 do
  begin
    P := Pos(#10, Text);

    if P > 0 then
    begin
      Line := Copy(Text, 1, P - 1);
      Delete(Text, 1, P);
    end
    else
    begin
      Line := Text;
      Text := '';
    end;

    if Pos(Prefix, Line) = 1 then
    begin
      Result := Copy(Line, Length(Prefix) + 1, Length(Line));
      Exit;
    end;
  end;
end;


; =========================================================
; File validation helpers
; =========================================================

function FileSizeMatches(FileName: String; ExpectedSize: Integer): Boolean;
var
  Size: Integer;
begin
  Result := False;

  if not FileExists(FileName) then
    Exit;

  if FileSize(FileName, Size) then
    Result := (Size = ExpectedSize);
end;

function RequiredFolderExists(BaseDir, FolderName: String): Boolean;
begin
  Result := DirExists(AddBackslash(BaseDir) + FolderName);
end;

function IsLargeAddressAware(ExePath: String): Boolean;
var
  ResultCode: Integer;
  PSCommand: String;
begin
  Result := False;

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
    Result := (ResultCode = 0);
end;


; =========================================================
; Game validation
; =========================================================
;
; Replace placeholder checks per title.
;
; Validation should verify:
; - Correct executable
; - Correct executable size
; - Latest official patch
; - LAA / 4GB Patch
; - Required folders
; - Critical files

function IsGameInstallReady(BaseDir: String): Boolean;
var
  ExePath: String;
begin
  Result := False;

  ExePath := AddBackslash(BaseDir) + '{#GameExe}';

  if not FileExists(ExePath) then Exit;

  ; TODO: replace with title-specific executable size.
  ; if not FileSizeMatches(ExePath, TODO_EXE_SIZE) then Exit;

  if not IsLargeAddressAware(ExePath) then Exit;

  ; TODO: replace required folders per title.
  if not RequiredFolderExists(BaseDir, 'CARS') then Exit;
  if not RequiredFolderExists(BaseDir, 'GLOBAL') then Exit;
  if not RequiredFolderExists(BaseDir, 'FRONTEND') then Exit;
  if not RequiredFolderExists(BaseDir, 'LANGUAGES') then Exit;

  ; TODO: add title-specific critical file checks.
  ; if not FileSizeMatches(AddBackslash(BaseDir) + 'GLOBAL\GlobalB.lzc', TODO_GLOBAL_SIZE) then Exit;
  ; if not FileSizeMatches(AddBackslash(BaseDir) + 'LANGUAGES\English.bin', TODO_LANGUAGE_SIZE) then Exit;

  Result := True;
end;


; =========================================================
; LegacyUI startup and install command handling
; =========================================================

function WaitForLegacyUIInstallCommand(): Boolean;
var
  CommandAnsi: AnsiString;
  CommandText: String;
  CommandValue: String;
  TargetValue: String;
  WaitMs: Integer;
begin
  Result := False;
  WaitMs := 0;

  while WaitMs < 120000 do
  begin
    Sleep(300);
    WaitMs := WaitMs + 300;

    if not FileExists(LegacyUICommandPath) then
      Continue;

    if not LoadStringFromFile(LegacyUICommandPath, CommandAnsi) then
      Continue;

    CommandText := String(CommandAnsi);
    CommandValue := ReadCommandValue(CommandText, 'command');

    if CompareText(CommandValue, 'exit') = 0 then
    begin
      WriteLegacyUIState('error', '100', 'Installation was cancelled before file operations started.');
      CreateErrorReport('LegacyUI closed before install command.');
      Exit;
    end;

    if CompareText(CommandValue, 'abort') = 0 then
    begin
      WriteLegacyUIState('error', '100', 'Installation was aborted before file operations started.');
      CreateErrorReport('LegacyUI aborted before install command.');
      Exit;
    end;

    if CompareText(CommandValue, 'install') = 0 then
    begin
      TargetValue := ReadCommandValue(CommandText, 'target');

      if TargetValue = '' then
      begin
        WriteLegacyUIState('error', '100', 'LegacyUI install command missing target path.');
        CreateErrorReport('LegacyUI install command missing target path.');
        Exit;
      end;

      LegacyUITargetPath := RemoveBackslashUnlessRoot(TargetValue);

      if not DirExists(LegacyUITargetPath) then
      begin
        WriteLegacyUIState('error', '100', 'Selected target folder does not exist.');
        CreateErrorReport('Selected target folder does not exist: ' + LegacyUITargetPath);
        Exit;
      end;

      if not IsGameInstallReady(LegacyUITargetPath) then
      begin
        WriteLegacyUIState('error', '100', 'Mandatory game validation failed. Installation stopped.');
        CreateErrorReport('Mandatory game validation failed for: ' + LegacyUITargetPath);
        Exit;
      end;

      WriteLegacyUIState('preparing', '8', 'Install command received. Preparing backend operations...');
      Result := True;
      Exit;
    end;
  end;

  WriteLegacyUIState('error', '100', 'LegacyUI did not send an install command within 120 seconds.');
  CreateErrorReport('LegacyUI command timeout.');
end;

procedure LaunchLegacyUI;
var
  Params: String;
  BridgeDir: String;
  LegacyUIExe: String;
  ExtractedCount: Integer;
begin
  BridgeDir := ExpandConstant('{tmp}\LegacyUIBridge');
  ForceDirectories(BridgeDir);

  LegacyUIStatePath := AddBackslash(BridgeDir) + 'legacyui_state.ini';
  LegacyUICommandPath := AddBackslash(BridgeDir) + 'legacyui_command.ini';

  if FileExists(LegacyUICommandPath) then
    DeleteFile(LegacyUICommandPath);

  WriteLegacyUIState('preparing', '5', 'Extracting LegacyUI runtime...');

  ExtractedCount := ExtractTemporaryFiles('{tmp}\LegacyUI\*');

  if ExtractedCount <= 0 then
  begin
    CreateErrorReport('Failed to extract LegacyUI runtime folder.');
    RaiseException('Failed to extract LegacyUI runtime folder.');
  end;

  LegacyUIExe := ExpandConstant('{tmp}\LegacyUI\LegacyUI.exe');

  if not FileExists(LegacyUIExe) then
  begin
    CreateErrorReport('LegacyUI.exe was not found after runtime extraction: ' + LegacyUIExe);
    RaiseException('LegacyUI.exe was not found after runtime extraction.');
  end;

  WriteLegacyUIState('preparing', '5', 'Waiting for LegacyUI install confirmation...');

  Params :=
    '--target "' + GetActiveInstallDir() + '" ' +
    '--mode install ' +
    '--game {#GameId} ' +
    '--state "' + LegacyUIStatePath + '" ' +
    '--command "' + LegacyUICommandPath + '"';

  if not Exec(
    LegacyUIExe,
    Params,
    ExpandConstant('{tmp}\LegacyUI'),
    SW_SHOW,
    ewNoWait,
    LegacyUIResultCode
  ) then
  begin
    CreateErrorReport('Failed to launch LegacyUI.exe from runtime folder.');
    RaiseException('Failed to launch LegacyUI.exe.');
  end;
end;

procedure HideInnoWizard;
begin
  try
    WizardForm.Hide;
  except
  end;
end;

procedure RunSplash;
var
  ResultCode: Integer;
begin
  ExtractTemporaryFile('Splash.exe');
  ExtractTemporaryFile('splash.png');

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
  InstallAbortRequested := False;

  LegacyUITargetPath := GetLauncherDirParam();

  if LegacyUITargetPath = '' then
    LegacyUITargetPath := GetDefaultDir('');

  HideInnoWizard;
  RunSplash;
  HideInnoWizard;

  LaunchLegacyUI;

  if not WaitForLegacyUIInstallCommand() then
  begin
    WriteLegacyUIState('error', '100', 'Installation cancelled before file operations started.');
    CreateErrorReport('LegacyUI did not provide install command.');
    KillAllFrontendBackendProcesses();
    Abort;
  end;

  WizardForm.DirEdit.Text := LegacyUITargetPath;
  HideInnoWizard;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;
end;


; =========================================================
; General helpers
; =========================================================

function CleanLogText(S: String): String;
var
  I: Integer;
begin
  Result := '';

  for I := 1 to Length(S) do
  begin
    if S[I] <> #8 then
      Result := Result + S[I];
  end;
end;

function GetDirectorySize(Dir: String): Int64;
var
  FindRec: TFindRec;
  FilePath: String;
  Size: Integer;
begin
  Result := 0;
  Dir := RemoveBackslashUnlessRoot(Dir);

  if not DirExists(Dir) then
    Exit;

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

procedure MakeWritable(FileName: String);
var
  ResultCode: Integer;
begin
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

function GetRestoreDataDir(GameDir: String): String;
begin
  Result := AddBackslash(GameDir) + '_LegacyInstaller\RestoreData';
end;

function GetBackupDir(GameDir: String): String;
begin
  Result := AddBackslash(GetRestoreDataDir(GameDir)) + 'Backup';
end;

procedure SetRestoreDataAttributes(GameDir: String);
var
  ResultCode: Integer;
  RestoreDataDir: String;
begin
  RestoreDataDir := GetRestoreDataDir(GameDir);

  if DirExists(RestoreDataDir) then
  begin
    Exec(
      ExpandConstant('{cmd}'),
      '/C attrib +H +S +R "' + RestoreDataDir + '" /S /D',
      '',
      SW_HIDE,
      ewWaitUntilTerminated,
      ResultCode
    );
  end;
end;

procedure UnlockRestoreDataAttributes(GameDir: String);
var
  ResultCode: Integer;
  RestoreDataDir: String;
begin
  RestoreDataDir := GetRestoreDataDir(GameDir);

  if DirExists(RestoreDataDir) then
  begin
    Exec(
      ExpandConstant('{cmd}'),
      '/C attrib -H -S -R "' + RestoreDataDir + '" /S /D',
      '',
      SW_HIDE,
      ewWaitUntilTerminated,
      ResultCode
    );
  end;
end;

function FilesAreSame(SourceFile, DestFile: String): Boolean;
var
  SourceSize: Integer;
  DestSize: Integer;
  ResultCode: Integer;
  SourceHashAnsi: AnsiString;
  DestHashAnsi: AnsiString;
  SourceHash: String;
  DestHash: String;
begin
  Result := False;

  if not FileExists(SourceFile) then Exit;
  if not FileExists(DestFile) then Exit;

  if not FileSize(SourceFile, SourceSize) then Exit;
  if not FileSize(DestFile, DestSize) then Exit;

  if SourceSize <> DestSize then Exit;

  Exec(
    ExpandConstant('{cmd}'),
    '/C certutil -hashfile "' + SourceFile + '" SHA256 | find /v "hash" | find /v "CertUtil" > "' + ExpandConstant('{tmp}\source_hash.txt') + '"',
    '',
    SW_HIDE,
    ewWaitUntilTerminated,
    ResultCode
  );

  Exec(
    ExpandConstant('{cmd}'),
    '/C certutil -hashfile "' + DestFile + '" SHA256 | find /v "hash" | find /v "CertUtil" > "' + ExpandConstant('{tmp}\dest_hash.txt') + '"',
    '',
    SW_HIDE,
    ewWaitUntilTerminated,
    ResultCode
  );

  if not LoadStringFromFile(ExpandConstant('{tmp}\source_hash.txt'), SourceHashAnsi) then Exit;
  if not LoadStringFromFile(ExpandConstant('{tmp}\dest_hash.txt'), DestHashAnsi) then Exit;

  SourceHash := Trim(String(SourceHashAnsi));
  DestHash := Trim(String(DestHashAnsi));

  Result := CompareText(SourceHash, DestHash) = 0;
end;

function BackupOriginalIfChanged(SourcePath, DestPath, BaseSourceDir, GameDir: String): Boolean;
var
  RelPath: String;
  BackupPath: String;
begin
  Result := True;

  if not FileExists(DestPath) then
    Exit;

  if FilesAreSame(SourcePath, DestPath) then
    Exit;

  RelPath := Copy(SourcePath, Length(BaseSourceDir) + 2, Length(SourcePath));
  BackupPath := AddBackslash(GetBackupDir(GameDir)) + RelPath;

  ForceDirectories(ExtractFileDir(BackupPath));
  MakeWritable(DestPath);

  if not CopyFile(DestPath, BackupPath, False) then
  begin
    CreateErrorReport('Failed to backup original file: ' + DestPath + ' -> ' + BackupPath);
    Result := False;
    Exit;
  end;
end;

procedure CreateExtractLogBox;
begin
  ExtractLogMemo := TNewMemo.Create(WizardForm);
  ExtractLogMemo.Parent := WizardForm.InstallingPage;
  ExtractLogMemo.Left := WizardForm.ProgressGauge.Left;
  ExtractLogMemo.Top := WizardForm.ProgressGauge.Top + WizardForm.ProgressGauge.Height + 12;
  ExtractLogMemo.Width := WizardForm.ProgressGauge.Width;
  ExtractLogMemo.Height := 170;
  ExtractLogMemo.ScrollBars := ssVertical;
  ExtractLogMemo.ReadOnly := True;
  ExtractLogMemo.Visible := False;
end;

function LegacyUIAbortRequested(): Boolean;
var
  CommandText: AnsiString;
  CommandValue: String;
begin
  Result := False;

  if FileExists(LegacyUICommandPath) then
  begin
    if LoadStringFromFile(LegacyUICommandPath, CommandText) then
    begin
      CommandValue := ReadCommandValue(String(CommandText), 'command');

      if (CompareText(CommandValue, 'abort') = 0) or
         (CompareText(CommandValue, 'exit') = 0) then
      begin
        InstallAbortRequested := True;
        Result := True;
      end;
    end;
  end;
end;

procedure AbortInstallAndCleanTemp();
var
  TempExtractPath: String;
begin
  TempExtractPath := ExpandConstant('{tmp}\{#TempExtractFolder}');

  KillInstallerProcesses();

  if DirExists(TempExtractPath) then
    DelTree(TempExtractPath, True, True, True);

#if EnableExternalPackage == 1
  if FileExists(ExpandConstant('{tmp}\{#ExternalArchiveName}')) then
    DeleteFile(ExpandConstant('{tmp}\{#ExternalArchiveName}'));

  if DirExists(ExpandConstant('{tmp}\{#ExternalExtractFolder}')) then
    DelTree(ExpandConstant('{tmp}\{#ExternalExtractFolder}'), True, True, True);
#endif

  WriteLegacyUIState('error', '100', 'Installation cancelled. Temporary files were cleaned.');
  CreateErrorReport('Installation cancelled during install operations.');
end;


; =========================================================
; FreeArc extraction
; =========================================================

function ExtractArchiveToTemp(): Boolean;
var
  ResultCode: Integer;
  ArcExe: String;
  ArcRunnerExe: String;
  ArchivePath: String;
  TempExtractPath: String;
  LogPath: String;
  Params: String;
  LogText: AnsiString;
  DisplayText: String;
  ExtractedSize: Int64;
  ProgressPercent: Integer;
begin
  Result := False;
  LogText := '';

  WriteLegacyUIState('extracting', '20', 'Extracting GAME_NAME archive payload...');

  ExtractTemporaryFile('arc.exe');
  ExtractTemporaryFile('ArcRunner.exe');
  ExtractTemporaryFile('{#ArchiveName}');

  ArcExe := ExpandConstant('{tmp}\arc.exe');
  ArcRunnerExe := ExpandConstant('{tmp}\ArcRunner.exe');
  ArchivePath := ExpandConstant('{tmp}\{#ArchiveName}');
  TempExtractPath := ExpandConstant('{tmp}\{#TempExtractFolder}');
  LogPath := ExpandConstant('{tmp}\arc_progress.log');

  if FileExists(LogPath) then
    DeleteFile(LogPath);

  if DirExists(TempExtractPath) then
    DelTree(TempExtractPath, True, True, True);

  ForceDirectories(TempExtractPath);

  Params :=
    '"' + ArcExe + '" ' +
    '"' + ArchivePath + '" ' +
    '"' + TempExtractPath + '" ' +
    '"' + LogPath + '"';

  CreateExtractLogBox();

  if not Exec(ArcRunnerExe, Params, '', SW_HIDE, ewNoWait, ResultCode) then
  begin
    WriteLegacyUIState('error', '100', 'Failed to launch archive extraction helper.');
    CreateErrorReport('Failed to launch ArcRunner.exe.');
    Exit;
  end;

  repeat
    Sleep(300);

    if LegacyUIAbortRequested() then
    begin
      AbortInstallAndCleanTemp();
      Exit;
    end;

    ExtractedSize := GetDirectorySize(TempExtractPath);
    ProgressPercent := Integer(ExtractedSize div {#ExtractProgressDivisor});

    if ProgressPercent > 99 then
      ProgressPercent := 99;

    if ProgressPercent < 20 then
      ProgressPercent := 20;

    WriteLegacyUIState('extracting', IntToStr(ProgressPercent), 'Extracting GAME_NAME archive payload...');

    if FileExists(LogPath) then
    begin
      if LoadStringFromFile(LogPath, LogText) then
      begin
        DisplayText := CleanLogText(String(LogText));

        if Length(DisplayText) > 0 then
        begin
          ExtractLogMemo.Text := DisplayText;
          ExtractLogMemo.SelStart := Length(ExtractLogMemo.Text);
          ExtractLogMemo.SelLength := 0;
        end;
      end;
    end;
  until (Pos('arc.exe exit code:', String(LogText)) > 0) or
        (Pos('All OK', String(LogText)) > 0);

  if (Pos('arc.exe exit code: 0', String(LogText)) = 0) and
     (Pos('All OK', String(LogText)) = 0) then
  begin
    WriteLegacyUIState('error', '100', 'Archive extraction failed.');
    CreateErrorReport('ArcRunner / FreeArc extraction failed. See arc_progress.log.');
    Exit;
  end;

  WriteLegacyUIState('copying', '65', 'Installing GAME_NAME modpack files...');
  Result := True;
end;


; =========================================================
; Manifest generation and file deployment
; =========================================================

function ShouldSkipManifest(RelPath: String): Boolean;
begin
  Result :=
    (Pos('Backup\', RelPath) = 1) or
    (Pos('RestoreData\', RelPath) = 1) or
    (Pos('_LegacyInstaller\', RelPath) = 1);
end;

function CopyDirectoryRecursive(SourceDir, DestDir, BaseSourceDir, ManifestPath, NewFilesManifestPath, GameDir: String): Boolean;
var
  FindRec: TFindRec;
  SourcePath: String;
  DestPath: String;
  RelPath: String;
begin
  Result := True;

  SourceDir := RemoveBackslashUnlessRoot(SourceDir);
  DestDir := RemoveBackslashUnlessRoot(DestDir);
  BaseSourceDir := RemoveBackslashUnlessRoot(BaseSourceDir);

  ForceDirectories(DestDir);

  if FindFirst(SourceDir + '\*', FindRec) then
  begin
    try
      repeat
        if (FindRec.Name <> '.') and (FindRec.Name <> '..') then
        begin
          SourcePath := SourceDir + '\' + FindRec.Name;
          DestPath := DestDir + '\' + FindRec.Name;

          if (FindRec.Attributes and FILE_ATTRIBUTE_DIRECTORY) <> 0 then
          begin
            if not CopyDirectoryRecursive(SourcePath, DestPath, BaseSourceDir, ManifestPath, NewFilesManifestPath, GameDir) then
            begin
              Result := False;
              Exit;
            end;
          end
          else
          begin
            RelPath := Copy(SourcePath, Length(BaseSourceDir) + 2, Length(SourcePath));

            if not FileExists(DestPath) then
            begin
              if not ShouldSkipManifest(RelPath) then
                SaveStringToFile(NewFilesManifestPath, RelPath + #13#10, True);
            end
            else
            begin
              if not BackupOriginalIfChanged(SourcePath, DestPath, BaseSourceDir, GameDir) then
              begin
                Result := False;
                Exit;
              end;

              MakeWritable(DestPath);

              if not DeleteFile(DestPath) then
              begin
                CreateErrorReport('Failed to delete existing file before overwrite: ' + DestPath);
                Result := False;
                Exit;
              end;
            end;

            ForceDirectories(ExtractFileDir(DestPath));

            if not CopyFile(SourcePath, DestPath, False) then
            begin
              CreateErrorReport('Failed to copy file: ' + SourcePath + ' -> ' + DestPath);
              Result := False;
              Exit;
            end;

            if not ShouldSkipManifest(RelPath) then
              SaveStringToFile(ManifestPath, RelPath + #13#10, True);
          end;
        end;
      until not FindNext(FindRec);
    finally
      FindClose(FindRec);
    end;
  end;
end;

function CopyExtractedFilesToGame(): Boolean;
var
  TempExtractPath: String;
  LegacyDir: String;
  ManifestPath: String;
  NewFilesManifestPath: String;
begin
  TempExtractPath := ExpandConstant('{tmp}\{#TempExtractFolder}');
  LegacyDir := AddBackslash(GetActiveInstallDir()) + '_LegacyInstaller';
  ManifestPath := AddBackslash(LegacyDir) + 'install_manifest.txt';
  NewFilesManifestPath := AddBackslash(LegacyDir) + 'new_files_manifest.txt';

  ForceDirectories(LegacyDir);

  if FileExists(ManifestPath) then
    DeleteFile(ManifestPath);

  if FileExists(NewFilesManifestPath) then
    DeleteFile(NewFilesManifestPath);

  WriteLegacyUIState('copying', '70', 'Copying extracted files into the GAME_NAME folder...');

  Result := CopyDirectoryRecursive(
    TempExtractPath,
    GetActiveInstallDir(),
    TempExtractPath,
    ManifestPath,
    NewFilesManifestPath,
    GetActiveInstallDir()
  );

  if Result then
    WriteLegacyUIState('finalizing', '76', 'Writing rollback manifests...')
  else
    WriteLegacyUIState('error', '100', 'File copy failed.');
end;


#if EnableExternalPackage == 1
; =========================================================
; Optional external package workflow
; =========================================================

function DownloadExternalPackage(): Boolean;
var
  ResultCode: Integer;
  PowerShellExe: String;
  ArchivePath: String;
  Params: String;
  Size: Integer;
begin
  Result := False;

  ArchivePath := ExpandConstant('{tmp}\{#ExternalArchiveName}');

  if FileExists(ArchivePath) then
    DeleteFile(ArchivePath);

  WriteLegacyUIState('downloading', '78', 'Downloading {#ExternalDisplayName}...');

  PowerShellExe := ExpandConstant('{sys}\WindowsPowerShell\v1.0\powershell.exe');

  Params :=
    '-NoProfile -ExecutionPolicy Bypass -Command "' +
    '$ProgressPreference = ''SilentlyContinue''; ' +
    'Invoke-WebRequest -Uri ''{#ExternalPackageUrl}'' -OutFile ''' + ArchivePath + ''' -UseBasicParsing' +
    '"';

  if not Exec(PowerShellExe, Params, '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
  begin
    WriteLegacyUIState('error', '100', 'Failed to start external package download helper.');
    CreateErrorReport('Failed to start PowerShell download helper.');
    Exit;
  end;

  if ResultCode <> 0 then
  begin
    WriteLegacyUIState('error', '100', 'External package download failed.');
    CreateErrorReport('PowerShell download failed. Exit code: ' + IntToStr(ResultCode));
    Exit;
  end;

  if not FileExists(ArchivePath) then
  begin
    WriteLegacyUIState('error', '100', 'External package was not downloaded.');
    CreateErrorReport('Downloaded external archive was not found: ' + ArchivePath);
    Exit;
  end;

  if not FileSize(ArchivePath, Size) then
  begin
    WriteLegacyUIState('error', '100', 'Could not verify external package size.');
    CreateErrorReport('Could not read external archive size: ' + ArchivePath);
    Exit;
  end;

  if Size < {#ExternalExpectedMinSize} then
  begin
    WriteLegacyUIState('error', '100', 'External package download was incomplete or invalid.');
    CreateErrorReport('External archive too small. Size: ' + IntToStr(Size));
    Exit;
  end;

  WriteLegacyUIState('downloading', '84', 'External package downloaded successfully.');
  Result := True;
end;

function ExtractExternalPackage(): Boolean;
var
  ResultCode: Integer;
  SevenZipExe: String;
  ArchivePath: String;
  ExtractPath: String;
  Params: String;
begin
  Result := False;

  WriteLegacyUIState('extracting', '86', 'Extracting {#ExternalDisplayName}...');

  ExtractTemporaryFile('7z.exe');
  ExtractTemporaryFile('7z.dll');

  SevenZipExe := ExpandConstant('{tmp}\7z.exe');
  ArchivePath := ExpandConstant('{tmp}\{#ExternalArchiveName}');
  ExtractPath := ExpandConstant('{tmp}\{#ExternalExtractFolder}');

  if DirExists(ExtractPath) then
    DelTree(ExtractPath, True, True, True);

  ForceDirectories(ExtractPath);

  Params :=
    'x "' + ArchivePath + '" ' +
    '-o"' + ExtractPath + '" ' +
    '-y';

  if not Exec(SevenZipExe, Params, ExpandConstant('{tmp}'), SW_HIDE, ewWaitUntilTerminated, ResultCode) then
  begin
    WriteLegacyUIState('error', '100', 'Failed to start external package extraction helper.');
    CreateErrorReport('Failed to start 7z.exe for external extraction.');
    Exit;
  end;

  if ResultCode <> 0 then
  begin
    WriteLegacyUIState('error', '100', 'External package extraction failed.');
    CreateErrorReport('7z external extraction failed. Exit code: ' + IntToStr(ResultCode));
    Exit;
  end;

  if not DirExists(AddBackslash(ExtractPath) + '{#ExternalSourceSubDir}') then
  begin
    WriteLegacyUIState('error', '100', 'External package source folder was not found.');
    CreateErrorReport('Expected external source folder missing: ' + AddBackslash(ExtractPath) + '{#ExternalSourceSubDir}');
    Exit;
  end;

  WriteLegacyUIState('extracting', '90', 'External package extracted successfully.');
  Result := True;
end;

function MoveExternalPackageToGame(): Boolean;
var
  SourceDir: String;
  SourceBaseDir: String;
  DestDir: String;
  LegacyDir: String;
  ManifestPath: String;
  NewFilesManifestPath: String;
begin
  Result := False;

  WriteLegacyUIState('copying', '92', 'Installing {#ExternalDisplayName}...');

  SourceDir := AddBackslash(ExpandConstant('{tmp}\{#ExternalExtractFolder}')) + '{#ExternalSourceSubDir}';
  SourceBaseDir := AddBackslash(ExpandConstant('{tmp}\{#ExternalExtractFolder}')) + '{#ExternalSourceBaseDir}';
  DestDir := AddBackslash(GetActiveInstallDir()) + '{#ExternalDestSubDir}';

  LegacyDir := AddBackslash(GetActiveInstallDir()) + '_LegacyInstaller';
  ManifestPath := AddBackslash(LegacyDir) + 'install_manifest.txt';
  NewFilesManifestPath := AddBackslash(LegacyDir) + 'new_files_manifest.txt';

  if not DirExists(SourceDir) then
  begin
    WriteLegacyUIState('error', '100', 'External package source folder was not found.');
    CreateErrorReport('External package source folder was not found: ' + SourceDir);
    Exit;
  end;

  ForceDirectories(DestDir);

  Result := CopyDirectoryRecursive(
    SourceDir,
    DestDir,
    SourceBaseDir,
    ManifestPath,
    NewFilesManifestPath,
    GetActiveInstallDir()
  );

  if Result then
    WriteLegacyUIState('finalizing', '95', 'External package installed.')
  else
  begin
    WriteLegacyUIState('error', '100', 'Failed to install external package.');
    CreateErrorReport('Failed to copy external package to: ' + DestDir);
  end;
end;

procedure CleanupExternalPackageTemp();
begin
  if FileExists(ExpandConstant('{tmp}\{#ExternalArchiveName}')) then
    DeleteFile(ExpandConstant('{tmp}\{#ExternalArchiveName}'));

  if DirExists(ExpandConstant('{tmp}\{#ExternalExtractFolder}')) then
    DelTree(ExpandConstant('{tmp}\{#ExternalExtractFolder}'), True, True, True);
end;

function InstallExternalPackage(): Boolean;
begin
  Result := False;

  if LegacyUIAbortRequested() then
  begin
    AbortInstallAndCleanTemp();
    Exit;
  end;

  if not DownloadExternalPackage() then Exit;

  if LegacyUIAbortRequested() then
  begin
    AbortInstallAndCleanTemp();
    Exit;
  end;

  if not ExtractExternalPackage() then Exit;

  if LegacyUIAbortRequested() then
  begin
    AbortInstallAndCleanTemp();
    Exit;
  end;

  if not MoveExternalPackageToGame() then Exit;

  CleanupExternalPackageTemp();

  Result := True;
end;
#endif


; =========================================================
; Rollback helpers
; =========================================================

procedure RestoreBackupFiles(SourceDir, DestDir: String);
var
  FindRec: TFindRec;
  SourcePath: String;
  DestPath: String;
begin
  SourceDir := RemoveBackslashUnlessRoot(SourceDir);
  DestDir := RemoveBackslashUnlessRoot(DestDir);

  if FindFirst(SourceDir + '\*', FindRec) then
  begin
    try
      repeat
        if (FindRec.Name <> '.') and (FindRec.Name <> '..') then
        begin
          SourcePath := SourceDir + '\' + FindRec.Name;
          DestPath := DestDir + '\' + FindRec.Name;

          if (FindRec.Attributes and FILE_ATTRIBUTE_DIRECTORY) <> 0 then
          begin
            ForceDirectories(DestPath);
            RestoreBackupFiles(SourcePath, DestPath);
          end
          else
          begin
            ForceDirectories(ExtractFileDir(DestPath));

            if FileExists(DestPath) then
            begin
              MakeWritable(DestPath);
              DeleteFile(DestPath);
            end;

            CopyFile(SourcePath, DestPath, False);
          end;
        end;
      until not FindNext(FindRec);
    finally
      FindClose(FindRec);
    end;
  end;
end;

procedure DeleteFilesFromManifest(GameDir, ManifestPath: String);
var
  ManifestAnsi: AnsiString;
  ManifestText: String;
  Line: String;
  P: Integer;
  TargetPath: String;
begin
  if not FileExists(ManifestPath) then
    Exit;

  if not LoadStringFromFile(ManifestPath, ManifestAnsi) then
    Exit;

  ManifestText := String(ManifestAnsi);

  while Length(ManifestText) > 0 do
  begin
    P := Pos(#10, ManifestText);

    if P > 0 then
    begin
      Line := Copy(ManifestText, 1, P - 1);
      Delete(ManifestText, 1, P);
    end
    else
    begin
      Line := ManifestText;
      ManifestText := '';
    end;

    StringChangeEx(Line, #13, '', True);
    StringChangeEx(Line, #10, '', True);

    if Line <> '' then
    begin
      TargetPath := AddBackslash(GameDir) + Line;

      if FileExists(TargetPath) then
      begin
        MakeWritable(TargetPath);
        DeleteFile(TargetPath);
      end;
    end;
  end;
end;

procedure RemoveEmptyDirectories(Dir: String);
var
  FindRec: TFindRec;
  SubDir: String;
begin
  Dir := RemoveBackslashUnlessRoot(Dir);

  if FindFirst(Dir + '\*', FindRec) then
  begin
    try
      repeat
        if (FindRec.Name <> '.') and (FindRec.Name <> '..') then
        begin
          if (FindRec.Attributes and FILE_ATTRIBUTE_DIRECTORY) <> 0 then
          begin
            SubDir := Dir + '\' + FindRec.Name;

            if (CompareText(FindRec.Name, 'Backup') <> 0) and
               (CompareText(FindRec.Name, 'RestoreData') <> 0) and
               (CompareText(FindRec.Name, '_LegacyInstaller') <> 0) then
            begin
              RemoveEmptyDirectories(SubDir);
              RemoveDir(SubDir);
            end;
          end;
        end;
      until not FindNext(FindRec);
    finally
      FindClose(FindRec);
    end;
  end;
end;

procedure CleanupRollbackArtifacts(GameDir: String);
var
  RestoreDataDir: String;
begin
  RestoreDataDir := GetRestoreDataDir(GameDir);

  if DirExists(RestoreDataDir) then
    DelTree(RestoreDataDir, True, True, True);
end;

procedure TitleSpecificRollbackCleanup(GameDir: String);
begin
  ; TODO: Add title-specific cleanup here if required.
  ; Examples:
  ; DeleteFilesFromManifest(GameDir, AddBackslash(GameDir) + '_LegacyInstaller\extra_manifest.txt');
  ; Delete generated runtime config files such as nextgenfx_settings.ini if validation requires it.
end;


; =========================================================
; Uninstall flow
; =========================================================

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  GameDir: String;
  BackupDir: String;
  LegacyDir: String;
  ManifestPath: String;
  NewFilesManifestPath: String;
begin
  if CurUninstallStep = usUninstall then
  begin
    GameDir := ExpandConstant('{app}');
    UnlockRestoreDataAttributes(GameDir);

    BackupDir := GetBackupDir(GameDir);
    LegacyDir := AddBackslash(GameDir) + '_LegacyInstaller';
    ManifestPath := AddBackslash(LegacyDir) + 'install_manifest.txt';
    NewFilesManifestPath := AddBackslash(LegacyDir) + 'new_files_manifest.txt';

    WriteLegacyUIState('removing', '25', 'Removing installed GAME_NAME Legacy Modpack files...');
    DeleteFilesFromManifest(GameDir, NewFilesManifestPath);

    if DirExists(BackupDir) then
    begin
      WriteLegacyUIState('restoring', '60', 'Restoring original GAME_NAME game files...');
      RestoreBackupFiles(BackupDir, GameDir);

      WriteLegacyUIState('cleaning', '82', 'Running title-specific rollback cleanup...');
      TitleSpecificRollbackCleanup(GameDir);

      WriteLegacyUIState('cleaning', '85', 'Cleaning empty folders and rollback leftovers...');
      RemoveEmptyDirectories(GameDir);

      WriteLegacyUIState('cleaning', '92', 'Removing rollback backup and LegacyUI runtime...');
      CleanupRollbackArtifacts(GameDir);

      WriteLegacyUIState('complete', '100', 'Rollback complete. Original GAME_NAME files restored.');
    end
    else
    begin
      WriteLegacyUIState('error', '100', 'Backup folder was not found. Restore could not complete.');
    end;
  end;
end;


; =========================================================
; Install flow
; =========================================================

procedure CurStepChanged(CurStep: TSetupStep);
begin
  HideInnoWizard();

  if CurStep = ssInstall then
  begin
    if not ExtractArchiveToTemp() then
    begin
      if InstallAbortRequested then
      begin
        WriteLegacyUIState('error', '100', 'Installation cancelled by user.');
        KillAllFrontendBackendProcesses();
        Abort;
      end;

      WriteLegacyUIState('error', '100', 'Archive extraction failed.');
      CreateErrorReport('Archive extraction failed.');
      KillInstallerProcesses();
      Abort;
    end;

    if not CopyExtractedFilesToGame() then
    begin
      WriteLegacyUIState('error', '100', 'File copy failed.');
      CreateErrorReport('File copy failed.');
      KillInstallerProcesses();
      Abort;
    end;

#if EnableExternalPackage == 1
    if not InstallExternalPackage() then
    begin
      WriteLegacyUIState('error', '100', 'External package installation failed.');
      CreateErrorReport('External package installation failed.');
      KillInstallerProcesses();
      Abort;
    end;
#endif

    SetRestoreDataAttributes(GetActiveInstallDir());
    WriteLegacyUIState('finalizing', '98', 'Finalizing GAME_NAME installation state...');
  end;

  if CurStep = ssPostInstall then
  begin
    HideInnoWizard();
    Sleep(1000);

    WriteLegacyUIState('complete', '100', 'Installation complete.');

    Sleep(3000);
  end;
end;
