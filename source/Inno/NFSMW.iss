#define MyAppName "Most Wanted Legacy Modpack"
#define MyAppVersion "1.3.0"
#define MyAppPublisher "Gxbbykko"
#define MyOutputName "MostWantedMP"

#define GameId "nfsmw"
#define GameExe "speed.exe"
#define ArchiveName "NFSMW.arc"
#define TempExtractFolder "MostWantedLegacy_Extract"

#define MoviesUrl "https://drive.usercontent.google.com/download?id=1rlpaia0-EbU7iEdPgbQe2y88oTnZKUQ4&export=download&confirm=t&uuid=b87cba59-98aa-4816-a055-080e77c83609"
#define MoviesArchiveName "NFSMW_MOVIES.7z"
#define MoviesExtractFolder "NFSMWMoviesExtract"
#define MoviesSourceSubDir "NFSMW\MOVIES"
#define MoviesExpectedMinSize 2500000000

#define ProjectRoot "C:\Users\Gabriel\Desktop\NFSMW_Modpack"
#define InstallerProject AddBackslash(ProjectRoot) + "InstallerProject"
#define ToolsDir AddBackslash(InstallerProject) + "Tools"
#define ImagesDir AddBackslash(InstallerProject) + "Images"

[Setup]
AppId={{E0C9B896-11D2-41A7-B9B0-0B71D0F3E2A5}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={code:GetDefaultDir}
UsePreviousAppDir=no
OutputDir={#ProjectRoot}
OutputBaseFilename={#MyOutputName}

Compression=none
SolidCompression=no
WizardStyle=modern

DisableWelcomePage=yes
DisableDirPage=yes
DisableReadyPage=yes
DisableReadyMemo=no
DisableFinishedPage=yes
DisableProgramGroupPage=yes
AlwaysShowComponentsList=no

WizardImageFile={#ImagesDir}\wizard.bmp
WizardSmallImageFile={#ImagesDir}\header.bmp
SetupIconFile={#ImagesDir}\NFSMW_icon.ico

Uninstallable=yes
CreateUninstallRegKey=yes
UninstallFilesDir={app}\_LegacyInstaller
UninstallDisplayName=Most Wanted Legacy Modpack Restore Tool

[Files]
Source: "{#ToolsDir}\arc.exe"; Flags: dontcopy
Source: "{#ToolsDir}\ArcRunner.exe"; Flags: dontcopy
Source: "{#ToolsDir}\7z.exe"; Flags: dontcopy
Source: "{#ToolsDir}\7z.dll"; Flags: dontcopy
Source: "{#ToolsDir}\Splash.exe"; Flags: dontcopy
Source: "{#ImagesDir}\splash.png"; Flags: dontcopy
Source: "{#InstallerProject}\{#ArchiveName}"; Flags: dontcopy

Source: "{#ToolsDir}\LegacyUI\*"; DestDir: "{tmp}\LegacyUI"; Flags: dontcopy recursesubdirs createallsubdirs noencryption
Source: "{#ToolsDir}\LegacyUI\*"; DestDir: "{app}\_LegacyInstaller\LegacyUI"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{app}\_LegacyInstaller\Restore Most Wanted Legacy Modpack"; Filename: "{app}\_LegacyInstaller\LegacyUI\LegacyUI.exe"; Parameters: "--target ""{app}"" --mode uninstall --game {#GameId}"; WorkingDir: "{app}\_LegacyInstaller\LegacyUI"; IconFilename: "{app}\_LegacyInstaller\LegacyUI\LegacyUI.exe"

[Code]

var
  ExtractLogMemo: TNewMemo;
  LegacyUIResultCode: Integer;
  LegacyUIStatePath: String;
  LegacyUICommandPath: String;
  LegacyUITargetPath: String;
  InstallAbortRequested: Boolean;

function GetDefaultDir(Param: String): String;
begin
  if FileExists('C:\Games\Need for Speed - Most Wanted - Black Edition\{#GameExe}') then
    Result := 'C:\Games\Need for Speed - Most Wanted - Black Edition'
  else if FileExists(ExpandConstant('{pf}\EA GAMES\Need for Speed Most Wanted\{#GameExe}')) then
    Result := ExpandConstant('{pf}\EA GAMES\Need for Speed Most Wanted')
  else if FileExists(ExpandConstant('{pf32}\EA GAMES\Need for Speed Most Wanted\{#GameExe}')) then
    Result := ExpandConstant('{pf32}\EA GAMES\Need for Speed Most Wanted')
  else
    Result := 'C:\Games\Need for Speed - Most Wanted - Black Edition';
end;

function GetLauncherDirParam(): String;
begin
  Result := ExpandConstant('{param:DIR|}');

  if Result <> '' then
  begin
    StringChangeEx(Result, '"', '', True);
    Result := RemoveBackslashUnlessRoot(Result);
  end;
end;

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

function GetInstallerErrorFolder(): String;
begin
  Result := AddBackslash(ExpandConstant('{src}')) + '_MostWantedLegacy_Error_Backup';
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
    'Most Wanted Legacy Modpack installation error'#13#10 +
    'Timestamp: ' + GetDateTimeString('yyyy-mm-dd hh:nn:ss', '-', ':') + #13#10 +
    'Selected game folder: ' + GetActiveInstallDir() + #13#10 +
    'Error: ' + ErrorText + #13#10,
    False
  );
end;

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
  TerminateProcessByName('7z.exe');
end;

procedure KillAllFrontendBackendProcesses();
begin
  TerminateProcessByName('ArcRunner.exe');
  TerminateProcessByName('arc.exe');
  TerminateProcessByName('7z.exe');
  TerminateProcessByName('LegacyUI.exe');
end;

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
    KillAllFrontendBackendProcesses;
    Abort;
  end;

  WizardForm.DirEdit.Text := LegacyUITargetPath;
  HideInnoWizard;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;
end;

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

procedure DeleteIfExists(FileName: String);
begin
  if FileExists(FileName) then
  begin
    MakeWritable(FileName);
    DeleteFile(FileName);
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
  MoviesArchivePath: String;
  MoviesExtractPath: String;
begin
  TempExtractPath := ExpandConstant('{tmp}\{#TempExtractFolder}');
  MoviesArchivePath := ExpandConstant('{tmp}\{#MoviesArchiveName}');
  MoviesExtractPath := ExpandConstant('{tmp}\{#MoviesExtractFolder}');

  KillInstallerProcesses;

  if DirExists(TempExtractPath) then
    DelTree(TempExtractPath, True, True, True);

  if FileExists(MoviesArchivePath) then
    DeleteFile(MoviesArchivePath);

  if DirExists(MoviesExtractPath) then
    DelTree(MoviesExtractPath, True, True, True);

  WriteLegacyUIState('error', '100', 'Installation cancelled. Temporary files were cleaned.');
  CreateErrorReport('Installation cancelled during install operations.');
end;

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

  WriteLegacyUIState('extracting', '20', 'Extracting Most Wanted archive payload...');

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

  CreateExtractLogBox;

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
    ProgressPercent := Integer(ExtractedSize div 75730942);

    if ProgressPercent > 99 then
      ProgressPercent := 99;

    if ProgressPercent < 20 then
      ProgressPercent := 20;

    WriteLegacyUIState('extracting', IntToStr(ProgressPercent), 'Extracting Most Wanted archive payload...');

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

  WriteLegacyUIState('copying', '65', 'Installing Most Wanted modpack files...');
  Result := True;
end;

function ShouldSkipManifest(RelPath: String): Boolean;
begin
  Result :=
    (Pos('Backup\', RelPath) = 1) or
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

  if FileExists(NewFilesManifestPath) then
    DeleteFile(NewFilesManifestPath);

  WriteLegacyUIState('copying', '70', 'Copying extracted files into the Most Wanted folder...');

  Result := CopyDirectoryRecursive(
    TempExtractPath,
    GetActiveInstallDir(),
    TempExtractPath,
    ManifestPath,
    NewFilesManifestPath,
    GetActiveInstallDir()
  );

  if Result then
    WriteLegacyUIState('finalizing', '76', 'Writing rollback manifest and preparing MOVIES package...')
  else
    WriteLegacyUIState('error', '100', 'File copy failed.');
end;

function DownloadMoviesPackage(): Boolean;
var
  ResultCode: Integer;
  PowerShellExe: String;
  MoviesArchivePath: String;
  Params: String;
begin
  Result := False;

  MoviesArchivePath := ExpandConstant('{tmp}\{#MoviesArchiveName}');

  if FileExists(MoviesArchivePath) then
    DeleteFile(MoviesArchivePath);

  WriteLegacyUIState('downloading', '78', 'Downloading Most Wanted MOVIES package...');

  PowerShellExe := ExpandConstant('{sys}\WindowsPowerShell\v1.0\powershell.exe');

  Params :=
    '-NoProfile -ExecutionPolicy Bypass -Command "' +
    '$ProgressPreference = ''SilentlyContinue''; ' +
    'Invoke-WebRequest -Uri ''{#MoviesUrl}'' -OutFile ''' + MoviesArchivePath + ''' -UseBasicParsing; ' +
    'if ((Get-Item ''' + MoviesArchivePath + ''').Length -lt {#MoviesExpectedMinSize}) { exit 23 }' +
    '"';

  if not Exec(
    PowerShellExe,
    Params,
    '',
    SW_HIDE,
    ewWaitUntilTerminated,
    ResultCode
  ) then
  begin
    WriteLegacyUIState('error', '100', 'Failed to start MOVIES download helper.');
    CreateErrorReport('Failed to start PowerShell download helper.');
    Exit;
  end;

  if ResultCode <> 0 then
  begin
    WriteLegacyUIState('error', '100', 'MOVIES package download failed or was incomplete.');
    CreateErrorReport('PowerShell download failed or file size check failed. Exit code: ' + IntToStr(ResultCode));
    Exit;
  end;

  if not FileExists(MoviesArchivePath) then
  begin
    WriteLegacyUIState('error', '100', 'MOVIES package was not downloaded.');
    CreateErrorReport('Downloaded MOVIES archive was not found: ' + MoviesArchivePath);
    Exit;
  end;

  WriteLegacyUIState('downloading', '84', 'MOVIES package downloaded successfully.');
  Result := True;
end;

function ExtractMoviesPackage(): Boolean;
var
  ResultCode: Integer;
  SevenZipExe: String;
  MoviesArchivePath: String;
  MoviesExtractPath: String;
  Params: String;
begin
  Result := False;

  WriteLegacyUIState('extracting', '86', 'Extracting Most Wanted MOVIES package...');

  ExtractTemporaryFile('7z.exe');
  ExtractTemporaryFile('7z.dll');

  SevenZipExe := ExpandConstant('{tmp}\7z.exe');
  MoviesArchivePath := ExpandConstant('{tmp}\{#MoviesArchiveName}');
  MoviesExtractPath := ExpandConstant('{tmp}\{#MoviesExtractFolder}');

  if DirExists(MoviesExtractPath) then
    DelTree(MoviesExtractPath, True, True, True);

  ForceDirectories(MoviesExtractPath);

  Params :=
    'x "' + MoviesArchivePath + '" ' +
    '-o"' + MoviesExtractPath + '" ' +
    '-y';

  if not Exec(
    SevenZipExe,
    Params,
    ExpandConstant('{tmp}'),
    SW_HIDE,
    ewWaitUntilTerminated,
    ResultCode
  ) then
  begin
    WriteLegacyUIState('error', '100', 'Failed to start MOVIES extraction helper.');
    CreateErrorReport('Failed to start 7z.exe for MOVIES extraction.');
    Exit;
  end;

  if ResultCode <> 0 then
  begin
    WriteLegacyUIState('error', '100', 'MOVIES package extraction failed.');
    CreateErrorReport('7z MOVIES extraction failed. Exit code: ' + IntToStr(ResultCode));
    Exit;
  end;

  if not DirExists(AddBackslash(MoviesExtractPath) + '{#MoviesSourceSubDir}') then
  begin
    WriteLegacyUIState('error', '100', 'Extracted MOVIES folder was not found.');
    CreateErrorReport(
      'Expected MOVIES source folder missing: ' +
      AddBackslash(MoviesExtractPath) + '{#MoviesSourceSubDir}'
    );
    Exit;
  end;

  WriteLegacyUIState('extracting', '90', 'MOVIES package extracted successfully.');
  Result := True;
end;

function MoveMoviesFolderToGame(): Boolean;
var
  SourceMoviesDir: String;
  SourceMoviesBaseDir: String;
  DestMoviesDir: String;
  LegacyDir: String;
  ManifestPath: String;
  NewFilesManifestPath: String;
begin
  Result := False;

  WriteLegacyUIState('copying', '92', 'Installing Most Wanted MOVIES package...');

  SourceMoviesDir :=
    AddBackslash(ExpandConstant('{tmp}\{#MoviesExtractFolder}')) + '{#MoviesSourceSubDir}';

  SourceMoviesBaseDir :=
    AddBackslash(ExpandConstant('{tmp}\{#MoviesExtractFolder}')) + 'NFSMW';

  DestMoviesDir := AddBackslash(GetActiveInstallDir()) + 'MOVIES';

  LegacyDir := AddBackslash(GetActiveInstallDir()) + '_LegacyInstaller';
  ManifestPath := AddBackslash(LegacyDir) + 'install_manifest.txt';
  NewFilesManifestPath := AddBackslash(LegacyDir) + 'new_files_manifest.txt';

  if not DirExists(SourceMoviesDir) then
  begin
    WriteLegacyUIState('error', '100', 'MOVIES source folder was not found.');
    CreateErrorReport('MOVIES source folder was not found: ' + SourceMoviesDir);
    Exit;
  end;

  ForceDirectories(DestMoviesDir);

  Result := CopyDirectoryRecursive(
    SourceMoviesDir,
    DestMoviesDir,
    SourceMoviesBaseDir,
    ManifestPath,
    NewFilesManifestPath,
    GetActiveInstallDir()
  );

  if Result then
    WriteLegacyUIState('finalizing', '95', 'Most Wanted MOVIES package installed.')
  else
  begin
    WriteLegacyUIState('error', '100', 'Failed to install MOVIES folder into the game directory.');
    CreateErrorReport('Failed to copy MOVIES folder to: ' + DestMoviesDir);
  end;
end;

procedure CleanupMoviesTemp();
var
  MoviesArchivePath: String;
  MoviesExtractPath: String;
begin
  MoviesArchivePath := ExpandConstant('{tmp}\{#MoviesArchiveName}');
  MoviesExtractPath := ExpandConstant('{tmp}\{#MoviesExtractFolder}');

  if FileExists(MoviesArchivePath) then
    DeleteFile(MoviesArchivePath);

  if DirExists(MoviesExtractPath) then
    DelTree(MoviesExtractPath, True, True, True);
end;

function InstallMoviesPackage(): Boolean;
begin
  Result := False;

  if LegacyUIAbortRequested() then
  begin
    AbortInstallAndCleanTemp();
    Exit;
  end;

  if not DownloadMoviesPackage() then
    Exit;

  if LegacyUIAbortRequested() then
  begin
    AbortInstallAndCleanTemp();
    Exit;
  end;

  if not ExtractMoviesPackage() then
    Exit;

  if LegacyUIAbortRequested() then
  begin
    AbortInstallAndCleanTemp();
    Exit;
  end;

  if not MoveMoviesFolderToGame() then
    Exit;

  CleanupMoviesTemp();

  Result := True;
end;

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

    WriteLegacyUIState('removing', '25', 'Removing installed Most Wanted Legacy Modpack files...');
    DeleteFilesFromManifest(GameDir, NewFilesManifestPath);

    if DirExists(BackupDir) then
    begin
      WriteLegacyUIState('restoring', '60', 'Restoring original Most Wanted game files...');
      RestoreBackupFiles(BackupDir, GameDir);

      WriteLegacyUIState('cleaning', '85', 'Cleaning empty folders and rollback leftovers...');
      RemoveEmptyDirectories(GameDir);

      WriteLegacyUIState('cleaning', '92', 'Removing rollback backup and LegacyUI runtime...');
      CleanupRollbackArtifacts(GameDir);

      WriteLegacyUIState('complete', '100', 'Rollback complete. Original Most Wanted files restored.');
    end
    else
    begin
      WriteLegacyUIState('error', '100', 'Backup folder was not found. Restore could not complete.');
    end;
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  HideInnoWizard;

  if CurStep = ssInstall then
  begin
    if not ExtractArchiveToTemp() then
    begin
      if InstallAbortRequested then
      begin
        WriteLegacyUIState('error', '100', 'Installation cancelled by user.');
        KillAllFrontendBackendProcesses;
        Abort;
      end;

      WriteLegacyUIState('error', '100', 'Archive extraction failed.');
      CreateErrorReport('Archive extraction failed.');
      KillInstallerProcesses;
      Abort;
    end;

    if not CopyExtractedFilesToGame() then
    begin
      WriteLegacyUIState('error', '100', 'File copy failed.');
      CreateErrorReport('File copy failed.');
      KillInstallerProcesses;
      Abort;
    end;

    if not InstallMoviesPackage() then
    begin
      WriteLegacyUIState('error', '100', 'MOVIES package installation failed.');
      CreateErrorReport('MOVIES package installation failed.');
      KillInstallerProcesses;
      Abort;
    end;

    SetRestoreDataAttributes(GetActiveInstallDir());
    WriteLegacyUIState('finalizing', '98', 'Finalizing Most Wanted installation state...');
  end;

  if CurStep = ssPostInstall then
  begin
    HideInnoWizard;
    Sleep(1000);

    WriteLegacyUIState('complete', '100', 'Installation complete.');

    Sleep(3000);
  end;
end;