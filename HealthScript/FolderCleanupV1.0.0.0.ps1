<# 
.Synopsis
	Removes items in the indecated path if the deadline or file size is reached
.DESCRIPTION
   This Script will upon run check the scan path to ensure that items within meet the criteria.
   The criteria meaning that it does not exceed a date and amount to a certain size
.Parameter
.Inputs
	-objDelDate => The Maximum date an object is allowed to age before it gets deleted
    -FolderLimit => The Maximum size the folder is allowed to be, in mb before files are removes (over and abov the date criteria)
    -numberoffiles =+ The number of files to remove if the Maximum file size is reached
    -ScanPath => The folder path you wish to scan
.Outputs
	No output is given on this script
.Example
    N/A
.Notes
	Created by 	: Henry Stock
	Version 	: V1.0.0.0
	Authorised	: Henry Stock
	OS			: Windows
	PS Version	: All
.Link
	

#>

#Set 30 days retention period
$objdeldate = (Get-Date).AddDays(-30)

#Set Folder Limit (mb) and File amount to delete
$FolderLimit = 150
$numberoffiles = 50

#Path to scan
$ScanPath = "c:\Automation\HealthReport\"

#Get a list of all files
$arrFileList = get-childitem $ScanPath

#iterate through each itm and check the date
foreach($objitem in $arrFileList)
{
    #if the date is older than 30 days remove the item
    if( ((get-item $objitem.fullname).CreationTime) -le $objdeldate)
    {
        remove-item $objitem.fullname -force
    }#End if statement

}#End for loop

#Get the sum of the folder, if more than 150mb remove the oldest 50 files
$FolderSize = Get-ChildItem $ScanPath -recurse | Measure-Object -property length -sum

$foldersizeInmb = $foldersize.sum /1mb

if ($foldersizeInmb -ge $FolderLimit)
{
    $ToDelete = get-childitem $ScanPath | sort-object length -Descending | select -First $numberoffiles
}

#Remove all items marked to delete

foreach($delitem in $ToDelete)
{
    remove-item $delitem -force
}