using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Net.Http;
using System.Reflection;
using System.Threading.Tasks;
using System.Windows.Forms;

internal static class Program
{
    private const string LauncherVersion = "2.0.0";
    private const string TempRootName = "NFSLegacyModpacks";
    private const string PackageFileName = "package.7z";
    private const string LocalIniFileName = "setup_launcher.ini";
    private const string LogFileName = "SetupLauncher.log";
    private const string SplashStatusFileName = "launcher_status.txt";

    private sealed class ApprovedInstaller
    {
        public string AppId { get; }
        public string Game { get; }
        public string BackendFileName { get; }
        public string Title { get; }
        public string IconPath { get; }
        public string GoogleDriveFileId { get; }
        public string ExpectedRootFolder { get; }
        public string[] LauncherFileNames { get; }

        public ApprovedInstaller(
            string appId,
            string game,
            string backendFileName,
            string title,
            string iconPath,
            string googleDriveFileId,
            string expectedRootFolder,
            params string[] launcherFileNames)
        {
            AppId = NormalizeAppId(appId);
            Game = game;
            BackendFileName = backendFileName;
            Title = title;
            IconPath = iconPath;
            GoogleDriveFileId = googleDriveFileId;
            ExpectedRootFolder = expectedRootFolder;
            LauncherFileNames = launcherFileNames;
        }
    }

    [STAThread]
    private static void Main()
    {
        ApplicationConfiguration.Initialize();

        try
        {
            RunAsync().GetAwaiter().GetResult();
        }
        catch (Exception ex)
        {
            ShowError("SetupLauncher failed.\n\n" + ex.Message, "NFS Legacy Modpacks");
        }
    }

