Import-Module ActiveDirectory
$current_user = whoami
$current_user = $current_user.split("\")[1]
$info = Get-ADUser -Identity $current_user
$current_Name = $info.Name
$date = (Get-Date)

Write-Host "Welcome" $current_Name"!" -ForegroundColor blue
Write-Host ""

$verification = @()
$groups = "JBG SMITH Main Office","JBG SMITH Residential","JBG SMITH Commercial","SGApp-OKTA-MimecastMSO","Outlook PST Policy","SGApp-Intune MDM Users","SGFile-JBG Corporate files-Corporate users","SGPolicy-UserFolderRedirection-CorpUsers","sgapp-adobeacrobatstandard-licensedusers","sgapp-okta-adobeenterprise","SGApp-OKTA-CiscoAnyconnect","SGApp-OKTA-Concur","sgapp-okta-knowbe4","SGApp-Okta-Zoom","SGApp-WVD-User"
$data = @(
      [pscustomobject]@{Code='16';Message='Locked Out'}
      [pscustomobject]@{Code='512';Message='Enabled Account'}
      [pscustomobject]@{Code='514';Message='Disabled Account'}
      [pscustomobject]@{Code='544';Message='Enabled, Password Not Required'}
      [pscustomobject]@{Code='546';Message='Disabled, Password Not Required'}
      [pscustomobject]@{Code='66048';Message='Enabled, Password Does not Expire'}
      [pscustomobject]@{Code='66050';Message='Disabled, Password Does not Expire'}
      [pscustomobject]@{Code='66082';Message='Disabled, Password Does not Expire & Not Required'}
      [pscustomobject]@{Code='8388608';Message='Password Expired'}
      )
Start-Sleep -Seconds 1

do{
$username = Read-Host "Please enter a username to begin"
Write-Host "Checking if user exists"
Write-Host "-------------------------------"
$error.clear()
$userExists = $true
try{
      $user= Get-aduser -Identity $username -properties name, mail,title,company, proxyaddresses,Mailnickname,TargetAddress, manager, department, physicaldeliveryofficename, streetaddress, st, postalcode, userAccountControl, MemberOf
}
catch{
      Write-Host "Username doesn't exist, please try another username" -Foreground red
      $userExists = $false
}
}while(!$userExists)


Write-Host "Verified entered username exists" -ForegroundColor green
$ou = Get-ADuser -Identity $username | select @{n='OU';e={$_.distinguishedname.split(',')[1].split('=')[1]}}
$expiration = Get-ADuser -Identity $username -properties accountexpires |select @{n='accountExpires';e = {[datetime]::FromFileTime($_.accountExpires)}}
$pswd = Get-ADuser -Identity $username -Properties PasswordLastSet | select -expandproperty PasswordLastSet
$difference = $date - $pswd
#$usergroups = Get-ADPrincipalGroupMembership $user -Server aze1dc2.jbg.com| select name
$usergroups = foreach ($group in $user.MemberOf) {(Get-ADGroup $group).SamAccountName}
$usergroups = $usergroups | sort
$uac = $data | where {$_.code -eq $user.userAccountControl}

do {
      do {
            Write-Host ""
            Write-Host "[A] - Check User Attributes"
            Write-Host "[B] - Check User Group Memberships"
            Write-Host "[C] - Reset a User's Password"
            Write-Host "[D] - Select another User"
            Write-Host ""
            Write-Host "[X] - Exit"
            Write-Host ""
            Write-Host -nonewline "What would you like to do? "
            
            $choice = Read-Host
            
            Write-Host ""
            
            $ok = $choice -match '^[abcdx]+$'
            
            if (-not $ok) {Write-Host "Invalid selection" -Foreground red}
      }until ($ok)

switch -Regex ($choice){
  "A"{
            Write-Host ""
            Write-Host "Checking User Account"
            Write-Host "-------------------------------"
            Start-Sleep -Seconds .5
            if ($user.name -eq $null){
            Write-Host "Name is missing!" -ForegroundColor red
            $namecheck = 'Missing'
            }
            Else{
            Write-Host "Name:" $user.name -ForegroundColor green
            $namecheck = 'Verified'
            }

            Start-Sleep -Seconds .5
            Write-Host "OU: "  $ou.ou -ForegroundColor green

            Start-Sleep -Seconds .5
            Write-Host "Account Status: "  $uac.message -ForegroundColor green

            Start-Sleep -Seconds .5
            if($expiration.accountExpires -eq 'Sunday, December 31, 1600 7:00:00 PM'){
            Write-Host "Account Expires: No Expiration" -ForegroundColor green
            }
            Else{
            Write-Host "Account Expires:" $expiration.accountExpires -ForegroundColor green
            }

            Start-Sleep -Seconds .5
            if($difference.days -le 90){
            Write-Host "Password: OK! Expires in" $difference.days "days" -ForegroundColor green
            }
            Else{
             Write-Host "Password is expired!" -ForegroundColor red     
            }

            Write-Host ""
            Write-Host "Checking Attributes"
            Write-Host "-------------------------------"
            Start-Sleep -Seconds .5
            if ($user.samaccountname -eq $null){
            Write-Host "SamAccountName is missing!!" -ForegroundColor red
            $usernamecheck = 'Missing'
            }
            Else{
            Write-Host "SamAccountName:" $user.samaccountname -ForegroundColor green
            $usernamecheck = 'Missing'
            }

            Start-Sleep -Seconds .5
            if ($user.manager -eq $null){
            Write-Host "Manager is missing!!" -ForegroundColor red
            $managercheck = 'Missing'
            }
            Else{
            Write-Host "Manager:" $user.manager.split('=')[1].split(',')[0] -ForegroundColor green
            $managercheck = 'Verified'
            }

            Start-Sleep -Seconds .5
            if ($user.title -eq $null){
            Write-Host "Title is missing!!" -ForegroundColor red
            $titlecheck = 'Missing'
            }
            Else{
            Write-Host "Title:" $user.title -ForegroundColor green
            $titlecheck = 'Verified'
            }

            Start-Sleep -Seconds .5
            if ($user.department -eq $null){
            Write-Host "Department is missing!!" -ForegroundColor red
            $departmentcheck = 'Missing'
            }
            Else{
            Write-Host "Department:" $user.department -ForegroundColor green
            $departmentcheck = 'Verified'
            }

            Start-Sleep -Seconds .5
            if ($user.physicaldeliveryofficename -eq $null){
            Write-Host "Office is missing!!" -ForegroundColor red
            $officecheck = 'Missing'
            }
            Else{
            Write-Host "Office: " $user.physicaldeliveryofficename -ForegroundColor green
            $officecheck = 'Verified'
            }

            Start-Sleep -Seconds .5
            if ($user.streetaddress -eq $null){
            Write-Host "Street is missing!!" -ForegroundColor red
            $streetcheck = 'Missing'
            }
            Else{
            Write-Host "Street:" $user.streetaddress -ForegroundColor green
            $streetcheck = 'Verified'
            }

            if ($user.st -eq $null){
            Write-Host "State is missing!!" -ForegroundColor red
            $statecheck = 'Missing'
            }
            Else{
            Write-Host "State:" $user.st -ForegroundColor green
            $statecheck = 'Verified'
            }

            Start-Sleep -Seconds .5
            if ($user.postalcode -eq $null){
            Write-Host "Zip Code is missing!!" -ForegroundColor red
            $zipcheck = 'Missing'
            }
            Else{
            Write-Host "Zip Code:" $user.postalcode -ForegroundColor green
            $zipcheck = 'Verified'
            }

            Start-Sleep -Seconds .5
            if ($user.company -eq $null){
            Write-Host "Company is missing!!" -ForegroundColor red
            $companycheck = 'Missing'
            }
            Else{
            Write-Host "Company:" $user.company -ForegroundColor green
            $companycheck = 'Verified'
            }

            Write-Host ""
            Write-Host "Checking Mail Attributes"
            Write-Host "-------------------------------"

            Start-Sleep -Seconds .5
            if ($user.mail -eq $null){
            Write-Host "Mail is missing!!" -ForegroundColor red
            $mailcheck = 'Missing'}
            Else{
            Write-Host "Mail:" $user.mail -ForegroundColor green
            $mailcheck = 'Verified'
            }

            Start-Sleep -Seconds .5
            if ($user.Mailnickname -eq $null){
            Write-Host "Mail Nickname is missing!!" -ForegroundColor red
            $mailnicknamecheck = 'Missing'
            }
            Else{
            Write-Host "Mail Nickname:" $user.Mailnickname -ForegroundColor green
            $mailnicknamecheck = 'Verified'
            }

            Start-Sleep -Seconds .5
            if ($user.proxyaddresses -eq $null){
            Write-Host "ProxyAddresses are missing!!" -ForegroundColor red
            $proxycheck = 'Missing'}
            Else{
            Write-Host "ProxyAddresses: " $user.proxyaddresses[0] and $user.proxyaddresses[1] and $user.proxyaddresses[2] -ForegroundColor green
            $proxycheck = 'Verified'
            }

            Start-Sleep -Seconds .5
            if ($user.TargetAddress -eq $null){
            Write-Host "TargetAddress are missing!!" -ForegroundColor red
            $targetaddresscheck = 'Missing'
            }
            Else{
            Write-Host "TargetAddress:" $user.TargetAddress -ForegroundColor green
            $targetaddresscheck = 'Verified'
            }

            Write-Host ""
            Write-Host "Checking Group Memberships"
            Write-Host "-------------------------------"

            Start-Sleep -Seconds .5
            foreach($group in $groups){
                  Start-Sleep -Seconds .5
                  if($usergroups -match $group){
                        Write-Host "Verified" $user.samaccountname "is member of $group" -ForegroundColor green
                        $groupcheck = 'Verified'
                  }
                  else{
                       Write-Host $user.samaccountname "is NOT a member of $group!!!" -ForegroundColor red
                       $groupcheck = 'Missing'
                  }
            }

            $properties = [ordered]@{
                  'User' = $user.name
                  'Username' = $user.samaccountname
                  'Manager' = $managercheck
                  'Title' =$titlecheck
                  'Department' = $departmentcheck
                  'Company' = $companycheck
                  'Office' = $officecheck
                  'Street' = $streetcheck
                  'State' = $statecheck
                  'Zip Code' = $zipcheck
                  'Mail' = $mailcheck
                  'Mail Nickname' = $mailnicknamecheck
                  'Proxy Addresses' = $proxycheck
                  'Target Address' = $targetaddresscheck
                  'Groups' = $groupcheck
                  'Date Run' = (Get-Date).ToString("MM.dd.yyyy HH:mm:ss")
            }

            $verification += New-Object PsObject -property $properties

            $verification | export-csv -Path C:\temp\usercheckexport.csv -Append -NoTypeInformation
      }
      "B"{
            Write-Host $user.samaccountname "is a member of" $usergroups.count "groups" -Foreground green
            Write-Host "-------------------Start Group Listing---------------------------" -Foreground green
            foreach($usergroup in $usergroups){
                  $usergroup
            }
            Write-Host "-------------------End Group Listing---------------------------" -Foreground green

      }
      "C"{
            Write-Host "You are resetting the password for" $user.samaccountname
            $Password = Read-Host "Please Enter a temporary password"
            $Pass = ConvertTo-SecureString $Password -AsPlainText -Force
            Set-ADAccountPassword $user -NewPassword $Pass -Reset
            Set-ADUser -Identity $user -ChangePasswordAtLogon $true
            Write-Host $user.samaccountname, $Password
      }
      "D"{
            do{
                $username = Read-Host "Please enter a username to begin"
                Write-Host "Checking if user exists"
                Write-Host "-------------------------------"
                $error.clear()
                try{
                      $user= Get-aduser -Identity $username -properties name, mail,title,company, proxyaddresses,Mailnickname,TargetAddress, manager, department, physicaldeliveryofficename, streetaddress, st, postalcode, userAccountControl, MemberOf
                }
                catch{
                      Write-Host "Username Doesn't Exist" -Foreground red
                }
            }until(!$error)
            Write-Host "Verified entered username exists" -ForegroundColor green
            $ou = Get-ADuser -Identity $username | select @{n='OU';e={$_.distinguishedname.split(',')[1].split('=')[1]}}
            $expiration = Get-ADuser -Identity $username -properties accountexpires |select @{n='accountExpires';e = {[datetime]::FromFileTime($_.accountExpires)}}
            $pswd = Get-ADuser -Identity $username -Properties PasswordLastSet | select -expandproperty PasswordLastSet
            $difference = $date - $pswd
            $usergroups = foreach ($group in $user.MemberOf) {(Get-ADGroup $group).SamAccountName}
            $usergroups = $usergroups | sort
            $uac = $data | where {$_.code -eq $user.userAccountControl}
            break
        }
        
 }
} until ( $choice -match "X" )
