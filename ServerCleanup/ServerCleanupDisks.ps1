<# 
.Synopsis
	This script cleans out known temp file locations and logfiles.
.DESCRIPTION
   This script cleans out logfiles and directories after 7 days. Due to some of the sensitivities 
   of the logfiles they have been explicityly refered to by location and split into different functions
   down to the very file paths. The days have also been hard coded for the same reason
.Parameter
.Inputs
	These Vary, please see individual configuration labeled #Configuration or "-" for input
.Outputs
	This file generate a logfile in the c:\windows\temp directory
.Example
    File to be scheduled or run on demand
.Notes
	Created by 	: Henry Stock
	Version 	: V1.0.0.0
	Dated		: March 2016
	Authorised	: Henry Stock
	OS			: Windows
	Clients		: All
	PS Version	: All
.Link
	

#>




#Change to Administrator
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

$PC=$env:COMPUTERNAME
$pcdate= Get-date -format ddMMyyy
$outfile = "c:\windows\temp\$pc-$PcDate.csv -append"

function delitems
{


    Param(
    
    	[parameter(
            Mandatory=$true,
    		Position=0,
    		ValueFromPipelineByPropertyName=$true,
    		ValueFromPipeline=$true,
    		HelpMessage="A path to the folder you would like to delete.")
    	]
    	[ValidateNotNullOrEmpty()]
    	[alias("P")]
    	[String[]]
    	$Path,
    	
    	[parameter(
            Mandatory=$true,
    		Position=1,
    		ValueFromPipelineByPropertyName=$true,
    		ValueFromPipeline=$true,
    		HelpMessage="Enter the number of days to delete, older than")
    	]
    	[ValidateNotNullOrEmpty()]
    	[alias("D,OlderThan,DeleteOlderThan")]
    	[string[]]
    	$DOlderThan,
    	
    	[parameter(
            Mandatory=$true,
    		Position=2,
    		ValueFromPipelineByPropertyName=$true,
    		ValueFromPipeline=$true,
    		HelpMessage="Enter if you would like to recursively delete items within the folder")
    	]
    	[ValidateNotNullOrEmpty()]
    	[alias("R,RecursiveDelete")]
    	[String[]]
    	$Recurse
    ) 
    
    
    
    
    ################################################################################## Code : Begin
    
    BEGIN
    {
        [double]$Dd= ($DOlderThan) -as [double]
        $DeleteDate = (get-date).AddDays(-$Dd)
        
        #workout Recurse Value
        if($Recurse -like "y" -or $Recurse -like "yes" -or $Recurse -like "Y" -or $Recurse -like "y"){$Recurcevalue = $true}
        if($Recurse -like "true" -or $Recurse -like "True" -or $Recurse -like $true -or $Recurse -like $True){$Recurcevalue = $true}
        if($Recurse -like "n" -or $Recurse -like "no" -or $Recurse -like "N" -or $Recurse -like "n"){$Recurcevalue = $false}
        if($Recurse -like "false" -or $Recurse -like "No" -or $Recurse -like $false -or $Recurse -like $False){$Recurcevalue = $false}


    
    }
    
    
    ################################################################################## Code : Process
    
    PROCESS
    {
        
        #Get Items in directory
        if($Recurcevalue = $true) {$arrValues = get-childitem $Path -recurse}
        if($Recurcevalue = $true) {$arrValues = get-childitem $Path}
         
        #ForEach item
        foreach($item in $arrValues)
        {

            $opath = $item.fullname
            $DDate =(get-item $opath).LastAccessTime

            #Check date before delete
            if( $DDate -le $DeleteDate)
            {
                if($Recurcevalue = $true) 
                {
                    #Log
                    "Deleted,$opath,LastAccessed:$DDate" | Out-file $outfile
                    remove-item $opath -Force  -Recurse:$true
                }
                if($Recurcevalue = $false) 
                {
                    #Log
                    "Deleted,$opath,LastAccessed:$DDate" | Out-file $outfile
                    remove-item $opath -Force -Recurse:$false
                }

            }

        
        }

    
    } # PROCESS ENDS
    

    


}



function cleanbin
{

    $Recycler = (New-Object -ComObject Shell.Application).NameSpace(0xa)
    $Recycler.items() | foreach { rm $_.path -force -recurse;"Cleaned RecycleBin Item"| Out-file $outfile }

}




function CleanWWW
{
    if(test-path "c:\inetpub\logs")
    {
        #IIS Is installed and logging

        #Get all sub folders
        $arr = get-childitem -path "C:\inetpub\logs\LogFiles\" -recurse
		
		Foreach($file in $arr)
        {
            
            $path = $file.fullname
            $DDate =(get-item $path).LastAccessTime
            

			if($file.fullname -like "*.log")
			{

				#This is a logfile
				if( $DDate -le (get-date).adddays(-7)) 
				{

                    #Log
                    "Deleted,$path,LastAccessed:$DDate" | Out-file $outfile					
                    remove-item $path -force
					
				}
			}
		}
	}




    if(test-path "c:\Windows\System32\LogFiles\HTTPERR\")
    {
        #IIS Is installed and logging

        #Get all sub folders
        $arr = get-childitem -path "c:\Windows\System32\LogFiles\HTTPERR\" -recurse
		
		Foreach($file in $arr)
        {
            
            $path = $file.fullname
            $DDate =(get-item $path).LastAccessTime

			if($file.fullname -like "*.log")
			{
				#This is a logfile
				if( $DDate -le (get-date).adddays(-7) ) 
				{
                    #Log
                    "Deleted,$path,LastAccessed:$DDate" | Out-file $outfile					
                    $DLM = (Get-item $file.fullname).LastAccessTime
					
				}
			}
		}
	}


 }



#CleanTemp Files
delitems  -Path $env:TEMP  -DOlderThan 7 -Recurse yesdelitems  -Path $env:TEMP  -DOlderThan 7 -Recurse yesdelitems  -Path "C:\Windows\Temp"  -DOlderThan 7 -Recurse yesdelitems -Path  "c:\temp"   -DOlderThan 7 -Recurse yes#Clean RecycleBincleanbin#Clean RecycleBinCleanWWW 