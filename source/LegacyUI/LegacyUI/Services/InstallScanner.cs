using System;
using System.IO;
using System.Linq;
using LegacyUI.Models;

namespace LegacyUI.Services
{
    public class InstallScanner
    {
        private readonly GameProfile _profile;
        private readonly string _targetPath;
        private readonly string _mode;
        private readonly DateTime _startTime;

        public InstallScanner(GameProfile profile, string targetPath, string mode)
        {
            _profile = profile;
            _targetPath = targetPath;
            _mode = mode.Equals("uninstall", StringComparison.OrdinalIgnoreCase)
                ? "uninstall"
                : "install";

            _startTime = DateTime.Now;
        }

        public ScanResult Scan()
        {
            long folderSize = 0;
            int fileCount = 0;
            int manifestLines = 0;

            if (Directory.Exists(_targetPath))
            {
                var files = Directory.EnumerateFiles(_targetPath, "*", SearchOption.AllDirectories)
                    .Where(path =>
                        !path.Contains(@"\Backup\", StringComparison.OrdinalIgnoreCase) &&
                        !path.EndsWith("unins000.exe", StringComparison.OrdinalIgnoreCase) &&
                        !path.EndsWith("unins000.dat", StringComparison.OrdinalIgnoreCase) &&
                        !Path.GetFileName(path).StartsWith("telemetry_", StringComparison.OrdinalIgnoreCase))
                    .ToList();

                fileCount = files.Count;

                foreach (string file in files)
                {
                    try
                    {
                        folderSize += new FileInfo(file).Length;
                    }
                    catch
                    {
                    }
                }

                string manifestPath = Path.Combine(_targetPath, "_LegacyInstaller", "install_manifest.txt");

                if (File.Exists(manifestPath))
                {
                    try
                    {
                        manifestLines = File.ReadLines(manifestPath).Count();
                    }
                    catch
                    {
                        manifestLines = 0;
                    }
                }
            }

            double elapsedSeconds = (DateTime.Now - _startTime).TotalSeconds;

            double progress = _mode == "uninstall"
                ? CalculateUninstallProgress(folderSize, elapsedSeconds)
                : CalculateInstallProgress(folderSize, manifestLines, elapsedSeconds);

            return new ScanResult
            {
                FolderSizeBytes = folderSize,
                FileCount = fileCount,
                ManifestLines = manifestLines,
                ElapsedSeconds = elapsedSeconds,
                ProgressPercent = Math.Clamp(progress, 0, 99)
            };
        }

        private double CalculateInstallProgress(long currentSize, int manifestLines, double elapsedSeconds)
        {
            double manifestProgress = SafeRatio(manifestLines, _profile.ExpectedManifestLines);

            double sizeProgress = SafeRatio(
                currentSize - _profile.BaselineSizeBytes,
                _profile.InstalledSizeBytes - _profile.BaselineSizeBytes
            );

            double timeProgress = SafeRatio(elapsedSeconds, _profile.ExpectedInstallSeconds);

            return ((manifestProgress * 0.60) + (sizeProgress * 0.30) + (timeProgress * 0.10)) * 100.0;
        }

        private double CalculateUninstallProgress(long currentSize, double elapsedSeconds)
        {
            long totalDelta = _profile.InstalledSizeBytes - _profile.RestoredSizeBytes;
            long currentDelta = currentSize - _profile.RestoredSizeBytes;

            double sizeRestoreProgress = 1.0 - SafeRatio(currentDelta, totalDelta);
            double timeProgress = SafeRatio(elapsedSeconds, _profile.ExpectedUninstallSeconds);

            return ((sizeRestoreProgress * 0.70) + (timeProgress * 0.30)) * 100.0;
        }

        private static double SafeRatio(double value, double total)
        {
            if (total <= 0)
                return 0;

            return Math.Clamp(value / total, 0, 1);
        }
    }

    public class ScanResult
    {
        public long FolderSizeBytes { get; set; }
        public int FileCount { get; set; }
        public int ManifestLines { get; set; }
        public double ElapsedSeconds { get; set; }
        public double ProgressPercent { get; set; }
    }
}