    private static async Task RunAsync()
    {
        string launcherDir = AppContext.BaseDirectory;
        string launcherExe = Path.GetFileName(Environment.ProcessPath ?? Application.ExecutablePath);
        string logPath = Path.Combine(launcherDir, LogFileName);

        Dictionary<string, ApprovedInstaller> approvedInstallers = CreateApprovedInstallers();
        ApprovedInstaller approved = ResolveInstallerFromLauncherName(approvedInstallers.Values, launcherExe);

        WriteLog(
            logPath,
            "========================================" + Environment.NewLine +
            "NFS Legacy Modpacks - SetupLauncher" + Environment.NewLine +
            "========================================" + Environment.NewLine +
            "Version: " + LauncherVersion + Environment.NewLine +
            "Date: " + DateTime.Now + Environment.NewLine +
            "Launcher Directory: " + launcherDir + Environment.NewLine +
            "Launcher EXE: " + launcherExe + Environment.NewLine +
            "Resolved Game: " + approved.Game + Environment.NewLine +
            "Title: " + approved.Title + Environment.NewLine
        );

        string tempRoot = Path.Combine(Path.GetTempPath(), TempRootName);
        CleanupOldTempFolders(tempRoot, logPath);

        string? selectedGameFolder = SelectGameFolder(approved.Title);

        if (string.IsNullOrWhiteSpace(selectedGameFolder))
        {
            AppendLog(logPath, "Status: User cancelled folder selection.");
            return;
        }

        if (!Directory.Exists(selectedGameFolder))
        {
            ShowError("Selected game folder does not exist:\n\n" + selectedGameFolder, approved.Title);
            AppendLog(logPath, "ERROR: Selected game folder does not exist: " + selectedGameFolder);
            return;
        }

        string tempWorkDir = Path.Combine(
            tempRoot,
            approved.Game + "_" + Guid.NewGuid().ToString("N")
        );

        string archivePath = Path.Combine(tempWorkDir, PackageFileName);
        string statusFilePath = Path.Combine(tempWorkDir, SplashStatusFileName);
        Process? splashProcess = null;

        try
        {
            Directory.CreateDirectory(tempWorkDir);
            WriteStatus(statusFilePath, "Preparing installer files...");
            splashProcess = TryStartBootstrapSplash(approved, tempWorkDir, statusFilePath, logPath);

            AppendLog(logPath, "Temp Work Directory: " + tempWorkDir);
            AppendLog(logPath, "Selected Game Folder: " + selectedGameFolder);
            AppendLog(logPath, "Download URL: " + BuildGoogleDriveDownloadUrl(approved.GoogleDriveFileId));

            WriteStatus(statusFilePath, "Downloading required installer package...");
            await DownloadPackageAsync(approved, archivePath, logPath, statusFilePath);

            if (!File.Exists(archivePath))
                throw new FileNotFoundException("Downloaded package was not found.", archivePath);

            FileInfo packageInfo = new FileInfo(archivePath);

            if (packageInfo.Length < 1024 * 1024)
                throw new InvalidDataException("Downloaded package is too small and is likely not the real archive.");

            AppendLog(logPath, "Downloaded Package Size: " + packageInfo.Length + " bytes");

            WriteStatus(statusFilePath, "Preparing extraction tools...");
            string sevenZipPath = PrepareSevenZip(tempWorkDir, logPath);
            WriteStatus(statusFilePath, "Extracting launcher contents...");
            ExtractArchive(sevenZipPath, archivePath, tempWorkDir, logPath);
            TryDeleteFile(archivePath, logPath);

            string extractedRoot = ResolveExtractedRoot(tempWorkDir, approved.ExpectedRootFolder);
            string iniPath = Path.Combine(extractedRoot, LocalIniFileName);
            string backendPath = Path.Combine(extractedRoot, "_backend", approved.BackendFileName);

            AppendLog(logPath, "Extracted Root: " + extractedRoot);
            AppendLog(logPath, "INI Path: " + iniPath);
            AppendLog(logPath, "Backend Path: " + backendPath);

            if (!File.Exists(iniPath))
                throw new FileNotFoundException("Extracted setup_launcher.ini was not found.", iniPath);

            if (!File.Exists(backendPath))
                throw new FileNotFoundException("Extracted backend executable was not found.", backendPath);

            Dictionary<string, string> config = ParseIni(File.ReadAllText(iniPath));
            ValidateConfig(config, approved);

            string configuredArguments = GetOptional(config, "arguments");

            if (configuredArguments.Length == 0)
                configuredArguments = "/SILENT";

            string finalArguments = configuredArguments.Trim() + " /DIR=\"" + selectedGameFolder + "\"";
            string workingDir = Path.GetDirectoryName(backendPath) ?? extractedRoot;

            AppendLog(logPath, "Backend Working Directory: " + workingDir);
            AppendLog(logPath, "Backend Arguments: " + finalArguments);
            WriteStatus(statusFilePath, "Launching Legacy Modpack installer...");
            AppendLog(logPath, "Status: Starting backend.");

            TryCloseSplash(splashProcess, logPath);
            splashProcess = null;

            var psi = new ProcessStartInfo
            {
                FileName = backendPath,
                Arguments = finalArguments,
                WorkingDirectory = workingDir,
                UseShellExecute = true
            };

            using Process? process = Process.Start(psi);

            if (process == null)
                throw new InvalidOperationException("Failed to start installer backend.");

            AppendLog(logPath, "Status: Backend started. Waiting for backend to exit.");

            process.WaitForExit();

            AppendLog(logPath, "Backend Exit Code: " + process.ExitCode);
            AppendLog(logPath, "Status: SetupLauncher finished.");
        }
        catch (Exception ex)
        {
            AppendLog(logPath, "ERROR: " + ex);
            ShowError("Failed to prepare or launch the installer.\n\n" + ex.Message, approved.Title);
        }
        finally
        {
            TryCloseSplash(splashProcess, logPath);
            TryDeleteFile(archivePath, logPath);
            TryDeleteDirectory(tempWorkDir, logPath);
        }
    }

