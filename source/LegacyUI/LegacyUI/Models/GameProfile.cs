namespace LegacyUI.Models
{
    public class GameProfile
    {
        public string GameId { get; set; } = string.Empty;
        public string Title { get; set; } = string.Empty;

        public long BaselineSizeBytes { get; set; }
        public int BaselineFileCount { get; set; }

        public long InstalledSizeBytes { get; set; }
        public int InstalledFileCount { get; set; }

        public int ExpectedManifestLines { get; set; }

        public double ExpectedInstallSeconds { get; set; }
        public double ExpectedUninstallSeconds { get; set; }

        public long RestoredSizeBytes { get; set; }
        public int RestoredFileCount { get; set; }
    }
}