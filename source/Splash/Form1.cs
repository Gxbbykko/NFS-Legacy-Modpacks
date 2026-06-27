using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Text;
using System.IO;
using System.Linq;
using System.Windows.Forms;

namespace Splash
{
    public partial class Form1 : Form
    {
        private const int DefaultCloseMilliseconds = 1800;
        private const int StatusPollMilliseconds = 400;
        private const int AnimationFrames = 4;

        private Timer closeTimer;
        private Timer statusTimer;
        private bool launcherMode;
        private bool isClosing;
        private int animationFrame;
        private string imagePath;
        private string statusFilePath;
        private string statusText = "Preparing installer files...";
        private string lastRenderedStatusText = string.Empty;
        private int lastRenderedAnimationFrame = -1;
        private Bitmap originalSplashImage;

        public Form1()
            : this(Environment.GetCommandLineArgs().Skip(1).ToArray())
        {
        }

        public Form1(string[] args)
        {
            InitializeComponent();

            SetStyle(
                ControlStyles.AllPaintingInWmPaint |
                ControlStyles.UserPaint |
                ControlStyles.OptimizedDoubleBuffer,
                true);

            UpdateStyles();
            ParseArguments(args ?? Array.Empty<string>());
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            try
            {
                LoadSplashImage();
                ConfigureWindow();

                if (launcherMode)
                    StartLauncherStatusMode();
                else
                    StartAutoCloseMode();
            }
            catch
            {
                CloseSafely();
            }
        }

        private void ParseArguments(string[] args)
        {
            for (int i = 0; i < args.Length; i++)
            {
                string arg = args[i].Trim();

                if (IsLauncherModeArgument(arg))
                {
                    launcherMode = true;
                    continue;
                }

                if (arg.Equals("/image", StringComparison.OrdinalIgnoreCase) && i + 1 < args.Length)
                {
                    imagePath = args[++i];
                    continue;
                }

                if (arg.Equals("/status", StringComparison.OrdinalIgnoreCase) && i + 1 < args.Length)
                {
                    statusFilePath = args[++i];
                    continue;
                }

                if (arg.Equals("/text", StringComparison.OrdinalIgnoreCase) && i + 1 < args.Length)
                {
                    statusText = args[++i];
                    continue;
                }

                if (string.IsNullOrWhiteSpace(imagePath) && File.Exists(arg))
                    imagePath = arg;
            }

            if (string.IsNullOrWhiteSpace(imagePath))
                imagePath = Path.Combine(Application.StartupPath, "splash.png");
        }

        private static bool IsLauncherModeArgument(string arg)
        {
            return arg.Equals("/launcher", StringComparison.OrdinalIgnoreCase) ||
                   arg.Equals("/bootstrap", StringComparison.OrdinalIgnoreCase) ||
                   arg.Equals("-launcher", StringComparison.OrdinalIgnoreCase) ||
                   arg.Equals("-bootstrap", StringComparison.OrdinalIgnoreCase);
        }

        private void LoadSplashImage()
        {
            if (File.Exists(imagePath))
            {
                using (var loadedImage = Image.FromFile(imagePath))
                {
                    originalSplashImage = new Bitmap(loadedImage);
                    pictureBox1.Image = new Bitmap(originalSplashImage);
                }

                ClientSize = pictureBox1.Image.Size;
            }
            else
            {
                ClientSize = new Size(600, 340);
                originalSplashImage = CreateFallbackImage(ClientSize);
                pictureBox1.Image = new Bitmap(originalSplashImage);
            }

            pictureBox1.Dock = DockStyle.Fill;
            pictureBox1.SizeMode = PictureBoxSizeMode.StretchImage;
        }

        private void ConfigureWindow()
        {
            StartPosition = FormStartPosition.Manual;
            Rectangle workingArea = Screen.PrimaryScreen.WorkingArea;
            Left = workingArea.Left + (workingArea.Width - Width) / 2;
            Top = workingArea.Top + (workingArea.Height - Height) / 2;
        }

        private void StartAutoCloseMode()
        {
            closeTimer = new Timer();
            closeTimer.Interval = DefaultCloseMilliseconds;
            closeTimer.Tick += CloseTimer_Tick;
            closeTimer.Start();
        }

        private void StartLauncherStatusMode()
        {
            UpdateStatusFromFile();
            RenderLauncherOverlay(forceRender: true);

            statusTimer = new Timer();
            statusTimer.Interval = StatusPollMilliseconds;
            statusTimer.Tick += StatusTimer_Tick;
            statusTimer.Start();
        }

