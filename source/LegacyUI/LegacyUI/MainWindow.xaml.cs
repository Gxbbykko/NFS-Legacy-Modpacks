using System;
using System.Diagnostics;
using System.IO;
using System.Windows;
using System.Windows.Threading;
using LegacyUI.Models;
using LegacyUI.Services;

namespace LegacyUI
{
    public partial class MainWindow : Window
    {
        private readonly GameProfile _profile;
        private readonly InstallScanner _scanner;
        private readonly DispatcherTimer _timer;
        private readonly string _mode;
        private readonly string _targetPath;
        private LegacyStateReader? _stateReader;
        private int _activityIndex = 0;
        private readonly string _commandPath;
        private readonly string _statePath;
        private readonly bool _simulateMode;
        private bool _uninstallPrepared = false;
        private bool _awaitingRestoreConfirmation = false;
        private bool _rollbackRunning = false;

        public MainWindow()
        {
            InitializeComponent();

            var parser = new ArgumentParser(Environment.GetCommandLineArgs());

            string target = parser.Get("target", Environment.CurrentDirectory);
            _targetPath = target;

            string gameId = parser.Get("game", "auto").ToLowerInvariant();
            _mode = parser.Get("mode", "install").ToLowerInvariant();
            _commandPath = parser.Get("command", "");

            string simulateValue = parser.Get("simulate", "false").ToLowerInvariant();
            _simulateMode =
                simulateValue == "true" ||
                simulateValue == "1" ||
                simulateValue == "yes";

            string parsedStatePath = parser.Get("state", "");

            if (_mode == "uninstall" && string.IsNullOrWhiteSpace(parsedStatePath))
            {
                parsedStatePath = Path.Combine(_targetPath, "_LegacyInstaller", "legacyui_state.ini");
            }

            _statePath = parsedStatePath;

            if (!string.IsNullOrWhiteSpace(_statePath))
            {
                _stateReader = new LegacyStateReader(_statePath);
            }

            if (gameId == "auto" || string.IsNullOrWhiteSpace(gameId))
            {
                gameId = GameDetector.Detect(target);
            }

            if (!GameProfiles.Profiles.TryGetValue(gameId, out _profile!))
            {
                _profile = GameProfiles.Profiles["nfsu"];
                gameId = "nfsu";
            }

            _scanner = new InstallScanner(_profile, target, _mode);

            Title = _profile.Title;
            TitleText.Text = _profile.Title;
            SubtitleText.Text = $"{gameId.ToUpperInvariant()} / {_mode.ToUpperInvariant()}";
            ModeText.Text = _simulateMode
                ? $"Mode: {_mode} / SIMULATION"
                : $"Mode: {_mode}";
            DetailText.Text = $"Monitoring: {target}";

            _timer = new DispatcherTimer
            {
                Interval = TimeSpan.FromMilliseconds(500)
            };

            _timer.Tick += (_, _) => UpdateTelemetry();
            _timer.Start();

            Loaded += async (_, _) =>
            {
                if (_mode == "uninstall" && !_uninstallPrepared)
                {
                    _uninstallPrepared = true;

                    if (_simulateMode)
                    {
                        await RunSimulatedUninstallAsync();
                    }
                    else
                    {
                        PrepareRestoreConfirmation();
                    }
                }
            };

            if (_mode != "uninstall")
            {
                UpdateTelemetry();
            }
            else
            {
                SetManualState(
                    0,
                    "Preparing rollback...",
                    _simulateMode
                        ? "Waiting for simulated rollback sequence."
                        : "Waiting for restore confirmation.",
                    "Preparing LegacyUI restore screen...",
                    "_LegacyInstaller\\"
                );
            }
        }

