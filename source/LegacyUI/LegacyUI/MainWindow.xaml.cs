using System;
using System.Diagnostics;
using System.IO;
using System.Windows;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Threading;
using LegacyUI.Models;
using LegacyUI.Services;

namespace LegacyUI
{
    public partial class MainWindow : Window
    {
        private enum InstallFrontendPage
        {
            Welcome,
            ChooseFolder,
            Validation,
            MoviesOption,
            ReadyToInstall,
            Installing
        }

        private sealed class UiTheme
        {
            public string Accent { get; }
            public string AccentSoft { get; }
            public string Background { get; }
            public string Panel { get; }
            public string PanelAlt { get; }
            public string Border { get; }

            public UiTheme(string accent, string accentSoft, string background, string panel, string panelAlt, string border)
            {
                Accent = accent;
                AccentSoft = accentSoft;
                Background = background;
                Panel = panel;
                PanelAlt = panelAlt;
                Border = border;
            }
        }

        private readonly GameProfile _profile;
        private readonly InstallScanner _scanner;
        private readonly DispatcherTimer _timer;
        private readonly OptionalFeatureService _optionalFeatures;
        private readonly string _mode;
        private readonly string _targetPath;
        private readonly string _gameId;
        private LegacyStateReader? _stateReader;
        private int _activityIndex = 0;
        private readonly string _commandPath;
        private readonly string _statePath;
        private readonly bool _simulateMode;
        private bool _uninstallPrepared = false;
        private bool _awaitingRestoreConfirmation = false;
        private bool _rollbackRunning = false;

        private InstallFrontendPage _installPage = InstallFrontendPage.Welcome;
        private bool _installCommandSent = false;
        private bool _allowUnsafeInstall = false;
        private string _selectedInstallPath = "";

        public MainWindow()
        {
            InitializeComponent();

            var parser = new ArgumentParser(Environment.GetCommandLineArgs());

            string target = parser.Get("target", Environment.CurrentDirectory);
            _targetPath = target;
            _selectedInstallPath = target;

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
                parsedStatePath = Path.Combine(_targetPath, "_LegacyInstaller", "legacyui_state.ini");

            _statePath = parsedStatePath;

            if (!string.IsNullOrWhiteSpace(_statePath))
                _stateReader = new LegacyStateReader(_statePath);

            if (gameId == "auto" || string.IsNullOrWhiteSpace(gameId))
                gameId = GameDetector.Detect(target);

            if (!GameProfiles.Profiles.TryGetValue(gameId, out _profile!))
            {
                _profile = GameProfiles.Profiles["nfsu"];
                gameId = "nfsu";
            }

            _gameId = gameId;
            _optionalFeatures = new OptionalFeatureService(_gameId);

            ApplyGameTheme(_gameId);

            _scanner = new InstallScanner(_profile, target, _mode);

            Title = _profile.Title;
            TitleText.Text = _profile.Title;
            SubtitleText.Text = $"{_gameId.ToUpperInvariant()} / {_mode.ToUpperInvariant()}";
            ModeText.Text = _simulateMode ? $"Mode: {_mode} / SIMULATION" : $"Mode: {_mode}";
            DetailText.Text = $"Monitoring: {target}";

            if (SelectedPathTextBox != null)
                SelectedPathTextBox.Text = _selectedInstallPath;

            if (MoviesPatchPanel != null)
                MoviesPatchPanel.Visibility = Visibility.Collapsed;

            if (MoviesPatchCheckBox != null)
                MoviesPatchCheckBox.IsChecked = _optionalFeatures.HasMoviesPatchOption();

            _timer = new DispatcherTimer
            {
                Interval = TimeSpan.FromMilliseconds(500)
            };

            _timer.Tick += (_, _) => UpdateTelemetry();
            _timer.Start();

            Closing += MainWindow_Closing;

            Loaded += async (_, _) =>
            {
                if (_mode == "uninstall" && !_uninstallPrepared)
                {
                    _uninstallPrepared = true;

                    if (_simulateMode)
                        await RunSimulatedUninstallAsync();
                    else
                        PrepareRestoreConfirmation();
                }
            };

            if (_mode == "install")
            {
                _timer.Stop();
                ShowWelcomePage();
            }
            else
            {
                SetManualState(
                    0,
                    "Preparing rollback...",
                    _simulateMode ? "Waiting for simulated rollback sequence." : "Waiting for restore confirmation.",
                    "Preparing LegacyUI restore screen...",
                    "_LegacyInstaller\\"
                );
            }
        }

