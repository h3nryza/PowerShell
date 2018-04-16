# Easy-Sql
This script uses e fules for perform its functions
- sqlsettings.xml
 - This file contains the encrypted settings to connect to your SQL database. Encryption is created using this script and easy-aes (see Create-SettingsFile)
- sqlheaders.xml
 - This file contains the table name and headers for your table. File is created with this script. (See ?)
- easy-aes.ps1
 - This is a module to help make AES encryption a bit easier

## Functions
- Create-SettingsFile():  Creates the xml for connection to SQL with encrypted information. Uses module Easy-AES
- Create-HeadersFile(): Created the headers file with no information for you to fill in the blanks
- Get-SqlSettings(): Gets the de-encrypted information from the SqlSettings.xml and returns it as  string. Uses module Easy-AES
- Get-SqlHeaders(): Gets the table and header information from the sqlheaders.xml. Returns as string:tablename,array:headers
- format-sqldata(): A subfunction that joins array information into a string with comma's at the end, exluding last item
- exec-Sqlstatement(): Executes a sql statement. Uses function Get-SqlSettings()
- create-sqldatabase(): Created a sql database. Calls function Get-SqlSettings()
- create-sqltable(): Creates a sql table based on your sqlheaders.xml. Calls functions  Get-SqlSettings(),Get-SqlHeaders()
- insert-sqldata(): Maps arn array of data to the SqlHeaders.xml file. Calls functions  Get-SqlSettings(),Get-SqlHeaders()
- truncate-sqltable(): Truncats the table from param $table. Calls functions  Get-SqlSettings()
- query-Sql(): Runs the query from param $inputdata. Calls functions  Get-SqlSettings()

## Function Information

### Create-SettingsFile()
	__Input Parameters__
	[string]$FilePath : Full path to the sqlsettings.xml file for creation
    [string]$servername: Name of the sql server needing for connection
    [string]$database= Name of the database for connection
    [string]$Table: Name of the table for connection
    [string]$username: Username for connection [if not integrated security]
    [string]$password: Password for connection [if not integrated security]
	
	__Returns__
	Nothing : outputs file to $FilePath
	
	__Examples__
	Create-SettingsFile -FilePath ".\sqlsettings.xml" -servername "myserver" -database "mydatabase" -Table "mytable" 
	Create-SettingsFile -FilePath ".\sqlsettings.xml" -servername "myserver" -database "mydatabase" -Table "mytable" -username "domain\name" -password "secretpassword"
	
### Create-HeadersFile()	
	__Input Parameters__
	[string]$FilePath : Full path to the sqlheaders.xml file for creation
	
	__Returns__
	Nothing : outputs file to $FilePath
	
	__Examples__
	Create-HeadersFile -FilePath ".\sqlheaders.xml"

### Get-SqlSettings()	
	__Input Parameters__
	[string]$FilePath : Full path to the sqlsettings.xml file
	
	__Returns__
	[string]"$servername,$database,$table,$port,$username,$password"
	
	__Examples__
	Create-SqlSettings -FilePath ".\sqlsettings.xml"

### Get-SqlHeaders()	
	__Input Parameters__
	[string]$FilePath : Full path to the sqlheaders.xml file

	__Returns__
	[string]$table,[array]$headersData
	
	__Examples__
	Create-SqlSettings -FilePath ".\sqlheaders.xml"
	
## format-sqldata()
	__Input Parameters__
	$inputData : Data in the form of an array

	__Returns__
	[string]$returnDataString
	
	__Examples__
	Create-SqlSettings -inputData ".\sqlheaders.xml"
	
## exec-Sqlstatement()
	__Input Parameters__
	[string]$SqlSettingsPath: Full path to the sqlheaders.xml file 
    [string]$inputData: Sql statement to execute
    [switch]$integrated : Forces integrated security

	__Returns__
	Nothing
	
	__Examples__
	exec-Sqlstatement -SqlSettingsPath ".\sqlsettings.xml" -inputData "drop table tablename"
	exec-Sqlstatement -SqlSettingsPath ".\sqlsettings.xml" -inputData "drop table tablename" -integrated
	
## create-sqldatabase()
	__Input Parameters__
	[string]$SqlSettingsPath: Full path to the sqlheaders.xml file 
    [switch]$integrated : Forces integrated security

	__Returns__
	Nothing
	
	__Examples__
	create-sqldatabase -SqlSettingsPath ".\sqlheaders.xml" 
	create-sqldatabase -SqlSettingsPath ".\sqlheaders.xml" -integrated
	
## create-sqltable()
	__Input Parameters__
	[string]$SqlSettingsPath: Full path to the sqlheaders.xml file 
	[string]$SqlHeadersPath: Path to the sqlheaders.xml file
    [switch]$integrated : Forces integrated security

	__Returns__
	Nothing
	
	__Examples__
	create-sqltable -SqlSettingsPath ".\sqlsettings.xml"  -SqlHeadersPath ".\sqlheaders.xml" 
	create-sqltable -SqlSettingsPath ".\sqlsettings.xml"  -SqlHeadersPath ".\sqlheaders.xml"  -integrated
	
## insert-sqldata()
	__Input Parameters__
	[string]$SqlSettingsPath: Full path to the sqlheaders.xml file 
	[string]$SqlHeadersPath: Path to the sqlheaders.xml file
	[Array]$arrayData: Array of data that needs to be inserted into SQL. Where each row contains sql row
    [switch]$integrated : Forces integrated security

	__Returns__
	Nothing
	
	__Examples__
	insert-sqldata -SqlSettingsPath ".\sqlsettings.xml"  -SqlHeadersPath ".\sqlheaders.xml" -arrayData $arrayOfData
	insert-sqldata -SqlSettingsPath ".\sqlsettings.xml"  -SqlHeadersPath ".\sqlheaders.xml" -arrayData $arrayOfData  -integrated
	
## truncate-sqltable()
	__Input Parameters__
	[string]$SqlSettingsPath: Full path to the sqlheaders.xml file 
	[string]$table: Table to be truncated
    [switch]$integrated : Forces integrated security

	__Returns__
	Nothing
	
	__Examples__
	truncate-sqltable -SqlSettingsPath ".\sqlsettings.xml"  -table "mytable"
	truncate-sqltable-SqlSettingsPath ".\sqlsettings.xml"  -table "mytable"  -integrated
	
## query-Sql()
	__Input Parameters__
	[string]$SqlSettingsPath: Full path to the sqlheaders.xml file 
	[string]$inputdata: Query needing to be run on sql
    [switch]$integrated : Forces integrated security

	__Returns__
	[Datatable]$resultTable
	
	__Examples__
	query-Sql -SqlSettingsPath ".\sqlsettings.xml" -inputdata $data 
	query-Sql -SqlSettingsPath ".\sqlsettings.xml"  -inputdata $data  -integrated