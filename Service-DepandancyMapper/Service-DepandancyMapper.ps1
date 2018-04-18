
<# 
.Synopsis
	Provides a custom dependancy mapper for windows services
.DESCRIPTION
    This script allows a custom dependancy mappe for windows services. Starting from the last depedant to the service itself
.Parameter
    create-dependancyXml: Creates the dependancy XML file
    get-dependancymap: Returns the dependancy map in a reversed array
    start-services: point of entry (main function). Gets the dependancies and starts the services
.Inputs
	-FilePath: Path to the dependancy xml 
.Outputs
	Results to screen, Alternatively, pipe to out-file
.Example
    start-services -FilePath ".\dependancymap.xml"
.Notes
	Created by 	: Henry Stock
	Version 	: V1.0.0.0
	Dated		: April 2018
	Authorised	: Henry Stock
	OS			: Windows
	PS Version	: All
.Link
	

#>




function create-dependancyXml(){
    param(
    [string]$FilePath=".\dependancymap.xml"
    )

$xml = @"
<services>
	<service>
        <name>
        ServiceNameA
        </name>
		<dependancy>
            <name>
                dependancy-level1a
            </name>
				<dependancy>
				<name>
					dependancy-level2a
				</name>
					<dependancy>
					<name>
						dependancy-level3a
					</name>
					</dependancy> 
				
				</dependancy> 
        </dependancy>         
	</service>
    <service>
        <name>
        SERVICENAMEB
        </name>
		<dependancy>
            <name>
                dependancy-level1b1
            </name>
        </dependancy>
        <dependancy>
            <name>
                dependancy-level1b2
            </name>
        </dependancy>
	</service>
</services>


"@
"$xml" | out-file $FilePath

}


function loop($node, $arr){
    #Try get name of node
    try{
        $nodename = $node.name.trim()
        #Add to array for result
        $arr += $nodename
        #loop back to look for sub dependancy
        loop $node.dependancy, $arr
    }
    catch{
        #NO RECORDS
    }
    #return the array
    return $arr
}


function get-dependancymap(){
    param(
    [string]$FilePath=".\dependancymap.xml"
    )

    #Empty array for end result
    $nodeArr= @()
    #Load XML Document
    $xmlDocument = New-Object System.XML.XMLDocument
    $xmlDocument.LoadXml((Get-Content $FilePath -Encoding UTF8))
    #Loop through child nodes
    foreach($node in $XmlDocument.services.ChildNodes){
        #Empty array for reversing child nodes
        $arr = @()
        #Returned array, Convert to string, add to main array
        $returnArr = loop $node, $arr
        $stringArr = ($returnArr -join ",").Substring(1)   
        $nodeArr += $stringArr
    }
    return $nodeArr   
}




function start-services(){
    param(
    [string]$FilePath=".\dependancymap.xml"
    )

    #Get all dependancy on services
    $dependancymap = get-dependancymap $FilePath
    foreach($serviceLine in $dependancymap){
        #split the line of dependancy from first to last sevrice that needs to be started
        $serviceLineSplit = $serviceLine.split(",")
        foreach($service in $serviceLineSplit){
            write-host "$service is starting"
            try{
                start-service $service -ErrorAction stop
            }
            catch{
                $ErrorMessage = $_.Exception.Message
                write-host "ERORR on $service ERROR MESSAGE: $ErrorMessage"
            }
        }
    }
}