        private void ApplyGameIcon(string gameId)
        {
            try
            {
                string iconFile = gameId switch
                {
                    "nfsu" => "NFSU.ico",
                    "nfsu2" => "NFSU2.ico",
                    "nfsmw" => "NFSMW.ico",
                    "nfsc" => "NFSC.ico",
                    "nfsps" => "NFSPS.ico",
                    "nfsuc" => "NFSUC.ico",
                    _ => "NFSU.ico"
                };

                Icon = BitmapFrame.Create(new Uri($"pack://application:,,,/Assets/Icons/{iconFile}", UriKind.Absolute));
            }
            catch
            {
                Icon = null;
            }
        }

        private void ApplyGameTheme(string gameId)
        {
            UiTheme theme = gameId switch
            {
                "nfsu" => new UiTheme("#3FA7FF", "#7FCBFF", "#07111F", "#101A28", "#08121D", "#2E5F8F"),
                "nfsu2" => new UiTheme("#39FF88", "#8DFFB8", "#07150D", "#101F16", "#08150D", "#2E8F55"),
                "nfsmw" => new UiTheme("#B9894A", "#E0B46D", "#15100A", "#21180F", "#140F09", "#8F6A35"),
                "nfsc" => new UiTheme("#4FA7FF", "#8ECCFF", "#07101A", "#101A25", "#08111B", "#2E6F9F"),
                "nfsps" => new UiTheme("#7CFF4F", "#B0FF8E", "#0B1408", "#162110", "#0D1508", "#4F8F2E"),
                "nfsuc" => new UiTheme("#FF9A32", "#FFC06F", "#160D06", "#24170D", "#140C06", "#9F632E"),
                _ => new UiTheme("#3FA7FF", "#7FCBFF", "#101014", "#181820", "#111118", "#2E2E3A")
            };

            RootGrid.Background = BrushFromHex(theme.Background);

            ApplyGameBackground(gameId);
            ApplyGameIcon(gameId);

            MainPanel.Background = BrushFromHexWithOpacity(theme.Panel, 0.55);
            MainPanel.BorderBrush = BrushFromHex(theme.Border);

            TelemetryPanel.Background = BrushFromHexWithOpacity(theme.PanelAlt, 0.50);
            TelemetryPanel.BorderBrush = BrushFromHex(theme.Border);

            ProgressTrack.Background = BrushFromHex(theme.PanelAlt);
            ProgressFill.Background = BrushFromHex(theme.Accent);

            ActivityText.Foreground = BrushFromHex(theme.AccentSoft);
            TelemetryTitle.Foreground = BrushFromHex(theme.AccentSoft);
            GameFolderLabel.Foreground = BrushFromHex(theme.AccentSoft);

            SelectedPathTextBox.BorderBrush = BrushFromHex(theme.Border);

            BrowseButton.BorderBrush = BrushFromHex(theme.Border);
            BackButton.BorderBrush = BrushFromHex(theme.Border);
            FinishButton.BorderBrush = BrushFromHex(theme.Border);

            if (MoviesPatchPanel != null)
                MoviesPatchPanel.BorderBrush = BrushFromHex(theme.Border);
        }

        private static SolidColorBrush BrushFromHexWithOpacity(string hex, double opacity)
        {
            Color color = (Color)ColorConverter.ConvertFromString(hex);
            color.A = (byte)Math.Clamp(opacity * 255, 0, 255);
            return new SolidColorBrush(color);
        }

        private void ApplyGameBackground(string gameId)
        {
            string backgroundFile = gameId switch
            {
                "nfsu" => "NFSU.png",
                "nfsu2" => "NFSU2.png",
                "nfsmw" => "NFSMW.png",
                "nfsc" => "NFSC.png",
                "nfsps" => "NFSPS.png",
                "nfsuc" => "NFSUC.png",
                _ => "NFSU.png"
            };

            try
            {
                var uri = new Uri($"pack://application:,,,/Assets/Backgrounds/{backgroundFile}", UriKind.Absolute);

                var bitmap = new BitmapImage();
                bitmap.BeginInit();
                bitmap.UriSource = uri;
                bitmap.CacheOption = BitmapCacheOption.OnLoad;
                bitmap.EndInit();
                bitmap.Freeze();

                BackgroundImage.Source = bitmap;
            }
            catch
            {
                BackgroundImage.Source = null;
            }
        }

