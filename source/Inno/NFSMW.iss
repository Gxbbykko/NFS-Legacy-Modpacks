#define MyAppName "Most Wanted Legacy Modpack"
#define MyAppVersion "1.3.0"
#define MyAppPublisher "Gxbbykko"
#define MyOutputName "MostWantedMP"

#define GameExe "speed.exe"
#define ArchiveName "NFSMW.arc"
#define TempExtractFolder "MostWantedLegacy_Extract"

[Setup]
AppId={{E0C9B896-11D2-41A7-B9B0-0B71D0F3E2A5}
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
WizardImageFile=C:\Users\Gabriel\Desktop\NFSMW_Modpack\InstallerProject\Images\wizard.bmp
WizardSmallImageFile=C:\Users\Gabriel\Desktop\NFSMW_Modpack\InstallerProject\Images\header.bmp
SetupIconFile=C:\Users\Gabriel\Desktop\NFSMW_Modpack\InstallerProject\Images\NFSMW_icon.ico
Uninstallable=yes
CreateUninstallRegKey=no
UninstallFilesDir={app}\_LegacyInstaller
UninstallDisplayName=Most Wanted Legacy Modpack Restore Tool

[Files]
Source: "C:\Users\Gabriel\Desktop\NFSMW_Modpack\InstallerProject\Tools\arc.exe"; Flags: dontcopy
Source: "C:\Users\Gabriel\Desktop\NFSMW_Modpack\InstallerProject\NFSMW.arc"; Flags: dontcopy
Source: "C:\Users\Gabriel\Desktop\NFSMW_Modpack\InstallerProject\Tools\Splash.exe"; Flags: dontcopy
Source: "C:\Users\Gabriel\Desktop\NFSMW_Modpack\InstallerProject\Images\splash.png"; Flags: dontcopy
Source: "C:\Users\Gabriel\Desktop\NFSMW_Modpack\InstallerProject\Tools\ArcRunner.exe"; Flags: dontcopy

[Code]

var
  UserAcceptedUnsafeInstall: Boolean;
  ExtractLogMemo: TNewMemo;

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

function FileSizeMatches(FileName: String; ExpectedSize: Integer): Boolean;
var
  Size: Integer;
begin
  Result := False;
  if not FileExists(FileName) then Exit;
  if FileSize(FileName, Size) then Result := Size = ExpectedSize;
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

  if Exec(ExpandConstant('{sys}\WindowsPowerShell\v1.0\powershell.exe'), PSCommand, '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
    Result := (ResultCode = 0);
end;

function RequiredFolderExists(BaseDir, FolderName: String): Boolean;
begin
  Result := DirExists(AddBackslash(BaseDir) + FolderName);
end;

function IsNFSMWInstallReady(BaseDir: String): Boolean;
var
  ExePath: String;
begin
  Result := False;

  ExePath := AddBackslash(BaseDir) + '{#GameExe}';

  if not FileExists(ExePath) then Exit;
  if not FileSizeMatches(ExePath, 6029312) then Exit;
  if not IsLargeAddressAware(ExePath) then Exit;

  if not FileSizeMatches(AddBackslash(BaseDir) + 'FRONTEND\FrontB.lzc', 2921499) then Exit;
  if not FileSizeMatches(AddBackslash(BaseDir) + 'GLOBAL\GlobalB.lzc', 1520744) then Exit;
  if not FileSizeMatches(AddBackslash(BaseDir) + 'GLOBAL\InGameB.lzc', 522637) then Exit;
  if not FileSizeMatches(AddBackslash(BaseDir) + 'LANGUAGES\English.bin', 232440) then Exit;

  if not RequiredFolderExists(BaseDir, 'CARS') then Exit;
  if not RequiredFolderExists(BaseDir, 'FRONTEND') then Exit;
  if not RequiredFolderExists(BaseDir, 'GLOBAL') then Exit;
  if not RequiredFolderExists(BaseDir, 'LANGUAGES') then Exit;
  if not RequiredFolderExists(BaseDir, 'TRACKS') then Exit;

  Result := True;
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
    'Selected game folder: ' + WizardDirValue() + #13#10 +
    'Error: ' + ErrorText + #13#10,
    False
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
begin
  Result := False;

  ExtractTemporaryFile('arc.exe');
  ExtractTemporaryFile('ArcRunner.exe');
  ExtractTemporaryFile('{#ArchiveName}');

  ArcExe := ExpandConstant('{tmp}\arc.exe');
  ArcRunnerExe := ExpandConstant('{tmp}\ArcRunner.exe');
  ArchivePath := ExpandConstant('{tmp}\{#ArchiveName}');
  TempExtractPath := ExpandConstant('{tmp}\{#TempExtractFolder}');
  LogPath := ExpandConstant('{tmp}\arc_progress.log');

  if FileExists(LogPath) then DeleteFile(LogPath);
  if DirExists(TempExtractPath) then DelTree(TempExtractPath, True, True, True);
  ForceDirectories(TempExtractPath);

  Params :=
    '"' + ArcExe + '" ' +
    '"' + ArchivePath + '" ' +
    '"' + TempExtractPath + '" ' +
    '"' + LogPath + '"';

  CreateExtractLogBox;

  WizardForm.StatusLabel.Caption := 'Installing Most Wanted Legacy Modpack...';
  WizardForm.FilenameLabel.Caption := 'Extracting archive silently. Please wait...';
  WizardForm.Refresh;
  
  if not Exec(ArcRunnerExe, Params, '', SW_HIDE, ewNoWait, ResultCode) then
  begin
    CreateErrorReport(
      'ArcRunner / FreeArc extraction failed.'#13#10 +
      'Expected temp log path: ' + LogPath + #13#10 +
      'ArcRunner path: ' + ArcRunnerExe + #13#10 +
      'Archive path: ' + ArchivePath
    );
    Exit;
  end;

  repeat
    Sleep(300);

    ExtractedSize := GetDirectorySize(TempExtractPath);
    ProgressPercent := Integer((ExtractedSize div 75730942));

    if ProgressPercent > 99 then
      ProgressPercent := 99;

    WizardForm.ProgressGauge.Position := ProgressPercent;
    WizardForm.StatusLabel.Caption := 'Installing Most Wanted Legacy Modpack...';
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
  Sleep(700);

  if (Pos('arc.exe exit code: 0', String(LogText)) = 0) and (Pos('All OK', String(LogText)) = 0) then
  begin
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
    if not IsNFSMWInstallReady(WizardDirValue()) then
    begin
      MsgResult :=
        MsgBox(
          'Your game does not appear to be patched to the required state.'#13#10#13#10 +
          '{#MyAppName} requires:'#13#10 +
          '• Need for Speed Most Wanted patched to v1.3'#13#10 +
          '• {#GameExe} patched with 4GB / Large Address Aware'#13#10 +
          '• A complete game installation with required v1.3 files'#13#10#13#10 +
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
    if not ExtractArchiveToTemp() then
    begin
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
      MsgBox(
        'File copy failed.'#13#10#13#10 +
        'Some files may not have been installed.'#13#10 +
        'An error report was created next to the installer.',
        mbError,
        MB_OK
      );
      RaiseException('Copy failed.');
    end;
  end;
end;