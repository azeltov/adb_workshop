# Connect to the AD tenant associated with the custom domain
#Connect-AzureAD -TenantId $customDomain

$customDomain = "dbxlab.com"
$defaultPwd = "DB!TrainingNON18"

# Set the number of groups and the number of users in each group
$numGroups = 2
$numUsersPerGroup = 5


# Remove old users and groups
For ($g=1; $g -lt ($numGroups+1); $g++)
{
    $groupName = "Group " + $g.ToString()
    Write-Host "Removing group: $groupName"
    Remove-AzureADGroup -ObjectId $groupName
}

For ($g=1; $g -lt (($numGroups*$numUsersPerGroup)+1); $g++)
{
    $userName = "user_" + $g.ToString()
    $email = $userName + "@" + $customDomain
    
    Write-Host "Removing user: $email" 
    Remove-AzureADUser -ObjectId $email
}

# Set Password and ForceChangePasswordNextLogin parameters
$PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
$PasswordProfile.Password = $defaultPwd
$PasswordProfile.ForceChangePasswordNextLogin = $false

# Create userNum variable to assign user number since we'll be using nested loops
$userNum = 1

# Iterate groups to create groups
For ($g=0; $g -lt $numGroups; $g++)
{
    $groupName = "group" + ($g + 1).ToString()
    $mailNickname = "group_" + ($g + 1).ToString()

    Write-Host "Creating group: $groupName"
    $newGroup = New-AzureADGroup -DisplayName $groupName -MailEnabled $false -SecurityEnabled $true -MailNickName $mailNickname

    # Iterate to create users
    For ($i=0; $i -lt $numUsersPerGroup; $i++)
    {
        $displayName = "User " + $userNum.ToString()
        $userName = "user" + $userNum.ToString()
        $userNum++

        $email = $userName + "@" + $customDomain

        Write-Host "Creating user: $email"
        $newUser = New-AzureADUser -AccountEnabled $True -DisplayName $displayName -PasswordProfile $PasswordProfile -UserPrincipalName $email -MailNickName $userName

        # Add user to group
        Add-AzureADGroupMember -ObjectId $newGroup.ObjectId -RefObjectId $newUser.ObjectId
    }
}