        private static SolidColorBrush BrushFromHex(string hex)
        {
            return new SolidColorBrush((Color)ColorConverter.ConvertFromString(hex));
        }

        private void MainWindow_Closing(object? sender, System.ComponentModel.CancelEventArgs e)
        {
            if (_mode == "install" && !_installCommandSent)
            {
                WriteCommandFile("exit", "window_close_before_install");
                return;
            }

            if (_mode == "install" && _installCommandSent)
            {
                WriteCommandFile("exit", "window_close_during_install");
                return;
            }

            if (_mode == "uninstall" && !_rollbackRunning)
            {
                WriteCommandFile("exit", "window_close_before_restore");
                return;
            }

            if (_mode == "uninstall" && _rollbackRunning)
            {
                WriteCommandFile("exit", "window_close_during_restore");
                return;
            }
        }

        private void WriteCommandFile(string command, string reason)
        {
            try
            {
                if (!string.IsNullOrWhiteSpace(_commandPath))
                {
                    string commandText =
                        "command=" + command + Environment.NewLine +
                        "source=LegacyUI" + Environment.NewLine +
                        "reason=" + reason + Environment.NewLine;

                    File.WriteAllText(_commandPath, commandText);
                }
            }
            catch
            {
            }
        }

        private void HideInstallPanels()
        {
            PathPanel.Visibility = Visibility.Collapsed;

            if (MoviesPatchPanel != null)
                MoviesPatchPanel.Visibility = Visibility.Collapsed;
        }

        private void ShowWelcomePage()
        {
            _installPage = InstallFrontendPage.Welcome;

            HideInstallPanels();

            BackButton.Visibility = Visibility.Collapsed;
            FinishButton.Visibility = Visibility.Visible;
            FinishButton.Content = "Next";

            ProgressFill.Width = 0;
            PercentText.Text = "0%";

            StageText.Text = "Welcome";
            DetailText.Text =
                $"This wizard will install the {_profile.Title} using a rollback-safe backend. Your original files will be preserved for restore.";
            ActivityText.Text = "Ready to configure installation...";
            CurrentFileText.Text = "No files have been changed yet.";

            FooterText.Text = $"Click Next to choose your {_profile.Title} game folder.";

            ElapsedText.Text = "Elapsed: 0.0s";
            SizeText.Text = "Folder size: waiting";
            FileCountText.Text = "Files: waiting";
            ManifestText.Text = "Install stage: welcome";
        }

        private void ShowChooseFolderPage()
        {
            _installPage = InstallFrontendPage.ChooseFolder;

            HideInstallPanels();

            PathPanel.Visibility = Visibility.Visible;
            BackButton.Visibility = Visibility.Visible;
            FinishButton.Visibility = Visibility.Visible;
            FinishButton.Content = "Next";

            if (string.IsNullOrWhiteSpace(SelectedPathTextBox.Text))
                SelectedPathTextBox.Text = _selectedInstallPath;

            ProgressFill.Width = 470 * 0.20;
            PercentText.Text = "20%";

            StageText.Text = "Choose game folder";
            DetailText.Text = $"Select the folder that contains your patched {_profile.Title} installation.";

            ActivityText.Text = "Waiting for selected game directory...";
            CurrentFileText.Text = GetExpectedExecutableHint();

            FooterText.Text = "Choose the game folder, then click Next.";

            SizeText.Text = Directory.Exists(SelectedPathTextBox.Text)
                ? $"Folder size: {FormatBytes(GetSafeDirectorySize(SelectedPathTextBox.Text))}"
                : "Folder size: unavailable";

            FileCountText.Text = Directory.Exists(SelectedPathTextBox.Text)
                ? $"Files: {GetSafeFileCount(SelectedPathTextBox.Text)}"
                : "Files: unavailable";

            ManifestText.Text = "Install stage: folder selection";
        }

