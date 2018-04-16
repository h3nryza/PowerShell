
<# 
.Synopsis
	Provides an easy to use Sql interface with encrypted XML
.DESCRIPTION
   This script provides an easy interface to SQL. It uses a XML file (Encrypted)
   for storing SQL data and passwords. Unencrypted  XML file for mapping of headers
   to data
.Parameter
.Inputs
	Please see accompanying readme.md
.Outputs
	Please see accompanying readme.md
.Example
    Please see accompanying readme.md
.Notes
	Created by 	: Henry Stock
	Version 	: V1.0.0.0
	Dated		: April 2018
	Authorised	: Henry Stock
	OS			: Windows
	PS Version	: All
.Link
	

#>


function Create-SettingsFile(){
    param(
    [string]$FilePath=".\sqlsettings.xml",
    [string]$name="IAMDEFAULT",
    [string]$servername="IAMDEFAULT",
    [string]$database="IAMDEFAULT",
    [string]$Table="IAMDEFAULT",
    [string]$username="IAMDEFAULT",
    [string]$password="IAMDEFAULT"
    )

    #Set the encryption
    import-module .\easy-aes.ps1
    $e_servername = Encrypt-String $servername
    $e_database = Encrypt-String $database
    $e_table = Encrypt-String $table
    $e_username = Encrypt-String $username
    $e_password = Encrypt-String $password

    #Build XML
    $info=@"
<sqlsettings>
	<server>
		$e_servername
	</server>
	
	<database>
		$e_database
	</database>
	
	<table>
		$e_table
	</table>
	
	<username>
		$e_username
	</username>
		
	<password>
		$e_password
	</password>

</sqlsettings>
"@

    "$info" | out-file "$FilePath" 

}




function Create-HeadersFile(){
    param(
    $FilePath=".\sqlheaders.xml"
    )

    #Build XML
    $info=@"
<sqlheaders>
	<table>
		IAMDEFAULT
	</table>

    <headers>

        <header>
		    header1, type
	    </header>

        <header>
		    header2, type
	    </header>

        <header>
		    header3, type
	    </header>

    </headers>
</sqlheaders>
"@

    "$info" | out-file "$FilePath" 

}


function Get-SqlSettings(){
    param(
    $SqlSettingsPath=".\sqlsettings.xml"
    )
    
    import-module .\easy-aes.ps1
    #Get encrypted information from XML
    [xml]$XmlDocument = Get-Content $SqlSettingsPath
    $servername_encrypted = $XmlDocument.sqlsettings.server.trim()
    $database_encrypted = $XmlDocument.sqlsettings.database.trim()
    $table_encrypted = $XmlDocument.sqlsettings.table.trim()
    $username_encrypted = $XmlDocument.sqlsettings.username.trim()
    $password_encrypted = $XmlDocument.sqlsettings.password.trim()
    #Decrypt the information provided
    $servername = Decrypt-String $servername_encrypted
    $database = Decrypt-String $database_encrypted
    $table = Decrypt-String $table_encrypted
    $username = Decrypt-String $username_encrypted
    $password = Decrypt-String $password_encrypted

    return "$servername,$database,$table,$port,$username,$password"

}


function Get-SqlHeaders(){
    param(
    [string]$SqlHeadersPath=".\sqlheaders.xml",
    [switch]$clean
    )
    
    #Get table from XML
    [xml]$XmlDocument = Get-Content $SqlHeadersPath
    $table = $XmlDocument.sqlheaders.table.trim()
    #For each header extract the information and create array
    $headers = $XmlDocument.sqlheaders.header
    $headersData = @()
    #If the clean option is chosen, split out the header type

    if($clean){
        foreach($header in $headers){
                $headerItem = $header.split(",")
                $headersData += $headerItem[0].trim()
        }#End loop
    }
    else{
        foreach($header in $headers){
            $headeritem = $header.replace(","," ")
            $headersData += $headerItem.trim()
        }#End loop
    }#End if/else

    return $table,$headersData
}