    private static Dictionary<string, ApprovedInstaller> CreateApprovedInstallers()
    {
        var installers = new Dictionary<string, ApprovedInstaller>(StringComparer.OrdinalIgnoreCase);

        Add(installers, new ApprovedInstaller(
            "{6E2E96A4-8A9A-45F9-BD76-5514E2D1A140}",
            "nfsu",
            "UndergroundMP.exe",
            "Underground Legacy Modpack",
            @"Assets\Icons\NFSU.ico",
            "1sF3bdVAvgWSRGROZFiPlZpOkzY-kbJF4",
            "NFSU",
            "UndergroundLegacy_v2.0.0.exe",
            "UndergroundLegacy.exe",
            "NFSU.exe"
        ));

        Add(installers, new ApprovedInstaller(
            "{B42B49F2-6F0C-48D6-91D2-2E1F37A6C2D8}",
            "nfsu2",
            "Underground2MP.exe",
            "Underground 2 Legacy Modpack",
            @"Assets\Icons\NFSU2.ico",
            "1bmURlPzUhP1_mP3u5Yf4yQbakB3PD67N",
            "NFSU2",
            "Underground2Legacy_v2.0.0.exe",
            "Underground2Legacy.exe",
            "NFSU2.exe"
        ));

        Add(installers, new ApprovedInstaller(
            "{E0C9B896-11D2-41A7-B9B0-0B71D0F3E2A5}",
            "nfsmw",
            "MostWantedMP.exe",
            "Most Wanted Legacy Modpack",
            @"Assets\Icons\NFSMW.ico",
            "1vTFj_1xNnWzrPYLEGi74PmMhBaGFzsYO",
            "NFSMW",
            "MostWantedLegacy_v2.0.0.exe",
            "MostWantedLegacy.exe",
            "NFSMW.exe"
        ));

        Add(installers, new ApprovedInstaller(
            "{D1B0EFD4-4570-4F52-93A2-7A4A8E42D6C1}",
            "nfsc",
            "CarbonMP.exe",
            "Carbon Legacy Modpack",
            @"Assets\Icons\NFSC.ico",
            "1He5MXPHV2BSB8D_czuBcaSsRabKW6OKw",
            "NFSC",
            "CarbonLegacy_v2.0.0.exe",
            "CarbonLegacy.exe",
            "NFSC.exe"
        ));

        Add(installers, new ApprovedInstaller(
            "{9E3C25AE-2F4B-407D-9B45-8E01C07F73D6}",
            "nfsps",
            "ProStreetMP.exe",
            "ProStreet Legacy Modpack",
            @"Assets\Icons\NFSPS.ico",
            "1QiXT7BUEUqsQ06YY25NJD4ruTVwN6M1D",
            "NFSPS",
            "ProStreetLegacy_v2.0.0.exe",
            "ProStreetLegacy.exe",
            "NFSPS.exe"
        ));

        Add(installers, new ApprovedInstaller(
            "{5F1C8E3D-9A24-44C1-BB0A-51C8D6B74E92}",
            "nfsuc",
            "UndercoverMP.exe",
            "Undercover Legacy Modpack",
            @"Assets\Icons\NFSUC.ico",
            "1KJf275mpmt82fk2T9sO3WZMyO8Ep9Sts",
            "NFSUC",
            "UndercoverLegacy_v2.0.0.exe",
            "UndercoverLegacy.exe",
            "NFSUC.exe"
        ));

        return installers;
    }

    private static void Add(Dictionary<string, ApprovedInstaller> installers, ApprovedInstaller installer)
    {
        installers[installer.AppId] = installer;
    }

    private static ApprovedInstaller ResolveInstallerFromLauncherName(IEnumerable<ApprovedInstaller> installers, string launcherExe)
    {
        foreach (ApprovedInstaller installer in installers)
        {
            foreach (string fileName in installer.LauncherFileNames)
            {
                if (StringEquals(launcherExe, fileName))
                    return installer;
            }
        }

        string availableNames = string.Join(
            Environment.NewLine,
            installers.SelectMany(i => i.LauncherFileNames).Distinct(StringComparer.OrdinalIgnoreCase)
        );

        throw new InvalidOperationException(
            "This launcher filename is not approved for any supported title.\n\n" +
            "Current filename:\n" + launcherExe + "\n\n" +
            "Expected one of:\n" + availableNames
        );
    }

    private static async Task DownloadPackageAsync(ApprovedInstaller approved, string archivePath, string logPath, string statusFilePath)
    {
        string url = BuildGoogleDriveDownloadUrl(approved.GoogleDriveFileId);

        using var client = new HttpClient
        {
            Timeout = TimeSpan.FromHours(3)
        };

        using HttpResponseMessage response = await client.GetAsync(url, HttpCompletionOption.ResponseHeadersRead);
        response.EnsureSuccessStatusCode();

        long? contentLength = response.Content.Headers.ContentLength;
        using Stream input = await response.Content.ReadAsStreamAsync();
        using FileStream output = new FileStream(archivePath, FileMode.Create, FileAccess.Write, FileShare.None);

        byte[] buffer = new byte[1024 * 1024];
        long totalBytes = 0;
        int read;

        while ((read = await input.ReadAsync(buffer, 0, buffer.Length)) > 0)
        {
            await output.WriteAsync(buffer, 0, read);
            totalBytes += read;

            if (totalBytes % (50L * 1024L * 1024L) < buffer.Length)
            {
                AppendLog(logPath, "Downloaded: " + totalBytes + " bytes");
                WriteDownloadStatus(statusFilePath, totalBytes, contentLength);
            }
        }
    }

