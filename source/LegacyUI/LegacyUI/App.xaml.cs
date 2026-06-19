using System;
using System.IO;
using System.Windows;
using System.Windows.Threading;

namespace LegacyUI
{
    public partial class App : Application
    {
        private bool _isShuttingDown;

        protected override void OnStartup(StartupEventArgs e)
        {
            AppDomain.CurrentDomain.UnhandledException += (_, args) =>
            {
                WriteCrashLog(args.ExceptionObject as Exception);
            };

            DispatcherUnhandledException += (_, args) =>
            {
                WriteCrashLog(args.Exception);

                if (_isShuttingDown || IsBenignShutdownException(args.Exception))
                {
                    args.Handled = true;
                    Shutdown(0);
                    return;
                }

                args.Handled = true;

                MessageBox.Show(
                    "LegacyUI crashed. A crash log was written next to LegacyUI.exe.",
                    "LegacyUI Crash",
                    MessageBoxButton.OK,
                    MessageBoxImage.Error
                );

                Shutdown(1);
            };

            Exit += (_, _) =>
            {
                _isShuttingDown = true;
            };

            base.OnStartup(e);
        }

        protected override void OnExit(ExitEventArgs e)
        {
            _isShuttingDown = true;
            base.OnExit(e);
        }

        private static bool IsBenignShutdownException(Exception ex)
        {
            string text = ex.ToString();

            return text.Contains("System.Diagnostics.Tracing", StringComparison.OrdinalIgnoreCase) ||
                   text.Contains("ControlsTraceLogger", StringComparison.OrdinalIgnoreCase) ||
                   text.Contains("CriticalShutdown", StringComparison.OrdinalIgnoreCase);
        }

        private static void WriteCrashLog(Exception? ex)
        {
            try
            {
                File.WriteAllText(
                    Path.Combine(AppContext.BaseDirectory, "LegacyUI_crash.log"),
                    ex?.ToString() ?? "Unknown exception"
                );
            }
            catch
            {
            }
        }
    }
}