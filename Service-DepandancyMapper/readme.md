# Service Dependancy Mapper
This script allows a custom dependancy mappe for windows services. Starting from the last depedant to the service itself

# Functions
- create-dependancyXml: Creates the dependancy XML file
- get-dependancymap: Returns the dependancy map in a reversed array
- start-services: point of entry (main function). Gets the dependancies and starts the services

# Inputs
FilePath: Path to the dependancy xml

# Results
None

# Example
create-dependancyXml -FilePath ".\dependancymap.xml"
get-dependancymap -FilePath ".\dependancymap.xml"
start-services -FilePath ".\dependancymap.xml"