        private bool ValidateUninstallBackend(out int manifestLines)
        {
            manifestLines = 0;

            string legacyDir = Path.Combine(_targetPath, "_LegacyInstaller");
            string uninstaller = Path.Combine(legacyDir, "unins000.exe");
            string uninstallData = Path.Combine(legacyDir, "unins000.dat");
            string manifest = Path.Combine(legacyDir, "install_manifest.txt");

            if (!Directory.Exists(legacyDir))
            {
                SetManualError("Rollback folder was not found. Missing _LegacyInstaller directory.");
                return false;
            }

            if (!File.Exists(uninstaller))
            {
                SetManualError("Restore tool was not found. Missing _LegacyInstaller\\unins000.exe.");
                return false;
            }

            if (!File.Exists(uninstallData))
            {
                SetManualError("Restore metadata was not found. Missing _LegacyInstaller\\unins000.dat.");
                return false;
            }

            if (!File.Exists(manifest))
            {
                SetManualError("Rollback manifest was not found. Missing _LegacyInstaller\\install_manifest.txt.");
                return false;
            }

            try
            {
                manifestLines = File.ReadAllLines(manifest).Length;
            }
            catch
            {
                manifestLines = 0;
            }

            return true;
        }

        private void PrepareRestoreConfirmation()
        {
            SetManualState(
                0,
                "Restore ready",
                "This will remove the installed modpack and restore your original game files from backup. No files are changed until Restore is pressed.",
                "Ready to restore original game state...",
                "Rollback system ready"
            );

            if (!ValidateUninstallBackend(out int manifestLines))
                return;

            ManifestText.Text = $"Rollback entries: {manifestLines}";

            FooterText.Text = "Click Restore to begin rollback. No files have been changed yet.";
            FinishButton.Content = "Restore";
            FinishButton.Visibility = Visibility.Visible;

            _awaitingRestoreConfirmation = true;
            _timer.Stop();
        }

        private async System.Threading.Tasks.Task RunRealUninstallAsync()
        {
            string legacyDir = Path.Combine(_targetPath, "_LegacyInstaller");
            string uninstaller = Path.Combine(legacyDir, "unins000.exe");

            SetManualState(
                5,
                "Preparing rollback...",
                "Preparing the restore operation and checking rollback files.",
                "Checking rollback system...",
                "Rollback system ready"
            );

            await System.Threading.Tasks.Task.Delay(500);

            if (!ValidateUninstallBackend(out int manifestLines))
                return;

            try
            {
                if (!string.IsNullOrWhiteSpace(_statePath) && File.Exists(_statePath))
                    File.Delete(_statePath);
            }
            catch
            {
                // Stale state cleanup is optional.
            }

            SetManualState(
                12,
                "Starting rollback...",
                $"Rollback system ready. {manifestLines} tracked entries will be restored or removed.",
                "Starting restore operation...",
                "Restoring original game files"
            );

            await System.Threading.Tasks.Task.Delay(500);

            Process? process = null;

            try
            {
                var psi = new ProcessStartInfo
                {
                    FileName = "cmd.exe",
                    Arguments = "/C start \"\" /WAIT \"" + uninstaller + "\" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART",
                    UseShellExecute = false,
                    CreateNoWindow = true,
                    WorkingDirectory = legacyDir,
                    WindowStyle = ProcessWindowStyle.Hidden
                };

                process = Process.Start(psi);
            }
            catch (Exception ex)
            {
                SetManualError("Failed to start restore backend: " + ex.Message);
                return;
            }

            if (process == null)
            {
                SetManualError("Failed to start restore backend.");
                return;
            }

            SetManualState(
                18,
                "Removing installed files...",
                "Removing installed modpack files and preparing original file restore.",
                "Removing tracked modpack files...",
                "Restoring original game files"
            );

            while (!process.HasExited)
            {
                UpdateTelemetry();
                await System.Threading.Tasks.Task.Delay(500);
            }

            UpdateTelemetry();

            await System.Threading.Tasks.Task.Delay(500);

            LegacyState? finalState = _stateReader?.Read();

            if (process.ExitCode != 0)
            {
                SetManualError("Restore failed. Inno uninstaller exit code: " + process.ExitCode);
                return;
            }

            if (finalState == null)
            {
                SetManualError("Restore backend exited, but no rollback state file was written.");
                return;
            }

            if (!finalState.IsComplete)
            {
                SetManualError("Restore backend exited, but rollback was not reported complete.");
                return;
            }

            SetManualState(
                100,
                "Rollback complete",
                "The original game state has been restored successfully.",
                "Complete: rollback finalized",
                "Rollback finalized"
            );

            FooterText.Text = "Rollback completed successfully.";
            FinishButton.Content = "Finish";
            FinishButton.Visibility = Visibility.Visible;
            _timer.Stop();
        }

