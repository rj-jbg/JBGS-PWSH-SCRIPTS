Import-Module ActiveDirectory
$current_user = whoami
$current_user = $current_user.split("\")[1]
$info = Get-ADUser -Identity $current_user
$current_Name = $info.Name
$date = (Get-Date)

Write-Host "Welcome" $current_Name"!" -ForegroundColor blue
Write-Host ""

do{
    $group_selected = Read-Host "Please enter a group name"
    Write-Host ""
    Start-Sleep -Seconds 1
    Write-Host "Checking for groups"
    Start-Sleep -Seconds 1

    Try{
        $results = Get-ADGroup -Filter "name -like '*$group_selected*'" -properties name, mail, description, managedby | select name, mail, description, managedby
         
    if ($results.count -ne 0){
        Start-Sleep -Seconds 1
        Write-Host ""
        Write-Host "Found matching group(s)"
        Write-Host "-------------------------------"

        do{
            #when selecting "No" loop doesn't break
            $choice = Read-Host "Do you want to continue (y/n)"
            Write-Host ""
            $ok = $choice -match '^[yn]+$'
        }while(!$ok)
        
        if($choice -eq "y"){
            Write-Host "You selected yes"
            Write-Host ""
            $groupExists = $true
        }else{
            Write-Host "You selected no"
            $groupExists = $false
            break
        }
    }else {1/0}
    }
    Catch{
        Write-Host "-------------------------------"
        Write-Host "Group Not Found"
        Write-Host ""
        Start-Sleep -Seconds 1
        $groupExists = $false
    }
}while(!$groupExists)

$groups = @()
$GroupListArray = for ($i = 0; $i -lt $results.Count; $i++) {
    if($results[$i].managedby -eq $null){
        $fixedmanager = ""
     }else{
        $fixedmanager = Get-aduser $results[$i].managedby | select -expandproperty name  
    }
    $groups += [PSCustomObject]@{
        Number = $i + 1
        Name   = $results[$i].name
        mail = $results[$i].mail
        description = $results[$i].description
        managedby = $fixedmanager
    }
}

 Write-Host "Here are your results:"
 Start-Sleep -Seconds 1
 Write-Host ""
for ($i = 0; $i -lt $groups.Count; $i++) {
    Write-Host $groups[$i].number $groups[$i].name -Foreground green
}

Write-Host ""
do{

    do {
        Write-Host ""
        Write-Host "[A] - Enter Group Selection"
        Write-Host "[B] - Export List of Groups"
        Write-Host "[C] - Enter New Group"
        Write-Host ""
        Write-Host "[x] - Exit"
        Write-Host ""

        $choice = Read-Host

        Write-Host ""

        $ok = $choice -match '^[abcx]+$'

        if (-not $ok) {Write-Host "Invalid selection" -Foreground red}
    }until ($ok)

switch -Regex ($choice){
    "A"{
        $US = read-host "Please enter a number to view corresponding group"
        $selection = $us -1
        $refinedresults = [PSCustomObject]@{
            Name = $groups[$selection].name
            Mail = $groups[$selection].mail
            Description = $groups[$selection].description
            Manager = $groups[$selection].managedby
        }
        $refinedresults
       
        do{
            Write-Host ""
            Write-Host "[A] - Get All Group Attributes"
            Write-Host "[B] - Get All Group Memebers"
            Write-Host ""
            Write-Host "[X] - Exit"
        
            $choice = Read-Host
        
            Write-Host ""
        
            $ok = $choice -match '^[abx]+$'
        
            if (-not $ok) {Write-Host "Invalid Selection" -ForegroundColor red}
        }until ($ok)
        
        switch -Regex ($choice){
            "A"{
                #Full list of attributes won't display. Array needed?
                $GroupAttributes = Get-ADGroup $groups[$selection].name -Properties *
                $GroupAttributes
                
                do{
                    Write-Host ""
                    Write-Host "[A] - Export List"
                    Write-Host "[B] - Select New Group(s)"
                    Write-Host ""
                    Write-Host "[X] - Exit"
                
                    $choice = Read-Host
                
                    Write-Host ""
                
                    $ok = $choice -match '^[abx]+$'
                
                    if (-not $ok) {Write-Host "Invalid Selection" -ForegroundColor red}
                }until ($ok)
                
                switch -Regex ($choice){
                    "A"{
                        $filename = Read-Host "Please name your file"
                        $filepath = "C:\users\" + $current_user + "\downloads\" + $filename + ".csv"
                        $GroupAttributes | Export-Csv $filepath -NoTypeInformation

                        do{
                            Write-Host ""
                            Write-Host "[A] - Select New Group(s)"
                            Write-Host ""
                            Write-Host "[X] - Exit"
                        
                            $choice = Read-Host
                        
                            Write-Host ""
                        
                            $ok = $choice -match '^[abx]+$'
                        
                            if (-not $ok) {Write-Host "Invalid Selection" -ForegroundColor red}
                        }until ($ok)
                        
                        switch -Regex ($choice){
                            "A"{
                                do{
                                    $group_selected = Read-Host "Please enter a group name"
                                    Write-Host ""
                                    Start-Sleep -Seconds 1
                                    Write-Host "Checking for groups"
                                    Start-Sleep -Seconds 1
                            
                                    Try{
                                        $results = Get-ADGroup -Filter "name -like '*$group_selected*'" -properties name, mail, description, managedby | select name, mail, description, managedby
                                    
                                    if ($results.count -ne 0){
                                        Start-Sleep -Seconds 1
                                        Write-Host ""
                                        Write-Host "Found matching group(s)"
                                        Write-Host "-------------------------------"
                                        do{
                                            $choice = Read-Host "Do you want to continue (y/n)"
                                            Write-Host ""
                                            $ok = $choice -match '^[yn]+$'
                                        }while(!$ok)
                                        if($choice -eq "y"){
                                            Write-Host "You selected yes"
                                            Write-Host ""
                                            $groupExists = $true
                                        }else{
                                            Write-Host "You selected no"
                                            $groupExists = $false
                                        }
                                        
                                    }else {1/0}
                                    }
                                    Catch{
                                        Write-Host "-------------------------------"
                                        Write-Host "Group Not Found"
                                        Write-Host ""
                                        Start-Sleep -Seconds 1
                                        $groupExists = $false
                                    }
                                }while(!$groupExists)
                                $groups = @()
                                $GroupListArray = for ($i = 0; $i -lt $results.Count; $i++) {
                                    if($results[$i].managedby -eq $null){
                                        $fixedmanager = ""
                                     }else{
                                        $fixedmanager = Get-aduser $results[$i].managedby | select -expandproperty name  
                                    }
                                    $groups += [PSCustomObject]@{
                                        Number = $i + 1
                                        Name   = $results[$i].name
                                        mail = $results[$i].mail
                                        description = $results[$i].description
                                        managedby = $fixedmanager
                                    }
                                }
                                
                                 Write-Host "Here are your results:"
                                 Start-Sleep -Seconds 1
                                 Write-Host ""
                                for ($i = 0; $i -lt $groups.Count; $i++) {
                                    Write-Host $groups[$i].number $groups[$i].name -Foreground green
                                }
                                break
                            }
                            "X"{
                                Start-Sleep -Seconds .5
                                Write-Host "Exiting..."
                            }
                        }
                    }
                    "B"{
                        do{
                            $group_selected = Read-Host "Please enter a group name"
                            Write-Host ""
                            Start-Sleep -Seconds 1
                            Write-Host "Checking for groups"
                            Start-Sleep -Seconds 1
                    
                            Try{
                                $results = Get-ADGroup -Filter "name -like '*$group_selected*'" -properties name, mail, description, managedby | select name, mail, description, managedby
                            
                            if ($results.count -ne 0){
                                Start-Sleep -Seconds 1
                                Write-Host ""
                                Write-Host "Found matching group(s)"
                                Write-Host "-------------------------------"
                                do{
                                    $choice = Read-Host "Do you want to continue (y/n)"
                                    Write-Host ""
                                    $ok = $choice -match '^[yn]+$'
                                }while(!$ok)
                                if($choice -eq "y"){
                                    Write-Host "You selected yes"
                                    Write-Host ""
                                    $groupExists = $true
                                }else{
                                    Write-Host "You selected no"
                                    $groupExists = $false
                                }
                                
                            }else {1/0}
                            }
                            Catch{
                                Write-Host "-------------------------------"
                                Write-Host "Group Not Found"
                                Write-Host ""
                                Start-Sleep -Seconds 1
                                $groupExists = $false
                            }
                        }while(!$groupExists)
                        $groups = @()
                        $GroupListArray = for ($i = 0; $i -lt $results.Count; $i++) {
                            if($results[$i].managedby -eq $null){
                                $fixedmanager = ""
                             }else{
                                $fixedmanager = Get-aduser $results[$i].managedby | select -expandproperty name  
                            }
                            $groups += [PSCustomObject]@{
                                Number = $i + 1
                                Name   = $results[$i].name
                                mail = $results[$i].mail
                                description = $results[$i].description
                                managedby = $fixedmanager
                            }
                        }
                        
                         Write-Host "Here are your results:"
                         Start-Sleep -Seconds 1
                         Write-Host ""
                        for ($i = 0; $i -lt $groups.Count; $i++) {
                            Write-Host $groups[$i].number $groups[$i].name -Foreground green
                        }
                        break
                    }
                    "X"{
                        Start-Sleep -Seconds .5
                         Write-Host "Exiting..."
                    }
                }
            }
            "B"{
                #Group members stopped printing, but will show up in export?????
                $group = Get-ADGroup -Identity $groups[$selection].name -properties members
                $members = $group | select -expandproperty Members
                $groupmembers = @()
                $Members | foreach {
                    $user = Get-ADUser -Identity $_ -properties CN
                  $groupmembers += [PSCustomObject]@{
                    CN = $user.cn
                  }
                }
                
                $groupmembers

                do{
                    Write-Host ""
                    Write-Host "[A] - Export Group Members"
                    Write-Host "[B] - Select New Group"
                    Write-Host ""
                    Write-Host "[X] - Exit"
                
                    $choice = Read-Host
                
                    Write-Host ""
                
                    $ok = $choice -match '^[abx]+$'
                
                    if (-not $ok) {Write-Host "Invalid Selection" -ForegroundColor red}
                }until ($ok)
                
                switch -Regex ($choice){
                    "A" {
                        $filename = Read-Host "Please name your file"
                        $filepath = "C:\users\" + $current_user + "\downloads\" + $filename + ".csv"
                        $groupmembers | Export-Csv $filepath -NoTypeInformation

                        do{
                            Write-Host ""
                            Write-Host "[A] - Select New Group"
                            Write-Host ""
                            Write-Host "[X] - Exit"

                            $choice = Read-Host
                
                            Write-Host ""
                        
                            $ok = $choice -match '^[ax]+$'
                        
                            if (-not $ok) {Write-Host "Invalid Selection" -ForegroundColor red}
                        }until ($ok)

                        switch -Regex ($choice){
                            "A"{
                                do{
                                    $group_selected = Read-Host "Please enter a group name"
                                    Write-Host ""
                                    Start-Sleep -Seconds 1
                                    Write-Host "Checking for groups"
                                    Start-Sleep -Seconds 1
                            
                                    Try{
                                        $results = Get-ADGroup -Filter "name -like '*$group_selected*'" -properties name, mail, description, managedby | select name, mail, description, managedby
                                    
                                    if ($results.count -ne 0){
                                        Start-Sleep -Seconds 1
                                        Write-Host ""
                                        Write-Host "Found matching group(s)"
                                        Write-Host "-------------------------------"
                                        do{
                                            $choice = Read-Host "Do you want to continue (y/n)"
                                            Write-Host ""
                                            $ok = $choice -match '^[yn]+$'
                                        }while(!$ok)
                                        if($choice -eq "y"){
                                            Write-Host "You selected yes"
                                            Write-Host ""
                                            $groupExists = $true
                                        }else{
                                            Write-Host "You selected no"
                                            $groupExists = $false
                                        }
                                        
                                    }else {1/0}
                                    }
                                    Catch{
                                        Write-Host "-------------------------------"
                                        Write-Host "Group Not Found"
                                        Write-Host ""
                                        Start-Sleep -Seconds 1
                                        $groupExists = $false
                                    }
                                }while(!$groupExists)
                                $groups = @()
                                $GroupListArray = for ($i = 0; $i -lt $results.Count; $i++) {
                                    if($results[$i].managedby -eq $null){
                                        $fixedmanager = ""
                                     }else{
                                        $fixedmanager = Get-aduser $results[$i].managedby | select -expandproperty name  
                                    }
                                    $groups += [PSCustomObject]@{
                                        Number = $i + 1
                                        Name   = $results[$i].name
                                        mail = $results[$i].mail
                                        description = $results[$i].description
                                        managedby = $fixedmanager
                                    }
                                }
                                
                                 Write-Host "Here are your results:"
                                 Start-Sleep -Seconds 1
                                 Write-Host ""
                                for ($i = 0; $i -lt $groups.Count; $i++) {
                                    Write-Host $groups[$i].number $groups[$i].name -Foreground green
                                }
                                break
                            }
                            "X"{
                                Start-Sleep -Seconds .5
                                Write-Host "Exiting..."
                            }
                        }
                    }
                    "B"{
                        do{
                            $group_selected = Read-Host "Please enter a group name"
                            Write-Host ""
                            Start-Sleep -Seconds 1
                            Write-Host "Checking for groups"
                            Start-Sleep -Seconds 1
                    
                            Try{
                                $results = Get-ADGroup -Filter "name -like '*$group_selected*'" -properties name, mail, description, managedby | select name, mail, description, managedby
                            
                            if ($results.count -ne 0){
                                Start-Sleep -Seconds 1
                                Write-Host ""
                                Write-Host "Found matching group(s)"
                                Write-Host "-------------------------------"
                                do{
                                    $choice = Read-Host "Do you want to continue (y/n)"
                                    Write-Host ""
                                    $ok = $choice -match '^[yn]+$'
                                }while(!$ok)
                                if($choice -eq "y"){
                                    Write-Host "You selected yes"
                                    Write-Host ""
                                    $groupExists = $true
                                }else{
                                    Write-Host "You selected no"
                                    $groupExists = $false
                                }
                                
                            }else {1/0}
                            }
                            Catch{
                                Write-Host "-------------------------------"
                                Write-Host "Group Not Found"
                                Write-Host ""
                                Start-Sleep -Seconds 1
                                $groupExists = $false
                            }
                        }while(!$groupExists)
                        $groups = @()
                        $GroupListArray = for ($i = 0; $i -lt $results.Count; $i++) {
                            if($results[$i].managedby -eq $null){
                                $fixedmanager = ""
                             }else{
                                $fixedmanager = Get-aduser $results[$i].managedby | select -expandproperty name  
                            }
                            $groups += [PSCustomObject]@{
                                Number = $i + 1
                                Name   = $results[$i].name
                                mail = $results[$i].mail
                                description = $results[$i].description
                                managedby = $fixedmanager
                            }
                        }
                        
                         Write-Host "Here are your results:"
                         Start-Sleep -Seconds 1
                         Write-Host ""
                        for ($i = 0; $i -lt $groups.Count; $i++) {
                            Write-Host $groups[$i].number $groups[$i].name -Foreground green
                        }
                        break
                    }
                    "X" {
                        Start-Sleep -Seconds .5
                        Write-Host "Exiting..."
                    }
                }

            }
        }
    }
    "B"{
        $filename = Read-Host "Please name your file"
        $filepath = "C:\users\" + $current_user + "\downloads\" + $filename + ".csv"
        $groups | Export-Csv $filepath -NoTypeInformation

        do{
            Write-Host ""
            Write-Host "[A] - Select New Group(s)"
            Write-Host ""
            Write-Host "[X] - Exit"
        
            $choice = Read-Host
        
            Write-Host ""
        
            $ok = $choice -match '^[ax]+$'
        
            if (-not $ok) {Write-Host "Invalid Selection" -ForegroundColor red}
        }until ($ok)

        switch -Regex ($choice){
            "A"{
                do{
                    $group_selected = Read-Host "Please enter a group name"
                    Write-Host ""
                    Start-Sleep -Seconds 1
                    Write-Host "Checking for groups"
                    Start-Sleep -Seconds 1
            
                    Try{
                        $results = Get-ADGroup -Filter "name -like '*$group_selected*'" -properties name, mail, description, managedby | select name, mail, description, managedby
                    
                    if ($results.count -ne 0){
                        Start-Sleep -Seconds 1
                        Write-Host ""
                        Write-Host "Found matching group(s)"
                        Write-Host "-------------------------------"
                        do{
                            $choice = Read-Host "Do you want to continue (y/n)"
                            Write-Host ""
                            $ok = $choice -match '^[yn]+$'
                        }while(!$ok)
                        if($choice -eq "y"){
                            Write-Host "You selected yes"
                            Write-Host ""
                            $groupExists = $true
                        }else{
                            Write-Host "You selected no"
                            $groupExists = $false
                        }
                        
                    }else {1/0}
                    }
                    Catch{
                        Write-Host "-------------------------------"
                        Write-Host "Group Not Found"
                        Write-Host ""
                        Start-Sleep -Seconds 1
                        $groupExists = $false
                    }
                }while(!$groupExists)
                $groups = @()
                $GroupListArray = for ($i = 0; $i -lt $results.Count; $i++) {
                    if($results[$i].managedby -eq $null){
                        $fixedmanager = ""
                     }else{
                        $fixedmanager = Get-aduser $results[$i].managedby | select -expandproperty name  
                    }
                    $groups += [PSCustomObject]@{
                        Number = $i + 1
                        Name   = $results[$i].name
                        mail = $results[$i].mail
                        description = $results[$i].description
                        managedby = $fixedmanager
                    }
                }
                
                 Write-Host "Here are your results:"
                 Start-Sleep -Seconds 1
                 Write-Host ""
                for ($i = 0; $i -lt $groups.Count; $i++) {
                    Write-Host $groups[$i].number $groups[$i].name -Foreground green
                }
                break
            }
            "X"{
                Start-Sleep -Seconds .5
                Write-Host "Exiting..."
            }
        }
     }

    "C" {
        do{
            $group_selected = Read-Host "Please enter a group name"
            Write-Host ""
            Start-Sleep -Seconds 1
            Write-Host "Checking for groups"
            Start-Sleep -Seconds 1
    
            Try{
                $results = Get-ADGroup -Filter "name -like '*$group_selected*'" -properties name, mail, description, managedby | select name, mail, description, managedby
            
            if ($results.count -ne 0){
                Start-Sleep -Seconds 1
                Write-Host ""
                Write-Host "Found matching group(s)"
                Write-Host "-------------------------------"
                do{
                    $choice = Read-Host "Do you want to continue (y/n)"
                    Write-Host ""
                    $ok = $choice -match '^[yn]+$'
                }while(!$ok)
                if($choice -eq "y"){
                    Write-Host "You selected yes"
                    Write-Host ""
                    $groupExists = $true
                }else{
                    Write-Host "You selected no"
                    $groupExists = $false
                }
                
            }else {1/0}
            }
            Catch{
                Write-Host "-------------------------------"
                Write-Host "Group Not Found"
                Write-Host ""
                Start-Sleep -Seconds 1
                $groupExists = $false
            }
        }while(!$groupExists)
        $groups = @()
        $GroupListArray = for ($i = 0; $i -lt $results.Count; $i++) {
            if($results[$i].managedby -eq $null){
                $fixedmanager = ""
             }else{
                $fixedmanager = Get-aduser $results[$i].managedby | select -expandproperty name  
            }
            $groups += [PSCustomObject]@{
                Number = $i + 1
                Name   = $results[$i].name
                mail = $results[$i].mail
                description = $results[$i].description
                managedby = $fixedmanager
            }
        }
        
         Write-Host "Here are your results:"
         Start-Sleep -Seconds 1
         Write-Host ""
        for ($i = 0; $i -lt $groups.Count; $i++) {
            Write-Host $groups[$i].number $groups[$i].name -Foreground green
        }
        break
    }

    "X" {
        Start-Sleep -Seconds .5
        Write-Host "Exiting..."
    }

    
    }
}until ( $choice -match "X" )