    private static string BuildGoogleDriveDownloadUrl(string fileId)
    {
        return "https://drive.usercontent.google.com/download?id=" + fileId + "&export=download&confirm=t";
    }

    private static Process? TryStartBootstrapSplash(ApprovedInstaller approved, string tempWorkDir, string statusFilePath, string logPath)
    {
        try
        {
            string splashExe = PrepareSplashExecutable(tempWorkDir, logPath);

            if (!File.Exists(splashExe))
            {
                AppendLog(logPath, "Splash: Splash.exe was not found. Continuing without bootstrap splash.");
                return null;
            }

            string? splashImage = PrepareSplashImage(approved, tempWorkDir, logPath);
            string arguments = "/bootstrap /status \"" + statusFilePath + "\"";

            if (!string.IsNullOrWhiteSpace(splashImage) && File.Exists(splashImage))
                arguments += " /image \"" + splashImage + "\"";

            var psi = new ProcessStartInfo
            {
                FileName = splashExe,
                Arguments = arguments,
                WorkingDirectory = Path.GetDirectoryName(splashExe) ?? tempWorkDir,
                UseShellExecute = true
            };

            Process? process = Process.Start(psi);
            AppendLog(logPath, "Splash: Bootstrap splash started.");
            return process;
        }
        catch (Exception ex)
        {
            AppendLog(logPath, "Splash: Failed to start bootstrap splash. " + ex.Message);
            return null;
        }
    }

    private static string PrepareSplashExecutable(string tempWorkDir, string logPath)
    {
        string toolsDir = Path.Combine(tempWorkDir, "Tools");
        Directory.CreateDirectory(toolsDir);

        string embeddedSplash = Path.Combine(toolsDir, "Splash.exe");
        ExtractEmbeddedResourceIfExists("Splash.exe", embeddedSplash);

        if (File.Exists(embeddedSplash))
        {
            AppendLog(logPath, "Splash: Embedded Splash.exe extracted: " + embeddedSplash);
            return embeddedSplash;
        }

        string[] candidatePaths =
        {
            Path.Combine(AppContext.BaseDirectory, "Splash.exe"),
            Path.Combine(AppContext.BaseDirectory, "Tools", "Splash.exe")
        };

        foreach (string candidatePath in candidatePaths)
        {
            if (File.Exists(candidatePath))
            {
                AppendLog(logPath, "Splash: External Splash.exe found: " + candidatePath);
                return candidatePath;
            }
        }

        return embeddedSplash;
    }

    private static string? PrepareSplashImage(ApprovedInstaller approved, string tempWorkDir, string logPath)
    {
        string splashDir = Path.Combine(tempWorkDir, "SplashImages");
        Directory.CreateDirectory(splashDir);

        string[] resourceNames =
        {
            approved.Game + ".png",
            approved.ExpectedRootFolder + ".png",
            "splash.png"
        };

        foreach (string resourceName in resourceNames)
        {
            string destination = Path.Combine(splashDir, resourceName);
            ExtractEmbeddedResourceIfExists(resourceName, destination);

            if (File.Exists(destination))
            {
                AppendLog(logPath, "Splash: Embedded splash image extracted: " + destination);
                return destination;
            }
        }

        string[] candidatePaths =
        {
            Path.Combine(AppContext.BaseDirectory, "SplashImages", approved.Game + ".png"),
            Path.Combine(AppContext.BaseDirectory, "SplashImages", approved.ExpectedRootFolder + ".png"),
            Path.Combine(AppContext.BaseDirectory, "splash.png")
        };

        foreach (string candidatePath in candidatePaths)
        {
            if (File.Exists(candidatePath))
            {
                AppendLog(logPath, "Splash: External splash image found: " + candidatePath);
                return candidatePath;
            }
        }

        AppendLog(logPath, "Splash: No splash image found. Splash will use fallback display.");
        return null;
    }

    private static void TryCloseSplash(Process? splashProcess, string logPath)
    {
        if (splashProcess == null)
            return;

        try
        {
            if (!splashProcess.HasExited)
            {
                splashProcess.CloseMainWindow();

                if (!splashProcess.WaitForExit(1500) && !splashProcess.HasExited)
                    splashProcess.Kill(entireProcessTree: true);
            }

            splashProcess.Dispose();
            AppendLog(logPath, "Splash: Bootstrap splash closed.");
        }
        catch (Exception ex)
        {
            AppendLog(logPath, "Splash: Failed to close bootstrap splash. " + ex.Message);
        }
    }

