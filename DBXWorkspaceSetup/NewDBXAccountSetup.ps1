$customDomain = "azureworkshops.net"
$defaultPwd = "*********"
$removeOldGroups = $false

# Set the number of groups and the number of users in each group
$numGroups = 10
$numUsersPerGroup = 5

# Connect to the AD tenant associated with the custom domain if you aren't already connected
try 
{
    $domain = Get-AzureADDomain -Name $customDomain
}
catch [Microsoft.Open.AzureAD16.Client.ApiException],[Microsoft.Open.AzureAD16.PowerShell.GetDomain], [Microsoft.Open.Azure.AD.CommonLibrary.AadNeedAuthenticationException]
{
    Connect-AzureAD -TenantId $customDomain
}
catch 
{
    Write-Host "An error occurred at login that could not be resolved"
    exit
}
finally
{
    $groups = Get-AzureADGroup -SearchString "Workshop Group"
}

# Remove old groups and users if the flag is set
if ($removeOldGroups)
{
    Write-Host ""
    Write-Host ""
    Write-Host "Removing Old Groups"
    Write-Host "==================="
    
    # Remove old users and groups
    ForEach ($group in $groups) 
    {
        Write-Host "Removing group: " $group.DisplayName
        $_ = Remove-AzureADGroup -ObjectId $group.ObjectId
    }

    Write-Host ""
    Write-Host "Removing Old Users"
    Write-Host "=================="

    For ($g=1; $g -lt (($numGroups*$numUsersPerGroup)+1); $g++)
    {
        $userName = "user_" + $g.ToString()
        $email = $userName + "@" + $customDomain
    
        Write-Host "Removing user: $userName" 
        Remove-AzureADUser -ObjectId $email
    }
}

# Set Password and ForceChangePasswordNextLogin parameters
$PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
$PasswordProfile.Password = $defaultPwd
$PasswordProfile.ForceChangePasswordNextLogin = $false

# Create userNum variable to assign user number since we'll be using nested loops
$userNum = 1

Write-Host ""
Write-Host ""
Write-Host "Creating New Groups and Users"
Write-Host "============================="

# Iterate groups to create groups
For ($g=0; $g -lt $numGroups; $g++)
{
    $groupName = "Workshop Group " + ($g + 1).ToString()
    $mailNickname = "workshop_group_" + ($g + 1).ToString()

    Write-Host "Creating group: $groupName"
    $newGroup = New-AzureADGroup -DisplayName $groupName -MailEnabled $false -SecurityEnabled $true -MailNickName $mailNickname -Description "Azure Databricks Workshop Group"

    # Iterate to create users
    For ($i=0; $i -lt $numUsersPerGroup; $i++)
    {
        $displayName = "User " + $userNum.ToString()
        $userName = "user_" + $userNum.ToString()
        $userNum++

        $email = $userName + "@" + $customDomain

        Write-Host "Creating user: $email"
        $newUser = New-AzureADUser -AccountEnabled $True -DisplayName $displayName -PasswordProfile $PasswordProfile -UserPrincipalName $email -MailNickName $userName

        # Add user to group
        Add-AzureADGroupMember -ObjectId $newGroup.ObjectId -RefObjectId $newUser.ObjectId
    }
    Write-Host ""
}
