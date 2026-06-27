using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Windows.Forms;

internal static class Program
{
    private sealed class ApprovedInstaller
    {
        public string AppId { get; }
        public string Game { get; }
        public string BackendFileName { get; }
        public string Title { get; }
        public string IconPath { get; }

        public ApprovedInstaller(string appId, string game, string backendFileName, string title, string iconPath)
        {
            AppId = NormalizeAppId(appId);
            Game = game;
            BackendFileName = backendFileName;
            Title = title;
            IconPath = iconPath;
        }
    }

    [STAThread]
    private static void Main()
    {
        ApplicationConfiguration.Initialize();

        string launcherDir = AppContext.BaseDirectory;

        var approvedInstallers = new Dictionary<string, ApprovedInstaller>(StringComparer.OrdinalIgnoreCase)
        {
            [NormalizeAppId("{6E2E96A4-8A9A-45F9-BD76-5514E2D1A140}")] =
                new ApprovedInstaller("{6E2E96A4-8A9A-45F9-BD76-5514E2D1A140}", "nfsu", "UndergroundMP.exe", "Underground Legacy Modpack", @"Assets\Icons\NFSU.ico"),

            [NormalizeAppId("{B42B49F2-6F0C-48D6-91D2-2E1F37A6C2D8}")] =
                new ApprovedInstaller("{B42B49F2-6F0C-48D6-91D2-2E1F37A6C2D8}", "nfsu2", "Underground2MP.exe", "Underground 2 Legacy Modpack", @"Assets\Icons\NFSU2.ico"),

            [NormalizeAppId("{E0C9B896-11D2-41A7-B9B0-0B71D0F3E2A5}")] =
                new ApprovedInstaller("{E0C9B896-11D2-41A7-B9B0-0B71D0F3E2A5}", "nfsmw", "MostWantedMP.exe", "Most Wanted Legacy Modpack", @"Assets\Icons\NFSMW.ico"),

            [NormalizeAppId("{D1B0EFD4-4570-4F52-93A2-7A4A8E42D6C1}")] =
                new ApprovedInstaller("{D1B0EFD4-4570-4F52-93A2-7A4A8E42D6C1}", "nfsc", "CarbonMP.exe", "Carbon Legacy Modpack", @"Assets\Icons\NFSC.ico"),

            [NormalizeAppId("{9E3C25AE-2F4B-407D-9B45-8E01C07F73D6}")] =
                new ApprovedInstaller("{9E3C25AE-2F4B-407D-9B45-8E01C07F73D6}", "nfsps", "ProStreetMP.exe", "ProStreet Legacy Modpack", @"Assets\Icons\NFSPS.ico"),

            [NormalizeAppId("{5F1C8E3D-9A24-44C1-BB0A-51C8D6B74E92}")] =
                new ApprovedInstaller("{5F1C8E3D-9A24-44C1-BB0A-51C8D6B74E92}", "nfsuc", "UndercoverMP.exe", "Undercover Legacy Modpack", @"Assets\Icons\NFSUC.ico")
        };

        try
        {
            Dictionary<string, string> config = ReadLocalIni(launcherDir, "setup_launcher.ini");

            string configuredAppId = NormalizeAppId(GetRequired(config, "appid"));

            if (!approvedInstallers.TryGetValue(configuredAppId, out ApprovedInstaller? approved))
            {
                ShowError("Launcher configuration is not approved.\n\nUnknown AppId:\n" + configuredAppId, "NFS Legacy Modpacks");
                return;
            }

            string configuredGame = GetRequired(config, "game");
            string configuredBackend = GetRequired(config, "backend");
            string configuredTitle = GetRequired(config, "title");
            string configuredIcon = GetOptional(config, "icon");
            string configuredArguments = GetOptional(config, "arguments");

            if (configuredArguments.Length == 0)
                configuredArguments = "/SILENT";

            if (configuredIcon.Length == 0)
                configuredIcon = approved.IconPath;

            if (!StringEquals(configuredGame, approved.Game))
            {
                ShowError("Launcher configuration does not match the approved game id.\n\nExpected: " + approved.Game + "\nConfigured: " + configuredGame, approved.Title);
                return;
            }

            if (!StringEquals(Path.GetFileName(configuredBackend), approved.BackendFileName))
            {
                ShowError("Launcher configuration does not match the approved backend.\n\nExpected: " + approved.BackendFileName + "\nConfigured: " + configuredBackend, approved.Title);
                return;
            }

            if (!StringEquals(configuredTitle, approved.Title))
            {
                ShowError("Launcher configuration does not match the approved title.\n\nExpected: " + approved.Title + "\nConfigured: " + configuredTitle, approved.Title);
                return;
            }

            if (!StringEquals(Path.GetFileName(configuredIcon), Path.GetFileName(approved.IconPath)))
            {
                ShowError("Launcher configuration does not match the approved icon.\n\nExpected: " + approved.IconPath + "\nConfigured: " + configuredIcon, approved.Title);
                return;
            }

            if (!StringEquals(configuredArguments, "/SILENT"))
            {
                ShowError("Launcher configuration uses unsupported base arguments.\n\nExpected: /SILENT\nConfigured: " + configuredArguments, approved.Title);
                return;
            }

            string backendPath = ResolveBackendPath(launcherDir, configuredBackend, approved.BackendFileName);

            if (!File.Exists(backendPath))
            {
                ShowError("Installer backend was not found.\n\nMissing:\n" + backendPath, approved.Title);
                return;
            }

            string? selectedGameFolder = SelectGameFolder(approved.Title);

            if (string.IsNullOrWhiteSpace(selectedGameFolder))
                return;

            if (!Directory.Exists(selectedGameFolder))
            {
                ShowError("Selected game folder does not exist:\n\n" + selectedGameFolder, approved.Title);
                return;
            }

            string finalArguments = configuredArguments.Trim() + " /DIR=\"" + selectedGameFolder + "\"";
            string workingDir = Path.GetDirectoryName(backendPath) ?? launcherDir;

            File.WriteAllText(
                Path.Combine(launcherDir, "SetupLauncher.log"),
                "launcherDir=" + launcherDir + Environment.NewLine +
                "backendPath=" + backendPath + Environment.NewLine +
                "workingDir=" + workingDir + Environment.NewLine +
                "selectedGameFolder=" + selectedGameFolder + Environment.NewLine +
                "arguments=" + finalArguments + Environment.NewLine
            );

            var psi = new ProcessStartInfo
            {
                FileName = backendPath,
                Arguments = finalArguments,
                WorkingDirectory = workingDir,
                UseShellExecute = true
            };

            Process.Start(psi);
        }
        catch (Exception ex)
        {
            ShowError("Failed to start installer backend.\n\n" + ex.Message, "NFS Legacy Modpacks");
        }
    }

