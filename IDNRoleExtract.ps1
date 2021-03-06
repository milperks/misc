#### Author: Millie Perkins
#### Date:15/1/2021
#### This powershell script uses the IDN api to find all role IDs and other info, then loops through that to export the json object of the role criteria and appends it to a file with the display name.


##IdentityNow Organisation
$org = "org name" 

##Auth token from idn
Write-Host "Enter Auth Token:" -ForegroundColor Cyan
$token = Read-Host

##Gets all roles list
$Roles = Invoke-RestMethod -Uri "https://$($org).api.identitynow.com/cc/api/role/list" -Headers @{"authorization" ="Bearer $token"} 

#Pulls all role items out
$result = $Roles.items | Select-Object * 

##Converts to format than can be exported as a csv
$objList = $result | Select-Object @{Name='id';Expression={$_.id}},@{Name='UserCount';Expression={$_.identityCount}},@{Name='RoleOwner';Expression={$_.owner}},@{Name='Requestable';Expression={$_.requestable}},@{Name='Disabled';Expression={$_.disabled}},@{Name='roleName';Expression={$_.displayName}},@{Name='Description';Expression={$_.description}}

##Exports role name and id
$objList | Export-Csv -Path ".\${org}RoleIDs.txt" -NoTypeInformation 
Write-host "Role ID CSV Exported" -ForegroundColor Magenta

##Overwrites previous file
Set-Content -Value $null -Path ".\${org}RoleInfo.txt"

##Loops through each role object in the list
$i = 1
$objList | Foreach {

    $RI = $_.id
    
    ##Pulls api and gets the full role info using the role id
    $RoleInfo = Invoke-RestMethod -Uri "https://$($org).api.identitynow.com/cc/api/role/get/?id=${RI}" -Headers @{"authorization" ="Bearer $token"}
    
    ##Gets the role criteria only and converts to json to make it readable
    $RoleInfoChildren = $RoleInfo.selector.complexRoleCriterion.children | ConvertTo-Json -Depth 10

    ##Exports to a file with the role name
    Add-Content -Value $RoleInfo.displayName, $RoleInfoChildren, "***********" -Path ".\${org}RoleInfo.txt"

    ##Progress
    Write-host "Total roles:" $objList.count "Up to Role number: "$i -ForegroundColor White -BackgroundColor DarkMagenta
    $i++

    }

