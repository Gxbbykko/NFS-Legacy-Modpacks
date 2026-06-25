namespace LegacyUI.Services
{
    public sealed class OptionalFeatureService
    {
        private readonly string _gameId;

        public OptionalFeatureService(string gameId)
        {
            _gameId = (gameId ?? "").Trim().ToLowerInvariant();
        }

        public bool HasMoviesPatchOption()
        {
            return _gameId == "nfsuc";
        }

        public string GetMoviesCommandValue(bool isChecked)
        {
            if (!HasMoviesPatchOption())
                return "none";

            return isChecked ? "filteroff" : "none";
        }
    }
}