    private static void WriteStatus(string statusFilePath, string status)
    {
        try
        {
            File.WriteAllText(statusFilePath, status);
        }
        catch
        {
            // Status updates must never block installation.
        }
    }

    private static void WriteDownloadStatus(string statusFilePath, long downloadedBytes, long? totalBytes)
    {
        double downloadedMb = downloadedBytes / 1024d / 1024d;

        if (totalBytes.HasValue && totalBytes.Value > 0)
        {
            double totalMb = totalBytes.Value / 1024d / 1024d;
            int percent = (int)Math.Min(100, Math.Round(downloadedBytes * 100d / totalBytes.Value));
            WriteStatus(statusFilePath, "Downloading package... " + percent + "% (" + downloadedMb.ToString("N0") + " MB / " + totalMb.ToString("N0") + " MB)");
        }
        else
        {
            WriteStatus(statusFilePath, "Downloading package... " + downloadedMb.ToString("N0") + " MB");
        }
    }

    private static string PrepareSevenZip(string tempWorkDir, string logPath)
    {
        string embeddedSevenZip = ExtractEmbeddedSevenZip(tempWorkDir, logPath);

        if (File.Exists(embeddedSevenZip))
            return embeddedSevenZip;

        string[] candidatePaths =
        {
            Path.Combine(AppContext.BaseDirectory, "7z.exe"),
            Path.Combine(AppContext.BaseDirectory, "Tools", "7z.exe"),
            @"C:\Program Files\7-Zip\7z.exe",
            @"C:\Program Files (x86)\7-Zip\7z.exe"
        };

        foreach (string candidatePath in candidatePaths)
        {
            if (File.Exists(candidatePath))
            {
                AppendLog(logPath, "7-Zip Path: " + candidatePath);
                return candidatePath;
            }
        }

        throw new FileNotFoundException(
            "7z.exe was not found.\n\n" +
            "Bundle 7z.exe as an embedded resource under Tools\\7z.exe, place it next to the launcher, or install 7-Zip."
        );
    }

    private static string ExtractEmbeddedSevenZip(string tempWorkDir, string logPath)
    {
        string toolsDir = Path.Combine(tempWorkDir, "Tools");
        Directory.CreateDirectory(toolsDir);

        string sevenZipExe = Path.Combine(toolsDir, "7z.exe");
        string sevenZipDll = Path.Combine(toolsDir, "7z.dll");

        ExtractEmbeddedResourceIfExists("7z.exe", sevenZipExe);
        ExtractEmbeddedResourceIfExists("7z.dll", sevenZipDll);

        if (File.Exists(sevenZipExe))
            AppendLog(logPath, "Embedded 7-Zip extracted: " + sevenZipExe);

        return sevenZipExe;
    }

    private static void ExtractEmbeddedResourceIfExists(string fileName, string destinationPath)
    {
        Assembly assembly = Assembly.GetExecutingAssembly();
        string? resourceName = assembly.GetManifestResourceNames()
            .FirstOrDefault(name => name.EndsWith(fileName, StringComparison.OrdinalIgnoreCase));

        if (resourceName == null)
            return;

        using Stream? input = assembly.GetManifestResourceStream(resourceName);

        if (input == null)
            return;

        using FileStream output = new FileStream(destinationPath, FileMode.Create, FileAccess.Write, FileShare.None);
        input.CopyTo(output);
    }

    private static void ExtractArchive(string sevenZipPath, string archivePath, string tempWorkDir, string logPath)
    {
        AppendLog(logPath, "Status: Extracting package.");

        var psi = new ProcessStartInfo
        {
            FileName = sevenZipPath,
            Arguments = "x \"" + archivePath + "\" -o\"" + tempWorkDir + "\" -y",
            WorkingDirectory = tempWorkDir,
            UseShellExecute = false,
            CreateNoWindow = true,
            RedirectStandardOutput = true,
            RedirectStandardError = true
        };

        using Process process = new Process
        {
            StartInfo = psi
        };

        process.Start();

        string stdout = process.StandardOutput.ReadToEnd();
        string stderr = process.StandardError.ReadToEnd();

        process.WaitForExit();

        AppendLog(logPath, "7-Zip Exit Code: " + process.ExitCode);

        if (!string.IsNullOrWhiteSpace(stdout))
            AppendLog(logPath, "7-Zip Output:" + Environment.NewLine + stdout);

        if (!string.IsNullOrWhiteSpace(stderr))
            AppendLog(logPath, "7-Zip Error:" + Environment.NewLine + stderr);

        if (process.ExitCode != 0)
            throw new InvalidOperationException("7-Zip extraction failed with exit code " + process.ExitCode + ".");
    }

