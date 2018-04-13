<# 
.Synopsis
	Health check Script with low CPU usage
.DESCRIPTION
   This Script runs at minimal CPU usage and checks the following

   -ComputerInformation => General information
   -Disk 		=> Space alerts on low space
   -Services 	=> Alerts on Problematic
   -Processes	=> Top 10 by CPU
   -Memory		=> Top 10 by working set
   -Pathces		=> Last 7 days installed
   -Logs		=> Last 10 Error,Warning,and audit failures form all logs
.Parameter
.Inputs
	n/a
.Outputs
	This file will generate output from the directory it is run in form of an html file
.Example
    n/a
.Notes
    TROUBLESHOOTING
	Running this script requires you to have the following
	1) Powershell Script Execution
		a) (run powershell as admin) Set-ExecutionPolicy bypass -force
			OR
		b)(run powershell as admin) Set-ExecutionPolicy unrestricted -force
	2) You will need access rights to view the System log
	3) When downloading this file from the internet you may need to unblock this file
		a) On the physical file right click, on the bottom of the file clock unblock then ok
    4) [NOTE] This script auto-elevates iteself

	CREATOR
	Created by 	: Henry Stock
	Version 	: V2.0.0.2
	Authorised	: Henry Stock
	OS			: Windows
	PS Version	: All
.Link
	

#>


#Elevate to Admin 
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

#Set Process to Below Normal for CPU Use
Function fncSetLow
{
    param([string]$objProcName,[string]$priority)
   #$objprocName = "*powershell*"
   #$priority="Normal"
   (Get-Process| where {$_.name -like $objProcName}).PriorityClass = $priority
}

fncSetLow "*powershell*" "BelowNormal"


#Declaration of Variables
$objFormattedDate=get-date -f "dd-MM-yyyy HH:mm:ss"
$objTxtDate=get-date -f "ddMMyyyHHmmss"
$objHotfixDate = (get-date).AddDays(-7) #.ToString('dd/MM/yy HH:mm:ss tt')
$objHost=$env:computername
$objHTML=$null


