using System;
using System.Collections.Generic;
using System.IO;

namespace LegacyUI.Services
{
    public class LegacyStateReader
    {
        private readonly string _statePath;

        public LegacyStateReader(string statePath)
        {
            _statePath = statePath;
        }

        public LegacyState Read()
        {
            var state = new LegacyState();

            if (string.IsNullOrWhiteSpace(_statePath) || !File.Exists(_statePath))
                return state;

            try
            {
                foreach (string line in File.ReadAllLines(_statePath))
                {
                    if (string.IsNullOrWhiteSpace(line) || !line.Contains('='))
                        continue;

                    string[] parts = line.Split('=', 2);
                    string key = parts[0].Trim();
                    string value = parts[1].Trim();

                    if (key.Equals("phase", StringComparison.OrdinalIgnoreCase))
                        state.Phase = value;

                    if (key.Equals("progress", StringComparison.OrdinalIgnoreCase) &&
                        double.TryParse(value, out double progress))
                        state.Progress = progress;

                    if (key.Equals("message", StringComparison.OrdinalIgnoreCase))
                        state.Message = value;
                }
            }
            catch
            {
                // Ignore temporary read/write collisions while Inno updates the file.
            }

            return state;
        }
    }

    public class LegacyState
    {
        public string Phase { get; set; } = "";
        public double Progress { get; set; } = -1;
        public string Message { get; set; } = "";

        public bool IsComplete =>
            Phase.Equals("complete", StringComparison.OrdinalIgnoreCase);

        public bool IsError =>
            Phase.Equals("error", StringComparison.OrdinalIgnoreCase);
    }
}