        private void ShowValidationPage()
        {
            _installPage = InstallFrontendPage.Validation;

            _selectedInstallPath = SelectedPathTextBox.Text.Trim();

            HideInstallPanels();

            PathPanel.Visibility = Visibility.Visible;
            BackButton.Visibility = Visibility.Visible;
            FinishButton.Visibility = Visibility.Visible;

            bool valid = IsSelectedInstallReady(_selectedInstallPath);

            ProgressFill.Width = 470 * 0.45;
            PercentText.Text = "45%";

            if (valid)
            {
                _allowUnsafeInstall = false;

                StageText.Text = "Game folder validated";
                DetailText.Text = $"The selected folder matches the expected patched {_profile.Title} installation state.";
                ActivityText.Text = "Validation passed.";
                CurrentFileText.Text = "Executable and required game data verified";
                FooterText.Text = _optionalFeatures.HasMoviesPatchOption()
                    ? "Click Next to choose the optional Undercover MOVIES patch."
                    : "Click Next to review the installation.";
                FinishButton.Content = "Next";
                ManifestText.Text = "Validation: passed";
            }
            else
            {
                _allowUnsafeInstall = true;

                StageText.Text = "Validation warning";
                DetailText.Text =
                    $"The selected folder does not fully match the expected patched {_profile.Title} state. Installing anyway may break your game, cause crashes, missing textures, or failed startup.";
                ActivityText.Text = "Validation failed. User confirmation required.";
                CurrentFileText.Text = "Expected patched game files were not fully matched";
                FooterText.Text = _optionalFeatures.HasMoviesPatchOption()
                    ? "Click Continue to choose the optional MOVIES patch, or Back to choose another folder."
                    : "Click Continue to install anyway, or Back to choose another folder.";
                FinishButton.Content = "Continue";
                ManifestText.Text = "Validation: warning";
            }

            SizeText.Text = Directory.Exists(_selectedInstallPath)
                ? $"Folder size: {FormatBytes(GetSafeDirectorySize(_selectedInstallPath))}"
                : "Folder size: unavailable";

            FileCountText.Text = Directory.Exists(_selectedInstallPath)
                ? $"Files: {GetSafeFileCount(_selectedInstallPath)}"
                : "Files: unavailable";
        }

        private void ShowMoviesOptionPage()
        {
            _installPage = InstallFrontendPage.MoviesOption;

            HideInstallPanels();

            MoviesPatchPanel.Visibility = Visibility.Visible;
            BackButton.Visibility = Visibility.Visible;
            FinishButton.Visibility = Visibility.Visible;
            FinishButton.Content = "Next";

            ProgressFill.Width = 470 * 0.52;
            PercentText.Text = "52%";

            StageText.Text = "Optional MOVIES patch";
            DetailText.Text = "Choose whether Undercover should install the optional Filter-Off MOVIES package.";

            ActivityText.Text = (MoviesPatchCheckBox.IsChecked ?? false)
                ? "Filter-Off MOVIES package selected."
                : "Filter-Off MOVIES package will be skipped.";

            CurrentFileText.Text = (MoviesPatchCheckBox.IsChecked ?? false)
                ? "Pending command: movies=filteroff"
                : "Pending command: movies=none";

            FooterText.Text = "Choose your MOVIES option, then click Next.";

            ManifestText.Text = (MoviesPatchCheckBox.IsChecked ?? false)
                ? "NFSUC option: Filter-Off MOVIES enabled"
                : "NFSUC option: vanilla MOVIES kept";
        }

        private void ShowReadyToInstallPage()
        {
            _installPage = InstallFrontendPage.ReadyToInstall;

            HideInstallPanels();

            BackButton.Visibility = Visibility.Visible;
            FinishButton.Visibility = Visibility.Visible;
            FinishButton.Content = "Install";

            ProgressFill.Width = 470 * 0.60;
            PercentText.Text = "60%";

            bool installFilterOffMovies =
                _optionalFeatures.HasMoviesPatchOption() &&
                (MoviesPatchCheckBox.IsChecked ?? false);

            StageText.Text = "Ready to install";
            DetailText.Text = installFilterOffMovies
                ? "LegacyUI is ready to start the hidden Inno backend. The installer will extract, copy files, write rollback metadata, and install the optional Undercover Filter-Off MOVIES patch."
                : "LegacyUI is ready to start the hidden Inno backend. The installer will extract, copy files, and write rollback metadata.";

            ActivityText.Text = _allowUnsafeInstall
                ? "Ready to install with validation warning accepted."
                : "Ready to install with validated game folder.";

            if (_optionalFeatures.HasMoviesPatchOption())
            {
                CurrentFileText.Text = installFilterOffMovies
                    ? "Waiting for Install command with movies=filteroff"
                    : "Waiting for Install command with movies=none";

                ManifestText.Text = installFilterOffMovies
                    ? "Install stage: ready / Filter-Off MOVIES selected"
                    : "Install stage: ready / vanilla MOVIES kept";
            }
            else
            {
                CurrentFileText.Text = "Waiting for Install command...";
                ManifestText.Text = "Install stage: ready";
            }

            FooterText.Text = "Click Install to begin. Do not close this window during installation.";
        }

