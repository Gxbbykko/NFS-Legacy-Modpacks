using System;
using System.Diagnostics;
using System.IO;
using System.Text;

namespace ArcRunner
{
    internal class Program
    {
        static int Main(string[] args)
        {
            if (args.Length < 4)
            {
                return WriteErrorAndExit(
                    args,
                    "Usage: ArcRunner.exe <arc.exe> <archive.arc> <destination> <logfile>",
                    10
                );
            }

            string arcExe = args[0];
            string archivePath = args[1];
            string destination = args[2];
            string logFile = args[3];

            try
            {
                Directory.CreateDirectory(Path.GetDirectoryName(logFile));

                WriteLog(logFile, "ArcRunner started");
                WriteLog(logFile, "arc.exe: " + arcExe);
                WriteLog(logFile, "archive: " + archivePath);
                WriteLog(logFile, "destination: " + destination);

                if (!File.Exists(arcExe))
                {
                    WriteLog(logFile, "ERROR: arc.exe not found.");
                    return 11;
                }

                if (!File.Exists(archivePath))
                {
                    WriteLog(logFile, "ERROR: archive not found.");
                    return 12;
                }

                Directory.CreateDirectory(destination);

                string parameters =
                    "x " + Quote(archivePath) + " " +
                    "-dp" + Quote(destination) + " " +
                    "* -o+";

                WriteLog(logFile, "Command: " + arcExe + " " + parameters);
                WriteLog(logFile, "--------------------------------------------------");

                ProcessStartInfo psi = new ProcessStartInfo
                {
                    FileName = arcExe,
                    Arguments = parameters,
                    UseShellExecute = false,
                    RedirectStandardOutput = true,
                    RedirectStandardError = true,
                    CreateNoWindow = true,
                    StandardOutputEncoding = Encoding.Default,
                    StandardErrorEncoding = Encoding.Default
                };

                using (Process process = new Process())
                {
                    process.StartInfo = psi;

                    process.OutputDataReceived += (sender, e) =>
                    {
                        if (!string.IsNullOrEmpty(e.Data))
                            WriteLog(logFile, e.Data);
                    };

                    process.ErrorDataReceived += (sender, e) =>
                    {
                        if (!string.IsNullOrEmpty(e.Data))
                            WriteLog(logFile, "ERR: " + e.Data);
                    };

                    process.Start();
                    process.BeginOutputReadLine();
                    process.BeginErrorReadLine();
                    process.WaitForExit();

                    // force stream cleanup
                    process.CancelOutputRead();
                    process.CancelErrorRead();

                    int exitCode = process.ExitCode;

                    WriteLog(logFile, "--------------------------------------------------");
                    WriteLog(logFile, "arc.exe exit code: " + exitCode);

                    return exitCode;
                }
            }
            catch (Exception ex)
            {
                try
                {
                    WriteLog(logFile, "FATAL: " + ex.ToString());
                }
                catch { }

                return 99;
            }
        }

        private static string Quote(string value)
        {
            return "\"" + value + "\"";
        }

        private static void WriteLog(string logFile, string text)
        {
            using (var fs = new FileStream(logFile, FileMode.Append, FileAccess.Write, FileShare.ReadWrite))
            using (var sw = new StreamWriter(fs, Encoding.UTF8))
            {
                sw.WriteLine("[" + DateTime.Now.ToString("HH:mm:ss") + "] " + text);
                sw.Flush();
            }
        }

        private static int WriteErrorAndExit(string[] args, string message, int code)
        {
            try
            {
                if (args.Length >= 4)
                {
                    WriteLog(args[3], "ERROR: " + message);
                }
            }
            catch { }

            return code;
        }
    }
}