using System;
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
        private readonly LegacyStateReader? _stateReader;
        private int _activityIndex = 0;
        private readonly string _commandPath;

        public MainWindow()
        {
            InitializeComponent();

            var parser = new ArgumentParser(Environment.GetCommandLineArgs());

            string target = parser.Get("target", Environment.CurrentDirectory);
            string gameId = parser.Get("game", "auto").ToLowerInvariant();
            _mode = parser.Get("mode", "install").ToLowerInvariant();
            string statePath = parser.Get("state", "");
            _commandPath = parser.Get("command", "");

            if (!string.IsNullOrWhiteSpace(statePath))
            {
                _stateReader = new LegacyStateReader(statePath);
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
            ModeText.Text = $"Mode: {_mode}";
            DetailText.Text = $"Monitoring: {target}";

            _timer = new DispatcherTimer
            {
                Interval = TimeSpan.FromMilliseconds(500)
            };

            _timer.Tick += (_, _) => UpdateTelemetry();
            _timer.Start();

            UpdateTelemetry();
        }

        private void UpdateTelemetry()
        {
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

                CurrentFileText.Text = "_LegacyInstaller\\install_manifest.txt";

                ProgressFill.Width = 470;
                PercentText.Text = "100%";
                ElapsedText.Text = $"Elapsed: {result.ElapsedSeconds:0.0}s";
                SizeText.Text = $"Folder size: {FormatBytes(result.FolderSizeBytes)}";
                FileCountText.Text = $"Files: {result.FileCount}";
                ManifestText.Text = $"Manifest lines: {result.ManifestLines}";

                FooterText.Text = _mode == "uninstall"
                    ? "Rollback completed successfully."
                    : "Installation completed successfully.";

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

        private void FinishButton_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                if (!string.IsNullOrWhiteSpace(_commandPath))
                {
                    string commandText =
                        "command=exit" + Environment.NewLine +
                        "source=LegacyUI" + Environment.NewLine +
                        "reason=finish_button" + Environment.NewLine;

                    System.IO.File.WriteAllText(_commandPath, commandText);
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