        private void StartInstallBackend()
        {
            _installCommandSent = true;
            _installPage = InstallFrontendPage.Installing;

            _selectedInstallPath = SelectedPathTextBox.Text.Trim();

            try
            {
                if (!string.IsNullOrWhiteSpace(_commandPath))
                {
                    string moviesValue = _optionalFeatures.GetMoviesCommandValue(
                        MoviesPatchCheckBox.IsChecked ?? false
                    );

                    string commandText =
                        "command=install" + Environment.NewLine +
                        "target=" + _selectedInstallPath + Environment.NewLine +
                        "source=LegacyUI" + Environment.NewLine +
                        "validation=" + (_allowUnsafeInstall ? "warning_accepted" : "passed") + Environment.NewLine +
                        "movies=" + moviesValue + Environment.NewLine;

                    string? commandDir = Path.GetDirectoryName(_commandPath);

                    if (!string.IsNullOrWhiteSpace(commandDir))
                        Directory.CreateDirectory(commandDir);

                    if (File.Exists(_commandPath))
                        File.Delete(_commandPath);

                    File.WriteAllText(_commandPath, commandText);

                    if (!File.Exists(_commandPath) || new FileInfo(_commandPath).Length == 0)
                    {
                        SetManualError("Install command file was not written correctly.");
                        return;
                    }
                }
            }
            catch (Exception ex)
            {
                SetManualError("Failed to write install command: " + ex.Message);
                return;
            }

            HideInstallPanels();

            BackButton.Visibility = Visibility.Collapsed;
            FinishButton.Visibility = Visibility.Collapsed;

            CancelButton.Content = "Cancel";
            CancelButton.IsEnabled = true;
            CancelButton.Visibility = Visibility.Visible;

            SetManualState(
                5,
                "Starting installation...",
                "Install command sent. Waiting for backend installer activity.",
                "Starting hidden Inno backend...",
                "Installer backend"
            );

            FooterText.Text = "Installer engine is running in the background. Do not close this window.";

            _timer.Start();
            UpdateTelemetry();
        }

        private string GetExpectedExecutableHint()
        {
            return _gameId switch
            {
                "nfsu" => "Select folder containing Speed.exe",
                "nfsu2" => "Select folder containing SPEED2.EXE",
                "nfsmw" => "Select folder containing speed.exe",
                "nfsc" => "Select folder containing NFSC.exe",
                "nfsps" => "Select folder containing nfs.exe",
                "nfsuc" => "Select folder containing nfs.exe",
                _ => "Select folder containing the game executable"
            };
        }

        private bool IsSelectedInstallReady(string baseDir)
        {
            if (string.IsNullOrWhiteSpace(baseDir))
                return false;

            if (!Directory.Exists(baseDir))
                return false;

            if (_gameId != "nfsu")
            {
                string detected = GameDetector.Detect(baseDir);
                return !string.IsNullOrWhiteSpace(detected) && detected != "auto";
            }

            string exePath = Path.Combine(baseDir, "Speed.exe");

            if (!File.Exists(exePath)) return false;
            if (!FileSizeMatchesLocal(exePath, 3178496)) return false;

            if (!FileSizeMatchesLocal(Path.Combine(baseDir, "FrontEnd", "FrontB.lzc"), 4182578)) return false;
            if (!FileSizeMatchesLocal(Path.Combine(baseDir, "Global", "GlobalB.lzc"), 972201)) return false;
            if (!FileSizeMatchesLocal(Path.Combine(baseDir, "Global", "InGameB.lzc"), 468419)) return false;
            if (!FileSizeMatchesLocal(Path.Combine(baseDir, "Languages", "LANGUAGE_ENGLISH.bin"), 159280)) return false;

            if (!Directory.Exists(Path.Combine(baseDir, "Cars"))) return false;
            if (!Directory.Exists(Path.Combine(baseDir, "FrontEnd"))) return false;
            if (!Directory.Exists(Path.Combine(baseDir, "Global"))) return false;
            if (!Directory.Exists(Path.Combine(baseDir, "Languages"))) return false;
            if (!Directory.Exists(Path.Combine(baseDir, "Tracks"))) return false;

            return true;
        }