#Start of HTML Document format
$objHTML=	"<html>"
$objHTML+=	"<head>"
$objHTML+=	"<Title><h1>" + $objHost + "</h1></Title>"
$objHTML+=	"<Style>"
$objHTML+=	" table{  border: 1px solid black;}`
			 td {  border-bottom: 1px solid #ddd;text-align: left;font-size:12}`
			 .label {  border-bottom: 1px solid #ddd;text-align: left;font-weight: bold;color:blue;font-size:18}`
			 th {  border-bottom: 1px solid #ddd;text-align: left;font-size:15;}`
"
$objHTML+=	"</Style>"
$objHTML+=	"</head>"
$objHTML+=	"<body>"
$objHTML+=	"<h1><b>"+ $objHost+"_"+$objFormattedDate+"</h1></b><th>"






###################################################################################### SECTION::Operation System Information

#Get Wmi Information into Array
$objOsInfo = gwmi -class Win32_OperatingSystem

#Set the Table and first header
$objHTML+=	"<table width=100%>"
$objHTML+= "<tr> <br> </tr>" 
$objHTML+= "<tr>"
$objHTML+= "<th class=""label""> Computer Information  </th>"
$objHTML+= "</tr>"

#Begin the information dump
$objHTML+=	"<tr><td><b> Caption </b></td>"
$objHTML+=	"<td>" + $objOsInfo.Caption + "</td></tr>"
$objHTML+=	"<tr><td><b> Service Pack </b></td>"
$objHTML+=	"<td" + $objOsInfo.CSDVersion + "</td></tr>"
$objHTML+=	"<tr><td><b> Architecture </b></td>"
$objHTML+=	"<td>" + $objOsInfo.OSArchitecture + "</td></tr>"
$objHTML+=	"<tr><td ><b> WindowsDirectory </b></td>"
$objHTML+=	"<td>" + $objOsInfo.WindowsDirectory + "</td></tr>"
$objHTML+=	"<tr><td colspan=1><b> NumberOfProcesses </b></td>"
$objHTML+=	"<td colspan=1>" + $objOsInfo.NumberOfProcesses + "</td></tr>"
$objHTML+=	"<tr><td><b> TotalVisibleMemorySize </b></td>"
$objHTML+=	"<td>" + [math]::Round($objOsInfo.TotalVisibleMemorySize/1024/1024,2) + "GB</td></tr>"
$objHTML+=	"<tr><td><b> FreePhysicalMemory </b></td>"
$objHTML+=	"<td>" + [math]::Round($objOsInfo.FreePhysicalMemory/1024/1024,2) + "GB</td></tr>"
$objHTML+=	"<tr><td><b> TotalVirtualMemorySize </b></td>"
$objHTML+=	"<td>" + [math]::Round($objOsInfo.TotalVirtualMemorySize/1024/1024) + "GB</td></tr>"
$objHTML+=	"<tr><td><b> FreeVirtualMemory </b></td>"
$objHTML+=	"<td>" + [math]::Round($objOsInfo.FreeVirtualMemory/1024/1024,2) + "GB</td></tr>"
$objHTML+=	"<tr><td><b> InstallDate </b></td>"
$objHTML+=	"<td>" + $objOsInfo.InstallDate.substring(0,8) + "</td></tr>"
$objHTML+=	"<tr><td><b> LastBootUpTime </b></td>"
$objHTML+=	"<td>" + $objOsInfo.LastBootUpTime.substring(0,4) +"-"+ $objOsInfo.LastBootUpTime.substring(4,2) +"-"+ `
$objOsInfo.LastBootUpTime.substring(6,2) +" "+ $objOsInfo.LastBootUpTime.substring(8,2) +":"+ $objOsInfo.LastBootUpTime.substring(10,2) +":"+$objOsInfo.LastBootUpTime.substring(12,2) + "</td></tr>"
$objHTML+=	"</table>"
#End Of Operating System Information

#Returned visible memory for later calculation
$objvisiblemem = $objOsInfo.TotalVisibleMemorySize

$objOsInfo=$null



###################################################################################### SECTION::Last Reboot

#Get Wmi Information into Array
$arrShutdownEventlog = Get-EventLog -LogName System -EntryType Information -InstanceId 2147484722 | sort-object $_.Time -descending

#Set the Table and first header
$objHTML+=	"<table width=100%>"
$objHTML+= "<tr> <br> </tr>" 
$objHTML+= "<tr>"
$objHTML+= "<th class=""label""> Last Shutdown Events (7 Days) </th>"
$objHTML+= "</tr>"

#Set Headers
$objHTML+= "<tr>"
$objHTML+= "<th><b> InstanceID  </b></th>"
$objHTML+= "<th><b> Time  </b></th>"
$objHTML+= "<th><b> Source  </b></th>"
$objHTML+= "<th><b> Message  </b></th>"
$objHTML+= "</tr>"

#Loop for each item in Array
Foreach ( $objShutdownEvent in $arrShutdownEventlog)
{
	$objHTML+=	"<tr>"
	$objHTML+=	"<td>" +	$objShutdownEvent.EventID		+ "</td>"
	$objHTML+=	"<td>" +	$objShutdownEvent.InstanceID	+ "</td>"
	$objHTML+=	"<td>" +	$objShutdownEvent.Time			+ "</td>"
	$objHTML+=	"<td>" +	$objShutdownEvent.Source		+ "</td>"
	$objHTML+=	"<td>" +	$objShutdownEvent.Message		+ "</td>"
	$objHTML+=	"</tr>"
	$objHTML+=	"</tr>"
}
$objHTML+=	"</table>"
#END Logical Disk Information

$arrShutdownEventlog =$null


###################################################################################### SECTION::Disks

#Get Wmi Information into Array
$objDiskInfo = gwmi -Query "Select * from Win32_LogicalDisk where DriveType = '3'"


#Set the Table and first header
$objHTML+=	"<table width=100%>"
$objHTML+= "<tr> <br> </tr>" 
$objHTML+= "<tr>"
$objHTML+= "<th class=""label""> Disk Information  </th>"
$objHTML+= "</tr>"

#Set Headers
$objHTML+= "<tr>"
$objHTML+= "<th><b> Disk  </b></th>"
$objHTML+= "<th><b> Description  </b></th>"
$objHTML+= "<th><b> Size  </b></th>"
$objHTML+= "<th><b> FreeSpace  </b></th>"
$objHTML+= "<th><b> % Free  </b></th>"

#Loop for each item in Array
Foreach ( $objDisk in $objDiskInfo)
{
	#Check if Disk is low on space, if yes, mark font as red
	IF($objDisk.FreeSpace/1024/1024/1024 -le 10 )
	{
		$objHTML+=	"<tr style=""color:red"">"
	}
	Else 
	{
		$objHTML+=	"<tr>"
	}
	
	#Dump information
	$objHTML+=	"<td>" +	$objDisk.DeviceID				 	+ "</td>"
	$objHTML+=	"<td>" +	$objDisk.VolumeName					+ "</td>"
	$objHTML+=	"<td>" +	[math]::Round($objDisk.Size/1024/1024/1024,2)		+ "GB</td>"
	$objHTML+=	"<td>" +	[math]::Round($objDisk.FreeSpace/1024/1024/1024,2)	+ "GB</td>"
    $objHTML+=	"<td>" +	[math]::Round($objDisk.FreeSpace/$objDisk.Size*100,2)	+ "%</td>"
	$objHTML+=	"</tr>"
}
$objHTML+=	"</table>"
#END Logical Disk Information


$objDiskInfo =$null



###################################################################################### SECTION::Services

#Get Wmi Information into Array
$objServiceInfo = gwmi -Query "Select * from win32_service" 


#Set the Table and first header
$objHTML+=	"<table width=100%>"
$objHTML+= "<tr> <br> </tr>" 
$objHTML+= "<tr>"
$objHTML+= "<th class=""label""> Problematic Services  </th>"
$objHTML+= "</tr>"

#Set Headers
$objHTML+= "<tr>"
$objHTML+= "<th><b> Name  </b></th>"
$objHTML+= "<th><b> DisplayName  </b></th>"
$objHTML+= "<th><b> StartMode  </b></th>"
$objHTML+= "<th><b> State  </b></th>"
$objHTML+= "<th><b> ProcessId  </b></th>"
$objHTML+= "<th><b> Path  </b></th>"

#Loop for each item in Array
Foreach ( $objService in $objServiceInfo)
{
	#Check if Disk is low on space, if yes, mark font as red
	IF( ($objService.StartMode -eq "Auto" -or  $objService.StartMode -like "*Delayd*") -and $objService.State -ne "Running"  )
	{
		$objHTML+=	"<tr style=""color:red"">"
			
			#Move this content below the else statement to print all info
			$objHTML+=	"<td>" +	$objService.Name				 	+ "</td>"
			$objHTML+=	"<td>" +	$objService.DisplayName				+ "</td>"
			$objHTML+=	"<td>" +	$objService.StartMode				+ "</td>"
			$objHTML+=	"<td>" +	$objService.State					+ "</td>"
			$objHTML+=	"<td>" +	$objService.ProcessId				+ "</td>"
			$objHTML+=	"<td>" +	$objService.PathName				+ "</td>"
			$objHTML+=	"</tr>"
	}
	Else 
	{
		#Do Nothing.Remove below hash and follow above steps to print everything
		#$objHTML+=	"<tr>"
	}
	

}
$objHTML+=	"</table>"
#END Services Information



$objServiceInfo =$null


###################################################################################### SECTION::Processe=>Top CPU

#Get Wmi Information into Array
$objTopProcessCPU = get-wmiobject Win32_PerfFormattedData_PerfProc_Process | Sort-Object percentprocessortime  -desc|select -first 10


#Get Total CPU Load for Table Header
$objCpu = Get-WmiObject win32_processor

#Array of CPU's and Loads
$CPULoad = 0
$arrCpuLoad =  $objCpu.loadpercentage

#Loop for each CPU load recieved and select the highest one
foreach($objitemcpu in $arrCpuLoad)
{
    if($objitemcpu -ge $CPULoad)
    {
        write-host $objitemcpu
        [int]$CPULoad = $objitemcpu
    }
}
[int]$objCpuLoadPerc =  100 - $objCPULoad

#Set the Table and first header
$objHTML+=	"<table width=100%>"
$objHTML+= "<tr> <br> </tr>" 
$objHTML+= "<tr>"
$objHTML+= "<th class=""label""> Top 10 Processes by CPU </th>"
$objHTML+= "</tr>"
$objHTML+= "<td><b>" + $CPULoad + "% USED | "+ $objCpuLoadPerc +" % FREE </b> <br> </td>"
$objHTML+= "</tr>"

#Set Headers
$objHTML+= "<tr>"
$objHTML+= "<th><b> ProcessName  </b></th>"
$objHTML+= "<th><b> ProcessID  </b></th>"
$objHTML+= "<th><b> CPU-Use%  </b></th>"
$objHTML+= "<th><b> Priority  </b></th>"
$objHTML+= "<th><b> HandleCount  </b></th>"
$objHTML+= "<th><b> ThreadCount  </b></th>"

#Loop for each item in Array
Foreach ( $objProc in $objTopProcessCPU)
{
	$objHTML+=	"<tr>"
	$objHTML+=	"<td>" +	$objProc.Name				+ "</td>"
	$objHTML+=	"<td>" +	$objProc.IDProcess			+ "</td>"
	$objHTML+=	"<td>" +	$objProc.PercentProcessorTime		+ "</td>"
	$objHTML+=	"<td>" +	$objProc.PriorityBase		+ "</td>"
	$objHTML+=	"<td>" +	$objProc.HandleCount		+ "</td>"
	$objHTML+=	"<td>" +	$objProc.ThreadCount		+ "</td>"
	$objHTML+=	"</tr>"

}
$objHTML+=	"</table>"
#END SProcess Information -> CPU


$objTopProcessCPU=$null


###################################################################################### SECTION::Processe=>Top Memory

#Get Wmi Information into Array
$objTopProcessMem = get-wmiobject WIN32_PROCESS | Sort-Object -Property ws -Descending|select -first 10


#Get total Memory useage for Table Header
$objMemLoad = [math]::round((get-process | Measure-Object workingset -sum).sum /1gb,2)
[int]$objPercMemUsed = [math]::round($objMemLoad/($objvisiblemem/1024/1024)*100,2)
$objMemLeftMB = [MATH]::Round(($objvisiblemem/1024/1024)-$objMemLoad,2)
$objMemLeftPerc = 100 - $objPercMemUsed

#Set the Table and first header
$objHTML+=	"<table width=100%>"
$objHTML+= "<tr> <br> </tr>" 
$objHTML+= "<tr>"
$objHTML+= "<th class=""label""> Top 10 Processes by Memory  </th>"
$objHTML+= "</tr>"
$objHTML+= "<td><b>"+ $objMemLoad + " Gb ( " + $objPercMemUsed + " %) USED | " + $objMemLeftGB + " GB (" + $objMemLeftPerc + " %) FREE</b> <br> </td>"
$objHTML+= "</tr>"





#Set Headers
$objHTML+= "<tr>"
$objHTML+= "<th><b> ProcessName  </b></th>"
$objHTML+= "<th><b> ProcessID  </b></th>"
$objHTML+= "<th><b> User  </b></th>"
$objHTML+= "<th><b> WorkingSet(mb)  </b></th>"
$objHTML+= "<th><b> VirtualMemory(mb)  </b></th>"
$objHTML+= "<th><b> PageFile(mb)  </b></th>"

#Loop for each item in Array
Foreach ( $objProc in $objTopProcessMem)
{
	$objHTML+=	"<tr>"
	$objHTML+=	"<td>" +	$objProc.ProcessName		 								+ "</td>"
	$objHTML+=	"<td>" +	$objProc.ProcessId 											+ "</td>"
	$objHTML+=	"<td>" +	$objProc.getowner().user									+ "</td>"
	$objHTML+=	"<td>" +	[math]::Round($objProc.WorkingSetSize /1mb,2)				+ "MB</td>"
	$objHTML+=	"<td>" +	[math]::Round($objProc.VirtualSize /1mb,2)					+ "MB</td>"
	$objHTML+=	"<td>" +	[math]::Round($objProc.PageFileUsage /1mb,2)				+ "MB</td>"
	$objHTML+=	"</tr>"

}
$objHTML+=	"</table>"
#END Process Information -> Memory


$objTopProcessMem=$null


###################################################################################### SECTION::Patches

#Get Wmi Information into Array
$objHotfix = gwmi -query "Select * from win32_QuickfixEngineering "| Sort-Object -Property InstalledOn -Descending|select -first 15 



#Set the Table and first header
$objHTML+=	"<table width=100%>"
$objHTML+= "<tr> <br> </tr>" 
$objHTML+= "<tr>"
$objHTML+= "<th class=""label"" colspan=4> Last 15 Patches installed  </th>"
$objHTML+= "</tr>"

#Set Headers
$objHTML+= "<tr>"
$objHTML+= "<th><b> Description  </b></th>"
$objHTML+= "<th><b> HotFixID  </b></th>"
$objHTML+= "<th><b> Caption  </b></th>"
$objHTML+= "<th><b> InstallDate  </b></th>"
$objHTML+= "<th><b> InstalledBy  </b></th>"

#Loop for each item in Array
Foreach ( $objPatch in $objHotfix)
{
	$objHTML+=	"<tr>"
	$objHTML+=	"<td>" +	$objPatch.Description	+ "</td>"
	$objHTML+=	"<td>" +	$objPatch.HotFixID		+ "</td>"
	$objHTML+=	"<td>" +	$objPatch.Caption		+ "</td>"
	$objHTML+=	"<td>" +	$objPatch.InstalledOn	+ "</td>"
	$objHTML+=	"<td>" +	$objPatch.InstalledBy	+ "</td>"
	$objHTML+=	"</tr>"

}
$objHTML+=	"</table>"
#END Last Hotfixes

$objHotfix=$null


###################################################################################### SECTION::Event Log System =>Error

#Get Wmi Information into Array
$objLogSysError = Get-Eventlog -LogName System -EntryType Error -Newest 10 | sort-object $_.Time -descending


#Set the Table and first header
$objHTML+=	"<table width=100%>"
$objHTML+= "<tr> <br> </tr>" 
$objHTML+= "<tr>"
$objHTML+= "<th class=""label"" colspan=5> Last 10 System Log Errors  </th>"
$objHTML+= "</tr>"

#Set Headers
$objHTML+= "<tr>"
$objHTML+= "<th><b> EventID  </b></th>"
$objHTML+= "<th><b> InstanceID  </b></th>"
$objHTML+= "<th><b> Time  </b></th>"
$objHTML+= "<th><b> Source  </b></th>"
$objHTML+= "<th><b> Message  </b></th>"

#Loop for each item in Array
Foreach ( $objEventError in $objLogSysError)
{
	$objHTML+=	"<tr>"
	$objHTML+=	"<td>" +	$objEventError.EventID		+ "</td>"
	$objHTML+=	"<td>" +	$objEventError.InstanceID	+ "</td>"
	$objHTML+=	"<td>" +	$objEventError.Time			+ "</td>"
	$objHTML+=	"<td>" +	$objEventError.Source		+ "</td>"
	$objHTML+=	"<td>" +	$objEventError.Message		+ "</td>"
	$objHTML+=	"</tr>"

}
$objHTML+=	"</table>"
#END Event Log => System Error

$objLogSysError=$null



###################################################################################### SECTION::Event Log System =>Warning

#Get Wmi Information into Array
$objLogSysError = Get-Eventlog -LogName System -EntryType Warning -Newest 10 | sort-object $_.Time -descending


#Set the Table and first header
$objHTML+=	"<table width=100%>"
$objHTML+= "<tr> <br> </tr>" 
$objHTML+= "<tr>"
$objHTML+= "<th class=""label"" colspan=5> Last 10 System Log Warnings  </th>"
$objHTML+= "</tr>"

#Set Headers
$objHTML+= "<tr>"
$objHTML+= "<th><b> EventID  </b></th>"
$objHTML+= "<th><b> InstanceID  </b></th>"
$objHTML+= "<th><b> Time  </b></th>"
$objHTML+= "<th><b> Source  </b></th>"
$objHTML+= "<th><b> Message  </b></th>"
$objHTML+= "</tr>"

#Loop for each item in Array
Foreach ( $objEventError in $objLogSysError)
{
	$objHTML+=	"<tr>"
	$objHTML+=	"<td>" +	$objEventError.EventID		+ "</td>"
	$objHTML+=	"<td>" +	$objEventError.InstanceID	+ "</td>"
	$objHTML+=	"<td>" +	$objEventError.Time			+ "</td>"
	$objHTML+=	"<td>" +	$objEventError.Source		+ "</td>"
	$objHTML+=	"<td>" +	$objEventError.Message		+ "</td>"
	$objHTML+=	"</tr>"

}
$objHTML+=	"</table>"
#END Event Log => System Warning


$objLogSysError=$null


###################################################################################### SECTION::Event Log Application =>Error

#Get Wmi Information into Array
$objLogSysError = Get-Eventlog -LogName Application -EntryType Error -Newest 10 | sort-object $_.Time -descending


#Set the Table and first header
$objHTML+=	"<table width=100%>"
$objHTML+= "<tr> <br> </tr>" 
$objHTML+= "<tr>"
$objHTML+= "<th class=""label"" colspan=5>  Last 10 Application Log Errors  </th>"
$objHTML+= "</tr>"

#Set Headers
$objHTML+= "<tr>"
$objHTML+= "<th><b> EventID  </b></th>"
$objHTML+= "<th><b> InstanceID  </b></th>"
$objHTML+= "<th><b> Time  </b></th>"
$objHTML+= "<th><b> Source  </b></th>"
$objHTML+= "<th><b> Message  </b></th>"
$objHTML+= "</tr>"

#Loop for each item in Array
Foreach ( $objEventError in $objLogSysError)
{
	$objHTML+=	"<tr>"
	$objHTML+=	"<td>" +	$objEventError.EventID		+ "</td>"
	$objHTML+=	"<td>" +	$objEventError.InstanceID	+ "</td>"
	$objHTML+=	"<td>" +	$objEventError.Time			+ "</td>"
	$objHTML+=	"<td>" +	$objEventError.Source		+ "</td>"
	$objHTML+=	"<td>" +	$objEventError.Message		+ "</td>"
	$objHTML+=	"</tr>"

}
$objHTML+=	"</table>"
#END Event Log => Application Error


$objLogSysError =$null


###################################################################################### SECTION::Event Log Application =>Warning

#Get Wmi Information into Array
$objLogSysError = Get-Eventlog -LogName Application -EntryType Warning -Newest 10 | sort-object $_.Time -descending


#Set the Table and first header
$objHTML+=	"<table width=100%>"
$objHTML+= "<tr> <br> </tr>" 
$objHTML+= "<tr>"
$objHTML+= "<th class=""label"" colspan=5> Last 10 Application Log Warnings  </th>"
$objHTML+= "</tr>"

#Set Headers
$objHTML+= "<tr>"
$objHTML+= "<th><b> EventID  </b></th>"
$objHTML+= "<th><b> InstanceID  </b></th>"
$objHTML+= "<th><b> Time  </b></th>"
$objHTML+= "<th><b> Source  </b></th>"
$objHTML+= "<th><b> Message  </b></th>"
$objHTML+= "</tr>"

#Loop for each item in Array
Foreach ( $objEventError in $objLogSysError)
{
	$objHTML+=	"<tr>"
	$objHTML+=	"<td>" +	$objEventError.EventID		+ "</td>"
	$objHTML+=	"<td>" +	$objEventError.InstanceID	+ "</td>"
	$objHTML+=	"<td>" +	$objEventError.Time			+ "</td>"
	$objHTML+=	"<td>" +	$objEventError.Source		+ "</td>"
	$objHTML+=	"<td>" +	$objEventError.Message		+ "</td>"
	$objHTML+=	"</tr>"

}
$objHTML+=	"</table>"
#END Event Log => Application Warning


$objLogSysError=$null


###################################################################################### SECTION::Event Log Application =>Warning

#Get Wmi Information into Array
$objLogSysError = Get-Eventlog -LogName Security -EntryType FailureAudit -Newest 10 | sort-object $_.Time -descending


#Set the Table and first header
$objHTML+=	"<table width=100%>"
$objHTML+= "<tr> <br> </tr>" 
$objHTML+= "<tr>"
$objHTML+= "<th class=""label"" colspan=5> Last 10 Security Audit Failures  </th>"
$objHTML+= "</tr>"

#Set Headers
$objHTML+= "<tr>"
$objHTML+= "<th><b> EventID  </b></th>"
$objHTML+= "<th><b> InstanceID  </b></th>"
$objHTML+= "<th><b> Time  </b></th>"
$objHTML+= "<th><b> Source  </b></th>"
$objHTML+= "<th><b> Message  </b></th>"
$objHTML+= "</tr>"

#Loop for each item in Array
Foreach ( $objEventError in $objLogSysError)
{
	$objHTML+=	"<tr>"
	$objHTML+=	"<td>" +	$objEventError.EventID		+ "</td>"
	$objHTML+=	"<td>" +	$objEventError.InstanceID	+ "</td>"
	$objHTML+=	"<td>" +	$objEventError.Time			+ "</td>"
	$objHTML+=	"<td>" +	$objEventError.Source		+ "</td>"
	$objHTML+=	"<td>" +	$objEventError.Message		+ "</td>"
	$objHTML+=	"</tr>"

}
$objHTML+=	"</table>"
#END Event Log => Application Warning

$objLogSysError=$null

#End of HTML
$objHTML+=	"</body>"
$objHTML+=	"</html>"

if (-not(test-path("c:\Automation")))
{
    new-item -itemtype directory "c:\automation"
}

if (-not(test-path("c:\automation\HealthReport")))
{
    new-item -itemtype directory "c:\Automation\HealthReport"
}

#Write File
$objHTML | out-file "c:\Automation\HealthReport\$objHost_$objTxtDate.html"

#Set HTML Object to Null
$objHTML=$null