        private async System.Threading.Tasks.Task RunSimulatedUninstallAsync()
        {
            SetManualState(
                5,
                "Preparing rollback...",
                "Checking rollback metadata and restore backend files.",
                "Scanning _LegacyInstaller folder...",
                "_LegacyInstaller\\"
            );

            await System.Threading.Tasks.Task.Delay(700);

            if (!ValidateUninstallBackend(out int manifestLines))
                return;

            SetManualState(
                15,
                "Rollback simulation started",
                $"Restore backend detected. Manifest contains {manifestLines} tracked entries. No files will be changed.",
                "Reading _LegacyInstaller\\install_manifest.txt",
                "_LegacyInstaller\\install_manifest.txt"
            );

            await System.Threading.Tasks.Task.Delay(900);

            SetManualState(
                30,
                "Removing installed files...",
                "Simulating removal of files tracked by the installation manifest.",
                "Simulating tracked modpack file removal...",
                "_LegacyInstaller\\install_manifest.txt"
            );

            await System.Threading.Tasks.Task.Delay(1100);

            SetManualState(
                55,
                "Restoring original game files...",
                "Simulating restore of backed up vanilla patched files.",
                "Simulating Backup\\ original game file restore...",
                "Backup\\"
            );

            await System.Threading.Tasks.Task.Delay(1100);

            SetManualState(
                78,
                "Cleaning leftover directories...",
                "Simulating cleanup of empty folders and temporary rollback leftovers.",
                "Simulating empty directory cleanup...",
                "Game folder cleanup"
            );

            await System.Threading.Tasks.Task.Delay(1000);

            SetManualState(
                92,
                "Finalizing rollback...",
                "Simulating final rollback verification and completion state.",
                "Simulating rollback state finalization...",
                "_LegacyInstaller\\legacyui_state.ini"
            );

            await System.Threading.Tasks.Task.Delay(900);

            SetManualState(
                100,
                "Rollback simulation complete",
                "Simulated rollback completed successfully. No files were changed.",
                "Complete: simulated rollback restoration finalized",
                "_LegacyInstaller\\install_manifest.txt"
            );

            FooterText.Text = "Rollback simulation completed. No files were changed.";
            FinishButton.Content = "Close";
            FinishButton.Visibility = Visibility.Visible;
            _timer.Stop();
        }

        private void SetManualState(double progress, string stage, string detail, string activity, string currentFile)
        {
            progress = Math.Clamp(progress, 0, 100);

            ScanResult result = _scanner.Scan();

            StageText.Text = stage;
            DetailText.Text = detail;
            ActivityText.Text = activity;
            CurrentFileText.Text = currentFile;

            ProgressFill.Width = 470 * (progress / 100.0);
            PercentText.Text = $"{progress:0}%";
            ElapsedText.Text = $"Elapsed: {result.ElapsedSeconds:0.0}s";
            SizeText.Text = $"Folder size: {FormatBytes(result.FolderSizeBytes)}";
            FileCountText.Text = $"Files: {result.FileCount}";
            ManifestText.Text = $"Manifest lines: {result.ManifestLines}";
        }