function format-sqldata(){
param(
      $inputData
      )

      $returnData = @()
      foreach($item in $inputData){
        #If not the last item, add a "," for sql notation 
        if($counter -ne $inputData.length-1){
            $returnData += "$item, "
        }
        else{
            $returnData += "$item"
        }#End if/else
        $counter = $counter +1
    }#End loop

    #Join the array to expor
    $returnDataString = -join $returnData 
    return  $returnDataString

}



function exec-Sqlstatement(){
param(
    [string]$SqlSettingsPath=".\sqlsettings.xml",
    [string]$inputData,
    [switch]$integrated
    )
    
    #Set the SQL settings obtained from XML
    $sqlSettings = Get-SqlSettings -sqlSettingsPath $SqlSettingsPath
    $SqlConnection = New-Object System.Data.SqlClient.SqlConnection 
    #Check for switch to know whether to set connection with username and password or integrated security
    if($integrated){
        $SqlConnection.ConnectionString = "Server = $sqlSettings[0];port=$sqlSettings[3]; Database = $sqlSettings[1]; Integrated Security = True"
    }
    else{
        $SqlConnection.ConnectionString = "Server = $sqlSettings[0];port=$sqlSettings[3]; Database = $sqlSettings[1]; User ID = $sqlSettings[3]; Password = $sqlSettings[4]"
    }
   
    #Open the Connection
    $SqlConnection.Open()  


    $sqlCMD = $inputData
    $dbwrite = $SqlConnection.CreateCommand()	
    $dbwrite.CommandText = $sqlCMD						
    $dbwrite.ExecuteNonQuery()	
    #Close connection
    $SqlConnection.close()

}




function create-sqldatabase(){
    param(
    [string]$SqlSettingsPath=".\sqlsettings.xml",
    [switch]$integrated
    )

    #Set the SQL settings obtained from XML
    $sqlSettings = Get-SqlSettings $SqlSettingsPath
    $sqlSettings = $sqlSettings.split(",")
    $Server = $sqlSettings[0]
    $Database = $sqlSettings[1]
    $User = $sqlSettings[3]
    $Password = $sqlSettings[4]

    $SqlConnection = New-Object System.Data.SqlClient.SqlConnection 
    #Check for switch to know whether to set connection with username and password or integrated security
    if($integrated){
        $SqlConnection.ConnectionString = "Server = $Server; Database = $sqlSettings; Integrated Security = True"
    }
    else{
        $SqlConnection.ConnectionString = "Server = $Server; Database = $sqlSettings; User ID = $User; Password = $Password"
    }
   
    #Open the Connection
    $SqlConnection.Open()
    $sqlCMD = "CREATE DATABASE $Server"

    $dbwrite = $SqlConnection.CreateCommand()	
    $dbwrite.CommandText = $sqlCMD						
    $dbwrite.ExecuteNonQuery()	
    #Close connection
    $SqlConnection.close()
}






function create-sqltable(){
param(
    [string]$SqlSettingsPath=".\sqlsettings.xml",
    [string]$SqlHeadersPath=".\sqlheaders.xml",
    [switch]$integrated
    )

    #Set the SQL settings obtained from XML
    $sqlSettings = Get-SqlSettings -sqlSettingsPath $SqlSettingsPath
    $sqlSettings = $sqlSettings.split(",")
    $Server = $sqlSettings[0]
    $Database = $sqlSettings[1]
    $User = $sqlSettings[3]
    $Password = $sqlSettings[4]

    $SqlConnection = New-Object System.Data.SqlClient.SqlConnection 
    #Check for switch to know whether to set connection with username and password or integrated security
    if($integrated){
        $SqlConnection.ConnectionString = "Server = $Server; Database = $sqlSettings; Integrated Security = True"
    }
    else{
        $SqlConnection.ConnectionString = "Server = $Server; Database = $sqlSettings; User ID = $User; Password = $Password"
    }
   
    #Open the Connection
    $SqlConnection.Open()

    #Get the table, Headers information from XML
    $tableinfo = Get-SqlHeaders $SqlHeadersPath

    $table=$tableinfo[0]
    #This is the array returned from Get-SqlHeaders function
    $headerinfo=$tableinfo[1]
    $formatedHeader = format-sqldata $headerinfo

    $sqlCMD = "CREATE TABLE $table ($formatedHeader)" 

    #Write the information to Sql
    $dbwrite = $SqlConnection.CreateCommand()	
    $dbwrite.CommandText = $sqlCMD						
    $dbwrite.ExecuteNonQuery()	
    #Close connection
    $SqlConnection.close()  

}



