NameAutoClean	:HealthReport
Version			:2.0.0.1
Intention 		:Monitors the server for high memory and CPU use, creates a server health report if targeted usage is reached
OS				:Windows 2008 Above
Requirements	:OS, Administrive account, PowerShellBaselines [Files]HealthScript.ps1,MonitorScript.ps1,ExecutionMonitorScript.bat,FolderCleanup.ps1
Runtime			:TaskScheduler
Comments		:Batch job runs on task scheduler to kick off the folder cleanup script and monitor script (Explained below) at time x. It should stop the task after 1 day 
				If the task scheduler does not stop the task, the task will continue running indefinitley.

				FolderCleanupV1.0.0.0 Cleans up the reports generated if they exceed the specified days (default 30) or the amount (default 1000) or the folder size (default 100mb)
				MonitorScriptV1.0.0.1 Monitors the Total CPU and memory usage. If any exceed the specified values (default cpu 70%, Memory 90%) the health script will begin
				HealthScriptV2.0.0.2 This script uses WMi to collect a number of usagestats and information about the current server, storing it in an html file for troubleshooting