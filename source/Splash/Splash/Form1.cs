using System;
using System.Drawing;
using System.IO;
using System.Windows.Forms;

namespace Splash
{
    public partial class Form1 : Form
    {
        private Timer closeTimer;

        public Form1()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            try
            {
                string imagePath;

                // If Inno passes a path
                if (Environment.GetCommandLineArgs().Length > 1)
                {
                    imagePath = Environment.GetCommandLineArgs()[1];
                }
                else
                {
                    // fallback for testing inside Visual Studio
                    imagePath = Path.Combine(Application.StartupPath, "splash.png");
                }

                if (File.Exists(imagePath))
                {
                    pictureBox1.Image = Image.FromFile(imagePath);

                    // resize form to image automatically
                    this.ClientSize = pictureBox1.Image.Size;

                    // force picturebox to fill form
                    pictureBox1.Dock = DockStyle.Fill;
                    pictureBox1.SizeMode = PictureBoxSizeMode.StretchImage;

                    // center after resizing
                    this.StartPosition = FormStartPosition.Manual;
                    this.Left = (Screen.PrimaryScreen.Bounds.Width - this.Width) / 2;
                    this.Top = (Screen.PrimaryScreen.Bounds.Height - this.Height) / 2;
                }

                // auto close timer
                closeTimer = new Timer();
                closeTimer.Interval = 1800; // 1.8 sec
                closeTimer.Tick += CloseTimer_Tick;
                closeTimer.Start();
            }
            catch
            {
                this.Close();
            }
        }

        private void CloseTimer_Tick(object sender, EventArgs e)
        {
            closeTimer.Stop();
            this.Close();
        }
    }
}