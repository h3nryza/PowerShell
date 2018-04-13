<# 
.Synopsis
	Script to start all services that are problematic
.DESCRIPTION
  This script checks for all services that are set to automatic but are stopped, then starts the services
.Parameter
  n/a
.Inputs
	n/a
.Outputs
	n/a
.Example
    n/a
.Notes
    TROUBLESHOOTING
	Running this script requires you to have the following
	1) Powershell Script Execution
		a) (run powershell as admin) Set-ExecutionPolicy bypass -force
			OR
		b)(run powershell as admin) Set-ExecutionPolicy unrestricted -force
	2) When downloading this file from the internet you may need to unblock this file
		a) On the physical file right click, on the bottom of the file clock unblock then ok
    3) [NOTE] This script auto-elevates iteself

	CREATOR
	Created by 	: Henry Stock
	Version 	: V1.0.0.0
	Authorised	: Henry Stock
	OS			: Windows
	PS Version	: All
.Link
	

#>


# Elevate to Admin
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

# Get problematic services and restart them
Get-CimInstance -class win32_service | where {$_.StartMode -like "*auto*" -and $_.State -like "*stop*"} | start-service
