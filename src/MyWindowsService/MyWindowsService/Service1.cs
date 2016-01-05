using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.ServiceProcess;
using System.Text;
using System.Threading.Tasks;

namespace MyWindowsService
{
    public partial class Service1 : ServiceBase
    {
        public Service1()
        {
            InitializeComponent();
        }

        protected override void OnStart(string[] args)
        {
            Log(new[] { "OnStart:", DateTime.Now.ToString()} );
        }

        protected override void OnStop()
        {
            Log(new[] { "OnStop:", DateTime.Now.ToString() });
        }

        private void Log(IEnumerable<string> lines)
        {
            try
            {
                File.AppendAllLines("c:\\MyWindowsService.log.txt", lines);
            }
            catch { }
        }
    }
}