        private void SetManualError(string message)
        {
            SetManualState(
                100,
                "Rollback failed",
                message,
                "Error: rollback backend failed",
                "Check _LegacyInstaller"
            );

            FooterText.Text = "Rollback failed.";
            FinishButton.Content = "Close";
            FinishButton.Visibility = Visibility.Visible;
            _timer.Stop();
        }

        private void UpdateTelemetry()
        {
            if (_mode == "uninstall" && !_uninstallPrepared)
                return;

            ScanResult result = _scanner.Scan();
            LegacyState? state = _stateReader?.Read();

            double scannerProgress = result.ProgressPercent;
            double stateProgress = state?.Progress ?? -1;

            double progress = stateProgress >= 0
                ? stateProgress
                : scannerProgress;

            progress = Math.Clamp(progress, 0, 100);

            if (state != null && state.IsComplete)
            {
                progress = 100;

                StageText.Text = _mode == "uninstall"
                    ? "Rollback complete"
                    : "Installation complete";

                DetailText.Text = _mode == "uninstall"
                    ? "The original game state has been restored successfully."
                    : "The installer engine has finished successfully.";

                ActivityText.Text = _mode == "uninstall"
                    ? "Complete: rollback restoration finalized"
                    : "Complete: rollback-safe installation finalized";

                CurrentFileText.Text = _mode == "uninstall"
                    ? "Rollback finalized"
                    : "_LegacyInstaller\\install_manifest.txt";

                ProgressFill.Width = 470;
                PercentText.Text = "100%";
                ElapsedText.Text = $"Elapsed: {result.ElapsedSeconds:0.0}s";
                SizeText.Text = $"Folder size: {FormatBytes(result.FolderSizeBytes)}";
                FileCountText.Text = $"Files: {result.FileCount}";
                ManifestText.Text = $"Manifest lines: {result.ManifestLines}";

                FooterText.Text = _mode == "uninstall"
                    ? "Rollback completed successfully."
                    : "Installation completed successfully.";

                FinishButton.Content = "Finish";
                FinishButton.Visibility = Visibility.Visible;

                _timer.Stop();
                return;
            }

            if (state != null && state.IsError)
            {
                progress = 100;

                StageText.Text = _mode == "uninstall"
                    ? "Rollback failed"
                    : "Installation failed";

                DetailText.Text = string.IsNullOrWhiteSpace(state.Message)
                    ? "The installer reported an error."
                    : state.Message;

                ActivityText.Text = "Error: install engine stopped";
                CurrentFileText.Text = "Check installer error report";

                ProgressFill.Width = 470;
                PercentText.Text = "100%";
                ElapsedText.Text = $"Elapsed: {result.ElapsedSeconds:0.0}s";
                SizeText.Text = $"Folder size: {FormatBytes(result.FolderSizeBytes)}";
                FileCountText.Text = $"Files: {result.FileCount}";
                ManifestText.Text = $"Manifest lines: {result.ManifestLines}";

                FooterText.Text = "The installer reported an error.";
                FinishButton.Content = "Close";
                FinishButton.Visibility = Visibility.Visible;

                _timer.Stop();
                return;
            }

            StageText.Text = GetStageText(progress);

            if (state != null && !string.IsNullOrWhiteSpace(state.Message))
                DetailText.Text = state.Message;
            else
                DetailText.Text = GetDetailText(progress);

            ActivityText.Text = GetActivityText(progress);
            CurrentFileText.Text = GetCurrentFileText(progress);

            double maxWidth = 470;
            ProgressFill.Width = maxWidth * (progress / 100.0);

            PercentText.Text = $"{progress:0}%";
            ElapsedText.Text = $"Elapsed: {result.ElapsedSeconds:0.0}s";
            SizeText.Text = $"Folder size: {FormatBytes(result.FolderSizeBytes)}";
            FileCountText.Text = $"Files: {result.FileCount}";
            ManifestText.Text = $"Manifest lines: {result.ManifestLines}";
        }