        private void StatusTimer_Tick(object sender, EventArgs e)
        {
            UpdateStatusFromFile();
            animationFrame = (animationFrame + 1) % AnimationFrames;
            RenderLauncherOverlay(forceRender: false);
        }

        private void UpdateStatusFromFile()
        {
            try
            {
                if (!string.IsNullOrWhiteSpace(statusFilePath) && File.Exists(statusFilePath))
                {
                    string text = File.ReadAllText(statusFilePath).Trim();

                    if (!string.IsNullOrWhiteSpace(text))
                        statusText = NormalizeStatusText(text);
                }
            }
            catch
            {
                // Splash must never block the launcher.
            }
        }

        private static string NormalizeStatusText(string text)
        {
            return text
                .Replace("\r\n", " ")
                .Replace("\n", " ")
                .Replace("\r", " ")
                .Trim();
        }

        private void RenderLauncherOverlay(bool forceRender)
        {
            if (originalSplashImage == null)
                return;

            if (!forceRender &&
                StringEquals(lastRenderedStatusText, statusText) &&
                lastRenderedAnimationFrame == animationFrame)
            {
                return;
            }

            try
            {
                Bitmap renderedImage = new Bitmap(originalSplashImage);

                using (Graphics g = Graphics.FromImage(renderedImage))
                {
                    g.SmoothingMode = SmoothingMode.AntiAlias;
                    g.InterpolationMode = InterpolationMode.HighQualityBicubic;
                    g.TextRenderingHint = TextRenderingHint.ClearTypeGridFit;

                    int width = renderedImage.Width;
                    int height = renderedImage.Height;
                    int panelHeight = Math.Max(92, height / 4);
                    Rectangle panel = new Rectangle(0, height - panelHeight, width, panelHeight);

                    using (LinearGradientBrush overlay = new LinearGradientBrush(
                        panel,
                        Color.FromArgb(40, 0, 0, 0),
                        Color.FromArgb(215, 0, 0, 0),
                        LinearGradientMode.Vertical))
                    {
                        g.FillRectangle(overlay, panel);
                    }

                    using (Pen topLine = new Pen(Color.FromArgb(115, 255, 255, 255), 1f))
                    {
                        g.DrawLine(topLine, 0, panel.Top, width, panel.Top);
                    }

                    DrawProgressDots(g, panel, width);
                    DrawBootstrapText(g, panel, width);
                }

                Image oldImage = pictureBox1.Image;
                pictureBox1.Image = renderedImage;

                if (oldImage != null)
                    oldImage.Dispose();

                lastRenderedStatusText = statusText;
                lastRenderedAnimationFrame = animationFrame;
            }
            catch
            {
                // Splash must never block the launcher.
            }
        }

        private void DrawBootstrapText(Graphics g, Rectangle panel, int width)
        {
            int margin = Math.Max(22, width / 30);
            int titleHeight = Math.Max(28, panel.Height / 3);
            int statusHeight = Math.Max(24, panel.Height / 3);
            int noteHeight = Math.Max(18, panel.Height / 5);

            Rectangle titleRect = new Rectangle(margin, panel.Top + 12, width - (margin * 2), titleHeight);
            Rectangle statusRect = new Rectangle(margin, titleRect.Bottom + 2, width - (margin * 2), statusHeight);
            Rectangle noteRect = new Rectangle(margin, statusRect.Bottom + 2, width - (margin * 2), noteHeight);

            using (Font titleFont = new Font("Segoe UI", Math.Max(15, width / 38), FontStyle.Bold, GraphicsUnit.Pixel))
            using (Font statusFont = new Font("Segoe UI", Math.Max(12, width / 50), FontStyle.Regular, GraphicsUnit.Pixel))
            using (Font noteFont = new Font("Segoe UI", Math.Max(10, width / 64), FontStyle.Regular, GraphicsUnit.Pixel))
            using (Brush white = new SolidBrush(Color.White))
            using (Brush soft = new SolidBrush(Color.FromArgb(230, 230, 230)))
            using (Brush muted = new SolidBrush(Color.FromArgb(185, 185, 185)))
            using (StringFormat center = new StringFormat { Alignment = StringAlignment.Center, LineAlignment = StringAlignment.Center, Trimming = StringTrimming.EllipsisCharacter })
            {
                g.DrawString("Preparing Legacy Modpack Installer", titleFont, white, titleRect, center);
                g.DrawString(statusText, statusFont, soft, statusRect, center);
                g.DrawString("Please wait. Temporary launcher files will be cleaned automatically.", noteFont, muted, noteRect, center);
            }
        }

