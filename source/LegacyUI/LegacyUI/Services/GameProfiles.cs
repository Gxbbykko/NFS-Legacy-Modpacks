using System.Collections.Generic;
using LegacyUI.Models;

namespace LegacyUI.Services
{
    public static class GameProfiles
    {
        public static readonly Dictionary<string, GameProfile> Profiles = new()
        {
            ["nfsu"] = new GameProfile
            {
                GameId = "nfsu",
                Title = "Underground Legacy Modpack",
                BaselineSizeBytes = 1353614450,
                BaselineFileCount = 430,
                InstalledSizeBytes = 4517369780,
                InstalledFileCount = 488,
                ExpectedManifestLines = 318,
                ExpectedInstallSeconds = 75.36,
                ExpectedUninstallSeconds = 22.48,
                RestoredSizeBytes = 1353623458,
                RestoredFileCount = 431
            },

            ["nfsu2"] = new GameProfile
            {
                GameId = "nfsu2",
                Title = "Underground 2 Legacy Modpack",
                BaselineSizeBytes = 1813321965,
                BaselineFileCount = 1231,
                InstalledSizeBytes = 4136504067,
                InstalledFileCount = 1405,
                ExpectedManifestLines = 976,
                ExpectedInstallSeconds = 96.22,
                ExpectedUninstallSeconds = 49.01,
                RestoredSizeBytes = 1813355615,
                RestoredFileCount = 1232
            },

            ["nfsmw"] = new GameProfile
            {
                GameId = "nfsmw",
                Title = "Most Wanted Legacy Modpack",
                BaselineSizeBytes = 3034477366,
                BaselineFileCount = 1384,
                InstalledSizeBytes = 7365143015,
                InstalledFileCount = 2259,
                ExpectedManifestLines = 1644,
                ExpectedInstallSeconds = 138.46,
                ExpectedUninstallSeconds = 72.04,
                RestoredSizeBytes = 3035770963,
                RestoredFileCount = 1390
            },

            ["nfsc"] = new GameProfile
            {
                GameId = "nfsc",
                Title = "Carbon Legacy Modpack",
                BaselineSizeBytes = 5708850182,
                BaselineFileCount = 1292,
                InstalledSizeBytes = 7132741345,
                InstalledFileCount = 1346,
                ExpectedManifestLines = 659,
                ExpectedInstallSeconds = 189.67,
                ExpectedUninstallSeconds = 42.31,
                RestoredSizeBytes = 5708869670,
                RestoredFileCount = 1293
            },

            ["nfsps"] = new GameProfile
            {
                GameId = "nfsps",
                Title = "ProStreet Legacy Modpack",
                BaselineSizeBytes = 8228955849,
                BaselineFileCount = 1977,
                InstalledSizeBytes = 8816695833,
                InstalledFileCount = 2007,
                ExpectedManifestLines = 862,
                ExpectedInstallSeconds = 138.53,
                ExpectedUninstallSeconds = 46.09,
                RestoredSizeBytes = 8228982029,
                RestoredFileCount = 1978
            },

            ["nfsuc"] = new GameProfile
            {
                GameId = "nfsuc",
                Title = "Undercover Legacy Modpack",
                BaselineSizeBytes = 6919532622,
                BaselineFileCount = 1715,
                InstalledSizeBytes = 6941877004,
                InstalledFileCount = 1744,
                ExpectedManifestLines = 57,
                ExpectedInstallSeconds = 35.78,
                ExpectedUninstallSeconds = 13.01,
                RestoredSizeBytes = 6919534583,
                RestoredFileCount = 1716
            }
        };
    }
}