        private string GetStageText(double progress)
        {
            if (_mode == "uninstall")
            {
                if (progress < 20) return "Preparing rollback...";
                if (progress < 45) return "Removing installed files...";
                if (progress < 75) return "Restoring original game files...";
                if (progress < 95) return "Cleaning leftover directories...";
                return "Finalizing rollback...";
            }

            if (progress < 10) return "Preparing installation...";
            if (progress < 25) return "Validating game directory...";
            if (progress < 45) return "Installing vehicle assets...";
            if (progress < 65) return "Installing frontend and global data...";
            if (progress < 85) return "Writing rollback manifest...";
            if (progress < 95) return "Finalizing installation...";
            return "Waiting for installer completion...";
        }

        private string GetDetailText(double progress)
        {
            if (_mode == "uninstall")
            {
                if (progress < 20) return "Preparing restore operation and reading rollback metadata.";
                if (progress < 45) return "Removing files tracked by the installation manifest.";
                if (progress < 75) return "Restoring backed up original game files.";
                if (progress < 95) return "Removing empty folders and temporary installer data.";
                return "Rollback is almost complete.";
            }

            if (progress < 10) return "Preparing installer environment and scanning target directory.";
            if (progress < 25) return "Checking game structure, executable state, and required folders.";
            if (progress < 45) return "Adding vehicle geometry, texture, and vinyl resources.";
            if (progress < 65) return "Adding frontend resources, global data, and gameplay files.";
            if (progress < 85) return "Recording installed files for rollback-safe uninstall.";
            if (progress < 95) return "Cleaning temporary data and preparing final installer state.";
            return "Install engine is finishing background operations.";
        }

        private string GetActivityText(double progress)
        {
            if (_mode == "uninstall")
            {
                if (progress < 20) return "Reading _LegacyInstaller\\install_manifest.txt";
                if (progress < 45) return "Removing tracked modpack files...";
                if (progress < 75) return "Restoring Backup\\ original game files...";
                if (progress < 95) return "Removing empty leftover directories...";
                return "Finalizing rollback state...";
            }

            if (progress < 10) return "Preparing temporary extraction workspace...";
            if (progress < 25) return "Checking executable and required game folders...";
            if (progress < 40) return "Installing CARS\\ geometry and texture assets...";
            if (progress < 55) return "Installing FRONTEND\\ interface resources...";
            if (progress < 70) return "Installing GLOBAL\\ gameplay data...";
            if (progress < 85) return "Writing _LegacyInstaller\\install_manifest.txt";
            if (progress < 95) return "Cleaning temporary installer files...";
            return "Waiting for installer engine to finish...";
        }