        private void DrawProgressDots(Graphics g, Rectangle panel, int width)
        {
            int dotCount = 4;
            int dotSize = Math.Max(5, width / 160);
            int spacing = dotSize * 3;
            int totalWidth = (dotCount * dotSize) + ((dotCount - 1) * spacing);
            int startX = (width - totalWidth) / 2;
            int y = panel.Bottom - Math.Max(18, panel.Height / 7);

            for (int i = 0; i < dotCount; i++)
            {
                int alpha = i == animationFrame ? 255 : 85;

                using (Brush brush = new SolidBrush(Color.FromArgb(alpha, 255, 255, 255)))
                {
                    g.FillEllipse(brush, startX + (i * (dotSize + spacing)), y, dotSize, dotSize);
                }
            }
        }

        private static Bitmap CreateFallbackImage(Size size)
        {
            Bitmap bitmap = new Bitmap(size.Width, size.Height);

            using (Graphics g = Graphics.FromImage(bitmap))
            {
                using (LinearGradientBrush background = new LinearGradientBrush(
                    new Rectangle(Point.Empty, size),
                    Color.FromArgb(8, 8, 8),
                    Color.FromArgb(28, 28, 28),
                    LinearGradientMode.Vertical))
                {
                    g.FillRectangle(background, new Rectangle(Point.Empty, size));
                }

                using (Font titleFont = new Font("Segoe UI", 26, FontStyle.Bold, GraphicsUnit.Pixel))
                using (Font subFont = new Font("Segoe UI", 13, FontStyle.Regular, GraphicsUnit.Pixel))
                using (Brush white = new SolidBrush(Color.White))
                using (Brush soft = new SolidBrush(Color.FromArgb(210, 210, 210)))
                using (StringFormat center = new StringFormat { Alignment = StringAlignment.Center, LineAlignment = StringAlignment.Center })
                {
                    Rectangle titleRect = new Rectangle(20, 0, size.Width - 40, size.Height / 2);
                    Rectangle subRect = new Rectangle(20, size.Height / 2 - 20, size.Width - 40, size.Height / 2);
                    g.DrawString("NFS Legacy Modpacks", titleFont, white, titleRect, center);
                    g.DrawString("Preparing installer...", subFont, soft, subRect, center);
                }
            }

            return bitmap;
        }

        private void CloseTimer_Tick(object sender, EventArgs e)
        {
            CloseSafely();
        }

        private void CloseSafely()
        {
            if (isClosing)
                return;

            isClosing = true;

            try
            {
                if (closeTimer != null)
                {
                    closeTimer.Stop();
                    closeTimer.Dispose();
                    closeTimer = null;
                }

                if (statusTimer != null)
                {
                    statusTimer.Stop();
                    statusTimer.Dispose();
                    statusTimer = null;
                }

                if (pictureBox1.Image != null)
                {
                    pictureBox1.Image.Dispose();
                    pictureBox1.Image = null;
                }

                if (originalSplashImage != null)
                {
                    originalSplashImage.Dispose();
                    originalSplashImage = null;
                }
            }
            catch
            {
                // Ignore cleanup errors.
            }

            Close();
        }

        protected override void OnFormClosing(FormClosingEventArgs e)
        {
            try
            {
                if (!isClosing)
                {
                    isClosing = true;

                    if (closeTimer != null)
                    {
                        closeTimer.Stop();
                        closeTimer.Dispose();
                        closeTimer = null;
                    }

                    if (statusTimer != null)
                    {
                        statusTimer.Stop();
                        statusTimer.Dispose();
                        statusTimer = null;
                    }

                    if (pictureBox1.Image != null)
                    {
                        pictureBox1.Image.Dispose();
                        pictureBox1.Image = null;
                    }

                    if (originalSplashImage != null)
                    {
                        originalSplashImage.Dispose();
                        originalSplashImage = null;
                    }
                }
            }
            catch
            {
                // Ignore cleanup errors.
            }

            base.OnFormClosing(e);
        }

        private static bool StringEquals(string left, string right)
        {
            return string.Equals(left ?? string.Empty, right ?? string.Empty, StringComparison.Ordinal);
        }
    }
}