function insert-sqldata(){
param(
    [string]$SqlSettingsPath=".\sqlsettings.xml",
    [string]$SqlHeadersPath=".\sqlheaders.xml",
    [Array]$arrayData,
    [switch]$integrated
    )

    #Set the SQL settings obtained from XML
    $sqlSettings = Get-SqlSettings -sqlSettingsPath $SqlSettingsPath
    $SqlConnection = New-Object System.Data.SqlClient.SqlConnection 
    #Check for switch to know whether to set connection with username and password or integrated security
    if($integrated){
        $SqlConnection.ConnectionString = "Server = $sqlSettings[0];port=$sqlSettings[3]; Database = $sqlSettings[1]; Integrated Security = True"
    }
    else{
        $SqlConnection.ConnectionString = "Server = $sqlSettings[0];port=$sqlSettings[3]; Database = $sqlSettings[1]; User ID = $sqlSettings[3]; Password = $sqlSettings[4]"
    }
   
    #Open the Connection
    $SqlConnection.Open()  

    
    #Get Sql header information from XML 
    $tableinfo = Get-SqlHeaders $SqlHeadersPath -clean
    $table = $tableinfo[0]
    $headers = format-sqldata $tableinfo[1]
    $errorRowCounter = 0
    foreach($datarow in $arrayData){
        #Error checking statement
        if($datarow.length -eq $headers.length){
            $sqlCMD = "insert into $table ($headers) Values ($datarow)"
        }
        else{
            write-host "ERROR: Dataset in line $errorRowCounter does not Equal headers" 
        }
       
    $dbwrite = $SqlConnection.CreateCommand()	
    $dbwrite.CommandText = $sqlCMD						
    $dbwrite.ExecuteNonQuery()	
    #Close connection
    }
    $SqlConnection.close() 
}



function truncate-sqltable(){
param(
    [string]$SqlSettingsPath=".\sqlsettings.xml",
    [string]$table,
    [switch]$integrated
    )
    
    $sqlCMD = "truncate table $table"
    if($integrated){
        exec-Sqlstatement $sqlCMD -inputData -SqlSettingsPath $SqlSettingsPath -integrated 
    }
    else{
        exec-Sqlstatement -inputData $sqlCMD -SqlSettingsPath $SqlSettingsPath
    }
}


function query-Sql(){
param(
    [string]$SqlSettingsPath=".\sqlsettings.xml",
    [string]$inputdata,
    [switch]$integrated
    )
    
    #Set the SQL settings obtained from XML
    $sqlSettings = Get-SqlSettings -sqlSettingsPath $SqlSettingsPath
    $SqlConnection = New-Object System.Data.SqlClient.SqlConnection 
    #Check for switch to know whether to set connection with username and password or integrated security
    if($integrated){
        $SqlConnection.ConnectionString = "Server = $sqlSettings[0];port=$sqlSettings[3]; Database = $sqlSettings[1]; Integrated Security = True"
    }
    else{
        $SqlConnection.ConnectionString = "Server = $sqlSettings[0];port=$sqlSettings[3]; Database = $sqlSettings[1]; User ID = $sqlSettings[3]; Password = $sqlSettings[4]"
    }
   
    #Open the Connection
    $SqlConnection.Open()
    $sqlCMD = $inputdata

    #Create and execute query
    $dbwrite = $SqlConnection.CreateCommand()	
    $dbwrite.CommandText = $sqlCMD						
    $result =$dbwrite.ExecuteReader()

    $resultTable = new-object “System.Data.DataTable”
    $resultTable.Load($result)
    #Close connection
    $SqlConnection.close() 

    return $resultTable
}