using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Reflection;
using System.Windows.Forms;

internal static class Program
{
    private sealed class ApprovedInstaller
    {
        public string AppId { get; }
        public string Backend { get; }
        public string Title { get; }

        public ApprovedInstaller(string appId, string backend, string title)
        {
            AppId = NormalizeAppId(appId);
            Backend = backend;
            Title = title;
        }
    }

    [STAThread]
    private static void Main()
    {
        ApplicationConfiguration.Initialize();

        string launcherDir = AppContext.BaseDirectory;
        string backendDir = Path.Combine(launcherDir, "_backend");

        var approvedInstallers = new Dictionary<string, ApprovedInstaller>(StringComparer.OrdinalIgnoreCase)
        {
            [NormalizeAppId("{6E2E96A4-8A9A-45F9-BD76-5514E2D1A140}")] =
                new ApprovedInstaller("{6E2E96A4-8A9A-45F9-BD76-5514E2D1A140}", "UndergroundMP.exe", "Underground Legacy Modpack"),

            [NormalizeAppId("{B42B49F2-6F0C-48D6-91D2-2E1F37A6C2D8}")] =
                new ApprovedInstaller("{B42B49F2-6F0C-48D6-91D2-2E1F37A6C2D8}", "Underground2MP.exe", "Underground 2 Legacy Modpack"),

            [NormalizeAppId("{E0C9B896-11D2-41A7-B9B0-0B71D0F3E2A5}")] =
                new ApprovedInstaller("{E0C9B896-11D2-41A7-B9B0-0B71D0F3E2A5}", "MostWantedMP.exe", "Most Wanted Legacy Modpack"),

            [NormalizeAppId("{D1B0EFD4-4570-4F52-93A2-7A4A8E42D6C1}")] =
                new ApprovedInstaller("{D1B0EFD4-4570-4F52-93A2-7A4A8E42D6C1}", "CarbonMP.exe", "Carbon Legacy Modpack"),

            [NormalizeAppId("{9E3C25AE-2F4B-407D-9B45-8E01C07F73D6}")] =
                new ApprovedInstaller("{9E3C25AE-2F4B-407D-9B45-8E01C07F73D6}", "ProStreetMP.exe", "ProStreet Legacy Modpack"),

            [NormalizeAppId("{5F1C8E3D-9A24-44C1-BB0A-51C8D6B74E92}")] =
                new ApprovedInstaller("{5F1C8E3D-9A24-44C1-BB0A-51C8D6B74E92}", "UndercoverMP.exe", "Undercover Legacy Modpack")
        };

        Dictionary<string, string> config;

        try
        {
            config = ReadEmbeddedIni("setup_launcher.ini");
        }
        catch (Exception ex)
        {
            ShowError("Failed to read embedded launcher configuration.\n\n" + ex.Message, "NFS Legacy Modpacks");
            return;
        }

        string configuredAppId = NormalizeAppId(GetRequired(config, "appid"));

        if (configuredAppId.Length == 0)
        {
            ShowError("Launcher configuration is invalid.\n\nMissing required key: appid", "NFS Legacy Modpacks");
            return;
        }

        if (!approvedInstallers.TryGetValue(configuredAppId, out ApprovedInstaller? approved))
        {
            ShowError("Launcher configuration is not approved.\n\nUnknown AppId:\n" + configuredAppId, "NFS Legacy Modpacks");
            return;
        }

        string configuredBackend = GetRequired(config, "backend");
        string configuredTitle = GetRequired(config, "title");
        string configuredArguments = GetOptional(config, "arguments");

        if (configuredArguments.Length == 0)
            configuredArguments = "/SILENT";

        if (!StringEquals(configuredBackend, approved.Backend))
        {
            ShowError(
                "Launcher configuration does not match the approved backend.\n\n" +
                "Expected: " + approved.Backend + "\n" +
                "Configured: " + configuredBackend,
                approved.Title
            );
            return;
        }

        if (!StringEquals(configuredTitle, approved.Title))
        {
            ShowError(
                "Launcher configuration does not match the approved title.\n\n" +
                "Expected: " + approved.Title + "\n" +
                "Configured: " + configuredTitle,
                approved.Title
            );
            return;
        }

        if (!StringEquals(configuredArguments, "/SILENT"))
        {
            ShowError(
                "Launcher configuration uses unsupported base arguments.\n\n" +
                "Expected: /SILENT\n" +
                "Configured: " + configuredArguments,
                approved.Title
            );
            return;
        }

        string backendPath = Path.Combine(backendDir, approved.Backend);

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

        string finalArguments =
            configuredArguments.Trim() +
            " /DIR=" + QuoteArgument(selectedGameFolder);

        try
        {
            var psi = new ProcessStartInfo
            {
                FileName = backendPath,
                Arguments = finalArguments,
                WorkingDirectory = backendDir,
                UseShellExecute = true
            };

            if (Process.Start(psi) == null)
                ShowError("Failed to start installer backend.", approved.Title);
        }
        catch (Exception ex)
        {
            ShowError("Failed to start installer backend.\n\n" + ex.Message, approved.Title);
        }
    }

    private static string? SelectGameFolder(string title)
    {
        using var dialog = new FolderBrowserDialog
        {
            Description = "Select your " + title + " game folder.",
            UseDescriptionForTitle = true,
            ShowNewFolderButton = false
        };

        DialogResult result = dialog.ShowDialog();

        if (result != DialogResult.OK)
            return null;

        return dialog.SelectedPath;
    }

    private static string QuoteArgument(string value)
    {
        return "\"" + value.Replace("\"", "\\\"") + "\"";
    }

    private static Dictionary<string, string> ReadEmbeddedIni(string fileName)
    {
        string content = ReadEmbeddedTextResource(fileName);
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

    private static string ReadEmbeddedTextResource(string fileName)
    {
        Assembly assembly = Assembly.GetExecutingAssembly();
        string resourceName = FindEmbeddedResourceName(assembly, fileName);

        using Stream? stream = assembly.GetManifestResourceStream(resourceName);

        if (stream == null)
            throw new FileNotFoundException("Embedded resource stream was not found: " + fileName);

        using var reader = new StreamReader(stream);
        return reader.ReadToEnd();
    }

    private static string FindEmbeddedResourceName(Assembly assembly, string fileName)
    {
        string[] resourceNames = assembly.GetManifestResourceNames();

        foreach (string resourceName in resourceNames)
        {
            if (resourceName.EndsWith(fileName, StringComparison.OrdinalIgnoreCase))
                return resourceName;
        }

        throw new FileNotFoundException(
            "Embedded resource was not found: " + fileName + "\n\nAvailable resources:\n" +
            string.Join("\n", resourceNames)
        );
    }

    private static string GetRequired(Dictionary<string, string> config, string key)
    {
        if (!config.TryGetValue(key, out string? value))
            return string.Empty;

        return value.Trim();
    }

    private static string GetOptional(Dictionary<string, string> config, string key)
    {
        if (!config.TryGetValue(key, out string? value))
            return string.Empty;

        return value.Trim();
    }

    private static string NormalizeAppId(string value)
    {
        return value
            .Trim()
            .TrimStart('{')
            .TrimEnd('}')
            .ToUpperInvariant();
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