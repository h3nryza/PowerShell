
<# 
.Synopsis
	Server Monitor - Monitors CPU and Memory Load
.DESCRIPTION
   This Script checks CPU and Memory load at a configured time interval, comparing them to configured MAX percentage values. When the value is higher than the max value
   the target script is run
.Parameter
    TimerInSeconds => Time interval that the script will check the values
    MaxCpuLoadInPercentage => Max cpu percentage before the target script will be run
    MaxMemoryInPercentage => Max memory percentage (total visibile memory) before the target script will be run
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
	Version 	: V1.0.0.1
	Authorised	: Henry Stock
	OS			: Windows
	PS Version	: All
.Link
	

#>


#Elevate to Admin 
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }


#Configurations
$TimerInSeconds = 300
$MaxCpuLoadInPercentage = 70
$MaxMemoryInPercentage = 70

<# Retired
$objScriptDir= [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition) 	#Set the script root directory
$HealthScript = get-childitem $objScriptDir | where {$_.name -like "*HealhReport*"} 	#Retrieve the Health Script
$HealthScriptpath = $HealthScript.fullname												#Set the Health Script Full Path Location
#>
$HealthScriptpath = "\\domain\scripts\Automation\HealthScript\HealhScriptV2.0.0.2.ps1"

#Get the total visible memory size
$objMemory = gwmi Win32_OperatingSystem
$TotalSystemMemory = [math]::round($objMemory.TotalVisibleMemorySize /1024,2)

#Continious loop
while (1 -le 100)
{
    #Get CPU Load Percentage
    $objCpu = Get-WmiObject win32_processor
    $objCpuLoad =  $objCpu.loadpercentage

    $objMemLoad = [math]::round((get-process | Measure-Object workingset -sum).sum /1mb,2)	#Get Total Memory Use

   
    [int]$objMemoryPerc= [math]::round(($objMemLoad/$TotalSystemMemory)*100,2)				#Work out percentage of memory used

     <#
        #Outputs
        write-host $objCpuLoad
        write-host $objMemLoad
        write-host $TotalSystemMemory
     #>   
        
	#Evaluate conditions
    if($objCpuLoad -ge  $MaxCpuLoadInPercentage -or  $objMemoryPerc -ge $MaxMemoryInPercentage)
    {
        #write-host $HealthScriptpath
        invoke-item $HealthScriptpath		#Start Health Script and Initiate Report
        sleep -s 600						#Slep for 10min to avoid any further CPU Spikes
    }

    sleep -Seconds $TimerInSeconds			#Sleep for 5min before next monitoring point (15min if script has run)

}