        private string GetCurrentFileText(double progress)
        {
            string prefix = _mode == "uninstall" ? "Restoring:" : "Installing:";
            string[] files;

            if (_mode == "uninstall")
            {
                files = new[]
                {
                    @"_LegacyInstaller\install_manifest.txt",
                    @"Backup\GLOBAL\GlobalB.lzc",
                    @"Backup\GLOBAL\InGameB.lzc",
                    @"Backup\FRONTEND\FrontB.lzc",
                    @"Backup\LANGUAGES\LANGUAGE_ENGLISH.bin",
                    @"Backup\CARS\vehicle assets",
                    @"Backup\TRACKS\track resources",
                    @"Cleaning empty directories",
                    @"Finalizing rollback state"
                };
            }
            else if (progress < 10)
            {
                prefix = "Preparing:";
                files = new[]
                {
                    @"temporary extraction workspace",
                    @"installer runtime files",
                    @"destination directory scan",
                    @"rollback environment",
                    @"game profile telemetry"
                };
            }
            else if (progress < 25)
            {
                prefix = "Validating:";
                files = new[]
                {
                    @"game executable",
                    @"required folder structure",
                    @"Large Address Aware state",
                    @"patched game files",
                    @"installation directory"
                };
            }
            else if (progress < 40)
            {
                files = new[]
                {
                    @"CARS\240SX\GEOMETRY.BIN",
                    @"CARS\240SX\TEXTURES.BIN",
                    @"CARS\350Z\GEOMETRY.BIN",
                    @"CARS\350Z\TEXTURES.BIN",
                    @"CARS\RX7\GEOMETRY.BIN",
                    @"CARS\RX7\TEXTURES.BIN",
                    @"CARS\SKYLINE\GEOMETRY.BIN",
                    @"CARS\SKYLINE\TEXTURES.BIN",
                    @"CARS\SUPRA\GEOMETRY.BIN",
                    @"CARS\SUPRA\TEXTURES.BIN"
                };
            }
            else if (progress < 55)
            {
                files = new[]
                {
                    @"FRONTEND\FrontB.lzc",
                    @"FRONTEND\FrontEndTextures.bin",
                    @"FRONTEND\HUD resources",
                    @"FRONTEND\menu assets",
                    @"FRONTEND\interface packages",
                    @"FRONTEND\loading screen data"
                };
            }
            else if (progress < 70)
            {
                files = new[]
                {
                    @"GLOBAL\GlobalB.lzc",
                    @"GLOBAL\InGameB.lzc",
                    @"GLOBAL\GLOBALB.BUN",
                    @"GLOBAL\Attributes.bin",
                    @"GLOBAL\gameplay.bin",
                    @"GLOBAL\visual treatment data",
                    @"GLOBAL\shared texture packages"
                };
            }
            else if (progress < 85)
            {
                files = new[]
                {
                    @"LANGUAGES\LANGUAGE_ENGLISH.bin",
                    @"TRACKS\STREAML2RA.BUN",
                    @"TRACKS\TRACKS.BIN",
                    @"SOUND\Speech.big",
                    @"MOVIES\BootFlow.mad",
                    @"MOVIES\frontend sequences",
                    @"TRACKS\world streaming data"
                };
            }
            else if (progress < 95)
            {
                prefix = "Writing:";
                files = new[]
                {
                    @"_LegacyInstaller\install_manifest.txt",
                    @"_LegacyInstaller\rollback metadata",
                    @"_LegacyInstaller\uninstall data",
                    @"Backup\original file map",
                    @"restore validation entries"
                };
            }
            else
            {
                prefix = "Finalizing:";
                files = new[]
                {
                    @"temporary extraction cleanup",
                    @"installer state verification",
                    @"rollback system verification",
                    @"directory cleanup",
                    @"installation completion state"
                };
            }

            _activityIndex++;

            if (_activityIndex >= files.Length)
                _activityIndex = 0;

            return $"{prefix} {files[_activityIndex]}";
        }

        private async void FinishButton_Click(object sender, RoutedEventArgs e)
        {
            string buttonText = FinishButton.Content?.ToString() ?? "";

            if (_mode == "uninstall" &&
                !_rollbackRunning &&
                (buttonText.Equals("Restore", StringComparison.OrdinalIgnoreCase) ||
                 _awaitingRestoreConfirmation))
            {
                _awaitingRestoreConfirmation = false;
                _rollbackRunning = true;

                FinishButton.Visibility = Visibility.Collapsed;
                _timer.Start();

                await RunRealUninstallAsync();
                return;
            }

            try
            {
                if (!string.IsNullOrWhiteSpace(_commandPath))
                {
                    string commandText =
                        "command=exit" + Environment.NewLine +
                        "source=LegacyUI" + Environment.NewLine +
                        "reason=finish_button" + Environment.NewLine;

                    File.WriteAllText(_commandPath, commandText);
                }
            }
            catch
            {
                // If command writing fails, still close the UI.
            }

            Close();
        }

        private static string FormatBytes(long bytes)
        {
            double value = bytes;

            string[] units = { "B", "KB", "MB", "GB", "TB" };
            int unit = 0;

            while (value >= 1024 && unit < units.Length - 1)
            {
                value /= 1024;
                unit++;
            }

            return $"{value:0.00} {units[unit]}";
        }
    }
}