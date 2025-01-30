Import-Module ActiveDirectory
$current_user = whoami
$current_user = $current_user.split("\")[1]
$info = Get-ADUser -Identity $current_user
$current_name = $info.Name
Write-Host "Version 1.0"
Write-Host ""
Write-Host "Welcome" $current_name"!" -ForegroundColor yellow
Write-Host ""
do{ #WC - start wrap logic for coming back
    do{
        $group_selected = Read-Host "Enter a group name to search"
        Write-Host ""
        Write-Host "Checking for group(s).."
        Start-Sleep -Seconds 1
        Try{
            $results = Get-ADGroup -Filter "name -like '*$group_selected*'" -properties name, mail, description, managedby, samaccountname | select name, mail, description, managedby, samaccountname
            if ($results.Count -ne $null -and $results.name -ne $null) {
                $array = $true
                Start-Sleep -Seconds 1
                Write-Host ""
                Write-Host "Found $($results.Count) matching group(s)" #WC - added count of how many hits it got 
                Write-Host "-------------------------------"-ForegroundColor Yellow
                do {
                    if ($results.count -lt 50){
                        $choice = Read-Host "Do you want to continue with this search? (Y/N)" #WC - made capital to look better
                    } Else{
                       $choice = Read-Host "The search returned $($results.count) groups. Would you like to continue or refine your search (Y/N)?"
                    }
                    Write-Host ""
                    $isValidChoice = $choice -match '^[YNyn]$' #WC - added option for capital or lower
                } while (!$isValidChoice)
                if ($choice -eq "Y" -or $choice -eq "y") { #WC - case for both options
                    Write-Host "You selected yes, getting group information..." -ForegroundColor Yellow
                    Write-Host ""
                    $groupExists = $true
                } else {
                    Write-Host "You selected no, please enter another group query"
                    $groupExists = $false
                }
            }elseif($results.Count -eq $null){
                $array = $false
                Start-Sleep -Seconds 1
                Write-Host ""
                Write-Host "Found 1 matching group" #WC- single group
                Write-Host "-------------------------------"
                do {
                    $choice = Read-Host "Do you want to continue with this search? (Y/N)" #WC - made capital to look better
                    Write-Host ""
                    $isValidChoice = $choice -match '^[YNyn]$' #WC - added option for capital or lower
                } while (!$isValidChoice)
                    if ($choice -eq "Y" -or $choice -eq "y") { #WC - case for both options
                        Write-Host "You selected yes, getting group information..." -ForegroundColor Yellow
                        
                        Write-Host ""
                        $selectedGroup = Get-ADGroup -Identity $results.samaccountname -properties name, mail, description, managedby, members, whenChanged | select name, mail, description, managedby, members, whenChanged
                        Write-Host "Group Selected --> $($selectedGroup.name)" -ForegroundColor Green
                        Write-Host "Group Description: $($selectedGroup.description)" -ForegroundColor Green
                        $prettymanager = (Get-ADUser -Identity $selectedGroup.managedby -Properties Name).Name #WC - get better name
                        Write-Host "Group Manager: $($prettymanager)" -ForegroundColor Green
                        Write-Host "Group Last Updated: $($selectedGroup.whenChanged)" -ForegroundColor Green
                        Write-Host "Group Member Count: $($selectedGroup.members.count)" -ForegroundColor Green
                        Write-Host "`nShowing the first 20 members:" -ForegroundColor Yellow #WC - lets only show 20 because otherwise its a lot
                        $first20members = $selectedGroup.members | select -First 20
                        $first20members | foreach{(Get-ADUser -Identity $_ -Properties Name).Name} | foreach{Write-Host $_}
            
                        if($selectedGroup.members.count -gt 20){
                        Write-Host ""
                        $exportChoice = Read-Host "Would you like to export the full list of members to a CSV file? (Y/N)"
                            if ($exportChoice -eq "Y" -or $exportChoice -eq "y") {
                                $filepath = "C:\users\" + $current_user + "\downloads\" + "$($selectedGroup.name)_members.csv"
                                $allmembers = $selectedGroup.members | foreach{Get-ADUser -Identity $_ -properties name,samaccountname,mail}|select name,samaccountname,mail
                                $allmembers | export-csv -path $filepath -NoTypeInformation
                                Start-Sleep -Seconds .5
                                Write-Host "Exported full list of members to $($filepath)" -ForegroundColor Green
                            }
                        }
                        Write-Host "--------------------------------"-ForegroundColor Yellow
                        $groupExists = $true
                    } else {
                        Write-Host "You selected no, please enter another group query" -ForegroundColor Yellow
                        $groupExists = $false
                    }
            }
            else {throw "No results found :("}#WC - cleaner way to throw error
        }
        Catch{
            Write-Host "No group(s) found in search, please try again." #WC - fixed messaging
            Write-Host ""
            Start-Sleep -Seconds 1
            $groupExists = $false
        }
    }while(!$groupExists)
    $groups = @()
    $GroupListArray = for ($i = 0; $i -lt $results.Count; $i++) {
        $fixedmanager = if($results[$i].managedby -eq $null){
            ""
        }else{
            (Get-ADUser $results[$i].managedby | Select-Object -ExpandProperty Name)
        }
        $groups += [PSCustomObject]@{
            Number = $i + 1
            Name   = $results[$i].name
            mail = $results[$i].mail
            description = $results[$i].description
            managedby = $fixedmanager
            samaccountname = $results[$i].samaccountname
        }
    }
    if($array -eq $true){
    Write-Host "Group(s) Found:" -ForegroundColor Green #WC - clearer to see
    Start-Sleep -Seconds 1
    Write-Host ""
    foreach ($group in $groups) { #WC - updated to simpler for each
        Write-Host "$($group.Number) $($group.Name)" -ForegroundColor Green
    }
    Write-Host ""
        do{
            do {
                Write-Host "[A] - Select a specific group"
                Write-Host "[B] - Export list of groups found"
                Write-Host "[C] - Try a new search"
                Write-Host "[X] - Exit"
                Write-Host ""    
                $choice = Read-Host "Select an option"
                $ok = $choice -match '^[ABCXabcx]$' #WC - uppercase options     
                if (-not $ok) {Write-Host "Invalid Selection" -ForegroundColor Red}
            } until ($ok)
            switch -Regex ($choice.toUpper()){ #WC - ensure passing uppercase
            "A"{#WC - updated a lot of this
                Write-Host ""
                $number = Read-Host "Enter the number of the group you would like to view" #WC - update language
                $selection = $number-1
                Write-Host ""
                $selectedGroup = Get-ADGroup -Identity $groups[$selection].samaccountname -properties name, mail, description, managedby, members, whenChanged | select name, mail, description, managedby, members, whenChanged
                Write-Host "Group Selected --> $($selectedGroup.name)" -ForegroundColor Green
                Write-Host "Group Description: $($selectedGroup.description)" -ForegroundColor Green
                $prettymanager = (Get-ADUser -Identity $selectedGroup.managedby -Properties Name).Name #WC - get better name
                Write-Host "Group Manager: $($prettymanager)" -ForegroundColor Green
                Write-Host "Group Last Updated: $($selectedGroup.whenChanged)" -ForegroundColor Green
                Write-Host "Group Member Count: $($selectedGroup.members.count)" -ForegroundColor Green
                Write-Host "`nShowing the first 20 members:" -ForegroundColor Yellow #WC - lets only show 20 because otherwise its a lot
                $first20members = $selectedGroup.members | select -First 20
                $first20members | foreach{(Get-ADUser -Identity $_ -Properties Name).Name} | foreach{Write-Host $_}

                if($selectedGroup.members.count -gt 20){
                Write-Host ""
                $exportChoice = Read-Host "Would you like to export the full list of members to a CSV file? (Y/N)"
                    if ($exportChoice -eq "Y" -or $exportChoice -eq "y") {
                        $filepath = "C:\users\" + $current_user + "\downloads\" + "$($selectedGroup.name)_members.csv"
                        $allmembers = $selectedGroup.members | foreach{Get-ADUser -Identity $_ -properties name,samaccountname,mail}|select name,samaccountname,mail
                        $allmembers | export-csv -path $filepath -NoTypeInformation
                        Start-Sleep -Seconds .5
                        Write-Host "Exported full list of members to $($filepath)" -ForegroundColor Green
                    }
                }
                Write-Host "--------------------------------"
                Write-Host "What would you like to do next?" -ForegroundColor Yellow    
                Start-Sleep -Seconds .5
                Write-Host ""
                $repeat = $false
            }
            "B"{#WC - most should be same
                $filename = Read-Host "Please name your file (with no extensions)" #WC - add no extensions
                $filepath = "C:\users\" + $current_user + "\downloads\" + $filename + ".csv"
                Write-Host "Exporting groups!" -ForegroundColor Green #WC - helps break up 
                Start-Sleep -Seconds 1
                $groups | Export-Csv $filepath -NoTypeInformation
                Write-Host "You can find your file in $($filepath)" -ForegroundColor Green #WC - let user know where to find file
                Write-Host "What would you like to do next?" -ForegroundColor Yellow
                Write-Host ""
                Start-Sleep -Seconds .5
                $repeat = $false
            }
            "C" {#WC - study simplicity
                Write-Host ""
                $repeat = $true #WC - run it back turbo
                Write-Host "Returning to the beginning for a new group search..." -ForegroundColor Yellow 
                Start-Sleep -Seconds .5
            }
            "X" {
                $repeat = $false
                Start-Sleep -Seconds .5
                Write-Host "Exiting..." -ForegroundColor Yellow
            }
        }   
        }until ($choice -match "X" -or $repeat)
    }else{
        do {
            $choice = Read-Host "Would you like another search? (Y/N)"
            Write-Host ""
            $isValidChoice = $choice -match '^[YNyn]$' #WC - added option for capital or lower
        } while (!$isValidChoice)
        if ($choice -eq "Y" -or $choice -eq "y") { #WC - case for both options
            $arrray = ''
            $repeat =$true
            Write-Host ""
        } else {
            Start-Sleep -Seconds .5
            Write-Host "Exiting..." -ForegroundColor Yellow
            $repeat = $false
        }
    }
}until(!$repeat)