    private static string ResolveBackendPath(string launcherDir, string configuredBackend, string approvedBackendFileName)
    {
        string cleanBackend = configuredBackend.Trim().Trim('"');

        if (Path.IsPathRooted(cleanBackend))
            return cleanBackend;

        if (!string.IsNullOrWhiteSpace(Path.GetDirectoryName(cleanBackend)))
            return Path.GetFullPath(Path.Combine(launcherDir, cleanBackend));

        return Path.GetFullPath(Path.Combine(launcherDir, "_backend", approvedBackendFileName));
    }

    private static string? SelectGameFolder(string title)
    {
        using var dialog = new FolderBrowserDialog
        {
            Description = "Select your " + title + " game folder.",
            UseDescriptionForTitle = true,
            ShowNewFolderButton = false
        };

        return dialog.ShowDialog() == DialogResult.OK ? dialog.SelectedPath : null;
    }

    private static Dictionary<string, string> ReadLocalIni(string launcherDir, string fileName)
    {
        string iniPath = Path.Combine(launcherDir, fileName);

        if (!File.Exists(iniPath))
            throw new FileNotFoundException("setup_launcher.ini was not found beside the launcher:\n" + iniPath);

        return ParseIni(File.ReadAllText(iniPath));
    }

    private static Dictionary<string, string> ParseIni(string content)
    {
        var result = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);

        using var reader = new StringReader(content);

        while (reader.ReadLine() is string rawLine)
        {
            string line = rawLine.Trim();

            if (line.Length == 0)
                continue;

            if (line.StartsWith(";") || line.StartsWith("#"))
                continue;

            if (line.StartsWith("[") && line.EndsWith("]"))
                continue;

            int equalsIndex = line.IndexOf('=');

            if (equalsIndex <= 0)
                continue;

            string key = line.Substring(0, equalsIndex).Trim();
            string value = line.Substring(equalsIndex + 1).Trim();

            result[key] = value;
        }

        return result;
    }

    private static string GetRequired(Dictionary<string, string> config, string key)
    {
        return config.TryGetValue(key, out string? value) ? value.Trim() : string.Empty;
    }

    private static string GetOptional(Dictionary<string, string> config, string key)
    {
        return config.TryGetValue(key, out string? value) ? value.Trim() : string.Empty;
    }

    private static string NormalizeAppId(string value)
    {
        return value.Trim().TrimStart('{').TrimEnd('}').ToUpperInvariant();
    }

    private static bool StringEquals(string left, string right)
    {
        return string.Equals(left.Trim(), right.Trim(), StringComparison.OrdinalIgnoreCase);
    }

    private static void ShowError(string message, string title)
    {
        MessageBox.Show(message, title, MessageBoxButtons.OK, MessageBoxIcon.Error);
    }
}