using System;
using System.IO;

namespace LegacyUI.Services
{
    public static class GameDetector
    {
        public static string Detect(string targetPath)
        {
            if (string.IsNullOrWhiteSpace(targetPath) || !Directory.Exists(targetPath))
                return "nfsu";

            bool HasFile(string relativePath)
            {
                return File.Exists(Path.Combine(targetPath, relativePath));
            }

            bool HasDir(string relativePath)
            {
                return Directory.Exists(Path.Combine(targetPath, relativePath));
            }

            long FileSize(string relativePath)
            {
                string fullPath = Path.Combine(targetPath, relativePath);

                if (!File.Exists(fullPath))
                    return -1;

                return new FileInfo(fullPath).Length;
            }

            // Underground 2
            if (HasFile("SPEED2.EXE") || HasFile("speed2.exe"))
                return "nfsu2";

            // Carbon
            if (HasFile("NFSC.exe") || HasFile("nfsc.exe"))
                return "nfsc";

            // Underground
            if ((HasFile("Speed.exe") || HasFile("speed.exe")) &&
                HasDir("Cars") &&
                HasDir("FrontEnd") &&
                HasDir("Tracks") &&
                HasFile(@"Languages\LANGUAGE_ENGLISH.bin"))
                return "nfsu";

            // Most Wanted
            if ((HasFile("speed.exe") || HasFile("Speed.exe")) &&
                HasDir("CARS") &&
                HasDir("GLOBAL") &&
                HasFile(@"GLOBAL\GlobalB.lzc"))
                return "nfsmw";

            // ProStreet / Undercover both use nfs.exe.
            // They are separated by executable size.
            long nfsExeSize = FileSize("nfs.exe");

            if (nfsExeSize < 0)
                nfsExeSize = FileSize("NFS.exe");

            // Undercover patched executable
            if (nfsExeSize == 10589456)
                return "nfsuc";

            // ProStreet executable
            if (nfsExeSize == 28739656)
                return "nfsps";

            // Safer fallback for nfs.exe-based games.
            // If the executable is very large, assume ProStreet.
            if (nfsExeSize > 20000000)
                return "nfsps";

            // If the executable is around 10 MB, assume Undercover.
            if (nfsExeSize > 9000000 && nfsExeSize < 12000000)
                return "nfsuc";

            // fallback
            return "nfsu";
        }
    }
}