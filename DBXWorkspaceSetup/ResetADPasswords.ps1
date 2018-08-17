$customDomain = "azureworkshops.net"
$defaultPwd = "jhg342#9)6jk"

# Set the number of groups and the number of users in each group
$numUsers = 50

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

# Set Password and ForceChangePasswordNextLogin parameters
$PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
$PasswordProfile.Password = $defaultPwd
$PasswordProfile.ForceChangePasswordNextLogin = $false

Write-Host ""
Write-Host ""
Write-Host "Resetting Passwords"
Write-Host "==================="

# Iterate users to reset passwords
For ($userNum=1; $userNum -lt ($numUsers+1); $userNum++)
{
    $displayName = "User " + $userNum.ToString()
    $userName = "user_" + $userNum.ToString()

    $email = $userName + "@" + $customDomain

    Write-Host "Resetting Password for user: $email"
    $user = Get-AzureADUser -ObjectId $email
    $objectId = $user.objectid

    Set-AzureADUserPassword -ObjectId  $objectId -Password (ConvertTo-SecureString -String $defaultPwd -Force –AsPlainText)
}
Write-Host ""
