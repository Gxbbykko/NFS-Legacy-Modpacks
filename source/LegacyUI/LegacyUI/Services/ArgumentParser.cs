using System;
using System.Collections.Generic;

namespace LegacyUI.Services
{
    public class ArgumentParser
    {
        private readonly Dictionary<string, string> _values =
            new(StringComparer.OrdinalIgnoreCase);

        public ArgumentParser(string[] args)
        {
            for (int i = 0; i < args.Length; i++)
            {
                string current = args[i];

                if (!current.StartsWith("--"))
                    continue;

                string key = current[2..];

                if (i + 1 < args.Length &&
                    !args[i + 1].StartsWith("--"))
                {
                    _values[key] = args[i + 1];
                    i++;
                }
                else
                {
                    _values[key] = "true";
                }
            }
        }

        public string Get(string key, string fallback = "")
        {
            return _values.TryGetValue(key, out string? value)
                ? value
                : fallback;
        }
    }
}