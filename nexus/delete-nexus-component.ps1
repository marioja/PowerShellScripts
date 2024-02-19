<#
.SYNOPSIS
Deletes a component from Nexus Repository using its id.

.DESCRIPTION
This script deletes a component from a specified repository using the Nexus REST API. It takes the component id as a parameter and invokes the DELETE method on the component endpoint.

.PARAMETER ComponentId
The id of the component to delete. You can get the component id by using the Search API or the Nexus UI.

.PARAMETER NexusUrl
The base URL of the Nexus server. The default is http://localhost:8081.

.PARAMETER Repository
The name of the repository that contains the component. The default is maven-releases.

.EXAMPLE
.\Delete-Nexus-Component.ps1 -ComponentId "a1b2c3d4e5f6g7h8i9j0"

Deletes the component with the id "a1b2c3d4e5f6g7h8i9j0" from the maven-releases repository on the local Nexus server.

.EXAMPLE
.\Delete-Nexus-Component.ps1 -ComponentId "a1b2c3d4e5f6g7h8i9j0" -NexusUrl "http://xx.xx.xxx.xxx:8081" -Repository "TestRepo"

Deletes the component with the id "a1b2c3d4e5f6g7h8i9j0" from the TestRepo repository on the Nexus server at http://xx.xx.xxx.xxx:8081.

.LINK
Online version: [5](https://stackoverflow.com/questions/34115434/how-to-delete-artifacts-with-classifier-from-nexus-using-rest-api)

.LINK
about Comment Based Help
#>

# Define the parameters for the script
param (
    [Parameter(Mandatory=$true)]
    [string]$ComponentId, # The id of the component to delete
    [string]$NexusUrl = "http://localhost:8081", # The default URL of the Nexus server
    [string]$Repository = "maven-releases" # The default name of the repository
)

# Prompt the user for the credentials and cache them
$Credential = Get-Credential -Message "Please enter your Nexus credentials"

# Create a basic authorization header
$unsecureCredential = $credential.GetNetworkCredential() # Convert from PSCredential object to NetworkCredential object
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $unsecureCredential.UserName,$unsecureCredential.Password))) # Encode the username and password in base64
$headers = @{"Authorization"="Basic $base64AuthInfo"} # Create the hashtable with the authorization header

# Build the REST API endpoint for deleting the component
$endpoint = "$NexusUrl/service/rest/v1/components/${ComponentId}?repository=$Repository"

# Invoke the REST API and check the status code
$response = Invoke-RestMethod -AllowUnencryptedAuthentication -Uri $endpoint -StatusCodeVariable 'statusCode' -Method Delete -headers $headers
if ($statusCode -eq 204) {
    Write-Host "Component deleted successfully."
}
else {
    Write-Host "Component deletion failed. Status code: $statusCode"
}