    private static string ResolveExtractedRoot(string tempWorkDir, string expectedRootFolder)
    {
        string expectedPath = Path.Combine(tempWorkDir, expectedRootFolder);

        if (Directory.Exists(expectedPath))
            return expectedPath;

        string[] candidateDirectories = Directory.GetDirectories(tempWorkDir);

        foreach (string candidateDirectory in candidateDirectories)
        {
            if (File.Exists(Path.Combine(candidateDirectory, LocalIniFileName)) &&
                Directory.Exists(Path.Combine(candidateDirectory, "_backend")))
            {
                return candidateDirectory;
            }
        }

        if (File.Exists(Path.Combine(tempWorkDir, LocalIniFileName)) &&
            Directory.Exists(Path.Combine(tempWorkDir, "_backend")))
        {
            return tempWorkDir;
        }

        throw new DirectoryNotFoundException("Extracted package root folder was not found: " + expectedRootFolder);
    }

    private static void ValidateConfig(Dictionary<string, string> config, ApprovedInstaller approved)
    {
        string configuredAppId = NormalizeAppId(GetRequired(config, "appid"));
        string configuredGame = GetRequired(config, "game");
        string configuredBackend = GetRequired(config, "backend");
        string configuredTitle = GetRequired(config, "title");
        string configuredIcon = GetOptional(config, "icon");
        string configuredArguments = GetOptional(config, "arguments");

        if (configuredArguments.Length == 0)
            configuredArguments = "/SILENT";

        if (configuredIcon.Length == 0)
            configuredIcon = approved.IconPath;

        if (!StringEquals(configuredAppId, approved.AppId))
            throw new InvalidOperationException("Launcher configuration AppId does not match the approved title.");

        if (!StringEquals(configuredGame, approved.Game))
            throw new InvalidOperationException("Launcher configuration does not match the approved game id.");

        if (!StringEquals(Path.GetFileName(configuredBackend), approved.BackendFileName))
            throw new InvalidOperationException("Launcher configuration does not match the approved backend.");

        if (!StringEquals(configuredTitle, approved.Title))
            throw new InvalidOperationException("Launcher configuration does not match the approved title.");

        if (!StringEquals(Path.GetFileName(configuredIcon), Path.GetFileName(approved.IconPath)))
            throw new InvalidOperationException("Launcher configuration does not match the approved icon.");

        if (!StringEquals(configuredArguments, "/SILENT"))
            throw new InvalidOperationException("Launcher configuration uses unsupported base arguments.");
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

    private static void WriteLog(string logPath, string content)
    {
        try
        {
            File.WriteAllText(logPath, content + Environment.NewLine);
        }
        catch
        {
            // Logging must never block installation.
        }
    }

    private static void AppendLog(string logPath, string content)
    {
        try
        {
            File.AppendAllText(logPath, content + Environment.NewLine);
        }
        catch
        {
            // Logging must never block installation.
        }
    }

    private static void CleanupOldTempFolders(string tempRoot, string logPath)
    {
        try
        {
            if (!Directory.Exists(tempRoot))
                return;

            foreach (string directory in Directory.GetDirectories(tempRoot))
            {
                TryDeleteDirectory(directory, logPath);
            }
        }
        catch (Exception ex)
        {
            AppendLog(logPath, "Cleanup: Old temp folders scan failed. " + ex.Message);
        }
    }

    private static void TryDeleteFile(string path, string logPath)
    {
        try
        {
            if (File.Exists(path))
            {
                File.Delete(path);
                AppendLog(logPath, "Cleanup: Deleted temp archive: " + path);
            }
        }
        catch (Exception ex)
        {
            AppendLog(logPath, "Cleanup: Temp archive could not be deleted. Windows may remove it later. " + ex.Message);
        }
    }

    private static void TryDeleteDirectory(string path, string logPath)
    {
        try
        {
            if (Directory.Exists(path))
            {
                Directory.Delete(path, true);
                AppendLog(logPath, "Cleanup: Deleted temp directory: " + path);
            }
        }
        catch (Exception ex)
        {
            AppendLog(logPath, "Cleanup: Temp directory could not be deleted: " + path + ". Windows may remove it later. " + ex.Message);
        }
    }

    private static void ShowError(string message, string title)
    {
        MessageBox.Show(message, title, MessageBoxButtons.OK, MessageBoxIcon.Error);
    }
}