        private static bool FileSizeMatchesLocal(string filePath, long expectedSize)
        {
            try
            {
                return File.Exists(filePath) && new FileInfo(filePath).Length == expectedSize;
            }
            catch
            {
                return false;
            }
        }

        private static long GetSafeDirectorySize(string dir)
        {
            try
            {
                long total = 0;

                foreach (string file in Directory.EnumerateFiles(dir, "*", SearchOption.AllDirectories))
                {
                    try
                    {
                        total += new FileInfo(file).Length;
                    }
                    catch
                    {
                    }
                }

                return total;
            }
            catch
            {
                return 0;
            }
        }

        private static int GetSafeFileCount(string dir)
        {
            try
            {
                int count = 0;

                foreach (string _ in Directory.EnumerateFiles(dir, "*", SearchOption.AllDirectories))
                    count++;

                return count;
            }
            catch
            {
                return 0;
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

            SetManualState(5, "Preparing rollback...", "Preparing the restore operation and checking rollback files.", "Checking rollback system...", "Rollback system ready");

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
            }

            SetManualState(12, "Starting rollback...", $"Rollback system ready. {manifestLines} tracked entries will be restored or removed.", "Starting restore operation...", "Restoring original game files");

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

            SetManualState(18, "Removing installed files...", "Removing installed modpack files and preparing original file restore.", "Removing tracked modpack files...", "Restoring original game files");

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
                SetManualState(
                    100,
                    "Rollback complete",
                    "The restore backend exited successfully. Original game files were restored.",
                    "Complete: rollback finalized",
                    "Rollback finalized"
                );

                FooterText.Text = "Rollback completed successfully.";
                FinishButton.Content = "Finish";
                FinishButton.Visibility = Visibility.Visible;
                _timer.Stop();
                return;
            }

            if (!finalState.IsComplete)
            {
                SetManualState(
                    100,
                    "Rollback complete",
                    "The restore backend exited successfully. Original game files were restored.",
                    "Complete: rollback finalized",
                    "Rollback finalized"
                );

                FooterText.Text = "Rollback completed successfully.";
                FinishButton.Content = "Finish";
                FinishButton.Visibility = Visibility.Visible;
                _timer.Stop();
                return;
            }

            SetManualState(100, "Rollback complete", "The original game state has been restored successfully.", "Complete: rollback finalized", "Rollback finalized");

            FooterText.Text = "Rollback completed successfully.";
            FinishButton.Content = "Finish";
            FinishButton.Visibility = Visibility.Visible;
            _timer.Stop();
        }

        private async System.Threading.Tasks.Task RunSimulatedUninstallAsync()
        {
            SetManualState(5, "Preparing rollback...", "Checking rollback metadata and restore backend files.", "Scanning _LegacyInstaller folder...", "_LegacyInstaller\\");
            await System.Threading.Tasks.Task.Delay(700);

            if (!ValidateUninstallBackend(out int manifestLines))
                return;

            SetManualState(15, "Rollback simulation started", $"Restore backend detected. Manifest contains {manifestLines} tracked entries. No files will be changed.", "Reading _LegacyInstaller\\install_manifest.txt", "_LegacyInstaller\\install_manifest.txt");
            await System.Threading.Tasks.Task.Delay(900);

            SetManualState(30, "Removing installed files...", "Simulating removal of files tracked by the installation manifest.", "Simulating tracked modpack file removal...", "_LegacyInstaller\\install_manifest.txt");
            await System.Threading.Tasks.Task.Delay(1100);

            SetManualState(55, "Restoring original game files...", "Simulating restore of backed up vanilla patched files.", "Simulating Backup\\ original game file restore...", "Backup\\");
            await System.Threading.Tasks.Task.Delay(1100);

            SetManualState(78, "Cleaning leftover directories...", "Simulating cleanup of empty folders and temporary rollback leftovers.", "Simulating empty directory cleanup...", "Game folder cleanup");
            await System.Threading.Tasks.Task.Delay(1000);

            SetManualState(92, "Finalizing rollback...", "Simulating final rollback verification and completion state.", "Simulating rollback state finalization...", "_LegacyInstaller\\legacyui_state.ini");
            await System.Threading.Tasks.Task.Delay(900);

            SetManualState(100, "Rollback simulation complete", "Simulated rollback completed successfully. No files were changed.", "Complete: simulated rollback restoration finalized", "_LegacyInstaller\\install_manifest.txt");

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
            HideInstallPanels();
            BackButton.Visibility = Visibility.Collapsed;

            SetManualState(100, _mode == "uninstall" ? "Rollback failed" : "Installation failed", message, "Error: backend operation failed", "Check installer state");

            FooterText.Text = _mode == "uninstall" ? "Rollback failed." : "Installation failed.";

            FinishButton.Content = "Close";
            FinishButton.Visibility = Visibility.Visible;
            _timer.Stop();
        }

