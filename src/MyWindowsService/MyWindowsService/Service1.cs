using System;
using System.Collections.Generic;
using System.IO;
using System.ServiceProcess;
using Couchbase;
using Couchbase.Configuration.Client;

namespace MyWindowsService
{
    public partial class Service1 : ServiceBase
    {
        bool firstRun;
        public Service1()
        {
            InitializeComponent();
        }

        protected override void OnStart(string[] args)
        {
            firstRun = true;

            Log(
                LogToCouchbase(new List<string> { "OnStart:", DateTime.Now.ToString() })
            );
        }

        protected override void OnStop()
        {
            Log(
                 LogToCouchbase(new List<string> { "OnStop:", DateTime.Now.ToString() })
             );
        }

        private List<string> Log(List<string> lines)
        {
            try
            {
                File.AppendAllLines("c:\\MyWindowsService.log.txt", lines);
            }
            catch (Exception ex)
            {
                lines.AddRange(
                    new[] {
                        "Excpetion:",
                        ex.Message,
                        ex.StackTrace
                    });
            }

            return lines;
        }

        private List<string> LogToCouchbase(List<string> lines)
        {
            try
            {
                if (firstRun)
                {
                    var config = new ClientConfiguration
                    {
                        Servers = new List<Uri> { new Uri("http://10.0.0.4:8091") }
                    };

                    ClusterHelper.Initialize(config);

                    firstRun = false;
                }

                // this will overwrite any old log lines!
                var result =
                    ClusterHelper
                    .GetBucket("default")
                    .Upsert<dynamic>(
                        "MyWindowsService.log.txt",
                        new
                        {
                            id = "MyWindowsService.log.txt",
                            log = string.Join("\n", lines)
                        }
                    );

                lines.AddRange(
                new[] {
                        "Couchbase result: ",
                        result.Success.ToString(),
                        "Document Key: ",
                        "MyWindowsService.log.txt"
                });
            }
            catch (Exception ex)
            {
                lines.AddRange(
                new[] {
                        "Excpetion:",
                        ex.Message,
                        ex.StackTrace
                });
            }

            return lines;
        }
    }
}