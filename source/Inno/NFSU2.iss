#define MyAppName "Underground 2 Legacy Modpack"
#define MyAppVersion "1.2.0"
#define MyAppPublisher "Gxbbykko"
#define MyOutputName "Underground2MP"

#define GameExe "SPEED2.EXE"
#define ArchiveName "NFSU2.arc"
#define TempExtractFolder "Underground2Legacy_Extract"

[Setup]
AppId={{B42B49F2-6F0C-48D6-91D2-2E1F37A6C2D8}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={code:GetDefaultDir}
DisableProgramGroupPage=yes
DisableReadyMemo=no
DisableReadyPage=no
OutputDir=.
OutputBaseFilename={#MyOutputName}
Compression=none
SolidCompression=no
WizardStyle=modern
WizardImageFile=C:\Users\Gabriel\Desktop\NFSU2_Modpack\InstallerProject\Images\wizard.bmp
WizardSmallImageFile=C:\Users\Gabriel\Desktop\NFSU2_Modpack\InstallerProject\Images\header.bmp
SetupIconFile=C:\Users\Gabriel\Desktop\NFSU2_Modpack\InstallerProject\Images\NFSU2_icon.ico
Uninstallable=yes
CreateUninstallRegKey=no
UninstallFilesDir={app}\_LegacyInstaller
UninstallDisplayName=Underground 2 Legacy Modpack Restore Tool

[Files]
Source: "C:\Users\Gabriel\Desktop\NFSU2_Modpack\InstallerProject\Tools\arc.exe"; Flags: dontcopy
Source: "C:\Users\Gabriel\Desktop\NFSU2_Modpack\InstallerProject\NFSU2.arc"; Flags: dontcopy
Source: "C:\Users\Gabriel\Desktop\NFSU2_Modpack\InstallerProject\Tools\Splash.exe"; Flags: dontcopy
Source: "C:\Users\Gabriel\Desktop\NFSU2_Modpack\InstallerProject\Images\splash.png"; Flags: dontcopy
Source: "C:\Users\Gabriel\Desktop\NFSU2_Modpack\InstallerProject\Tools\ArcRunner.exe"; Flags: dontcopy
Source: "C:\Users\Gabriel\Desktop\NFSU2_Modpack\InstallerProject\Tools\LegacyUI.exe"; Flags: dontcopy
Source: "C:\Users\Gabriel\Desktop\NFSU2_Modpack\InstallerProject\Tools\D3DCompiler_47_cor3.dll"; Flags: dontcopy
Source: "C:\Users\Gabriel\Desktop\NFSU2_Modpack\InstallerProject\Tools\PenImc_cor3.dll"; Flags: dontcopy
Source: "C:\Users\Gabriel\Desktop\NFSU2_Modpack\InstallerProject\Tools\PresentationNative_cor3.dll"; Flags: dontcopy
Source: "C:\Users\Gabriel\Desktop\NFSU2_Modpack\InstallerProject\Tools\vcruntime140_cor3.dll"; Flags: dontcopy
Source: "C:\Users\Gabriel\Desktop\NFSU2_Modpack\InstallerProject\Tools\wpfgfx_cor3.dll"; Flags: dontcopy

[Code]

var
  UserAcceptedUnsafeInstall: Boolean;
  ExtractLogMemo: TNewMemo;
  LegacyUIResultCode: Integer;
  LegacyUIStatePath: String;
  LegacyUICommandPath: String;

function GetDefaultDir(Param: String): String;
begin
  if FileExists('C:\Games\Need for Speed - Underground 2\{#GameExe}') then
    Result := 'C:\Games\Need for Speed - Underground 2'
  else if FileExists(ExpandConstant('{pf}\EA GAMES\Need for Speed Underground 2\{#GameExe}')) then
    Result := ExpandConstant('{pf}\EA GAMES\Need for Speed Underground 2')
  else if FileExists(ExpandConstant('{pf32}\EA GAMES\Need for Speed Underground 2\{#GameExe}')) then
    Result := ExpandConstant('{pf32}\EA GAMES\Need for Speed Underground 2')
  else
    Result := 'C:\Games\Need for Speed - Underground 2';
end;

function FileSizeMatches(FileName: String; ExpectedSize: Integer): Boolean;
var
  Size: Integer;
begin
  Result := False;

  if not FileExists(FileName) then
    Exit;

  if FileSize(FileName, Size) then
    Result := Size = ExpectedSize;
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

function RequiredFolderExists(BaseDir, FolderName: String): Boolean;
begin
  Result := DirExists(AddBackslash(BaseDir) + FolderName);
end;

function IsNFSU2InstallReady(BaseDir: String): Boolean;
var
  ExePath: String;
begin
  Result := False;

  ExePath := AddBackslash(BaseDir) + '{#GameExe}';

  if not FileExists(ExePath) then Exit;
  if not FileSizeMatches(ExePath, 4800512) then Exit;
  if not IsLargeAddressAware(ExePath) then Exit;

  if not FileSizeMatches(AddBackslash(BaseDir) + 'FRONTEND\FrontB.lzc', 1750771) then Exit;
  if not FileSizeMatches(AddBackslash(BaseDir) + 'GLOBAL\GlobalB.lzc', 5145778) then Exit;
  if not FileSizeMatches(AddBackslash(BaseDir) + 'GLOBAL\InGameCommon.lzc', 479938) then Exit;
  if not FileSizeMatches(AddBackslash(BaseDir) + 'LANGUAGES\English.bin', 270456) then Exit;

  if not RequiredFolderExists(BaseDir, 'CARS') then Exit;
  if not RequiredFolderExists(BaseDir, 'FRONTEND') then Exit;
  if not RequiredFolderExists(BaseDir, 'GLOBAL') then Exit;
  if not RequiredFolderExists(BaseDir, 'LANGUAGES') then Exit;
  if not RequiredFolderExists(BaseDir, 'TRACKS') then Exit;

  Result := True;
end;

function GetInstallerErrorFolder(): String;
begin
  Result := AddBackslash(ExpandConstant('{src}')) + '_Underground2Legacy_Error_Backup';
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
    'Underground 2 Legacy Modpack installation error'#13#10 +
    'Timestamp: ' + GetDateTimeString('yyyy-mm-dd hh:nn:ss', '-', ':') + #13#10 +
    'Selected game folder: ' + WizardDirValue() + #13#10 +
    'Error: ' + ErrorText + #13#10,
    False
  );
end;

procedure WriteLegacyUIState(Phase, Progress, Message: String);
var
  StateText: String;
  StateDir: String;
begin
  StateDir := AddBackslash(WizardDirValue()) + '_LegacyInstaller';
  ForceDirectories(StateDir);

  LegacyUIStatePath := AddBackslash(StateDir) + 'legacyui_state.ini';

  StateText :=
    'phase=' + Phase + #13#10 +
    'progress=' + Progress + #13#10 +
    'message=' + Message + #13#10;

  if FileExists(LegacyUIStatePath) then
    DeleteFile(LegacyUIStatePath);

  if not SaveStringToFile(LegacyUIStatePath, StateText, False) then
    CreateErrorReport('Failed to write LegacyUI state file: ' + LegacyUIStatePath);
end;

procedure LaunchLegacyUI;
var
  Params: String;
  LegacyDir: String;
begin
  ExtractTemporaryFile('LegacyUI.exe');
  ExtractTemporaryFile('D3DCompiler_47_cor3.dll');
  ExtractTemporaryFile('PenImc_cor3.dll');
  ExtractTemporaryFile('PresentationNative_cor3.dll');
  ExtractTemporaryFile('vcruntime140_cor3.dll');
  ExtractTemporaryFile('wpfgfx_cor3.dll');

  LegacyDir := AddBackslash(WizardDirValue()) + '_LegacyInstaller';
  ForceDirectories(LegacyDir);

  LegacyUIStatePath := AddBackslash(LegacyDir) + 'legacyui_state.ini';
  LegacyUICommandPath := AddBackslash(LegacyDir) + 'legacyui_command.ini';

  if FileExists(LegacyUICommandPath) then
    DeleteFile(LegacyUICommandPath);

  WriteLegacyUIState('preparing', '5', 'Preparing Underground 2 installation environment...');

  Params :=
    '--target "' + WizardDirValue() + '" ' +
    '--mode install ' +
    '--game nfsu2 ' +
    '--state "' + LegacyUIStatePath + '" ' +
    '--command "' + LegacyUICommandPath + '"';

  Exec(
    ExpandConstant('{tmp}\LegacyUI.exe'),
    Params,
    ExpandConstant('{tmp}'),
    SW_SHOW,
    ewNoWait,
    LegacyUIResultCode
  );
end;

procedure WaitForLegacyUIExitCommand;
var
  CommandText: AnsiString;
begin
  while True do
  begin
    Sleep(300);

    if FileExists(LegacyUICommandPath) then
    begin
      if LoadStringFromFile(LegacyUICommandPath, CommandText) then
      begin
        if Pos('command=exit', String(CommandText)) > 0 then
          Break;
      end;
    end;
  end;
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
  ExtractLogMemo.Visible := True;
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
  LegacyProgress: Integer;
begin
  Result := False;

  LogText := '';
  WriteLegacyUIState('extracting', '10', 'Extracting Underground 2 archive payload...');

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

  WizardForm.StatusLabel.Caption := 'Installing Underground 2 Legacy Modpack...';
  WizardForm.FilenameLabel.Caption := 'Extracting archive silently. Please wait...';
  WizardForm.Refresh;

  if not Exec(ArcRunnerExe, Params, '', SW_HIDE, ewNoWait, ResultCode) then
  begin
    WriteLegacyUIState('error', '100', 'Failed to launch archive extraction helper.');
    CreateErrorReport('Failed to launch ArcRunner.exe.');
    Exit;
  end;

  repeat
    Sleep(300);

    ExtractedSize := GetDirectorySize(TempExtractPath);
    ProgressPercent := Integer((ExtractedSize div 50427015));

    if ProgressPercent > 99 then
      ProgressPercent := 99;

    LegacyProgress := 10 + ((ProgressPercent * 55) div 100);

    if LegacyProgress > 65 then
      LegacyProgress := 65;

    WriteLegacyUIState(
      'extracting',
      IntToStr(LegacyProgress),
      'Extracting Underground 2 archive payload...'
    );

    WizardForm.ProgressGauge.Position := ProgressPercent;
    WizardForm.StatusLabel.Caption := 'Installing Underground 2 Legacy Modpack...';
    WizardForm.FilenameLabel.Caption :=
      'Extracting archive silently. Estimated progress: ' + IntToStr(ProgressPercent) + '%';

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

    WizardForm.Refresh;

  until (Pos('arc.exe exit code:', String(LogText)) > 0) or
        (Pos('All OK', String(LogText)) > 0);

  WizardForm.ProgressGauge.Position := 100;
  WizardForm.StatusLabel.Caption := 'Extraction completed successfully.';
  WizardForm.FilenameLabel.Caption := 'Preparing files for installation...';
  WizardForm.Refresh;

  WriteLegacyUIState('extracting', '66', 'Archive extraction completed successfully.');
  Sleep(700);

  if (Pos('arc.exe exit code: 0', String(LogText)) = 0) and
     (Pos('All OK', String(LogText)) = 0) then
  begin
    WriteLegacyUIState('error', '100', 'Archive extraction failed.');
    CreateErrorReport('ArcRunner / FreeArc extraction failed. See arc_progress.log.');
    Exit;
  end;

  Result := True;
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

function ShouldSkipManifest(RelPath: String): Boolean;
begin
  Result :=
    (Pos('Backup\', RelPath) = 1) or
    (Pos('_LegacyInstaller\', RelPath) = 1);
end;

function CopyDirectoryRecursive(SourceDir, DestDir, BaseSourceDir, ManifestPath: String): Boolean;
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
            if not CopyDirectoryRecursive(SourcePath, DestPath, BaseSourceDir, ManifestPath) then
            begin
              Result := False;
              Exit;
            end;
          end
          else
          begin
            if FileExists(DestPath) then
            begin
              MakeWritable(DestPath);

              if not DeleteFile(DestPath) then
              begin
                CreateErrorReport('Failed to delete existing file before overwrite: ' + DestPath);
                Result := False;
                Exit;
              end;
            end;

            if not CopyFile(SourcePath, DestPath, False) then
            begin
              CreateErrorReport('Failed to copy file: ' + SourcePath + ' -> ' + DestPath);
              Result := False;
              Exit;
            end;

            RelPath := Copy(SourcePath, Length(BaseSourceDir) + 2, Length(SourcePath));

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
begin
  TempExtractPath := ExpandConstant('{tmp}\{#TempExtractFolder}');
  LegacyDir := AddBackslash(WizardDirValue()) + '_LegacyInstaller';
  ManifestPath := AddBackslash(LegacyDir) + 'install_manifest.txt';

  ForceDirectories(LegacyDir);

  if FileExists(ManifestPath) then
    DeleteFile(ManifestPath);

  WizardForm.StatusLabel.Caption := 'Installing modpack files...';
  WizardForm.FilenameLabel.Caption := 'Copying extracted files into the game folder';

  WriteLegacyUIState('copying', '70', 'Copying extracted files into the Underground 2 folder...');
  Result := CopyDirectoryRecursive(TempExtractPath, WizardDirValue(), TempExtractPath, ManifestPath);
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
  UserAcceptedUnsafeInstall := False;
  RunSplash;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
var
  MsgResult: Integer;
begin
  Result := True;

  if CurPageID = wpSelectDir then
  begin
    if not IsNFSU2InstallReady(WizardDirValue()) then
    begin
      MsgResult :=
        MsgBox(
          'Your game does not appear to be patched to the required state.'#13#10#13#10 +
          '{#MyAppName} requires:'#13#10 +
          '• Need for Speed Underground 2 patched to v1.2'#13#10 +
          '• {#GameExe} patched with 4GB / Large Address Aware'#13#10 +
          '• A complete game installation with required v1.2 files'#13#10#13#10 +
          'Installing anyway may break your game, cause crashes, missing textures, or failed startup.'#13#10#13#10 +
          'YES = Continue anyway at your own risk'#13#10 +
          'NO = Go back and patch the game first',
          mbCriticalError,
          MB_YESNO
        );

      if MsgResult = IDYES then
      begin
        UserAcceptedUnsafeInstall := True;
        Result := True;
      end
      else
      begin
        Result := False;
      end;
    end;
  end;
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

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  GameDir: String;
  BackupDir: String;
  LegacyDir: String;
  ManifestPath: String;
begin
  if CurUninstallStep = usUninstall then
  begin
    GameDir := ExpandConstant('{app}');
    BackupDir := AddBackslash(GameDir) + 'Backup';
    LegacyDir := AddBackslash(GameDir) + '_LegacyInstaller';
    ManifestPath := AddBackslash(LegacyDir) + 'install_manifest.txt';

    DeleteFilesFromManifest(GameDir, ManifestPath);

    if DirExists(BackupDir) then
    begin
      RestoreBackupFiles(BackupDir, GameDir);
      RemoveEmptyDirectories(GameDir);

      MsgBox(
        'Backup files were restored successfully.'#13#10#13#10 +
        'Modpack-added files were removed using the install manifest.',
        mbInformation,
        MB_OK
      );
    end
    else
    begin
      MsgBox(
        'Backup folder was not found.'#13#10#13#10 +
        'The uninstaller removed manifest files but could not restore original files.',
        mbError,
        MB_OK
      );
    end;
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssInstall then
  begin
    LaunchLegacyUI;
    WizardForm.Hide;

    if not ExtractArchiveToTemp() then
    begin
      WriteLegacyUIState('error', '100', 'Archive extraction failed.');

      MsgBox(
        'Archive extraction failed.'#13#10#13#10 +
        'The game folder was not modified.'#13#10 +
        'An error report was created next to the installer.',
        mbError,
        MB_OK
      );

      RaiseException('Extraction failed.');
    end;

    if not CopyExtractedFilesToGame() then
    begin
      WriteLegacyUIState('error', '100', 'File copy failed.');

      MsgBox(
        'File copy failed.'#13#10#13#10 +
        'Some files may not have been installed.'#13#10 +
        'An error report was created next to the installer.',
        mbError,
        MB_OK
      );

      RaiseException('Copy failed.');
    end;

    WriteLegacyUIState('finalizing', '98', 'Finalizing Underground 2 installation state...');
  end;

  if CurStep = ssPostInstall then
  begin
    Sleep(1000);

    WriteLegacyUIState('complete', '100', 'Installation complete.');
    WaitForLegacyUIExitCommand;

    WizardForm.Close;
    Sleep(500);
    TerminateProcessByName('Setup.tmp');
    TerminateProcessByName('{#MyOutputName}.tmp');
  end;
end;