        private void UpdateTelemetry()
        {
            if (_mode == "uninstall" && !_uninstallPrepared)
                return;

            if (_mode == "install" && !_installCommandSent)
                return;

            ScanResult result = _scanner.Scan();
            LegacyState? state = _stateReader?.Read();

            double scannerProgress = result.ProgressPercent;
            double stateProgress = state?.Progress ?? -1;

            double progress = stateProgress >= 0 ? stateProgress : scannerProgress;
            progress = Math.Clamp(progress, 0, 100);

            if (state != null && state.IsComplete)
            {
                progress = 100;

                StageText.Text = _mode == "uninstall" ? "Rollback complete" : "Installation complete";
                DetailText.Text = _mode == "uninstall" ? "The original game state has been restored successfully." : "The installer engine has finished successfully.";
                ActivityText.Text = _mode == "uninstall" ? "Complete: rollback restoration finalized" : "Complete: rollback-safe installation finalized";
                CurrentFileText.Text = _mode == "uninstall" ? "Rollback finalized" : "_LegacyInstaller\\install_manifest.txt";

                ProgressFill.Width = 470;
                PercentText.Text = "100%";
                ElapsedText.Text = $"Elapsed: {result.ElapsedSeconds:0.0}s";
                SizeText.Text = $"Folder size: {FormatBytes(result.FolderSizeBytes)}";
                FileCountText.Text = $"Files: {result.FileCount}";
                ManifestText.Text = $"Manifest lines: {result.ManifestLines}";

                FooterText.Text = _mode == "uninstall" ? "Rollback completed successfully." : "Installation completed successfully.";

                FinishButton.Content = "Finish";
                FinishButton.Visibility = Visibility.Visible;
                BackButton.Visibility = Visibility.Collapsed;
                CancelButton.Visibility = Visibility.Collapsed;
                HideInstallPanels();

                _timer.Stop();
                return;
            }

            if (state != null && state.IsError)
            {
                progress = 100;

                StageText.Text = _mode == "uninstall" ? "Rollback failed" : "Installation failed";
                DetailText.Text = string.IsNullOrWhiteSpace(state.Message) ? "The installer reported an error." : state.Message;
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
                BackButton.Visibility = Visibility.Collapsed;
                CancelButton.Visibility = Visibility.Collapsed;
                HideInstallPanels();

                _timer.Stop();
                return;
            }

            StageText.Text = GetStageText(progress);
            DetailText.Text = state != null && !string.IsNullOrWhiteSpace(state.Message) ? state.Message : GetDetailText(progress);
            ActivityText.Text = GetActivityText(progress);
            CurrentFileText.Text = GetCurrentFileText(progress);

            ProgressFill.Width = 470 * (progress / 100.0);
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

        private void BrowseButton_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                var dialog = new Microsoft.Win32.OpenFolderDialog
                {
                    Title = $"Select {_profile.Title} folder",
                    Multiselect = false
                };

                if (Directory.Exists(SelectedPathTextBox.Text))
                    dialog.InitialDirectory = SelectedPathTextBox.Text;
                else if (Directory.Exists(_selectedInstallPath))
                    dialog.InitialDirectory = _selectedInstallPath;

                bool? result = dialog.ShowDialog(this);

                if (result == true && !string.IsNullOrWhiteSpace(dialog.FolderName))
                {
                    SelectedPathTextBox.Text = dialog.FolderName;
                    _selectedInstallPath = dialog.FolderName;
                }
            }
            catch (Exception ex)
            {
                SetManualError("Folder browser failed: " + ex.Message);
            }
        }

        private void BackButton_Click(object sender, RoutedEventArgs e)
        {
            if (_mode != "install" || _installCommandSent)
                return;

            if (_installPage == InstallFrontendPage.ChooseFolder)
            {
                ShowWelcomePage();
            }
            else if (_installPage == InstallFrontendPage.Validation)
            {
                ShowChooseFolderPage();
            }
            else if (_installPage == InstallFrontendPage.MoviesOption)
            {
                ShowValidationPage();
            }
            else if (_installPage == InstallFrontendPage.ReadyToInstall)
            {
                if (_optionalFeatures.HasMoviesPatchOption())
                    ShowMoviesOptionPage();
                else
                    ShowValidationPage();
            }
        }

        private void CancelButton_Click(object sender, RoutedEventArgs e)
        {
            if (_mode != "install" || !_installCommandSent)
                return;

            CancelButton.IsEnabled = false;
            CancelButton.Content = "Cancelling...";

            WriteCommandFile("abort", "cancel_button_during_install");

            SetManualState(
                100,
                "Cancelling installation...",
                "Cancel command sent. The installer backend is stopping extraction and cleaning temporary files.",
                "Stopping backend installer...",
                "Waiting for backend abort confirmation"
            );

            FooterText.Text = "Cancelling installation. Please wait...";
        }

        private async void FinishButton_Click(object sender, RoutedEventArgs e)
        {
            string buttonText = FinishButton.Content?.ToString() ?? "";

            if (_mode == "install" && !_installCommandSent)
            {
                if (_installPage == InstallFrontendPage.Welcome)
                {
                    ShowChooseFolderPage();
                    return;
                }

                if (_installPage == InstallFrontendPage.ChooseFolder)
                {
                    ShowValidationPage();
                    return;
                }

                if (_installPage == InstallFrontendPage.Validation)
                {
                    if (_optionalFeatures.HasMoviesPatchOption())
                        ShowMoviesOptionPage();
                    else
                        ShowReadyToInstallPage();

                    return;
                }

                if (_installPage == InstallFrontendPage.MoviesOption)
                {
                    ShowReadyToInstallPage();
                    return;
                }

                if (_installPage == InstallFrontendPage.ReadyToInstall)
                {
                    StartInstallBackend();
                    return;
                }
            }

            if (_mode == "uninstall" &&
                !_rollbackRunning &&
                (buttonText.Equals("Restore", StringComparison.OrdinalIgnoreCase) || _awaitingRestoreConfirmation))
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
                _timer.Stop();
            }
            catch
            {
            }

            WriteCommandFile("exit", "finish_button");

            if (_mode == "uninstall")
                ScheduleLegacySelfCleanup();

            Environment.Exit(0);
        }

        private void ScheduleLegacySelfCleanup()
        {
            try
            {
                string legacyDir = Path.Combine(_targetPath, "_LegacyInstaller");   

                if (!Directory.Exists(legacyDir))
                    return;

                string cmdCommand =
                    "/C timeout /T 5 /NOBREAK > nul " +
                    "& attrib -R -S -H \"" + legacyDir + "\" /S /D " +
                    "& del /F /Q \"" + Path.Combine(legacyDir, "LegacyUI", "*") + "\" " +
                    "& rmdir /S /Q \"" + Path.Combine(legacyDir, "LegacyUI") + "\" " +
                    "& rmdir /S /Q \"" + legacyDir + "\" " +
                    "& timeout /T 5 /NOBREAK > nul " +
                    "& rmdir /S /Q \"" + Path.Combine(legacyDir, "LegacyUI") + "\" " +
                    "& rmdir /S /Q \"" + legacyDir + "\"";

                var psi = new ProcessStartInfo
                {
                    FileName = "cmd.exe",
                    Arguments = cmdCommand,
                    WorkingDirectory = Path.GetTempPath(),
                    UseShellExecute = false,
                    CreateNoWindow = true
                };

                Process.Start(psi);
            }
            catch
            {
            }
        }

        private static string QuotePowerShellArgument(string value)
        {
            return "\"" + value.Replace("\"", "\\\"") + "\"";
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